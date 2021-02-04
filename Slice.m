% -------------------------------------------------------------------------
function [Link LinkSet Node SignalControl] = Slice(Link,Node,SignalControl,dt) 
% A subroutine to slice links into smaller segments 

MaxNumCell = 50;       % default maximum number of sub-cells
OriginalNumLink = length(Link);
OriginalNumNode = length(Node);
NewNumLink = length(Link);
NewNumNode = length(Node);

m = length(Link)+1; % link index 
n = length(Node)+1;

LinkSet = []; 
Set = 0;  % LinkSet ID 

for i = 1:OriginalNumLink
    if (Link(i).FrNode > 0) && (Link(i).ToNode > 0) 
        
        Set = Set + 1; 
        LinkSet(Set).ID = i; 
        LinkSet(Set).Components = []; 
        
        % condition: length of sub-cell has to be greater than distance
        % travelled by free-flow speed times delta_t 
        NumCell = min(MaxNumCell, floor(Link(i).Length/(Link(i).V*dt/3600)) );

        for k = 1:NumCell 
            if k == 1 
                Link(m).FrNode = Link(i).FrNode;
            else
                Link(m).FrNode = n-1;
            end
            if k == NumCell 
                Link(m).ToNode = Link(i).ToNode;
            else
                Link(m).ToNode = n;
            end
            
            LinkSet(Set).Components = [LinkSet(Set).Components; m]; 
            
            Link(m).Length = Link(i).Length/NumCell; 
            Link(m).V = Link(i).V; 
            Link(m).SatFlow = Link(i).SatFlow; 
            Link(m).kjam = Link(i).kjam; 
            Link(m).Demand = 0; 
            Link(m).kcrit = Link(i).kcrit;
            Link(m).W = Link(i).W;
            m = m+1;
            
            if k < NumCell 
                Node(n).InLink = m-1;
                Node(n).OutLink = m;
                Node(n).Split = 1; 
                n = n+1;
            end

        end

        % Modify the controller and node settings accordingly: 
        loc = find(Node(Link(i).ToNode).InLink == i);
        Node(Link(i).ToNode).InLink(loc) = m - 1; 
        loc = find(SignalControl(Link(i).ToNode).Restricted == i);
        SignalControl(Link(i).ToNode).Restricted(loc) = m - 1;
        
        loc = find(Node(Link(i).FrNode).OutLink == i);       
        Node(Link(i).FrNode).OutLink(loc) = m - NumCell;

    end
end