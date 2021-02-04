% -------------------------------------------------------------------------
function [Inflow Outflow rho Speed] = CTM(control,Link,Node,dt,TotalTimeStep) 

% Traffic model -- Cell transmission model
% Reference: Kurzhanskiy A, Kwon J and Varaiya P (2009) Aurora Road Network
% Modeler. In: Proceedings of 12th IFAC Symposium on Control in Transportation
% Systems.


% i - 'from' cell 
% j - 'to' link
% Inflow(j,t)   - flow [veh/hr] into cell j during time interval t 
% Outflow(i,t)   - flow [veh/hr] out of cell i during time interval t  
% rho(i,t)    - density [veh/mile] in cell i by the end of time interval t 

% Initialize matrics
Inflow = zeros(length(Link), TotalTimeStep);
Outflow = zeros(length(Link), TotalTimeStep);
rho = zeros(length(Link), TotalTimeStep);

TotalSend = zeros(length(Link), TotalTimeStep);
TotalReceive = zeros(length(Link), TotalTimeStep);

    
for t = 1:TotalTimeStep
    
    % Calculate 'outflow' from each cell without restriction 
    % (Step 1 in Kurzhanskiy et al., Eqn 2)
     for i = 1:length(Link)
        TotalSend(i,t) = min(Link(i).V*rho(i,t),Link(i).SatFlow*control(i,t)); 
     end

    % Calculate the splitted outflow from each cell without restriction
    % (Step 2 in Kurzhanskiy et al., Eqn 3)
    for n = 1:length(Node)
        for i = 1:length(Node(n).InLink) 
            for j = 1:length(Node(n).OutLink) 
                Node(n).SplitSend(i,j,t) = ...
                    TotalSend(Node(n).InLink(i),t)*Node(n).Split(i,j); 
            end
        end
    end   
    
    % Calculate flow reaching each cell without restriction 
    % (Step 2 in Kurzhanskiy et al., Eqn 4)
    for n = 1:length(Node)
        for j = 1:length(Node(n).OutLink) 
            A = [];
            for i = 1:length(Node(n).InLink)
                A = [A TotalSend(Node(n).InLink(i),t)];
            end
            TotalReceive(Node(n).OutLink(j),t) = A*Node(n).Split(:,j); 
        end
    end   
    
    % Calculate 'available space' at downstream
    % (Step 3 in Kurzhanskiy et al., Eqn 5)
    for j = 1:length(Link) 
        Available(j,t) = min(Link(j).SatFlow, Link(j).W*(Link(j).kjam-rho(j,t)));
    end
    
    % Adjusted "Flow" after taking restriction into account 
    % (Step 4 in Kurzhanskiy et al., Eqn 6)
    for n = 1:length(Node)
        for i = 1:length(Node(n).InLink)
            for j = 1:length(Node(n).OutLink) 
                if TotalReceive(Node(n).OutLink(j),t) > 0
                    AdjustNode(n).SplitSend(i,j,t) = ...
                       min(TotalReceive(Node(n).OutLink(j),t),...
                           Available(Node(n).OutLink(j),t))...
                           /TotalReceive(Node(n).OutLink(j),t)*Node(n).SplitSend(i,j,t);
                else
                    AdjustNode(n).SplitSend(i,j,t) = 0;
                end    
            end    
        end
    end
        
    % (Step 4 in Kurzhanskiy et al., Eqn 7)
    for n = 1:length(Node)
        for i = 1:length(Node(n).InLink)
            AdjustTotalSend(Node(n).InLink(i),t) = ...
                sum(AdjustNode(n).SplitSend(i,:,t)); 
        end
    end
    
    for i = 1:length(Link)
        if Link(i).ToNode < 0       
            % recognized as a sink (i.e. no restraint downstream)
            AdjustTotalSend(i,t) = TotalSend(i,t); 
        end
    end
    
    % Ensure node FIFO 
    % (Step 5 in Kurzhanskiy et al., Eqn 8)
    for n = 1:length(Node) 
       for i = 1:length(Node(n).InLink)
           TuneRatio(Node(n).InLink(i),t) = 99999;
           for j = 1:length(Node(n).OutLink) 
                if AdjustTotalSend(Node(n).InLink(i),t)*Node(n).Split(i,j) > 0 
                    r = AdjustNode(n).SplitSend(i,j,t)/...
                        (AdjustTotalSend(Node(n).InLink(i),t)*...
                         Node(n).Split(i,j));
                else
                    r = 1;
                end
                if (r < TuneRatio(Node(n).InLink(i),t))
                    TuneRatio(Node(n).InLink(i),t) = r;
                end
           end
       end
    end
    
    % Calculate final outflow from each cell
    % (Step 5 in Kurzhanskiy et al., Eqn 8)
    for i = 1:length(Link) 
        if Link(i).ToNode < 0 
            TuneRatio(i,t) = 1;
        end
        Outflow(i,t)=AdjustTotalSend(i,t)*TuneRatio(i,t);   
    end
           
    % Calculate inflow to each cell (including sources) 
    % (Step 6 in Kurzhanskiy et al., Eqn 9)
    for n = 1:length(Node)
        for j = 1:length(Node(n).OutLink) 
            A = [];
            for i = 1:length(Node(n).InLink)
                A = [A Outflow(Node(n).InLink(i),t)];
            end
            Inflow(Node(n).OutLink(j),t) = A*Node(n).Split(:,j); 
        end
    end
    
    for j=1:length(Link)
        if (Link(j).FrNode < 0) 
            % demand profile resolution: 15-min
            % assume demand is normally distributed with variance = 10% of
            % mean 
            if t/900+1 > length(Link(j).Demand)
                Inflow(j,t) = Link(j).Demand(end) + sqrt(0.1*Link(j).Demand(end))*randn(1);
            else
                Inflow(j,t) = Link(j).Demand(floor(t/900)+1)+ ...
                    sqrt(0.1*Link(j).Demand(floor(t/900)+1))*randn(1);      
            end
            Inflow(j,t) = max(Inflow(j,t),0);
        end
    end 
    
    % Update density (Eqn 10 in Kurzhanski et al.)
    for i = 1:length(Link) 
        rho(i,t+1) = rho(i,t) + (Inflow(i,t)-Outflow(i,t))*...
           (dt/3600)/Link(i).Length;
    end
    
end

for t = 1:TotalTimeStep
    for i = 1:length(Link)
        if rho(i,t) > 0
            Speed(i,t) = Outflow(i,t)/rho(i,t);
        else 
            Speed(i,t) = Link(i).V;
        end
    end
end