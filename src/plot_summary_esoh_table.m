function plot_summary_esoh_table()

    tbl = readtable('output/2020-10-esoh-results-summary/y100-fix/y100_fix_summary_esoh_table.csv');

    keyboard
    
    set_default_plot_settings_manuscript();

    plot_helper_state_variables('HT', tbl)
    plot_helper_state_variables('RT', tbl)
    
    plot_helper_degradation_metrics('HT', tbl)
    plot_helper_degradation_metrics('RT', tbl)

end

function plot_helper_degradation_metrics(plot_type, tbl)

    YLIM = [0 25];
    XLIM = [0 500];
    fh = figure();    

    ax1 = subplot(131); grid on; box on;
    ylabel('LAM_{PE} (%)');
    ylim(YLIM)
    xlim(XLIM)
    xlabel('Cycle Number')
    
    ax2 = subplot(132); grid on; box on;
    ylabel('LAM_{NE} (%)');
    ylim(YLIM)
    xlim(XLIM)
    xlabel('Cycle Number')
    
    ax3 = subplot(133); grid on; box on;
    ylabel('LLI (%)');
    ylim(YLIM)
    xlim(XLIM)
    xlabel('Cycle Number')

    
    cellids = unique(tbl.cellid);
    
    for i = 1:numel(cellids)

        cellid = cellids(i);
        config = get_cellid_config(cellid);

        if ~strcmpi(config.temperature, plot_type)
            continue
        end
        
        if cellid == 9
            continue
        end

        idx = find(tbl.cellid == cellid);
        this_tbl = tbl(idx, :);

        % Get rid of high RMS data points
        RMSE_THRESHOLD_MV = 120;
        idx = find(this_tbl.RMSE_mV < RMSE_THRESHOLD_MV);
        this_tbl = this_tbl(idx, :);
        
        % Sort by increasing cycle number
        [~, is] = sort(this_tbl.cycle_number);
        this_tbl = this_tbl(is, :);
        
        % Calculate the degradation metrics LLI, LAM_PE, LAM_NE using
        % definitions from Suhak's paper
        
        y100 = this_tbl.y100;
        x100 = this_tbl.x100;
        Cn = this_tbl.Cn;
        Cp = this_tbl.Cp;
        
        n_li = 3600/96485 .* (y100 .* Cp + x100 .* Cn);
        lli = 1 - n_li ./ n_li(1);
        
        lam_pe = 1 - Cp ./ Cp(1);
        lam_ne = 1 - Cn ./ Cn(1);


        % FILTER OUT RESULTS EXCEEDING SOME THRESHOLD
        LOSS_THRESHOLD = 0.25;
        
        idx = find(lam_pe < LOSS_THRESHOLD);
        line(this_tbl.cycle_number(idx), lam_pe(idx).*100, ...
            'Marker', 'o', 'Parent', ax1, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        idx = find(lam_ne < LOSS_THRESHOLD);
        line(this_tbl.cycle_number(idx), lam_ne(idx).*100, ...
            'Marker', 'o', 'Parent', ax2, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        idx = find(lli < LOSS_THRESHOLD);
        line(this_tbl.cycle_number(idx), lli(idx).*100, ...
            'Marker', 'o', 'Parent', ax3, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        
    end % loop over cellids

    linkaxes([ax1, ax2, ax3], 'x')

    saveas(fh, sprintf('esoh_features_deg_all_cells_%s.png', plot_type))
    saveas(fh, sprintf('esoh_features_deg_all_cells_%s.fig', plot_type))
    
    
end

function plot_helper_state_variables(plot_type, tbl)

    fh_summary = figure();

    ax1 = subplot(3, 2, 1); grid on; box on;
    ylim([0.03, 0.06])
    ylabel('y_{100}')
    xlabel('Cycle Number')

    ax2 = subplot(3, 2, 2); grid on; box on;
    ylim([0.8, 3.2])
    ylabel('C_p (Ah)')
    xlabel('Cycle Number')

    ax3 = subplot(3, 2, 3); grid on; box on;
    ylim([0.7 1])
    ylabel('x_{100}')
    xlabel('Cycle Number')

    ax4 = subplot(3, 2, 4); grid on; box on;
    ylim([0.8, 3.2])
    ylabel('C_n (Ah)')
    xlabel('Cycle Number')

    ax5 = subplot(3, 2, 5); grid on; box on;
    ylim([0 100])
    ylabel('Q_{comp} (mAh)')
    xlabel('Cycle Number')

    ax6 = subplot(3, 2, 6); grid on; box on;
    ylim([0 200])
    ylabel('RMSE_{mV}')
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

        % idx_exclude = this_tbl.RMSE_mV > 50;
        % this_tbl(idx_exclude, :) = [];

        [~, is] = sort(this_tbl.cycle_number);

        line(this_tbl.cycle_number(is), this_tbl.y100(is), ...
            'Marker', 'o', 'Parent', ax1, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        line(this_tbl.cycle_number(is), this_tbl.Cp(is), ...
            'Marker', 'o', 'Parent', ax2, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        line(this_tbl.cycle_number(is), this_tbl.x100(is), ...
            'Marker', 'o', 'Parent', ax3, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        line(this_tbl.cycle_number(is), this_tbl.Cn(is), ...
            'Marker', 'o', 'Parent', ax4, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        line(this_tbl.cycle_number(is), this_tbl.Qcomp(is)*1000, ...
            'Marker', 'o', 'Parent', ax5, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

        line(this_tbl.cycle_number(is), this_tbl.RMSE_mV(is), ...
            'Marker', 'o', 'Parent', ax6, 'Color', config.color, ...
            'MarkerFaceColor', config.color, 'LineStyle', config.linestyle)

    end % loop over cellids

    linkaxes([ax1, ax2, ax3, ax4, ax5, ax6], 'x')

    saveas(fh_summary, sprintf('esoh_features_all_cells_%s.png', plot_type))
    saveas(fh_summary, sprintf('esoh_features_all_cells_%s.fig', plot_type))

end