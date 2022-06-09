function plot_summary_esoh_table()

    % Configure your own path here; this will be different for you
    root_path = 'C:/Users/wenga/Documents/fast-formation/';
    output_path = [root_path 'outputs/2021-04-12-formation-esoh-fits/'];
    tbl = readtable([output_path 'summary_esoh_table.csv']);
   
    % Get rid of high RMS data points
%     RMSE_THRESHOLD_MV = 120;
%     idx = find(tbl.RMSE_mV < RMSE_THRESHOLD_MV);
%     tbl = tbl(idx, :);
    
    % Get rid of unwanted cellids
    idx = find(tbl.cellid == 9);
    tbl(idx, :) = [];
  
    set_default_plot_settings_manuscript();
    set(0, 'DefaultAxesFontSize', 17)

    plot_helper_state_variables('HT', tbl)
    plot_helper_state_variables('RT', tbl)
    
    plot_helper_degradation_metrics('HT', tbl)
    plot_helper_degradation_metrics('RT', tbl)
    
%     plot_helper_degradation_correlations('RT', tbl)
%     plot_helper_degradation_correlations('HT', tbl)

end

function plot_helper_degradation_correlations(plot_type, tbl)

    cellids = unique(tbl.cellid);
    
    for i = 1:numel(cellids)

        cellid = cellids(i);
        config = get_cellid_config(cellid);

        if ~strcmpi(config.temperature, plot_type)
            continue
        end

        idx = find(tbl.cellid == cellid);
        this_tbl = tbl(idx, :);
        
        % Sort by increasing cycle number
        [~, is] = sort(this_tbl.cycle_number);
        this_tbl = this_tbl(is, :);
            
        y100 = this_tbl.y100;
        x100 = this_tbl.x100;
        Cn = this_tbl.Cn;
        Cp = this_tbl.Cp;
        n_li = this_tbl.n_li;

        lli = 1 - n_li ./ n_li(1);

        lam_pe = 1 - Cp ./ Cp(1);
        lam_ne = 1 - Cn ./ Cn(1);

        % Full Cell Loss
        c20_loss = 1 - this_tbl.Qfull ./ this_tbl.Qfull(1);

    end
    
    
        
end


function plot_helper_degradation_metrics(plot_type, tbl)
    % Plot of C/20 Loss, LAM_PE, LAM_NE, and LLI
    % Against cycle count
    
%     YLIM = [1.5 3];
    YLIM = [0 15];
    XLIM = [0 500];
    fh = figure('Position', [0 0 1300 400]);

    ax1 = subplot(141); grid on; box on;
    ylabel('C/20 Capaciy Loss (%)');
    ylim(YLIM)
    xlim(XLIM)
    set(gca, 'XTick', [0 250 500])
    xlabel('Cycle Number')    
    
    ax2 = subplot(142); grid on; box on;
    ylabel('LAM_{PE} (%)');
    ylim(YLIM)
    xlim(XLIM)
    set(gca, 'XTick', [0 250 500])
    xlabel('Cycle Number')
    
    ax3 = subplot(143); grid on; box on;
    ylabel('LAM_{NE} (%)');
    ylim(YLIM)
    xlim(XLIM)
    set(gca, 'XTick', [0 250 500])
    xlabel('Cycle Number')
    
    ax4 = subplot(144); grid on; box on;
    ylabel('LLI (%)');
    ylim(YLIM)
    xlim(XLIM)
    set(gca, 'XTick', [0 250 500])
    xlabel('Cycle Number')

    
    cellids = unique(tbl.cellid);
    
    for i = 1:numel(cellids)

        cellid = cellids(i);
        config = get_cellid_config(cellid);

        if ~strcmpi(config.temperature, plot_type)
            continue
        end

        idx = find(tbl.cellid == cellid);
        this_tbl = tbl(idx, :);
        
        % Sort by increasing cycle number
        [~, is] = sort(this_tbl.cycle_number);
        this_tbl = this_tbl(is, :);
        
        % Calculate the degradation metrics LLI, LAM_PE, LAM_NE using
        % definitions from Suhak's paper
        
        y100 = this_tbl.y100;
        x100 = this_tbl.x100;
        Cn = this_tbl.Cn;
        Cp = this_tbl.Cp;
        n_li = this_tbl.n_li;
        Q_full = this_tbl.Qfull;
        
        lli = 1 - n_li ./ n_li(1);
        
        lam_pe = 1 - Cp ./ Cp(1);
        lam_ne = 1 - Cn ./ Cn(1);

        % Full Cell Loss
        c20_loss = 1 - Q_full ./ Q_full(1);
        
        % FILTER OUT RESULTS EXCEEDING SOME THRESHOLD
        LOSS_THRESHOLD = 1;
        
        marker_size = 4;
        
