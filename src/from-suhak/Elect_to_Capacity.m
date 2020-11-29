% Li-ion cell OCV simulator
% : generating OCV for N data points w.r.t Q based on given electrode parameters 
% : this code is written for Q as charge capacity --> needs x0, y0
% : half-cell potential function can be changed for different chemistry

clear all;
close all;
clc;

%% --------------- electrode parameters (Given) ---------------
x0 = 0.0050;   % NE utilization at Vmin
y0 = 0.9421;   % PE utilization at Vmin
Cn = 2.8931;   % NE capacity
Cp = 2.5022;   % PE capacity


%% --------------- half cell potential ---------------
% Up - LiFePO4
% Un - Graphite
Up = @(y) 3.4323-0.8428*exp(-80.2493*(1-y).^1.3198)-3.2474e-06*exp(20.2645*(1-y).^3.8003)+3.2482e-06*exp(20.2646*(1-y).^3.7995);
Un = @(x) 0.063+0.8*exp(-75*(x+0.007))+...
          -0.0120*tanh((x-0.127)/0.016)+...
          -0.0118*tanh((x-0.155)/0.016)+...
          -0.0035*tanh((x-0.220)/0.020)+...
          -0.0095*tanh((x-0.190)/0.013)+...
          -0.0145*tanh((x-0.490)/0.030)+...
          -0.0800*tanh((x-1.030)/0.055); 

syms y x
dUp = matlabFunction(diff(Up,y));
dUn = matlabFunction(diff(Un,x));

%% --------------- cell OCV function ---------------
OCV = @(Q) Up(y0-Q/Cp)-Un(x0+Q/Cn);
dV_dQ = @(Q) -dUp(y0-Q/Cp)/Cp-dUn(x0+Q/Cn)/Cn;

% voltage limits: user define
Vmin = 2.8;
Vmax = 4.2; 

%% --------------- Estimating capacity ---------------

% equality constraint for Vmax
cost = @(Q)(OCV(Q) - Vmax)^2;
options = optimoptions('fminunc','Algorithm','quasi-newton','OptimalityTolerance',1e-15);
C_int = 2.2; % initial guess

[C_est,fval,exitflag,output] = fminunc(cost,C_int,options);

% cell capacity est.
C_est

% electrode parameter at Vmax
y100 = y0 - C_est/Cp
x100 = x0 + C_est/Cn

%% --------------- plot ---------------
QQ = 0:0.001:C_est; % data points

figure; 
plot(QQ,OCV(QQ),'linewidth',1.5); set(gca,'Fontsize',14);
xlabel('Q [Ah]'); ylabel('Voltage [V]'); legend('OCV');

% IC curve (dQ/dV vs. V)
figure; 
plot(OCV(QQ),1./dV_dQ(QQ),'linewidth',1.5); set(gca,'Fontsize',14);
xlabel('Voltage [V]'); ylabel('dQ/dV [Ah/V]'); legend('IC curve'); axis([3.19 3.41 0 105]);

% DV curve (dV/dQ vs. Q)
figure; 
plot(QQ,dV_dQ(QQ),'linewidth',1.5); set(gca,'Fontsize',14);
xlabel('Voltage [V]'); ylabel('dV/dQ [V/Ah]'); legend('DV curve'); ylim([0 1]);


