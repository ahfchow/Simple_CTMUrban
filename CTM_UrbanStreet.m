
% A script written for running CTM simulation of urban signalized traffic networks 
%
% by: Andy Chow
% Centre for Transport Studies
% University College London  
% revised: OCT 2012 
% 
% This is the 'MAIN' program 
% 
% Configuration file: "UrbanConfig.m"
%
% sub-program: 
% --------------
% 1. CTM.m            - CTM Simulator 
% 2. MOE.m            - Calculation of 'Measures of Effectiveness'
% 3. ControlVector.m  - Generation of 'control' vector based on given signal timing plan
% 4. Slice.m          - Generation of 'shorter' links for simulation 


% Simulation settings
dt = 1;                             % simulation sampling time step - [sec] 
TotalTimeStep = 3000;               % Total number of simiulation time steps 


% Import network configuration: 
[Node] = UrbanConfig('Nodes');
[Link] = UrbanConfig('Links');


% Import signal control setting
[SignalControl] = UrbanConfig('Controllers');

% Slice intermediate links into shorter segments (cells) 
[Link LinkSet Node SignalControl] = Slice(Link,Node,SignalControl,dt); 

% Calculate control vector 
[control] = ControlVector(Link,SignalControl,TotalTimeStep); 

% Traffic state updates (Cell transmission model) 
[Inflow Outflow rho Speed] = CTM(control,Link,Node,dt,TotalTimeStep); 

% Calculate the performance indices (VHT, VMT, Delay, Productivity Loss) 
[VHT VMT Delay PL] = MOE(rho,Outflow,Link,control,dt,TotalTimeStep);



% % Plot of total system delay 
figure;
hold on;
plot(sum(Delay,1))
xlabel('Time [sec]','fontsize',18);
ylabel('Total network delay [veh-hr/sec]','fontsize',18); 
title('Total network delay','fontsize',18);
hold off

% Density contour along main-line
figure;
hold on;
[X,Y] = meshgrid(670:1:1150, 0.2/24:0.2/24:0.2);  
h = surf(X,Y,rho(11:34,670:1:1150));    % one block  
shading flat;
xlabel('Time','fontsize',18); 
ylabel('Location','fontsize',18)
title('Density contour') 
% colormap gray  
set(gca,'FontSize',18)
colorbar('fontsize',18)
hold off;




