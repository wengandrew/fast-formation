function find_peaks_peyman()

    %% Adding the required paths
    addpath('diagnostic_test_sample_data/')

    fn.Cell09 = {'diagnostic_test_cell_9_cyc_3.csv','diagnostic_test_cell_9_cyc_56.csv','diagnostic_test_cell_9_cyc_159.csv','diagnostic_test_cell_9_cyc_262.csv'};
    fn.Cell11 = {'diagnostic_test_cell_11_cyc_3.csv','diagnostic_test_cell_11_cyc_56.csv','diagnostic_test_cell_11_cyc_159.csv','diagnostic_test_cell_11_cyc_262.csv'};
    fn.Cell29 = {'diagnostic_test_cell_29_cyc_3.csv','diagnostic_test_cell_29_cyc_56.csv','diagnostic_test_cell_29_cyc_159.csv','diagnostic_test_cell_29_cyc_262.csv'};
    fn.Cell31 = {'diagnostic_test_cell_31_cyc_3.csv','diagnostic_test_cell_31_cyc_56.csv','diagnostic_test_cell_31_cyc_159.csv','diagnostic_test_cell_31_cyc_262.csv'};
    fn.Cell35 = {'diagnostic_test_cell_35_cyc_3.csv','diagnostic_test_cell_35_cyc_56.csv','diagnostic_test_cell_35_cyc_159.csv','diagnostic_test_cell_35_cyc_262.csv'};

    % Cell_num = {'Cell09','Cell11','Cell29','Cell31','Cell35'};
    Cell_num = {'Cell35'};
    cell_legend = {'BL form HT','BL form RT','Micro form RT','Micro form HT','Micro form HT'};
    color = {'*','*','*','*','*','*','*','*','*'};
    marker = '-o';
    startColor = [0.8500 0.3250 0.0980];

    j = 1;

    Char_OCV = ['fn.',Cell_num{j}];
    BL_OCV_fn.main = eval(Char_OCV);
    Cy_num_OCV = [3,56,159,262];
    Cycle_num_target = 1:length(eval(Char_OCV));
    for i = 4
        data = csvread(BL_OCV_fn.main{i},1,1);
        Q = data(:,1); Voltage = data(:,2);
        x = Voltage; %
        % dx = mean(x(2:end)-x(1:end-1));
        N1 = 3;                     % Order of polynomial fit
        F1 = 7;                    % Window length
        [b1,g1] = sgolay(N1,F1);    % Calculate S-G coefficients
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

  
        figure(1)
        subplot(2,1,1)
        plot(Q,Voltage,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('Q [Ah]','Interpreter','LaTex');
        ylabel('$V_t$ [V]','Interpreter','LaTex');
        h = legend('data');
        set(h,'Interpreter','latex','Location','best')
        hold on

        subplot(2,1,2)
        plot(Qd_data,dVdQ_data,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('Q [Ah]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data');
        % set(h,'Interpreter','latex','Location','best')
        ylim([0 1])
        hold on

        
        keyboard
        SOC = Q./max(Q);
        SOC_d = Qd_data./max(Qd_data);
        [M,I] = max(-SG1(find(x<2,1):find(x<1,1)));
        v_2_Cover10 = x(I+find(x<2,1));
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
        figure(2)
        subplot(2,1,1)
        plot(SOC,Voltage,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$V_t$ [V]','Interpreter','LaTex');
        h = legend('data');
        set(h,'Interpreter','latex','Location','best')
        hold on
        subplot(2,1,2)
        plot(SOC_d,dVdQ_data,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data');
        % set(h,'Interpreter','latex','Location','best')
        ylim([0 1])
        hold on
        subplot(2,1,2)
        plot(SOC_p1,dV1,'k*',SOC_p2,dV2,'k*')
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data','peaks');
        % set(h,'Interpreter','latex','Location','best')
        ylim([0 1])
        hold on
        figure(3)
        subplot(2,1,1)
        plot(SOC_d,dVdQ_data,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data');
        % set(h,'Interpreter','latex','Location','best')
        ylim([0 1])
        hold on
        subplot(2,1,1)
        plot([SOC_d(id_SOC_40p),SOC_d(id_SOC_80p)],[dVdQ_data(id_SOC_40p),dVdQ_data(id_SOC_80p)],'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data','line');
        % set(h,'Interpreter','latex','Location','best')
        ylim([0 1])
        hold on
        subplot(2,1,2)
        plot(SOC_d(id_SOC_40p:id_SOC_80p),dVdQ_data(id_SOC_40p:id_SOC_80p)- a.*SOC_d(id_SOC_40p:id_SOC_80p) + b,'linewidth',1.5)
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data');
        % set(h,'Interpreter','latex','Location','best')
        ylim([-0.05 0.5])
        xlim([0 1])
        hold on
        dVdQ_data_rd = dVdQ_data(id_SOC_40p:id_SOC_80p)- a.*SOC_d(id_SOC_40p:id_SOC_80p) + b;
        [dV2_rd,id_p2_rd] = max(dVdQ_data_rd);
        SOC_p2_rd = SOC_d(id_SOC_40p + id_p2_rd - 1);
        Q_p2_rd = Qd_data(id_SOC_40p + id_p2_rd - 1);
        subplot(2,1,2)
        plot(SOC_p2_rd,dV2_rd,'k*')
        set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
        xlabel('SOC [-]','Interpreter','LaTex');
        ylabel('$dV/dQ$ [V/Ah]','Interpreter','LaTex');
        h = legend('data','true peak');
        % set(h,'Interpreter','latex','Location','best')
        ylim([-0.05 0.5])
        xlim([0 1])
        hold on
        C_n(i) = (Q_p2_rd - Q_p1) / (0.49 - 0.129); % the peak location @0.49 and @0.129 are selected based on OG Un function
        x100(i) = 0.49 + (max(Q) - Q_p2_rd)./C_n(i);
    end

    figure(301)
    subplot(1,2,1)
    plot(Cy_num_OCV(1:length(x100)),x100,'-*','linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$x_{100}$','Interpreter','LaTex');
    ylim([0.6 1]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on

    subplot(1,2,2)
    plot(Cy_num_OCV(1:length(x100)),C_n,'-*','linewidth',1.5,'MarkerSize',4)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$C_{n}$ [Ah]','Interpreter','LaTex');
    ylim([1.5 3]);
    h = legend(Cell_num);
    set(h,'Interpreter','latex','Location','best')
    hold on

end
