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
Cell_num = {'Cell11'};
cell_legend = {'BL form HT','BL form RT','Micro form RT','Micro form HT','Micro form HT'};
color = {'*','*','*','*','*','*','*','*','*'};
marker = '-o';
startColor = [0.8500 0.3250 0.0980];




%%



for j = 1:length(Cell_num)
%%
Char_OCV = ['fn.',Cell_num{j}];
BL_OCV_fn.main = eval(Char_OCV);

Cy_num_OCV = [3,56,159,262];

Capac_OCV = [];
% Xi = [0.03;4.5;0.83;4.5;0.005];
% Xi = [0.001;2.768464971216000;0.896080139372822;2.837676595496400;0.05];
% Xi = [0.023;2.768464971216000;0.05];
y100 = [];
Cp = 0;
x100 = [];
Cn = 0;

y0 = [];
x0 = [];

RMSE_V_out = [];

%% Raw functions
Un = @(x) 0.063+1*exp(-75*(x+0.00))+...
                    -0.0120*tanh((x-0.127)/0.016)+...
                    -0.0118*tanh((x-0.155)/0.016)+...
                    -0.0035*tanh((x-0.230)/0.015)+...
                    -0.0095*tanh((x-0.190)/0.013)+...
                    -0.0145*tanh((x-0.490)/0.018)+...
                    -0.0800*tanh((x-1.030)/0.055); % Graphite HT
                
Up = @(y) 4.3452-1.6518*(y)+1.6525*(y).^2-2.0843*(y).^3+3.5146*y.^4-2.2266*y.^5-0.5623e-4*exp(109.451*(y)-100.006); % NMC

%% 
Cycle_num_target = 1:length(eval(Char_OCV));
% Cycle_num_target = 1;

for i = Cycle_num_target


data = csvread(BL_OCV_fn.main{i},1,1);

Q = data(:,1); Voltage = data(:,2);

figure(1)

