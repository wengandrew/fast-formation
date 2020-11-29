function [Cn, x100] = peak_finding_fn(Q,Voltage)

x = Voltage; % 
% dx = mean(x(2:end)-x(1:end-1));
N1 = 3;                     % Order of polynomial fit
F1 = 7;                    % Window length
[~,g1] = sgolay(N1,F1);    % Calculate S-G coefficients
y = Q;                % 


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



% figure(1)
% subplot(2,1,1)
% plot(Q,Voltage,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$V_t$ [V]','Interpreter','LaTex');
% h = legend('data');
% set(h,'Interpreter','latex','Location','best')
% hold on
% 
% subplot(2,1,2)
% plot(Qd_data,dVdQ_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on

SOC = Q./max(Q);
SOC_d = Qd_data./max(Qd_data);


id_SOC_10p = find(SOC_d>0.1,1);
id_SOC_40p = find(SOC_d>0.4,1);
id_SOC_80p = find(SOC_d>0.8,1);

[dV1,id_p1] = max(dVdQ_data(id_SOC_10p:id_SOC_40p));
[dV2,id_p2] = max(dVdQ_data(id_SOC_40p:id_SOC_80p));

SOC_p1 = SOC_d(id_SOC_10p + id_p1 - 1);
Q_p1 = Qd_data(id_SOC_10p + id_p1 - 1);
SOC_p2 = SOC_d(id_SOC_40p + id_p2 - 1);

a = (dVdQ_data(id_SOC_80p)-dVdQ_data(id_SOC_40p))/(SOC_d(id_SOC_80p)-SOC_d(id_SOC_40p)); % line slope
b = dVdQ_data(id_SOC_80p) - a*SOC_d(id_SOC_40p); % line intercept

% figure(2)
% subplot(2,1,1)
% plot(SOC,Voltage,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$V_t$ [V]','Interpreter','LaTex');
% h = legend('data');
% set(h,'Interpreter','latex','Location','best')
% hold on
% 
% subplot(2,1,2)
% plot(SOC_d,dVdQ_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on
% 
% subplot(2,1,2)
% plot(SOC_p1,dV1,'k*',SOC_p2,dV2,'k*')
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data','peaks');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on

% figure(3)
% subplot(2,1,1)
% plot(SOC_d,dVdQ_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on 
% 
% subplot(2,1,1)
% plot([SOC_d(id_SOC_40p),SOC_d(id_SOC_80p)],[dVdQ_data(id_SOC_40p),dVdQ_data(id_SOC_80p)],'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data','line');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on 
% 
% subplot(2,1,2)
% plot(SOC_d(id_SOC_40p:id_SOC_80p),dVdQ_data(id_SOC_40p:id_SOC_80p)- a.*SOC_d(id_SOC_40p:id_SOC_80p) + b,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data');
% % set(h,'Interpreter','latex','Location','best')
% ylim([-0.05 0.5])
% xlim([0 1])
% hold on

dVdQ_data_rd = dVdQ_data(id_SOC_40p:id_SOC_80p)- a.*SOC_d(id_SOC_40p:id_SOC_80p) + b;
[dV2_rd,id_p2_rd] = max(dVdQ_data_rd);

SOC_p2_rd = SOC_d(id_SOC_40p + id_p2_rd - 1);
Q_p2_rd = Qd_data(id_SOC_40p + id_p2_rd - 1);

% subplot(2,1,2)
% plot(SOC_p2_rd,dV2_rd,'k*')
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('SOC [-]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('data','true peak');
% % set(h,'Interpreter','latex','Location','best')
% ylim([-0.05 0.5])
% xlim([0 1])
% hold on

Cn = (Q_p2_rd - Q_p1) / (0.50 - 0.112); % the peak location @0.49 and @0.129 are selected based on OG Un function
x100 = 0.50 + (max(Q) - Q_p2_rd)./Cn;
% x0 = max(x100 - (max(Q))./Cn,0);
% 
% x100 = x0 + (max(Q))./Cn;
end