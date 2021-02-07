function plot_figures()
    % Generate figures for manuscript

    global BLUE
    global ORANGE
    global GREEN
    global RED

    ORANGE = [1 0.5 0];
    BLUE = [0 0.5 1];
    GREEN = [0 0.75 0];

    set_default_plot_settings_manuscript()

%   fig_formation_protocol()

    fig_aging_variable('average_voltage')
    fig_aging_variable('voltage_efficiency')
    fig_aging_variable('discharge_energy')
    fig_aging_variable('discharge_capacity')
    fig_aging_variable('coulombic_efficiency')


%    fig_formation_performance_distributions()
%   fig_aging_distributions()
%   fig_initial_dcr_from_rpt()
%   fig_initial_esoh_distributions()
%   fig_thickness_distributions()
%   fig_esoh_metrics()
%   fig_correlations()
%   fig_dvdq_comparison()

end

function fig_dvdq_comparison()
    % Plot the dvdq for all 40 cells


    tbl = readtable('documents/cell_tracker.xlsx');

    % Exclude cell number 9
    tbl(find(tbl.cell_number == 9), :) = [];
    
    fig_dvdq_comparison_helper(tbl, 'charge')
    fig_dvdq_comparison_helper(tbl, 'discharge')
    
end

function fig_dvdq_comparison_helper(tbl, charge_or_discharge)
    
    % Plot the fresh curve
    CYC_NUMBER = 56;
    
    data_directory = 'data/2020-10-diagnostic-test-c20';    

    fh = figure();

    ax1 = subplot(211);
    xlabel('Capacity (Ah)')
    ylabel('dV/dQ (Ah/V)')
    ylim([0.1 0.6])
    xlim([0 2.5])
    box on; grid on;
    title('Room Temp')
    
    ax2 = subplot(212);
    xlabel('Capacity (Ah)')
    ylabel('dV/dQ (Ah/V)')
    ylim([0.1 0.6])
    xlim([0 2.5])
    title('45°C')
    box on; grid on;
    
    cellids = tbl.cell_number;
    
    for i = 1:numel(cellids)

        cellid = cellids(i);
        
        file = find_files(data_directory, ...
            sprintf('diagnostic_test_cell_%g_cyc_%g_%s', cellid, ...
            CYC_NUMBER, charge_or_discharge));
        file = file{:};
        
        if strcmpi(charge_or_discharge, 'charge')
            
            [capacity, voltage, dvdq] = get_dvdq_info_from_chg_file(file);
        else
            [capacity, voltage, dvdq] = get_dvdq_info_from_dch_file(file);
        end
        

        if strcmpi(tbl.aging_test{i}, 'rt')
            col = 'b';
            ax = ax1;
        else
            col = 'r';
            ax = ax2;
        end
        
        if strcmpi(tbl.formation_protocol{i}, 'baseline')
            col = 'k';
        end
        
        
        line(capacity, abs(dvdq), 'Color', col, 'Parent', ax)
        
        
    end

    linkaxes([ax1, ax2], 'xy');

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

