function [Up_modified, Un_modified] = recalibrate(Voltage, Q, Cn, x100, Cp, y100)

[Un, Up] = get_electrode_models('original');

x0 = x100 - max(Q)./Cn;

Un_data = -Voltage + Up(y100+(max(Q)-Q)./Cp);

% figure(1)
% subplot(2,1,1)
% plot(Q,Up(y100+(max(Q)-Q)./Cp)-Un(x0+Q./Cn),Q,Voltage,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$V_t$ [V]','Interpreter','LaTex');
% h = legend('Model','data');
% set(h,'Interpreter','latex','Location','best')
% hold on
% subplot(2,1,2)
% plot(Q,Un_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$Un$ [V]','Interpreter','LaTex');
% % h = legend('Model','data');
% % set(h,'Interpreter','latex','Location','best')
% hold on

% x = Un_data; % Q+Xt(5);
% % dx = mean(x(2:end)-x(1:end-1));
% N1 = 3;                     % Order of polynomial fit
% F1 = 5;                    % Window length
% [b1,g1] = sgolay(N1,F1);    % Calculate S-G coefficients
% y = Q; %Voltage;                % Sinusoid with noise
% 
% 
% HalfWin  = ((F1+1)/2) -1;
% 
% for n = (F1+1)/2:length(x)-(F1+1)/2
%   % Zeroth derivative (smoothing only)
%   SG0(n) = dot(g1(:,1),y(n - HalfWin:n + HalfWin));
% 
%   
%   
%   % 1st differential
%   SG1(n) = dot(g1(:,2),y(n - HalfWin:n + HalfWin));
%   SG1x(n) = dot(g1(:,2),x(n - HalfWin:n + HalfWin));
%   
%   
%   % 2nd differential
% %   SG2(n) = 2*dot(g1(:,3)',y(n - HalfWin:n + HalfWin))';
% 
% end
% 
% 
% % SG1 = SG1./dx;        % Turn differential into derivative
% 
% Qd_data = SG0(HalfWin+1:end);
% dVdQ_data = SG1x(HalfWin+1:end)./SG1(HalfWin+1:end);


% Q_model = 0:0.01:max(Q);
% Q = 0:0.01:(max(Q_data));


Xi = [0.063;-75;0];
% Xi = ones(9,1);
Un_reduced =@(X,x) X(1)+1*exp(X(2)*x+X(3))+...
                    -0.0120*tanh((x-0.127+0.015)/0.016)+...
                    -0.0118*tanh((x-0.155+0.015)/0.016)+...
                    -0.0035*tanh((x-0.230+0.015)/0.015)+...
                    -0.0095*tanh((x-0.190+0.015)/0.013)+...
                    -0.0145*tanh((x-0.500)/0.018)+...
                    -0.0800*tanh((x-1.030+0.015)/0.055); 
% Un_reduced =@(X,x) X(1)+X(2)*exp(-75*(x+0.00));

xtarg_g = x0+(Q)./Cn;
% Untarg = Un_data;
xtarg = xtarg_g(1:100);
Vtarg = Un_data(1:100);

% fun = @(X) (Un_reduced(X,xtarg)-Vtarg)'*(Un_reduced(X,xtarg)-Vtarg);
fun = @(X) norm(Un_reduced(X,xtarg)-Vtarg,1);
% 
options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','OptimalityTolerance',1e-7,'MaxFunctionEvaluations',9000);
[Xr,fval,exitflag] = fmincon(fun,Xi,[],[],[],[],[],[],[],options);


Un_modified = @(x) Un_reduced(Xr,x); 
                
% Un_model = Un_modified(x0+Q_model./Cn);
% dUn_model = Un_model(2:end)-Un_model(1:end-1);
% dQ = Q_model(2:end)-Q_model(1:end-1);
% Qd = Q_model(1:end-1)+(Q_model(2:end)-Q_model(1:end-1))./2;


% figure(1)
% subplot(2,1,2)
% plot(xtarg_g,Un_data,0:0.01:1,Un_modified(0:0.01:1),'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('x [-]','Interpreter','LaTex');
% ylabel('$Un$ [V]','Interpreter','LaTex');
% h = legend('data','Model');
% set(h,'Interpreter','latex','Location','best')
% hold on
% 
% dUn_modeldQ = dUn_model./dQ;  
% % 
% figure(1501)
% plot(Qd,-dUn_modeldQ,Qd_data,-dVdQ_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
% h = legend('Model','data');
% % set(h,'Interpreter','latex','Location','best')
% ylim([0 1])
% hold on

%%

Up_data = Voltage + Un_modified(x0+Q./Cn);
% Up_model = Up(y100+(max(Q)-Q)./Cp);

% figure(1502)
% plot(Q,Up_model,Q,Up_data,'linewidth',1.5)
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% xlabel('Q [Ah]','Interpreter','LaTex');
% ylabel('$Up$ [V]','Interpreter','LaTex');
% h = legend('Model','data');
% % set(h,'Interpreter','latex','Location','best')
% % ylim([0 1])
% hold on



Xi = [4.35;-1.9762;2.3514;2.1042;-1.3877;-1.9123;0;100;-100];
% Xi = ones(9,1);
Up =@(X,y) X(1)+X(2)*(y)+X(3)*(y).^2+X(4)*(y).^3+X(5)*y.^4+X(6)*y.^5+X(7)*exp(X(8)*(y)+X(9)); % NMC

ytarg = y100+(max(Q)-Q)./Cp;
% Vtarg = Up_data;

ytarg = ytarg(100:end);
Vtarg = Up_data(100:end);

S = [1;1;1;1;1;1;1e4;1/100;1/100];
fun = @(X) (Up(X./S,ytarg)-Vtarg)'*(Up(X./S,ytarg)-Vtarg);
% 
options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','OptimalityTolerance',1e-7,'MaxFunctionEvaluations',9000);
[Xr,fval,exitflag] = fmincon(fun,Xi.*S,[],[],[],[],[],[],[],options);
%     
% y =0:0.001:1;
% figure(4)
% plot(y,Up(Xr./S,y),ytarg,Vtarg,'linewidth',1.5)
% xlabel('$y$','Interpreter','LaTex');ylabel('$V$ [V]','Interpreter','LaTex')
% set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')

Up_modified = @(y) Up(Xr./S,y);

end