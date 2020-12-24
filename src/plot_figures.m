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
%   fig_aging_test_result()
%   fig_formation_performance_distributions()
%   fig_aging_distributions()
  fig_initial_dcr_from_rpt()
%   fig_aging_diagnostics()
%     fig_correlations()
    
end

function fig_correlations()
    % Plot the correlations

   
    path = 'output/correlation_data.csv';
    
    tbl = readtable(path);

    % Exclude extreme outlier from this analysis
    idx = find(tbl.cellid == 9);
    tbl(idx, :) = [];

    row_vars = {'retention_at_c400', ...
                'dcr_0_soc_at_c400', ...
                'dcr_50_soc_at_c400', ...
                'dcr_100_soc_at_c400', ...
                'swelling_severity'};

    row_labels = {{'Retention', '400 cycles (%)'}, ...
                  {'DCR, 0% SOC', '400 cycles (m\Omega)'}, ...
                  {'DCR, 50% SOC' '400 cycles (m\Omega)'}, ...
                  {'DCR, 100% SOC' '400 cycles(m\Omega)'}, ...
                  {'Swelling', 'severity'}};
              
    col_vars = {'form_first_cv_hold_capacity_ah', ...
            'form_6hr_rest_voltage_decay_v', ...
            'form_final_discharge_capacity_ah', ...
            'initial_cell_dcr_0_soc', ...
            'initial_cell_dcr_50_soc', ...
            'initial_cell_dcr_100_soc'};
    
    col_labels = {{'Q_{CV}', 'formation (Ah)'}, ...
                  {'\Delta V_{rest}', 'formation (V)'}, ...
                  {'Q_d', 'formation (Ah)'}, ...
                  {'DCR, 0% SOC', 'fresh (m\Omega)'}, ...
                  {'DCR, 50% SOC', 'fresh (m\Omega)'}, ...
                  {'DCR, 100% SOC', 'fresh (m\Omega)'}};
              
    idx_row_filt = [1, 5];
    row_labels = row_labels(idx_row_filt);
    row_vars = row_vars(idx_row_filt);
    
    idx = find(tbl.is_room_temp_aging == 1);
    fig_correlations_helper(tbl(idx, :), row_vars, col_vars, ...
                            row_labels, col_labels, 'subset_low_temp')

    idx = find(tbl.is_room_temp_aging == 0);
    fig_correlations_helper(tbl(idx, :), row_vars, col_vars, ...
        row_labels, col_labels, 'subset_high_temp')

    fig_correlations_helper(tbl, row_vars, col_vars, ...
        row_labels, col_labels, 'subset_all')
    
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
    
    saveas(fh, sprintf('figures/fig_correlations_%s.png', figure_name))
    
end

function fig_aging_diagnostics()
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
              'DCR, 0% SOC (m\Omega)'};
    varnames = {'initial_cell_dcr_100_soc_mohm', ...
                'initial_cell_dcr_50_soc_mohm', ...
                'initial_cell_dcr_0_soc_mohm'};
                        
    plot_distribution_two_temps(tbl, varnames, labels)

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
              'DCR, 0% SOC, c400'};
    
    varnames = {'dcr_100_soc_at_c400_mohms', ...
                'dcr_50_soc_at_c400_mohms', ...
                'dcr_0_soc_at_c400_mohms'};
                        
    plot_distribution_two_temps(tbl, varnames, labels);
    
    
    labels = {'Cycles to 50%', ...
              'Cycles to 80%', ...
              'Swelling Severity (Rank)'};
    
    varnames = {'cycles_to_50_pct', ...
                'cycles_to_80_pct', ...
                'swelling_severity'};
    
    plot_distribution_two_temps(tbl, varnames, labels);

end