function fig_correlations()
    % Plot the correlations

    path = 'output/correlation_data_with_esoh.csv';

    tbl = readtable(path);

    % Exclude extreme outlier from this analysis
    idx = find(tbl.cellid == 9);
    tbl(idx, :) = [];

    row_vars = {'retention_at_c400', ...
                'dcr_0_soc_at_c400', ...
                'dcr_50_soc_at_c400', ...
                'dcr_100_soc_at_c400', ...
                'swelling_severity', ...
                'thickness_mm'};

    row_labels = {{'Retention', '400 cycles (%)'}, ...
                  {'DCR, 4% SOC', '400 cycles (m\Omega)'}, ...
                  {'DCR, 50% SOC' '400 cycles (m\Omega)'}, ...
                  {'DCR, 100% SOC' '400 cycles(m\Omega)'}, ...
                  {'Swelling', 'severity'}, ...
                  {'Final' 'Thickness (mm)'}};

    col_vars = {'form_first_cv_hold_capacity_ah', ...
            'form_6hr_rest_voltage_decay_v', ...
            'form_final_discharge_capacity_ah', ...
            'initial_cell_dcr_0_soc', ...
            'initial_cell_dcr_50_soc', ...
            'initial_cell_dcr_100_soc', ...
            'pos_excess_c3', ...
            'neg_excess_c3', ...
            'np_ratio_c3', ...
            'Cp_c3', ...
            'Cn_c3', ...
            'n_li_c3', ...
            'var_q_56_3'};

    col_labels = {{'Q_{CV}', 'formation (Ah)'}, ...
                  {'\Delta V_{rest}', 'formation (V)'}, ...
                  {'Q_d', 'formation (Ah)'}, ...
                  {'DCR, 4% SOC', 'fresh (m\Omega)'}, ...
                  {'DCR, 50% SOC', 'fresh (m\Omega)'}, ...
                  {'DCR, 100% SOC', 'fresh (m\Omega)'}, ...
                  {'Pos Excess, c3 (Ah)'}, ...
                  {'Neg Excess, c3 (Ah)'}, ...
                  {'C_n / C_p, c3'}, ...
                  {'C_p, c3 (Ah)'}, ...
                  {'C_n, c3 (Ah)'}, ...
                  {'LI, c3 (moles)'}, ...
                  {'Var(Q_{56-3}) (mAh)'}};

           
    fig_correlations_staging(tbl, row_vars, col_vars, ...
                             row_labels, col_labels, 'subset_1', ...
                             [1], [1, 2, 3, 4, 5, 6])
% 
%     fig_correlations_staging(tbl, row_vars, col_vars, ...
%                              row_labels, col_labels, 'subset_2', ...
%                              [1, 6], [7, 8, 9, 10, 11, 12, 13]) 
% 

%     fig_correlations_staging(tbl, row_vars, col_vars, ...
%                              row_labels, col_labels, 'subset_3', ...
%                              [1 6], [1, 2, 6, 4, 9, 11])
%     fig_correlations_staging(tbl, row_vars, col_vars, ...
%                              row_labels, col_labels, 'subset_3', ...
%                              [1, 2, 3, 4, 5, 6], ...
%                              [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]) 

end

function fig_correlations_staging(tbl, row_vars, col_vars, ...
                                row_labels, col_labels, figure_name, ...
                                idx_row_filt, idx_col_filt)
                            
    row_labels = row_labels(idx_row_filt);
    row_vars = row_vars(idx_row_filt);

    col_labels = col_labels(idx_col_filt);
    col_vars = col_vars(idx_col_filt);

    idx = find(tbl.is_room_temp_aging == 1);
    fig_correlations_helper(tbl(idx, :), row_vars, col_vars, ...
                            row_labels, col_labels, ...
                            sprintf('%s_rt', figure_name));

    idx = find(tbl.is_room_temp_aging == 0);
    fig_correlations_helper(tbl(idx, :), row_vars, col_vars, ...
                            row_labels, col_labels, ...
                            sprintf('%s_ht', figure_name));

    fig_correlations_helper(tbl, row_vars, col_vars, ...
                            row_labels, col_labels, ...
                            sprintf('%s_all', figure_name));
                        
end

