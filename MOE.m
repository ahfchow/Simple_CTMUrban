% -----------------------------------------------------------------
function [VHT VMT Delay PL] = MOE(rho,Outflow,Link,control,dt,TotalTimeStep)

% Measure of Effectiveness 
% ----------------------------

for i = 1:length(Link)
    for t = 1:TotalTimeStep
       VHT(i,t) = rho(i,t)*Link(i).Length*dt/3600; 
       VMT(i,t) = Outflow(i,t)*Link(i).Length*dt/3600;
       Delay(i,t) = max(0,VHT(i,t)-VMT(i,t)/Link(i).V); 
       if rho(i,t) <= Link(i).kcrit 
           PL(i,t) = 0; 
       elseif control(i,t) == 1 
           PL(i,t) = (1-Outflow(i,t)/Link(i).SatFlow)*Link(i).Length*dt/3600;
       else
           PL(i,t) = 0;
       end 
    end
end
