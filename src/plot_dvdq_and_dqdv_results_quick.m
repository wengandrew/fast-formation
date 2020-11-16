function plot_dvdq_and_dqdv_results_quick()


    path = '/Users/aweng/Google Drive File Stream/My Drive/formation';
    directory = 'data/2020-10-diagnostic-test-c20';

    full_path = fullfile(path, directory);

    set_default_plot_settings();
    ref_table = readtable(fullfile(path, 'cell_tracker.xlsx'));

    cellids = 36;

    for i = 1:numel(cellids)

        cellid = cellids(i);

        files_chg = find_files(full_path, sprintf('diagnostic_test_cell_%g_.*_charge', cellid));

        cyc_indices_chg = get_cycle_indices_from_filenames(files_chg);
        [~, sort_idx] = sort(cyc_indices_chg);
        cyc_indices_chg = cyc_indices_chg(sort_idx);
        files_chg = files_chg(sort_idx);

        files_dch = find_files(full_path, sprintf('diagnostic_test_cell_%g_.*_discharge', cellid));

        cyc_indices_dch = get_cycle_indices_from_filenames(files_dch);
        [~, sort_idx] = sort(cyc_indices_dch);
        cyc_indices_dch = cyc_indices_dch(sort_idx);
        files_dch = files_dch(sort_idx);

        fh = figure();
        ax1 = gca;
        xlabel('Capacity (Ah)')
        ylabel('dV/dQ (Ah/V)')
        grid on; box on;
        ylim([-1 1])
        title(sprintf('Cell %g', cellid))

        fh = figure();
        ax2 = gca;
        xlabel('Voltage (V)')
        ylabel('dQ/dV (V/Ah)')
        ylim([-10 10])
        grid on; box on
        title(sprintf('Cell %g', cellid))

        fh = figure();
        ax3 = gca;
        xlabel('Capacity (Ah)');
        ylabel('Voltage (V)');
        ylim([3.0 4.2]);
        grid on; box on;
        title(sprintf('Cell %g', cellid))

        col = parula(numel(files_chg));

        for idx_chg = 1:numel(files_chg)

            [capacity, voltage, dvdq] = get_dvdq_info_from_chg_file(files_chg{idx_chg});

            line(capacity, dvdq, 'LineWidth', 2, ...
                    'DisplayName', sprintf('Cycle %g', cyc_indices_chg(idx_chg)), ...
                    'Color', col(idx_chg, :), ...
                    'Parent', ax1)

            line(voltage, 1./dvdq, 'LineWidth', 2, ...
                    'DisplayName', sprintf('Cycle %g', cyc_indices_chg(idx_chg)), ...
                    'Color', col(idx_chg, :), ...
                    'Parent', ax2)

            line(capacity, voltage, 'LineWidth', 2, ...
                    'DisplayName', sprintf('Cycle %g', cyc_indices_chg(idx_chg)), ...
                    'Color', col(idx_chg, :), ...
                    'Parent', ax3)

        end

        for idx_dch = 1:numel(files_dch)

            [capacity, voltage, dvdq] = get_dvdq_info_from_dch_file(files_dch{idx_dch});

            line(max(capacity)-capacity, dvdq, 'LineWidth', 2, ...
                    'HandleVisibility', 'off', ...
                    'Color', col(idx_dch, :), ...
                    'Parent', ax1)

            line(voltage, 1./dvdq, 'LineWidth', 2, ...
                    'HandleVisibility', 'off', ...
                    'Color', col(idx_dch, :), ...
                    'Parent', ax2)

            line(max(capacity)-capacity, voltage, 'LineWidth', 2, ...
                    'HandleVisibility', 'off', ...
                    'Color', col(idx_dch, :), ...
                    'Parent', ax3, ...
                    'LineStyle', ':')

        end

        legend(ax1, 'show')
        legend(ax2, 'show')
        legend(ax3, 'show')


    end

    keyboard


end

function [capacity, voltage, dvdq] = get_dvdq_info_from_chg_file(filepath)

    tbl = readtable(filepath);

    capacity = tbl.chg_capacity;
    dvdq = tbl.chg_dvdq;
    voltage = tbl.chg_voltage;

    if ~isempty(capacity)
        capacity(end) = [];
        dvdq(end) = [];
        voltage(end) = [];
        capacity(1) = [];
        dvdq(1) = [];
        voltage(1) = [];
    end
    
end


function [capacity, voltage, dvdq] = get_dvdq_info_from_dch_file(filepath)

    tbl = readtable(filepath);

    capacity = tbl.dch_capacity;
    dvdq = tbl.dch_dvdq;
    voltage = tbl.dch_voltage;
    

    if ~isempty(capacity)
        capacity(end) = [];
        dvdq(end) = [];
        voltage(end) = [];
        capacity(1) = [];
        dvdq(1) = [];
        voltage(1) = [];
    end

end


function cycle_index = get_cycle_indices_from_filenames(files)

    for i = 1:numel(files)
        [~, filename, ~] = fileparts(files{i});
        parts = strsplit(filename, '_');
        cycle_index(i) = str2num(parts{6});

    end

end