function fig_correlations_helper(tbl, row_vars, col_vars, ...
                                row_labels, col_labels, figure_name)


    global BLUE
    global ORANGE

    fh = figure('Position', ...
        [0 0 numel(col_vars)*270 numel(row_vars)*230]);

    plot_counter = 1;

    for i = 1:numel(row_vars)

        xvar = row_vars{i};
        xlab = row_labels{i};

        for j = 1:numel(col_vars)

            yvar = col_vars{j};
            ylab = col_labels{j};

            subplot(numel(row_vars), numel(col_vars), plot_counter)
            box on;
            grid on;

            x = tbl.(xvar);
            y = tbl.(yvar);

            if regexpi(xvar, 'dcr')
                x = x*1000;
            end
            if regexpi(yvar, 'dcr')
                y = y*1000;
            end

            if regexpi(xvar, 'retention')
                x = x*100;
            end
            if regexpi(yvar, 'retention')
                y = y*100;
            end
            if regexpi(xvar, 'var_q')
                x = x*1000;
            end
            if regexpi(yvar, 'var_q')
                y = y*1000;
            end

            for k = 1:numel(x)

                if tbl.is_room_temp_aging(k)
                    color = [0 0 1];
                else
                    color = [1 0 0];
                end

                if tbl.is_baseline_formation(k)
                    color = [0 0 0];
                end


                if tbl.cellid(k) == 35 || tbl.cellid(k) == 37
                    color = ORANGE;
                elseif tbl.cellid(k) == 36 || tbl.cellid(k) == 38
                    color = BLUE;
                end

                line(y(k), x(k), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', color, ...
                    'Color', color, ...
                    'MarkerSize', 7, ...
                    'HandleVisibility', 'off')


            end

            mdl = fitlm(x, y);

            a = mdl.Coefficients.Estimate(2);
            b = mdl.Coefficients.Estimate(1);
            r2 = mdl.Rsquared.Ordinary;

            if r2 > 0.5
                xx = linspace(min(x), max(x), 100);
                yy = a.*xx + b;

                line(yy, xx, 'Color', [0.6, 0.6, 0.6], ...
                    'HandleVisibility', 'off');

            end

            if r2 > 0.5
                font_weight = 'bold';
            else
                font_weight = 'normal';
            end

            title(sprintf('R^2 = %.2f', r2), ...
                'FontSize', 20, ...
                'FontWeight', font_weight)

            if j == 1
                ylabel(xlab)
            end

            if i == numel(row_vars)
                xlabel(ylab)
            end


            plot_counter = plot_counter + 1;

        end

    end

    tightfig();


    print(fh, '-dtiff', '-r300', ...
        sprintf('figures/fig_correlations_%s.tiff', figure_name))
    

end

function fig_esoh_metrics()
    % Plot dV/dQ loss metrics

    plot_summary_esoh_table()

end

function fig_initial_dcr_from_rpt()
    % Plot the figure containing the initial performance metrics from the
    % fresh cell RPT

    path = 'output/correlation_data.csv';

    tbl = readtable(path);

    % Better packaging of variables
    tbl.initial_cell_dcr_50_soc_mohm = tbl.initial_cell_dcr_50_soc.*1000;
    tbl.initial_cell_dcr_0_soc_mohm = tbl.initial_cell_dcr_0_soc.*1000;
    tbl.initial_cell_dcr_100_soc_mohm = tbl.initial_cell_dcr_100_soc.*1000;

    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    labels = {'DCR, 100% SOC (m\Omega)', ...
              'DCR, 50% SOC (m\Omega)', ...
              'DCR, 4% SOC (m\Omega)'};
    varnames = {'initial_cell_dcr_100_soc_mohm', ...
                'initial_cell_dcr_50_soc_mohm', ...
                'initial_cell_dcr_0_soc_mohm'};

    plot_distribution_two_temps(tbl, varnames, labels, 'initial_dcr')

end

