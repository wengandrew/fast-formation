clc
clear
close all

%% Adding the required paths
addpath('diagnostic_test_sample_data/') 

%%

fn.Cell09 = {'diagnostic_test_cell_9_cyc_3.csv','diagnostic_test_cell_9_cyc_56.csv','diagnostic_test_cell_9_cyc_159.csv','diagnostic_test_cell_9_cyc_262.csv'};
fn.Cell11 = {'diagnostic_test_cell_11_cyc_3.csv','diagnostic_test_cell_11_cyc_56.csv','diagnostic_test_cell_11_cyc_159.csv','diagnostic_test_cell_11_cyc_262.csv'};
fn.Cell29 = {'diagnostic_test_cell_29_cyc_3.csv','diagnostic_test_cell_29_cyc_56.csv','diagnostic_test_cell_29_cyc_159.csv','diagnostic_test_cell_29_cyc_262.csv'};
fn.Cell31 = {'diagnostic_test_cell_31_cyc_3.csv','diagnostic_test_cell_31_cyc_56.csv','diagnostic_test_cell_31_cyc_159.csv','diagnostic_test_cell_31_cyc_262.csv'};
fn.Cell35 = {'diagnostic_test_cell_35_cyc_3.csv','diagnostic_test_cell_35_cyc_56.csv','diagnostic_test_cell_35_cyc_159.csv','diagnostic_test_cell_35_cyc_262.csv'};
    
%%
% Cell_num = {'Cell09','Cell11','Cell29','Cell31','Cell35'};
Cell_num = {'Cell31'};
cell_legend = {'BL form HT','BL form RT','Micro form RT','Micro form HT','Micro form HT'};
color = {'*','*','*','*','*','*','*','*','*'};
marker = '-o';
startColor = [0.8500 0.3250 0.0980];


j = 1;
%%
Char_OCV = ['fn.',Cell_num{j}];
BL_OCV_fn.main = eval(Char_OCV);

Cy_num_OCV = [3,56,159,262];

Capac_OCV = [];
Xi = [0.03;4.5;0.83;4.5;0.005];
y100 = [];
Cp = 0;
x100 = [];
Cn = 0;

y0 = [];
x0 = [];

RMSE_V_out = [];
RMSE_E_out = [];

max_Dis_t = [];

%% 
Cycle_num_target = 1:length(eval(Char_OCV));

i = 1;


data = csvread(BL_OCV_fn.main{i},1,1);

Q = data(:,1); Voltage = data(:,2);

% Un = @(x) 0.063+0.7*exp(-75*(x+0.007))+...
%                     -0.0120*tanh((x-0.127)/0.016)+...
%                     -0.0118*tanh((x-0.155)/0.016)+...
%                     -0.0035*tanh((x-0.220)/0.020)+...
%                     -0.0095*tanh((x-0.190)/0.013)+...
%                     -0.0145*tanh((x-0.490)/0.018)+...
%                     -0.0800*tanh((x-1.030)/0.055); % Graphite OG

Un = @(x) 0.08+1*exp(-75*(x+0.00))+...
                    -0.0120*tanh((x-0.127)/0.016)+...
                    -0.0118*tanh((x-0.155)/0.016)+...
                    -0.0035*tanh((x-0.230)/0.015)+...
                    -0.0095*tanh((x-0.190)/0.013)+...
                    -0.0145*tanh((x-0.490)/0.018)+...
                    -0.0800*tanh((x-1.030)/0.055); % Graphite HT
                
% Up = @(y) 4.3452-1.6518*(y)+1.6525*(y).^2-2.0843*(y).^3+3.5146*y.^4-2.2266*y.^5-0.5623e-4*exp(109.451*(y)-100.006); % NMC
Up = @(y) 4.1352-0.9518*(y)+1.0225*(y).^2-2.0843*(y).^3+3.4546*y.^4-2.0566*y.^5-0.5623e-4*exp(109.451*(y)-100.006); % NMC


%                 
% Up = Voltage + Un(x0+Q./Cn);

y100 = 0.023;
Cp = max(Q)*1.1;

x0 = 0.020;
x0 = fsolve(@(x) Up(y100+(max(Q)-0)./Cp) - Un(x) - 3,x0);
% Cn = Cp*1.0;
Cn = 2.80;

Un_data = -Voltage + Up(y100+(max(Q)-Q)./Cp);