plot(Q,Voltage,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
h = legend(Cell_num);
% set(h,'Interpreter','latex','Location','best')
hold on

figure(2)

plot(Q./max(Q),Voltage,'linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('SOC [-]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
h = legend(Cell_num);
% set(h,'Interpreter','latex','Location','best')
hold on

Capac_OCV = [Capac_OCV,max(Q)];
[Cn(i), x100(i)] = peak_finding_fn(Q,Voltage);

if i == 1 
    y100(i) = 0.023;
    Cp(i) = Cn(i)*0.995;
    [Up_modified, Un_modified] = recalibrate(Voltage, Q, Un, Up, Cn(i), x100(i), Cp(i), y100(i));
    
    Q_s = 0:0.01:(max(Q));

    Vt = Up_modified(y100(i)+Q_s/Cp(i))-Un_modified(x100(i)-Q_s/Cn(i));
    dV = Vt(2:end)-Vt(1:end-1);
    dQ = Q_s(2:end)-Q_s(1:end-1);
    Qd = Q_s(1:end-1)+(Q_s(2:end)-Q_s(1:end-1))./2;

    dVdQ = dV./dQ;  
    
    y0(i) = y100(i) + (max(Q))/Cp(i);
    x0(i) = max(x100(i) - (max(Q))/Cn(i),0);
    
    Xi = [y100(i);Cp(i)];
else
    id1 = (find(Voltage>3.38,1):length(Voltage));
    [Xt,RMSE_V,Q_s,Vt,Qd,dVdQ] = diagnostics_recal(Q(id1),Voltage(id1),Up_modified,Un_modified,Xi,i,Cn,x100);

    y100(i) = Xt(1);
    Cp(i) = Xt(2);

    % Xt(5) = 0;

    y0(i) = y100(i) + (max(Q))/Cp(i);
    x0(i) = max(x100(i) - (max(Q))/Cn(i),0);

    Xi = Xt;

    RMSE_V_out(i) = RMSE_V;


end



figure(150)
% subplot(2,1,1)
plot(max(Q)-fliplr(Q_s),fliplr(Vt),'k',Q,Voltage,'k--','linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$V_t$ [V]','Interpreter','LaTex');
h = legend('Model','data');
set(h,'Interpreter','latex','Location','best')
str = string(Cy_num_OCV(i));
t = text(max(Q_s),Vt(1)+0.05,str);
set(t,'Interpreter','latex','FontSize',14)
hold on
% 
x = Voltage; % Q+Xt(5);
dx = mean(x(2:end)-x(1:end-1));
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
  
  
  % 2nd differential
%   SG2(n) = 2*dot(g1(:,3)',y(n - HalfWin:n + HalfWin))';

end

SG1 = SG1./dx;        % Turn differential into derivative

Qd_data = SG0(HalfWin+1:end);
dVdQ_data = 1./SG1(HalfWin+1:end);
% 
figure(1501)
plot(max(Q)-fliplr(Qd),fliplr(abs(dVdQ))-0.1*(i-1),'k',Qd_data,dVdQ_data-0.1*(i-1),'k--','linewidth',1.5)
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
xlabel('Q [Ah]','Interpreter','LaTex');
ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
h = legend('Model','data');
set(h,'Interpreter','latex','Location','best')
t = text(max(Qd),abs(dVdQ(1))-0.1*(i-1)+0.05,str);
set(t,'Interpreter','latex','FontSize',14)
ylim([-0.1 1])
hold on


SG0 = [];
SG1 = [];
end

%%

    figure(4)
    plot(Cy_num_OCV(1:length(y100)),Capac_OCV./Capac_OCV(1).*100,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('SOH $[\%]$','Interpreter','LaTex');
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    
    figure(500)
    subplot(2,3,1)
    plot(Capac_OCV./Capac_OCV(1).*100,y100,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
%     xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$y_{100}$','Interpreter','LaTex');
    ylim([0 0.5]);
%     h = legend(Path);
    hold on
    
    subplot(2,3,2)
    plot(Capac_OCV./Capac_OCV(1).*100,y0,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
%     xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$y_{0}$','Interpreter','LaTex');
    ylim([0.5 1]);
%     h = legend(Path);
    hold on
    
    subplot(2,3,3)
    plot(Capac_OCV./Capac_OCV(1).*100,Cp,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
%     xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$C_{p}$ [Ah]','Interpreter','LaTex');
    ylim([1.5 3]);
%     h = legend(Path);
    hold on
    
    subplot(2,3,4)
    plot(Capac_OCV./Capac_OCV(1).*100,x100,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
    xlabel('SOH $[\%]$','Interpreter','LaTex');
    ylabel('$x_{100}$','Interpreter','LaTex');
    ylim([0.5 1]);
%     h = legend(Path);
    hold on
    
    subplot(2,3,5)
    plot(Capac_OCV./Capac_OCV(1).*100,x0,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
    xlabel('SOH $[\%]$','Interpreter','LaTex');
    ylabel('$x_{0}$','Interpreter','LaTex');
    ylim([-0.01 0.5]);
%     h = legend(Path);
    hold on
    
    subplot(2,3,6)
    plot(Capac_OCV./Capac_OCV(1).*100,Cn,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
    xlabel('SOH $[\%]$','Interpreter','LaTex');
    ylabel('$C_{n}$ [Ah]','Interpreter','LaTex');
    ylim([1.5 3]);
%     h = legend(Path);
    hold on
    

    
    figure(301)
    subplot(3,2,1)
    plot(Cy_num_OCV(1:length(y100)),y100,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$y_{100}$','Interpreter','LaTex');
    ylim([0 0.4]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    subplot(3,2,3)
    plot(Cy_num_OCV(1:length(y100)),y0,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$y_{0}$','Interpreter','LaTex');
    ylim([0.6 1]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    subplot(3,2,5)
    plot(Cy_num_OCV(1:length(y100)),Cp,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$C_{p}$ [Ah]','Interpreter','LaTex');
    ylim([1.5 3]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    subplot(3,2,2)
    plot(Cy_num_OCV(1:length(y100)),x100,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$x_{100}$','Interpreter','LaTex');
    ylim([0.6 1]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    subplot(3,2,4)
    plot(Cy_num_OCV(1:length(y100)),x0,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$x_{0}$','Interpreter','LaTex');
    ylim([-0.001 0.4]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    subplot(3,2,6)
    plot(Cy_num_OCV(1:length(y100)),Cn,marker,'Color', startColor,'linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$C_{n}$ [Ah]','Interpreter','LaTex');
    ylim([1.5 3]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on

    %
    figure(3)
    plot(Cy_num_OCV(1:length(Capac_OCV)),Capac_OCV,'-s')
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('Capacity OCV [Ah]','Interpreter','LaTex');
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    
    %
    figure(302)
    plot(Cy_num_OCV(1:length(y100)),RMSE_V_out,'-s','linewidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$RMSE_{V}$ [V]','Interpreter','LaTex');
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on
    

   
    



    

    
    
%     aging_calculation(y100, x100, Cp, Cn, Cy_num_OCV, Ah_Tot_OCV, Capac_OCV,startColor, marker)
    startColor = startColor + ([1 1 1] - startColor)./7;
    
    


end




