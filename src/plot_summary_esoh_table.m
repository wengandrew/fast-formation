function plot_summary_esoh_table()

    tbl = readtable('summary_esoh_table.csv');

    set_default_plot_settings();

    plot_helper('HT', tbl)
    plot_helper('RT', tbl)

end

function plot_helper(plot_type, tbl)

    fh_summary = figure();

    ax1 = subplot(3, 2, 1); grid on; box on;
    ylim([0.03, 0.06])
    ylabel('y_{100}')

    ax2 = subplot(3, 2, 2); grid on; box on;
    ylim([2.3 3.0])
    ylabel('C_p (Ah)')

    ax3 = subplot(3, 2, 3); grid on; box on;
    ylim([0.7 1])
    ylabel('x_{100}')
    xlabel('Cycle Number')

    ax4 = subplot(3, 2, 4); grid on; box on;
    ylim([2.3, 3.0])
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

end