figure(1)
subplot(2,1,1)
plot(Q,Up(y100+(max(Q)-Q)./Cp)-Un(x0+Q./Cn),Q,Voltage,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
h = legend('Model','data');
set(h,'Interpreter','latex','Location','best')
hold on
subplot(2,1,2)
plot(Q,Un_data,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$Un$ [V]','Interpreter','LaTex');
% h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
hold on

x = Un_data; % Q+Xt(5);
% dx = mean(x(2:end)-x(1:end-1));
N1 = 3;                     % Order of polynomial fit
F1 = 5;                    % Window length
[b1,g1] = sgolay(N1,F1);    % Calculate S-G coefficients
y = Q; %Voltage;                % Sinusoid with noise


HalfWin  = ((F1+1)/2) -1;

for n = (F1+1)/2:length(x)-(F1+1)/2
  % Zeroth derivative (smoothing only)
  SG0(n) = dot(g1(:,1),y(n - HalfWin:n + HalfWin));

  
  
  % 1st differential
  SG1(n) = dot(g1(:,2),y(n - HalfWin:n + HalfWin));
  SG1x(n) = dot(g1(:,2),x(n - HalfWin:n + HalfWin));
  
  
  % 2nd differential
%   SG2(n) = 2*dot(g1(:,3)',y(n - HalfWin:n + HalfWin))';

end


% SG1 = SG1./dx;        % Turn differential into derivative

Qd_data = SG0(HalfWin+1:end);
dVdQ_data = SG1x(HalfWin+1:end)./SG1(HalfWin+1:end);


Q_model = 0:0.01:max(Q);
% Q = 0:0.01:(max(Q_data));


Un_model = Un(x0+Q_model./Cn);
dUn_model = Un_model(2:end)-Un_model(1:end-1);
dQ = Q_model(2:end)-Q_model(1:end-1);
Qd = Q_model(1:end-1)+(Q_model(2:end)-Q_model(1:end-1))./2;


figure(1)
subplot(2,1,2)
plot(Q_model,Un_model,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$Un$ [V]','Interpreter','LaTex');
h = legend('data','Model');
set(h,'Interpreter','latex','Location','best')
hold on

dUn_modeldQ = dUn_model./dQ;  
% 
figure(1501)
plot(Qd,-dUn_modeldQ,Qd_data,-dVdQ_data,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
ylim([0 1])
hold on

%%

Up_data = Voltage + Un(x0+Q./Cn);
Up_model = Up(y100+(max(Q)-Q)./Cp);

figure(1502)
plot(Q,Up_model,Q,Up_data,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$Up$ [V]','Interpreter','LaTex');
h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
hold on

y0 = y100+max(Q)/Cp;
x100 = x0+max(Q)/Cn;

Xi = [4.35;-1.9762;2.3514;2.1042;-1.3877;-1.9123;0;100;-100];
% Xi = ones(9,1);
Up =@(X,y) X(1)+X(2)*(y)+X(3)*(y).^2+X(4)*(y).^3+X(5)*y.^4+X(6)*y.^5+X(7)*exp(X(8)*(y)+X(9)); % NMC

ytarg = y100+(max(Q)-Q)./Cp;
Vtarg = Up_data;

ytarg = ytarg(100:end);
Vtarg = Up_data(100:end);

S = [1;1;1;1;1;1;1e4;1/100;1/100];
fun = @(X) (Up(X./S,ytarg)-Vtarg)'*(Up(X./S,ytarg)-Vtarg);
% 
options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','OptimalityTolerance',1e-7,'MaxFunctionEvaluations',9000);
[Xr,fval,exitflag] = fmincon(fun,Xi.*S,[],[],[],[],[],[],[],options);
%     
y =0:0.001:1;
figure(4)
plot(y,Up(Xr./S,y),ytarg,Vtarg,'linewidth',1.5)
xlabel('$y$','Interpreter','LaTex');ylabel('$V$ [V]','Interpreter','LaTex')
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')

%%

Un_data = -Voltage + Up(Xr./S,y100+(max(Q)-Q)./Cp);

figure(12)
subplot(2,1,1)
plot(Q,Voltage,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
% h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
hold on
subplot(2,1,2)
plot(Q,Un_data,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$Un$ [V]','Interpreter','LaTex');
% h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
hold on

x = Un_data; % Q+Xt(5);
% dx = mean(x(2:end)-x(1:end-1));
N1 = 3;                     % Order of polynomial fit
F1 = 5;                    % Window length
[b1,g1] = sgolay(N1,F1);    % Calculate S-G coefficients
y = Q; %Voltage;                % Sinusoid with noise


HalfWin  = ((F1+1)/2) -1;

for n = (F1+1)/2:length(x)-(F1+1)/2
  % Zeroth derivative (smoothing only)
  SG0(n) = dot(g1(:,1),y(n - HalfWin:n + HalfWin));

  
  
  % 1st differential
  SG1(n) = dot(g1(:,2),y(n - HalfWin:n + HalfWin));
  SG1x(n) = dot(g1(:,2),x(n - HalfWin:n + HalfWin));
  
  
  % 2nd differential
%   SG2(n) = 2*dot(g1(:,3)',y(n - HalfWin:n + HalfWin))';

end


% SG1 = SG1./dx;        % Turn differential into derivative

Qd_data = SG0(HalfWin+1:end);
dVdQ_data = SG1x(HalfWin+1:end)./SG1(HalfWin+1:end);


Q_model = 0:0.01:max(Q);
% Q = 0:0.01:(max(Q_data));
Up_model = Up(Xr./S,y100+(max(Q_model)-Q_model)./Cp);

Un_model = Un(x0+Q_model./Cn);
dUn_model = Un_model(2:end)-Un_model(1:end-1);
dQ = Q_model(2:end)-Q_model(1:end-1);
Qd = Q_model(1:end-1)+(Q_model(2:end)-Q_model(1:end-1))./2;


figure(12)
subplot(2,1,2)
plot(Q_model,Un_model,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$Un$ [V]','Interpreter','LaTex');
h = legend('data','Model');
set(h,'Interpreter','latex','Location','best')
hold on

dUn_modeldQ = dUn_model./dQ;  
% 
figure(15012)
plot(Qd,-dUn_modeldQ,Qd_data,-dVdQ_data,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
ylim([0 1])
hold on

figure(2)
% subplot(2,1,1)
plot(Q_model,Up_model-Un_model,Q,Voltage,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
hold on