function fig_initial_esoh_distributions()
    % Plot the figure containing the initial esoh metrics from the
    % fresh cell RPT

    path = 'output/correlation_data_with_esoh.csv';

    tbl = readtable(path);

    
    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    labels = {'C_n, c3 (Ah)', ...
              'x_{0}, c3', ...
              'x_{100}, c3'};
    varnames = {'Cn_c3', ...
                'x0_c3', ...
                'x100_c3'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_1')


    labels = {'C_p, c3 (Ah)', ...
              'y_{0}, c3', ...
              'y_{100}, c3'};
    varnames = {'Cp_c3', ...
                'y0_c3', ...
                'y100_c3'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_2')
            

    labels = {'n_{Li}, c3 (moles)', ...
              'Positive Excess, c3 (Ah)', ...
              'Negative Excess, c3 (Ah)'};
    varnames = {'n_li_c3', ...
                'pos_excess_c3', ...
                'neg_excess_c3'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_3')


    labels = {'C_n / C_p, c3', ...
              'C_n / C_p, c56', ...
              'Var(Q_{56-3})'};
    varnames = {'np_ratio_c3', ...
                'np_ratio_c56', ...
                'var_q_56_3'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_4')

end

function fig_thickness_distributions()
    % Plot the figure containing the thickness distribution at EOL

    path = 'output/correlation_data_with_esoh.csv';

    tbl = readtable(path);

    tbl = remove_from_table(tbl, 'cellid', 9);

    labels = {'Thickness (mm)', ...
	          '', ...
	          ''};
    
    varnames = {'thickness_mm', ...
	            'thickness_mm', ...
		        'thickness_mm'};

    ylims = {[0 40], [0 40], [0 40]};
    
    plot_distribution_two_temps(tbl, varnames, labels, ...
                        'thickness_distribution', ylims);

    
end


function fig_aging_distributions()
    % Plot the figure containing aging distributions

    path = 'output/correlation_data.csv';

    tbl = readtable(path);

    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    tbl.dcr_100_soc_at_c400_mohms = tbl.dcr_100_soc_at_c400.*1000;
    tbl.dcr_50_soc_at_c400_mohms = tbl.dcr_50_soc_at_c400.*1000;
    tbl.dcr_0_soc_at_c400_mohms = tbl.dcr_0_soc_at_c400.*1000;

    % Begin plotting
    labels = {'DCR, 100% SOC, c400', ...
              'DCR, 50% SOC, c400', ...
              'DCR, 4% SOC, c400'};

    varnames = {'dcr_100_soc_at_c400_mohms', ...
                'dcr_50_soc_at_c400_mohms', ...
                'dcr_0_soc_at_c400_mohms'};

    plot_distribution_two_temps(tbl, varnames, labels, 'dcr_at_c400');


    labels = {'Cycles to 50%', ...
              'Cycles to 80%', ...
              'Swelling Severity (Rank)'};

    varnames = {'cycles_to_50_pct', ...
                'cycles_to_80_pct', ...
                'swelling_severity'};

    plot_distribution_two_temps(tbl, varnames, labels, 'cycles_to_eol_and_swell');

end

function plot_distribution_two_temps(tbl, varnames, labels, fig_title, ylims)

    global ORANGE
    global BLUE
    global GREEN

    if nargin == 4
	    ylims = [];
    end 
	    
    fh = figure('Position', [1 1 850 600].*1.2);

    legend_varname = {'a)', 'b)', 'c)', 'd)', 'e)', 'f)'};

    counter = 0;

    for i = 1:2

        % OVERRIDE COLOR SCHEMA TO MATCH TEMPERATURES
        if i == 1
            BLUE = [0 0 1];
        else
            BLUE = [1 0 0];
        end

        % Loop over variables
        for j = 1:3

            counter = counter + 1;
            curr_var = varnames{j};

            if i == 1
                curr_tbl = tbl(find(tbl.is_room_temp_aging == 1), :);
                color = [0 0 1];
            else
                curr_tbl = tbl(find(tbl.is_room_temp_aging == 0), :);
                color = [1 0 0];
            end

            tbl_base = curr_tbl(find(curr_tbl.is_baseline_formation == 1), :);
            tbl_fast = curr_tbl(find(curr_tbl.is_baseline_formation == 0), :);


            idx_of_interest_1 = find((tbl_fast.cellid == 35) | ...
                               (tbl_fast.cellid == 37) );

            idx_of_interest_2 = find((tbl_fast.cellid == 36) | ...
                                     (tbl_fast.cellid == 38));

            tbl_fast_set_1 = tbl_fast;
            tbl_fast_set_1([idx_of_interest_1 ; idx_of_interest_2], :) = [];
            tbl_fast_set_2 = tbl_fast(idx_of_interest_1, :);
            tbl_fast_set_3 = tbl_fast(idx_of_interest_2, :);


            ax(counter) = subplot(2, 3, counter); box on;

            % Make the boxchart
            b = boxchart(curr_tbl.is_baseline_formation, curr_tbl.(curr_var), ...
                'BoxFaceColor', [0.5 0.5 0.5]);
            box on;
            b.MarkerColor = 'None';
            ylabel(labels{j});
            set(gca, 'XTick', unique(curr_tbl.is_baseline_formation), ...
                     'XTickLabel', {'Fast', 'Baseline'})

            % Add the scatter points

            % Plot without the interesting cells first
            s = line(add_noise(1.*ones(size(tbl_base, 1))), ...
                    tbl_base.(curr_var), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', 'k', ...
                    'LineStyle', 'none', ...
                    'Color', 'k');

            s = line(add_noise(0.*ones(size(tbl_fast_set_1, 1))), ...
                    tbl_fast_set_1.(curr_var), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', BLUE, ...
                    'LineStyle', 'none', ...
                    'Color', BLUE);

            % Add the interesting cells
            s = line(add_noise(0.*ones(size(tbl_fast_set_2, 1))), ...
                    tbl_fast_set_2.(curr_var), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', ORANGE, ...
                    'LineStyle', 'none', ...
                    'Color', ORANGE);

            s = line(add_noise(0.*ones(size(tbl_fast_set_3, 1))), ...
                    tbl_fast_set_3.(curr_var), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', GREEN, ...
                    'LineStyle', 'none', ...
                    'Color', GREEN);

            % Add cells of interest

            xlim([-0.5 1.5])
            if ~isempty(ylims)
                ylim(ylims{j})
            end

            % Get some statistics
            [hypothesis, p_value] = ttest2(tbl_base.(curr_var), tbl_fast.(curr_var));

            % Add the significance value on the plot
            if p_value < 0.05
                significance = p_value;
            else
                significance = nan;
            end

            sigstar({[0, 1]}, significance)

            h = findobj('Tag', 'sigstar');
            set(h, 'DisplayName', '', 'HandleVisiblity', 'off');

            fprintf('%s:\n', curr_var)
            fprintf('  base: %g (%g)\n', mean(tbl_base.(curr_var)), std(tbl_base.(curr_var)))
            fprintf('  fast: %g (%g)\n\n', mean(tbl_fast.(curr_var)), std(tbl_fast.(curr_var)))

%             dummyh = line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
%             lh = legend(dummyh, legend_varname{counter});
%             set(lh, 'Location', 'NorthWest', 'Color', 'None', 'Box', 'off', 'FontSize', 32)
%             pos = get(lh, 'Position');
%             set(lh, 'Position', pos + [-0.1 0.080 0 0])

            if i == 1
                title('Room Temperature', 'FontWeight', 'normal')
            else
                title('45°C', 'FontWeight', 'normal')
            end

        end

    end

    saveas(fh, sprintf('figures/fig_%s.png', fig_title))

end

function fig_formation_performance_distributions()
    % Plot the figure containing initial performance metrics from the
    % formation cycle AND from other parts of the test


    path = 'output/correlation_data.csv';

    tbl = readtable(path);

    % Better packaging of variables
    tbl.form_6hr_rest_voltage_decay_mv = tbl.form_6hr_rest_voltage_decay_v.*1000;
    tbl.form_coulombic_efficiency_pct = tbl.form_coulombic_efficiency.*100;
    tbl.initial_cell_dcr_50_soc_mohm = tbl.initial_cell_dcr_50_soc.*1000;
    tbl.initial_cell_dcr_0_soc_mohm = tbl.initial_cell_dcr_0_soc.*1000;

   
    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);
    
    keyboard

    % Begin plotting
    labels = {'Q_d (Ah)', ...
                     'CE (%)', ...
                     'Q_{CV} (Ah)', ...
                     '\Delta V (mV)'};

    varnames = {'form_final_discharge_capacity_ah', ...
                        'form_coulombic_efficiency_pct', ...
                        'form_first_cv_hold_capacity_ah', ...
                        'form_6hr_rest_voltage_decay_mv'};

    plot_distribution_one_temp(tbl, varnames, labels);


end

function plot_distribution_one_temp(tbl, varnames, labels)

    global ORANGE
    global BLUE
    global GREEN

    fh = figure('Position', [1 1 1200 600].*1.2);

    legend_varname = {'a)', 'b)', 'c)', 'd)', 'e)', 'f)'};

    for i = 1:numel(varnames)

        curr_var = varnames{i};

        tbl_base = tbl(find(tbl.is_baseline_formation == 1), :);
        tbl_fast = tbl(find(tbl.is_baseline_formation == 0), :);

        % Current bump cells
        idx_of_interest_1 = find((tbl_fast.cellid == 35) | ...
                                (tbl_fast.cellid == 37) );

        % Blah cells
        idx_of_interest_2 = find((tbl_fast.cellid == 36) | ...
                                 (tbl_fast.cellid == 38));

        tbl_fast_set_1 = tbl_fast;
        tbl_fast_set_1([idx_of_interest_1 ; idx_of_interest_2], :) = [];
        tbl_fast_set_2 = tbl_fast(idx_of_interest_1, :);
        tbl_fast_set_3 = tbl_fast(idx_of_interest_2, :);

        ax(i) = subplot(2, 3, i);

        % Make the boxchart
        b = boxchart(tbl.is_baseline_formation, tbl.(curr_var), ...
            'BoxFaceColor', [0.5 0.5 0.5]);
        box on;
        b.MarkerColor = 'None';
        ylabel(labels{i});
        set(gca, 'XTick', unique(tbl.is_baseline_formation), ...
                 'XTickLabel', {'Fast', 'Baseline'})

        % Add the scatter points

        % Plot without the interesting cells first
        s = line(add_noise(1.*ones(size(tbl_base, 1))), ...
                tbl_base.(curr_var), ...
                'Marker', 'o', ...
                'MarkerFaceColor', 'k', ...
                'LineStyle', 'none', ...
                'Color', 'k');

        s = line(add_noise(0.*ones(size(tbl_fast_set_1, 1))), ...
                tbl_fast_set_1.(curr_var), ...
                'Marker', 'o', ...
                'MarkerFaceColor', BLUE, ...
                'LineStyle', 'none', ...
                'Color', BLUE);

        % Add the interesting cells
        s = line(add_noise(0.*ones(size(tbl_fast_set_2, 1))), ...
                tbl_fast_set_2.(curr_var), ...
                'Marker', 'o', ...
                'MarkerFaceColor', ORANGE, ...
                'LineStyle', 'none', ...
                'Color', ORANGE);

        s = line(add_noise(0.*ones(size(tbl_fast_set_3, 1))), ...
                tbl_fast_set_3.(curr_var), ...
                'Marker', 'o', ...
                'MarkerFaceColor', GREEN, ...
                'LineStyle', 'none', ...
                'Color', GREEN);

        xlim([-0.5 1.5])


        % Get some statistics
        [hypothesis, p_value] = ttest2(tbl_base.(curr_var), tbl_fast.(curr_var));

        % Add the significance value on the plot
        if p_value < 0.05
            significance = p_value;
        else
            significance = nan;
        end

        sigstar({[0, 1]}, significance)

        h = findobj('Tag', 'sigstar');
        set(h, 'DisplayName', '', 'HandleVisiblity', 'off');

        fprintf('%s:\n', curr_var)
        fprintf('  base: %g (%g)\n', mean(tbl_base.(curr_var)), std(tbl_base.(curr_var)))
        fprintf('  fast: %g (%g)\n\n', mean(tbl_fast.(curr_var)), std(tbl_fast.(curr_var)))

        dummyh = line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
        lh = legend(dummyh, legend_varname{i});
        set(lh, 'Location', 'NorthWest', 'Color', 'None', 'Box', 'off', 'FontSize', 32)
        pos = get(lh, 'Position');
        set(lh, 'Position', pos + [-0.05 0.080 0 0])


    end

    tightfig();

end


function fig_formation_protocol()

    fig_title = 'formation_protocol';
    
    global BLUE
    
    path = 'data/2020-06-microformation-timeseries';

    file_base = fullfile(path, 'UM_Internal_0620_-_Form_-_1.001.csv');
    file_fast = fullfile(path, 'UM_Internal_0620_-_MicroForm_-_21.022.csv');

    tbl_base = readtable(file_base);
    tbl_fast = readtable(file_fast);

    tbl_base = remove_from_table(tbl_base, 'StepIndex', 1);
    tbl_fast = remove_from_table(tbl_fast, 'StepIndex', 1);

    time_base = (tbl_base.TestTime_s_ - min(tbl_base.TestTime_s_)) ./3600;
    time_fast = (tbl_fast.TestTime_s_ - min(tbl_fast.TestTime_s_)) ./3600;

    
    fh = figure('Position', [1 1 900 200].*2);
    
    % Fast Formation
    ax1 = subplot(121);
    ylim([2.95 4.25])
    box on;
    title('Fast Formation Protocol');
    ylabel('Potential (V)')
    
    line(time_fast, tbl_fast.Potential_V_, ...
        'LineWidth', 2', 'LineStyle', '-', ...
        'DisplayName', 'Fast Formation',...
        'Color', 'k', 'Parent', ax1)

    idx = find(tbl_fast.CycleNumber == 6);
    
    line(time_fast(idx), tbl_fast.Potential_V_(idx), ...
        'LineWidth', 4, 'LineStyle', '-', ...
        'HandleVisibility', 'off', ...
        'Color', BLUE, 'Parent', ax1)
    
    yyaxis right;
    ax2 = gca;
    ylabel('Current (A)')
    ax2.YColor = [0.4 0.4 0.4];

    line(time_fast, tbl_fast.Current_A_, ...
        'LineWidth', 2, 'LineStyle', ':', ...
        'Color', [0.4 0.4 0.4], 'Parent', ax2)


    % Baseline formation
    ax3 = subplot(122);
    ylim([2.95 4.25])
    box on;
    
    title('Baseline Formation Protocol');
    ylabel('Potential (V)')
    xlabel('Time (hours)')

    line(time_base, tbl_base.Potential_V_, ...
        'LineWidth', 2, 'LineStyle', '-', ...
        'DisplayName', 'Baseline Formation', ...
        'Color', 'k', 'Parent', ax3)


    % Highlight the diagnostic cycles
    idx = find(tbl_base.CycleNumber == 2 & ...
               tbl_base.StepIndex == 12);
    
    line(time_base(idx), tbl_base.Potential_V_(idx), ...
        'LineWidth', 4, 'LineStyle', '-', ...
        'HandleVisibility', 'off', ...
        'Color', BLUE, 'Parent', ax3)
    
    yyaxis right;
    ax4 = gca;
    ax4.YColor = [0.4 0.4 0.4];
    ylabel('Current (A)')

    line(time_base, tbl_base.Current_A_, ...
        'LineWidth', 2, 'LineStyle', ':', ...
        'Color', [0.4 0.4 0.4], 'Parent', ax4)
    
    xlim(ax3, [-1 65])
    linkaxes([ax3, ax4, ax1, ax2], 'x')
    ylim(ax2, [-3 3])
    ylim(ax4, [-3 3])
    xlabel('Time (hours)')

    tightfig()

    print(fh, '-dtiff', '-r300', sprintf('figures/fig_%s.tiff', fig_title))
    
end

function fig_aging_variable(type)
    % Given a plot type, make a standard view of (metric) vs cycle number,
    % where (metric) is something available from the raw cycling data
    % sheets.
    %
    % Args:
    %  type: see config below for valid inputs
    
    % Configure the settings
    switch type
        case 'average_voltage'
            config.variable_name = 'MeanDischargePotential_capacity_weighted__V_';
            config.ylim = [3.6 3.7];
            config.ylabel = 'Average Voltage (V)';
        case 'voltage_efficiency'
            config.variable_name = 'VoltageEfficiency';
            config.ylim = [0.85 1.01];
            config.ylabel = 'Voltage Efficiency';
        case 'coulombic_efficiency'
            config.variable_name = 'CoulombicEfficiency';
            config.ylim = [0.96, 1.01];
            config.ylabel = 'Coulombic Efficiency';
        case 'discharge_capacity'
            config.variable_name = 'DischargeCapacity_Ah_';
            config.ylim = [0 2.5];
            config.ylabel = 'Discharge Capacity (Ah)';
        case 'discharge_energy'
            config.variable_name = 'DischargeEnergy_Wh_';
            config.ylim = [0 9];
            config.ylabel = 'Discharge Energy (Wh)';
    end

    path = pwd;
    directory = 'data/2020-10-aging-test-cycles';

    full_path = fullfile(path, directory);

    files = find_files(full_path, 'UM_Internal');

    ref_table = readtable(fullfile(path, 'documents/cell_tracker.xlsx'));

    fh = figure();

    ax1 = subplot(211); grid on; box on;
    xlabel('Cycle Number')
    ylabel(config.ylabel)
    title('Room Temperature Cycling')

    ax2 = subplot(212); grid on; box on;
    xlabel('Cycle Number');
    ylabel(config.ylabel)
    title('High Temperature Cycling (45°C)')


    for i = 1:numel(files)

        file = files{i};

        [cycle_index, y_var] = fetch_cycling_data(file, config.variable_name);

        info = get_cell_info(file, ref_table);

        % Skip cell 9 which had a build lissue
        if info.cell_number == 9
            continue
        end

        % Baseline formation
        if strcmpi(info.formation_protocol, 'baseline')
            color = 'k';
            linestyle = ':';
        % Fast formation
        else
            color = info.color;
            linestyle = '-';
        end

        % Room temperature
        if strcmpi(info.aging_test, 'rt')
            parent = ax1;
        % High temperature
        else
            parent = ax2;
        end

        if info.cell_number == 35
            color = info.color; % pass
        end

        line(cycle_index, y_var, ...
                'Color', color, ...
                'Parent', parent, ...
                'LineWidth', 2.0, ...
                'LineStyle', linestyle)

    end

    linkaxes([ax1, ax2], 'xy');
    ylim(ax1, config.ylim)

    tightfig()

end


function info = get_cell_info(file, ref_table)

    [~, filename, ~] = fileparts(file);

    filename = strsplit(filename, '.');
    filename = filename{1};

    parts = strsplit(filename, '_');

    cellid = str2double(parts{end});

    info = table2struct(ref_table(find(ref_table.cell_number == cellid), :));

    if strcmpi(info.aging_test, 'rt')
        info.color = 'b';
    else
        info.color = 'r';
    end

end

function [cycle_index, y_var] = fetch_cycling_data(file, variable_name)

    tbl = readtable(file);
    
    cycle_index = tbl.CycleNumber;
    
    y_var = tbl.(variable_name);
    % Use some filtering to identify and exclude the cycle numbers
    % corresponding to the RPT (either from the C/20 or C/3
    % charge/discharge cycles, or from the HPPC pulse cycles. Here we use
    % total charge time to define when an RPT is happening or not.
    idx_to_filter = find((tbl.TotalChargeTime_s_ > 8500) | ...
                         (tbl.TotalChargeTime_s_ < 100));


    cycle_index(idx_to_filter) = nan;
    y_var(idx_to_filter) = nan;
   
    % Remove last cycle which is not guaranteed to be a full cycle
    cycle_index(end) = [];
    y_var(end) = [];

end


function tbl = remove_from_table(tbl, varname, target_val)
    % Return a table that excludes rows with values matching target value
    % for a given variable name

    idx = find(tbl.(varname) == target_val);
    tbl(idx, :) = [];

end



function output = add_noise(input)

    output = input + (rand(size(input, 1), 1) - 0.5) * 0.2;

end