function plot_distribution_two_temps(tbl, varnames, labels)

    global ORANGE
    global BLUE
    global GREEN    

    fh = figure('Position', [1 1 1200 600].*1.2);

    legend_varname = {'a)', 'b)', 'c)', 'd)', 'e)', 'f)'};
    
    counter = 0;
    
    for i = 1:2
        
        % OVERRIDE COLOR SCHEMA TO MATCH TEMPERATURES
        if i == 1
            BLUE = [0 0 1];
        else
            BLUE = [1 0 0];
        end
        
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
            lh = legend(dummyh, legend_varname{counter});
            set(lh, 'Location', 'NorthWest', 'Color', 'None', 'Box', 'off', 'FontSize', 32)
            pos = get(lh, 'Position');
            set(lh, 'Position', pos + [-0.1 0.080 0 0])
            
            if i == 1
                title('Room Temperature', 'FontWeight', 'normal')
            else
                title('45°C', 'FontWeight', 'normal')
            end
                    
        end
    
    end
        
    tightfig();
    saveas(fh, 'figures/fig_initial_performance_comparison_rpt.png')

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

    path = 'data/2020-06-microformation-timeseries';
    
    file_1 = fullfile(path, 'UM_Internal_0620_-_Form_-_1.001.csv');
    file_2 = fullfile(path, 'UM_Internal_0620_-_MicroForm_-_21.022.csv');
    
    tbl_1 = readtable(file_1);
    tbl_2 = readtable(file_2);
    
    tbl_1 = remove_from_table(tbl_1, 'StepIndex', 1);
    tbl_2 = remove_from_table(tbl_2, 'StepIndex', 1);
    
    time_1 = (tbl_1.TestTime_s_ - min(tbl_1.TestTime_s_)) ./3600;
    time_2 = (tbl_2.TestTime_s_ - min(tbl_2.TestTime_s_)) ./3600;

    fh = figure('Position', [1 1 900 200].*2);
    
    ax1 = subplot(122); 
    ylim([2.95 4.25])
    box on; 
    title('Baseline Formation Protocol'); 
    ylabel('Potential (V)')
    xlabel('Time (hours)')

    line(time_1, tbl_1.Potential_V_, ...
        'LineWidth', 2, 'LineStyle', '-', ...
        'DisplayName', 'Baseline Formation', ...
        'Color', 'k', 'Parent', ax1)

    yyaxis right; 
    ax2 = gca; 
    ax2.YColor = [0.4 0.4 0.4];
    ylabel('Current (A)')

    line(time_1, tbl_1.Current_A_, ...
        'LineWidth', 2, 'LineStyle', ':', ...
        'Color', [0.4 0.4 0.4], 'Parent', ax2)
    
    ax3 = subplot(121);
    ylim([2.95 4.25])
    box on; 
    title('Fast Formation Protocol'); 
    ylabel('Potential (V)')

    line(time_2, tbl_2.Potential_V_, ...
        'LineWidth', 2', 'LineStyle', '-', ...
        'DisplayName', 'Fast Formation',...
        'Color', 'k', 'Parent', ax3)
    
   
    yyaxis right; 
    ax4 = gca; 
    ylabel('Current (A)')
    ax4.YColor = [0.4 0.4 0.4];
    
    line(time_2, tbl_2.Current_A_, ...
        'LineWidth', 2, 'LineStyle', ':', ...
        'Color', [0.4 0.4 0.4], 'Parent', ax4)
    
    
    xlim(ax1, [-1 65])
    linkaxes([ax1, ax2, ax3, ax4], 'x')
    ylim(ax4, [-3 3])
    ylim(ax2, [-3 3])
    xlabel('Time (hours)')
    
    tightfig()

end

function fig_aging_test_result()
    % Quick and dirty plotter for the cycling results. No time to write
    % nice data structures. Just load all of the data in and plot it
    % together.
    
    path = pwd;
    directory = 'data/2020-10-aging-test-cycles';
   
    full_path = fullfile(path, directory);
   
    files = find_files(full_path, 'UM_Internal');
    
    ref_table = readtable(fullfile(path, 'documents/cell_tracker.xlsx'));
      
    fh = figure();
    
    ax1 = subplot(211); grid on; box on;
    xlabel('Cycle Number')
    ylabel('Discharge Capacity (Ah)')
    title('Room Temperature Cycling')
    
    ax2 = subplot(212); grid on; box on;
    xlabel('Cycle Number');
    ylabel('Discharge Capacity (Ah)')
    title('High Temperature Cycling (45°C)')
    
    
    for i = 1:numel(files)
              
        file = files{i};
        
        [cycle_index, discharge_capacity] = get_capacity_data_from_file(file);
        
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
        
        line(cycle_index, discharge_capacity, ...
                'Color', color, ...
                'Parent', parent, ...
                'LineWidth', 2.0, ...
                'LineStyle', linestyle)
                     
    end
    
    linkaxes([ax1, ax2], 'xy');
    ylim(ax1, [0 2.5])
    
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

function [cycle_index, discharge_capacity] = get_capacity_data_from_file(file)


    tbl = readtable(file);
    cycle_index = tbl.CycleNumber;
    discharge_capacity = tbl.DischargeCapacity_Ah_;
    
    % Use some filtering to identify and exclude the cycle numbers
    % corresponding to the RPT (either from the C/20 or C/3
    % charge/discharge cycles, or from the HPPC pulse cycles. Here we use
    % total charge time to define when an RPT is happening or not. 
    idx_to_filter = find((tbl.TotalChargeTime_s_ > 8500) | ...
                         (tbl.TotalChargeTime_s_ < 100));
    
    
    cycle_index(idx_to_filter) = nan;
    discharge_capacity(idx_to_filter) = nan;
    
    % Remove last cycle which is not guaranteed to be a full cycle
    cycle_index(end) = [];
    discharge_capacity(end) = [];
    

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
                 
