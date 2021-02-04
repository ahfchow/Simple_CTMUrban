function [result]=UrbanConfig(z,varargin)


if(strcmp(z,'Nodes'))
    % node configuration 
    % split matrix: row - InLinks; column - OutLinks
    
    Node(1).InLink = [1 5]; 
    Node(1).OutLink = [2 6]; 
    Node(1).Split = [1.0 0.0;       
                     0.0 1.0]; 
   
    Node(2).InLink = [2 7]; 
    Node(2).OutLink = [3 8]; 
    Node(2).Split = [1.0 0.0;       
                     0.0 1.0];   
                 
    Node(3).InLink = [3 9]; 
    Node(3).OutLink = [4 10]; 
    Node(3).Split = [1.0 0.0;       
                     0.0 1.0];                
                 
    for n = 1:length(Node)
        for i = 1:length(Node(n).InLink)
            if sum(Node(n).Split(i,:)) ~= 1.0
                error(['The split ratio at node ' num2str(n) ' does not add up to one'])
            end
        end
    end          
    
    result = Node;
    return
end


if(strcmp(z,'Controllers'))
    % Controller configuration                 
                 
    SignalControl(1).Node = 1;                % Node being controlled
    SignalControl(1).Cycle = 120; 
    SignalControl(1).Offset = 0; 
    SignalControl(1).StageEnd = [60; 120];
    SignalControl(1).Restricted = [5; 1];     % Links restricted at each stage  
    
    SignalControl(2).Node = 2;                % Node being controlled
    SignalControl(2).Cycle = 120; 
    SignalControl(2).Offset = 0; 
    SignalControl(2).StageEnd = [60; 120];
    SignalControl(2).Restricted = [7; 2];     % Links restricted at each stage  
    
    SignalControl(3).Node = 3;                % Node being controlled
    SignalControl(3).Cycle = 120; 
    SignalControl(3).Offset = 0; 
    SignalControl(3).StageEnd = [60; 120];
    SignalControl(3).Restricted = [9; 3];     % Links restricted at each stage  
                             
    
    for s = 1:length(SignalControl)
        if SignalControl(s).StageEnd(length(SignalControl(s).StageEnd)) ...
                ~= SignalControl(s).Cycle
            error('The end time of the final stage does not equal to the cycle time')
        end
    end

    result = SignalControl;
    return
end


if(strcmp(z,'Links'))
    % Link configuration 
    Link(1).FrNode = -1;
    Link(1).ToNode = 1;
    Link(1).Length = 0.01; 
    Link(1).V = 30;
    Link(1).SatFlow = 1800;
    Link(1).kjam = 230;
    Link(1).Demand = [700 850 700 0]; 
    
    Link(2).FrNode = 1;
    Link(2).ToNode = 2;
    Link(2).Length = 0.1; 
    Link(2).V = 30;
    Link(2).SatFlow = 1800;
    Link(2).kjam = 230;
    Link(2).Demand = 0; 
    
    Link(3).FrNode = 2;
    Link(3).ToNode = 3;
    Link(3).Length = 0.1; 
    Link(3).V = 30;
    Link(3).SatFlow = 1800;
    Link(3).kjam = 230;
    Link(3).Demand = 0; 
    
    Link(4).FrNode = 3;
    Link(4).ToNode = -1;
    Link(4).Length = 0.2; 
    Link(4).V = 30;
    Link(4).SatFlow = 1800;
    Link(4).kjam = 230;
    Link(4).Demand = 0; 
    
    Link(5).FrNode = -1;
    Link(5).ToNode = 1;
    Link(5).Length = 0.01; 
    Link(5).V = 30;
    Link(5).SatFlow = 1800;
    Link(5).kjam = 230;
    Link(5).Demand = [450 300 200 0]; 
    
    Link(6).FrNode = 1;
    Link(6).ToNode = -1;
    Link(6).Length = 0.01; 
    Link(6).V = 30;
    Link(6).SatFlow = 1800;
    Link(6).kjam = 230;
    Link(6).Demand = 0; 
    
    Link(7).FrNode = -1;
    Link(7).ToNode = 2;
    Link(7).Length = 0.01; 
    Link(7).V = 30;
    Link(7).SatFlow = 1800;
    Link(7).kjam = 230;
    Link(7).Demand = [400 500 200 0]; 
   
    Link(8).FrNode = 2;
    Link(8).ToNode = -1;
    Link(8).Length = 0.01; 
    Link(8).V = 30;
    Link(8).SatFlow = 1800;
    Link(8).kjam = 230;
    Link(8).Demand = 0; 
    
    Link(9).FrNode = -1;
    Link(9).ToNode = 3;
    Link(9).Length = 0.01; 
    Link(9).V = 30;
    Link(9).SatFlow = 1800;
    Link(9).kjam = 230;
    Link(9).Demand = [300 300 400 0]; 
   
    Link(10).FrNode = 3;
    Link(10).ToNode = -1;
    Link(10).Length = 0.01; 
    Link(10).V = 30;
    Link(10).SatFlow = 1800;
    Link(10).kjam = 230;
    Link(10).Demand = 0; 

    
    for i = 1:length(Link) 
        Link(i).kcrit = Link(i).SatFlow/Link(i).V;
        Link(i).W = Link(i).SatFlow/(Link(i).kjam-Link(i).kcrit);
        if Link(i).FrNode > 0
            Link(i).Demand = 0; 
        elseif Link(i).Demand == 0 
            warning(['there is no demand from source Link ' num2str(i)]);
        end
    end
    
    result = Link;
    return
end


if(strcmp(z,'Approaches'))
    % Approach configuration 
    Approach{1} = [];
    Approach{2} = [];
    
    for i = 11:22
        Approach{1} = [Approach{1} i];
    end
    for i = 23:34
        Approach{2} = [Approach{2} i];
    end
    
    result = Approach;
    return
end


if(strcmp(z,'Routes'))
    % Route configuration 
    Route = [];
    for i = 11:34
        Route = [Route i];
    end
    
    % Calculating length of the route
    RouteLength = 0;
    for i = 1:length(Route)
       RouteLength = RouteLength+Link(i).Length; 
    end

    result = Route;
    return
end