%         line(this_tbl.cycle_number, Q_full, ...
        line(this_tbl.cycle_number, c20_loss.*100, ...
            'Marker', 'o', 'Parent', ax1, 'Color', config.color, ...
            'MarkerFaceColor', config.color, ...
            'LineStyle', config.linestyle, ...
            'LineWidth', 1, ...
            'MarkerSize', marker_size)
        
        idx = find(lam_pe < LOSS_THRESHOLD);
        %         line(this_tbl.cycle_number, Cp, ...
        line(this_tbl.cycle_number(idx), lam_pe(idx).*100, ...
            'Marker', 'o', 'Parent', ax2, 'Color', config.color, ...
            'MarkerFaceColor', config.color, ...
            'LineStyle', config.linestyle, ...
            'LineWidth', 1, ...
            'MarkerSize', marker_size)

        idx = find(lam_ne < LOSS_THRESHOLD);
        %         line(this_tbl.cycle_number, Cn, ...
        line(this_tbl.cycle_number(idx), lam_ne(idx).*100, ...
            'Marker', 'o', 'Parent', ax3, ...
            'Color', config.color, ...
            'MarkerFaceColor', config.color, ...
            'LineWidth', 1, ...
            'LineStyle', config.linestyle, ...
            'MarkerSize', marker_size)

        
        idx = find(lli < LOSS_THRESHOLD);
        %         line(this_tbl.cycle_number, n_li, ...
        line(this_tbl.cycle_number(idx), lli(idx).*100, ...
            'Marker', 'o', 'Parent', ax4, ...
            'Color', config.color, ...
            'MarkerFaceColor', config.color, ...
            'LineStyle', config.linestyle, ...
            'LineWidth', 1, ...
            'MarkerSize', marker_size)

        
    end % loop over cellids
    

    linkaxes([ax1, ax2, ax3], 'x')

    tightfig()
    
    saveas(fh, sprintf('esoh_features_deg_all_cells_%s.png', plot_type))
    saveas(fh, sprintf('esoh_features_deg_all_cells_%s.fig', plot_type))
    
    
end

function plot_helper_state_variables(plot_type, tbl)

    fh_summary = figure('Position', [0 0 1200 1800]);

    cellids = unique(tbl.cellid);

    varnames = {'y100', 'x100', ...
                'y0', 'x0', ...
                'Cp', 'Cn', 'pos_excess', 'neg_excess', ...
                'np_ratio', 'n_li', 'RMSE_mV', 'Qcomp', ...
                'Cn_pf', 'x100_pf'};

    varlabels = {'y_{100}', 'x_{100}', 'y_0', 'x_0', ...
                 'C_p (Ah)', 'C_n (Ah)', 'C_{p,excess} (Ah)', 'C_{n,excess} (Ah)', ...
                 'C_n / C_p', 'n_{Li} (moles)', 'RMSE_mV', 'Q_{comp}', ...
                 'C_{n,PF} (Ah)', 'x_{100, PF}'};
   
    ylims = {[0 0.05], [0.75 1], ...
             [0.6, 1], [-0.01 0.05], ...
             [1.5 3], [1.5 3], ...
             [0 0.8], [0 0.8], ...
             [0.5 1.10], [0.03 0.10], [0 150], ...
             [-0.05 0.05], ...
             [1.5 3], [0.75 1]};
         
    % Axis declaration
    for i = 1:numel(varnames)

        ax(i) = subplot(7, 2, i);
        grid on; 
        box on;
        ylim(ylims{i})
        if i == 13 || i == 14
            xlabel('Cycle Number')
        end
        ylabel(varlabels{i})

    end

    for i = 1:numel(cellids)

        cellid = cellids(i);
        config = get_cellid_config(cellid);

        if ~strcmpi(config.temperature, plot_type)
            continue
        end

        idx = find(tbl.cellid == cellid);
        this_tbl = tbl(idx, :);

        [~, is] = sort(this_tbl.cycle_number);
        for i = 1:numel(varnames)

            varname = varnames{i};
           
            curr_vals = this_tbl.(varname);
            line(this_tbl.cycle_number(is), curr_vals(is), ...
            'Marker', 'o', ...
            'Parent', ax(i), ...
            'Color', config.color, ...
            'MarkerFaceColor', config.color, ...
            'MarkerSize', 2, ...
            'LineStyle', config.linestyle)
           
        end

    end % loop over cellids

    linkaxes(ax, 'x')
    
    saveas(fh_summary, sprintf('esoh_features_all_cells_%s_1.png', plot_type))
    saveas(fh_summary, sprintf('esoh_features_all_cells_%s_1.fig', plot_type))

end
