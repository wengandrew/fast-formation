function plot_figures()
    % Generate figures for manuscript

    global BLUE
    global ORANGE
    global GREEN
    global RED
    global PATH_CORRELATION_FILE
    
    ORANGE = [1 0.5 0];
    BLUE = [44 121 245]./255;
    GREEN = [0 0.75 0];

    PATH_CORRELATION_FILE = 'output/2021-03-fast-formation-esoh-fits/correlation_data.csv';

    
    set_default_plot_settings_manuscript()

%    fig_formation_protocol()

%    fig_aging_variable('average_voltage')
%    fig_aging_variable('voltage_efficiency')
   fig_aging_variable('discharge_energy')
%    fig_aging_variable('discharge_capacity')
%    fig_aging_variable('coulombic_efficiency')


%    fig_formation_performance_distributions()
%    fig_aging_distributions()
%    fig_initial_dcr_from_rpt()
%    fig_initial_esoh_distributions()
%    fig_thickness_distributions()
%    fig_esoh_metrics()
   fig_correlations()
%    fig_dvdq_comparison()
%    fig_temperature()

end

function fig_temperature()
    % Plot the temperatures during the test
    
    %% Load the datasets
    
    tbl_ht = readtable('data/2020-10-aging-temperature-timeseries/45C_Chamber_Temperature_Monitor_-_Anna.043.csv');
    tbl_rt = readtable('data/2020-10-aging-temperature-timeseries/Room_Temperature_Monitor_-_Anna.042.csv');
    
    % Timeseries
    fh = figure();
    
    subplot(211)
    xlabel('Time (days)')
    ylabel('Temperature (°C)')
    title('45°C Oven')
    line(tbl_ht.TestTime_s_./3600./24, tbl_ht.AuxiliaryTemperature__C_0__C_, ...
        'Color', 'r', 'LineWidth', 2);
    ylim([42 48])
    legend(sprintf('mean = %.1f°C, std = %.1f°C', ...
        mean(tbl_ht.AuxiliaryTemperature__C_0__C_(1:end-1)), ...
        std(tbl_ht.AuxiliaryTemperature__C_0__C_(1:end-1))));
    grid on; box on;
    
    subplot(212)
    xlabel('Time (days)')
    ylabel('Temperature (°C)')
    title('Room Temperature Monitor')    
    ylim([22 28])
    grid on; box on;
    line(tbl_rt.TestTime_s_./3600./24, tbl_rt.AuxiliaryTemperature__C_0__C_, ...
        'Color', 'b', 'LineWidth', 2);
    legend(sprintf('mean = %.1f°C, std = %.1f°C', ...
        mean(tbl_rt.AuxiliaryTemperature__C_0__C_), ...
        std(tbl_rt.AuxiliaryTemperature__C_0__C_)));
    
    % Histogram
    fh = figure();
    
    subplot(121)
    [n, x] = hist(tbl_ht.AuxiliaryTemperature__C_0__C_(1:end-1), 40);
    y = n./(sum(n.*(diff(x(1:2)))));
    line(x, y, 'Color', 'r', 'LineWidth', 2);
    xlabel('Temperature (°C)')
    ylabel('Probability')
    title('45°C Oven')
    xlim([42 48])
    
    subplot(122)
    [n, x] = hist(tbl_rt.AuxiliaryTemperature__C_0__C_, 40);
    y = n./(sum(n.*(diff(x(1:2)))));
    line(x, y, 'Color', 'b', 'LineWidth', 2);
    xlabel('Temperature (°C)')
    ylabel('Probability')
    title('Room Temperature Monitor')
    xlim([22 28])
    
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
    % TODO: deprecate this function in favor of the Python equivalent
    % Plot the correlations

    path = 'output/2021-03-fast-formation-esoh-fits/correlation_data.csv';

    tbl = readtable(path);

    % Exclude extreme outlier from this analysis
    idx = find(tbl.cellid == 9);
    tbl(idx, :) = [];

    % Remove obvious outlier due to numerical issue
    idx = find(tbl.esoh_c3_Cn > 3);
    tbl.esoh_c3_Cn(idx) = nan;
    tbl.esoh_c3_CnCp(idx) = nan;
    
    idx = find(tbl.esoh_c56_Cn > 3);
    tbl.esoh_c56_Cn(idx) = nan;
    
    idx = find(tbl.esoh_c159_Cn > 3);
    tbl.esoh_c159_Cn(idx) = nan;
    
    idx = find(tbl.esoh_c262_Cn > 3);
    tbl.esoh_c262_Cn(idx) = nan;
    
    idx = find(tbl.esoh_c365_Cn > 3);
    tbl.esoh_c365_Cn(idx) = nan;
    
%     idx = find(tbl.form_6hr_rest_mv_per_day_steady < -35);
%     tbl.form_6hr_rest_mv_per_day_steady(idx) = nan;

%     fig_correlations_staging(tbl, {'retent
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'form_final_discharge_capacity_ah', ...
%                                   'form_6hr_rest_delta_voltage_v', ...
%                                   'form_c20_charge_right_peak_v_per_ah', ...
%                                   'form_c20_charge_qpp_ah', ...
%                                   'dcr_10s_5_soc_at_c3', ...
%                                   'dcr_10s_90_soc_at_c3', ...
%                                   'esoh_c3_Cn', ...
%                                   'var_q_56_3'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'Form Q_d (Ah)'}, ...
%                                    {'Form \Delta V'}, ...
%                                    {'Form q_2 height'}, ...
%                                    {'Form q_{pp} (Ah)'}, ...
%                                    {'R_{10s, 5% SOC} (m\Omega)'}, ...
%                                    {'R_{10s, 90% SOC} (m\Omega)'}, ...
%                                    {'C_n (Ah)'}, ...
%                                    {'VarQ_{56-3}'}}, ...
%                                    'main_correlations');

% 


%     fig_correlations_staging(tbl, {'thickness_mm'}, ...
%                                   {'dcr_10s_5_soc_at_c3'}, ...
%                                   {{'Thickness'}}, ...
%                                   {{'R_{10s, 90%SOC}, c3'}}, ...
%                                    'gas_gen'
%                                
%                                

    fig_correlations_staging(tbl, {'cycles_to_50_pct', ...
                                   'cycles_to_60_pct', ...
                                   'cycles_to_70_pct', ...
                                   'cycles_to_80_pct'}, ...
                                  {'form_final_discharge_capacity_ah', ...
                                   'form_qc_minus_qd_ah', ...
                                   'form_coulombic_efficiency', ...
                                   'dcr_10s_5_soc_at_c3', ...
                                   'dcr_10s_90_soc_at_c3'}, ...
                                  {{'Cycles to 50%'}, ...
                                   {'Cycles to 60%'}, ...
                                   {'Cycles to 70%'}, ...
                                   {'Cycles to 80%'}}, ...
                                  {{'Q_d (Ah)'}, ...
                                   {'CE_f'}, ...
                                   {'Q_c - Q_d (Ah)'}, ...
                                   {'R_{10s, 5% SOC} (m\Omega)'}, ...
                                   {'R_{10s, 90% SOC} (m\Omega)'}}, ...
                                   'initial_corr');
%                                
%                                
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'esoh_c3_CnCp', ...
%                                    'esoh_c56_CnCp', ...
%                                    'esoh_c159_CnCp', ...
%                                    'esoh_c262_CnCp', ...
%                                    'esoh_c365_CnCp'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'C_n/C_p, c3 (Ah)'}, ...
%                                    {'C_n/C_p, c56 (Ah)'}, ...
%                                    {'C_n/C_p, c159 (Ah)'}, ...
%                                    {'C_n/C_p, c262 (Ah)'}, ...
%                                    {'C_n/C_p, c365 (Ah)'}}, ...
%                                    'Cn_correlation_over_time');   
%     
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'esoh_c3_Cn', ...
%                                    'esoh_c56_Cn', ...
%                                    'esoh_c159_Cn', ...
%                                    'esoh_c262_Cn', ...
%                                    'esoh_c365_Cn'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'C_n, c3 (Ah)'}, ...
%                                    {'C_n, c56 (Ah)'}, ...
%                                    {'C_n, c159 (Ah)'}, ...
%                                    {'C_n, c262 (Ah)'}, ...
%                                    {'C_n, c365 (Ah)'}}, ...
%                                    'Cn_correlation_over_time');
%                                
%                                
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'var_q_c56_c3', ...
%                                    'var_q_c159_c3', ...
%                                    'var_q_c262_c3', ...
%                                    'var_q_c365_c3'}, ...
%                                    {{'Cycles to 70%'}}, ...
%                                    {{'VarQ c56-c3'}, ...
%                                     {'VarQ c159-c3'}, ...
%                                     {'VarQ c262-c3'}, ...
%                                     {'VarQ c365-c3'}}, ...
%                                     'VarQ_correlation_over_time');
%                                
% 
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'dcr_10s_5_soc_at_c3', ...
%                                   'dcr_10s_5_soc_at_c50', ...
%                                   'dcr_10s_5_soc_at_c150', ...
%                                   'dcr_10s_5_soc_at_c250', ...
%                                   'dcr_10s_5_soc_at_c350'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'R_{10s, 5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{10s, 5% SOC}, c50 (m\Omega)'}, ...
%                                    {'R_{10s, 5% SOC}, c150 (m\Omega)'}, ...
%                                    {'R_{10s, 5% SOC}, c250 (m\Omega)'}, ...
%                                    {'R_{10s, 5% SOC}, c350 (m\Omega)'}}, ...
%                                    'resistance_correlation_over_time');
%                              
%                                  
%                                  
% %     
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'form_first_discharge_capacity_below_3p2v_ah', ...
%                                   'form_first_discharge_rest_voltage_rebound_1s', ...
%                                   'form_first_discharge_rest_voltage_rebound_10s', ...
%                                   'form_last_charge_voltage_after_1s', ...
%                                   'form_last_charge_voltage_after_10s', ...
%                                   'form_last_charge_voltage_after_60s'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'Form Q_d < 3.2V'}, ...
%                                    {'Form Disch.', 'Rest V, 1s'}, ...
%                                    {'Form Disch.', 'Rest V, 10s'}, ...
%                                    {'Form Last Chg.', '1s Voltage'}, ...
%                                    {'Form Last Chg.', '10s Voltage'}, ...
%                                    {'Form Last Chg.', '60s Voltage'}}, ...
%                                    'formation_discharge_correlation_to_life');
% %                                
%     fig_correlations_staging(tbl, {'cycles_to_70_pct'}, ...
%                                   {'form_c20_charge_qpp_ah', ...
%                                   'form_c20_charge_right_peak_v_per_ah'}, ...
%                                   {{'Cycles to 70%'}}, ...
%                                   {{'Form Q_{pp} (Ah)'}, ...
%                                    {'Form Q_{p2}, height'}}, ...
%                                    'formation_c20_charge_qpp_correlation_to_life');
                               
%     fig_correlations_staging(tbl, {'retention_at_c400'}, ...
%                                   {'form_6hr_rest_delta_voltage_v', ...
%                                    'form_6hr_rest_voltage_v', ...
%                                    'form_6hr_rest_mv_per_day_steady', ...
%                                    'form_6hr_rest_mv_per_sec_initial'}, ...
%                                   {{'Retention', '400 cycles (%)'}}, ...
%                                   {{'\Delta V_{6hr} (V)'}, ...
%                                    {'V_{6hr}'}, ...
%                                    {'mV / day, final'}, ...
%                                    {'mV / sec, initial'}}, ...
%                                   'delta_v_correlation_to_life')
%                               % 
%     fig_correlations_staging(tbl, {'retention_at_c400'}, ...
%                                   {'esoh_c3_Cn', ...
%                                    'esoh_c3_Cn_pf', ...
%                                    'esoh_c3_x100', ...
%                                    'esoh_c3_x100_pf'}, ...
%                                   {{'Retention', '400 cycles (%)'}}, ...
%                                   {{'C_n, c3 (Ah)'}, ...
%                                    {'C_{n,PF}, c3 (Ah)'}, ...
%                                    {'x_{100}, c3'}, ...
%                                    {'x_{100,PF}, c3'}}, ...
%                                   'c_n_correlation_to_life')
% 
%     fig_correlations_staging(tbl, {'esoh_c3_Cn', 'esoh_c3_x100'}, ...
%                                   {'esoh_c3_Cn_pf', 'esoh_c3_x100_pf'}, ...
%                                   {{'C_n, c3 (Ah)'}, ...
%                                    {'x_{100,PF}, c3'}}, ...
%                                   {{'C_{n,PF}, c3 (Ah)'}, ...
%                                    {'x_{100,PF}, c3'}}, ...
%                                   'voltagefit_vs_peakfind')
%   
%     fig_correlations_staging(tbl, {'esoh_c3_Cn'}, ...
%                                   {'esoh_c3_y0'}, ...
%                                   {{'C_n, c3 (Ah)'}}, ...
%                                   {{'y_0, c3'}}, ...
%                                   'cn_versus_y0')

%     fig_correlations_staging(tbl, {'form_6hr_rest_delta_voltage_v', ...
%                                    'form_6hr_rest_voltage_v', ...
%                                    'form_6hr_rest_mv_per_day_steady', ...
%                                    'form_6hr_rest_mv_per_sec_initial'}, ...
%                                   {'dcr_1s_5_soc_at_c3', ...
%                                    'dcr_10s_5_soc_at_c3', ...
%                                    'dcr_1s_90_soc_at_c3', ...
%                                    'dcr_10s_90_soc_at_c3'}, ...
%                                   {{'\Delta V_{6hr} (V)'}, ...
%                                    {'V_{6hr}'}, ...
%                                    {'mV / day, final'}, ...
%                                    {'mV / day, initial'}}, ...
%                                   {{'R_{1s,5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{10s,5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{1s,90% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{10s,90% SOC}, c3 (m\Omega)'}}, ...
%                                   'voltage_drop_versus_dcr')
%
%
%     fig_correlations_staging(tbl, {'esoh_c3_Cn', 'esoh_c3_x100'}, ...
%                                   {'esoh_c3_Cn_pf', 'esoh_c3_x100_pf'}, ...
%                                   {{'C_n, c3 (Ah)'}, ...
%                                    {'x_{100}, c3'}}, ...
%                                   {{'C_{n,PF}, c3 (Ah)'}, ...
%                                    {'x_{100,PF}, c3'}}, ...
%                                   'voltagefit_vs_peakfind')
%                               
%     fig_correlations_staging(tbl, {'retention_at_c400'}, ...
%                                   {'dcr_10s_5_soc_at_c3', ...
%                                    'dcr_3s_5_soc_at_c3', ...
%                                    'dcr_1s_5_soc_at_c3', ...
%                                    'dcr_10s_90_soc_at_c3', ...
%                                    'dcr_3s_90_soc_at_c3', ...
%                                    'dcr_1s_90_soc_at_c3'}, ...
%                                   {{'Retention', '400 cycles '}}, ...
%                                   {{'R_{10s,5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{3s,5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{1s,5% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{10s,90% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{3s,90% SOC}, c3 (m\Omega)'}, ...
%                                    {'R_{1s,90% SOC}, c3 (m\Omega)'}}, ...
%                                   'resistance_predictions')
% 
%     fig_correlations_staging(tbl, {'form_6hr_rest_voltage_decay_v'}, ...
%                                   {'form_6hr_rest_final_voltage'}, ...
%                                   {{'\Delta V_{6hr} (V)'}}, ...
%                                   {{'V_{6hr}'}}, ...
%                                   'delta_v_comparison')
%                               
%     fig_correlations_staging(tbl, {'retention_at_c300', ...
%                                    'retention_at_c400', ...
%                                    'retention_at_c450'}, ...
%                                   {'form_6hr_rest_voltage_decay_v', ...
%                                    'dcr_10s_5_soc_at_c3', ...
%                                    'esoh_c3_Cn'}, ...
%                                   {{'Retention', '300 cycles (%)'}, ...
%                                    {'Retention', '400 cycles (%)'}, ...
%                                    {'Retention', '450 cycles (%)'}}, ...
%                                   {{'\Delta V_{6hr}'}, ...
%                                    {'R_{10s, 5% SOC}, c3 (m\Omega)'}, ...
%                                    {'C_n, c3 (Ah)'}}, ...
%                                   'correlations_retention_sensitivity_to_knee')
%  
%     fig_correlations_staging(tbl, {'dcr_10s_5_soc_at_c300', ...
%                                    'dcr_10s_5_soc_at_c400', ...
%                                    'dcr_10s_5_soc_at_c450'}, ...
%                                   {'form_6hr_rest_voltage_decay_v', ...
%                                    'dcr_10s_5_soc_at_c3', ...
%                                    'esoh_c3_Cn'}, ...
%                                   {{'R_{10s, 5% SOC}', '300 cycles (%)'}, ...
%                                    {'R_{10s, 5% SOC}', '400 cycles (%)'}, ...
%                                    {'R_{10s, 5% SOC}', '450 cycles (%)'}}, ...
%                                   {{'\Delta V_{6hr}'}, ...
%                                    {'R_{10s, 5% SOC}, c3 (m\Omega)'}, ...
%                                    {'C_n, c3 (Ah)'}}, ...
%                                   'correlations_dcr_5soc_sensitivity_to_knee')
%                               
%     fig_correlations_staging(tbl, {'dcr_10s_90_soc_at_c300', ...
%                                    'dcr_10s_90_soc_at_c400', ...
%                                    'dcr_10s_90_soc_at_c450'}, ...
%                                   {'form_6hr_rest_voltage_decay_v', ...
%                                    'dcr_10s_5_soc_at_c3', ...
%                                    'esoh_c3_Cn'}, ...
%                                   {{'R_{10s, 90% SOC}', '300 cycles (%)'}, ...
%                                    {'R_{10s, 90% SOC}', '400 cycles (%)'}, ...
%                                    {'R_{10s, 90% SOC}', '450 cycles (%)'}}, ...
%                                   {{'\Delta V_{6hr}'}, ...
%                                    {'R_{10s, 5% SOC}, c3 (m\Omega)'}, ...
%                                    {'C_n, c3 (Ah)'}}, ...
%                                   'correlations_dcr_90soc_sensitivity_to_knee')
                              
end

function fig_correlations_staging(tbl, row_vars, col_vars, ...
                                row_labels, col_labels, figure_name)
                            
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


    to_make_detailed_plot = false;
    
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

% 
%                 if tbl.cellid(k) == 35 || tbl.cellid(k) == 37
%                     color = ORANGE;
%                 elseif tbl.cellid(k) == 36 || tbl.cellid(k) == 38
%                     color = BLUE;
%                 end

                line(y(k), x(k), ...
                    'Marker', 'o', ...
                    'MarkerFaceColor', color, ...
                    'Color', color, ...
                    'MarkerSize', 7, ...
                    'HandleVisibility', 'off')


            end

            
            %% Fast Formation + Baseline Formation
            [r2_tot, rho_tot, xx, yy] = get_fit(x, y);
            
            if r2_tot > 0.5
                line(yy, xx, 'Color', [0.6, 0.6, 0.6], ...
                    'HandleVisibility', 'off');
            end
            
            % Add detailed annotations
            if to_make_detailed_plot 
                
                x_f = x(tbl.is_baseline_formation == 0);
                y_f = y(tbl.is_baseline_formation == 0);

                [r2_f, ~, xx, yy] = get_fit(x_f, y_f);

                if r2_f > 0.5 
                    line(yy, xx, 'Color', 'g', ...
                        'HandleVisibility', 'off');
                end

                x_b = x(tbl.is_baseline_formation == 1);
                y_b = y(tbl.is_baseline_formation == 1);

                [r2_b, ~, xx, yy] = get_fit(x_b, y_b);

                if r2_b > 0.5
                    line(yy, xx, 'Color', 'g', ...
                        'HandleVisibility', 'off');
                end
                
            end
            
            if r2_tot > 0.5
                font_weight = 'bold';
            else
                font_weight = 'normal';
            end

            if to_make_detailed_plot
                title(sprintf('$$\\rho$$ = %.2f, $$R^2$$ = %.2f, \n $$R^2$$ = %.2f (F), %.2f (B)', ...
                    rho_tot, r2_tot, r2_f, r2_b), ...
                    'FontSize', 13, ...
                    'FontWeight', font_weight, ...
                    'Interpreter', 'Latex')
            else
                title(sprintf('$$\\rho$$ = %.2f', rho_tot), ...
                    'FontSize', 13, ...
                    'FontWeight', font_weight, ...
                    'Interpreter', 'Latex')
            end

            if j == 1
                ylabel(xlab, 'FontSize', 18)
            end

            xlabel(ylab, 'FontSize', 18)
            
            
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;

            plot_counter = plot_counter + 1;

        end

    end

%     tightfig();


%     print(fh, '-dtiff', '-r300', ...
%         sprintf('figures/fig_correlations_%s.tiff', figure_name))
    

end

function fig_esoh_metrics()
    % Plot dV/dQ loss metrics

    plot_summary_esoh_table()

end

function fig_initial_dcr_from_rpt()
    % Plot the figure containing the initial performance metrics from the
    % fresh cell RPT


    path = 'output/2021-03-fast-formation-esoh-fits/correlation_data.csv';

    tbl = readtable(path);

    % Better packaging of variables
    tbl.dcr_10s_90_soc_at_c3_mohm = tbl.dcr_10s_90_soc_at_c3.*1000;
    tbl.dcr_10s_50_soc_at_c3_mohm = tbl.dcr_10s_50_soc_at_c3.*1000;
    tbl.dcr_10s_5_soc_at_c3_mohm = tbl.dcr_10s_5_soc_at_c3.*1000;
    tbl.dcr_1s_5_soc_at_c3_mohm = tbl.dcr_1s_5_soc_at_c3.*1000;
    tbl.dcr_3s_5_soc_at_c3_mohm = tbl.dcr_3s_5_soc_at_c3.*1000;
    
    tbl.dcr_10s_0_soc_at_c3_mohm = tbl.dcr_10s_0_soc_at_c3.*1000;
    tbl.dcr_10s_5_soc_at_c3_mohm = tbl.dcr_10s_5_soc_at_c3.*1000;
    tbl.dcr_10s_7_soc_at_c3_mohm = tbl.dcr_10s_7_soc_at_c3.*1000;
    tbl.dcr_10s_10_soc_at_c3_mohm = tbl.dcr_10s_10_soc_at_c3.*1000;
    tbl.dcr_10s_15_soc_at_c3_mohm = tbl.dcr_10s_15_soc_at_c3.*1000;

    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    
    %% Effect of pulse duration
    labels = {'R_{10s, 5% SOC} (m\Omega)', ...
              'R_{3s, 5% SOC} (m\Omega)', ...
              'R_{1s, 5% SOC} (m\Omega)'};
    varnames = {'dcr_10s_5_soc_at_c3_mohm', ...
                'dcr_3s_5_soc_at_c3_mohm', ...
                'dcr_1s_5_soc_at_c3_mohm'};

    plot_distribution_two_temps(tbl, varnames, labels, 'initial_dcr')


    %% Effect of SOC setting
    
    % Note: 0% here in the variable name just refers to the lowest
    % available SOC which is 4%
    
    labels = {'R_{10s, 4% SOC} (m\Omega)', ...
              'R_{10s, 7% SOC} (m\Omega)', ...
              'R_{10s, 10% SOC} (m\Omega)', ...
              'R_{10s, 15% SOC} (m\Omega)', ...
              'R_{10s, 90% SOC} (m\Omega)'};
    
    varnames = {'dcr_10s_0_soc_at_c3_mohm', ...
                'dcr_10s_7_soc_at_c3_mohm', ...
                'dcr_10s_10_soc_at_c3_mohm', ...
                'dcr_10s_15_soc_at_c3_mohm', ...
                'dcr_10s_90_soc_at_c3_mohm'};

    plot_distribution_two_temps(tbl, varnames, labels, 'initial_dcr')
    
    
end

function fig_initial_esoh_distributions()
    % Plot the figure containing the initial esoh metrics from the
    % fresh cell RPT

    global PATH_CORRELATION_FILE
    
    tbl = readtable(PATH_CORRELATION_FILE);
    
    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    labels = {'C_n, c3 (Ah)', ...
              'x_{0}, c3', ...
              'x_{100}, c3'};
    varnames = {'esoh_c3_Cn', ...
                'esoh_c3_x0', ...
                'esoh_c3_x100'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_1')


    labels = {'C_p, c3 (Ah)', ...
              'y_{0}, c3', ...
              'y_{100}, c3'};
    varnames = {'esoh_c3_Cp', ...
                'esoh_c3_y0', ...
                'esoh_c3_y100'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_2')
            

    labels = {'n_{Li}, c3 (moles)', ...
              'Positive Excess, c3 (Ah)', ...
              'Negative Excess, c3 (Ah)'};
    varnames = {'esoh_c3_n_li', ...
                'esoh_c3_pos_excess', ...
                'esoh_c3_neg_excess'};

    plot_distribution_two_temps(tbl, varnames, labels, 'esoh_metrics_initial_3')

end

function fig_thickness_distributions()
    % Plot the figure containing the thickness distribution at EOL

    global PATH_CORRELATION_FILE
    
    tbl = readtable(PATH_CORRELATION_FILE);

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

    global PATH_CORRELATION_FILE
    
    tbl = readtable(PATH_CORRELATION_FILE);

    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);

    tbl.dcr_10s_90_soc_at_70_pct_mohm = tbl.dcr_10s_90_soc_at_70_pct.*1000;
    tbl.dcr_10s_50_soc_at_70_pct_mohm = tbl.dcr_10s_50_soc_at_70_pct.*1000;
    tbl.dcr_10s_5_soc_at_70_pct_mohm = tbl.dcr_10s_5_soc_at_70_pct.*1000;

    % Begin plotting
    labels = {'R_{10s, 90% SOC}, 70% (m\Omega)', ...
              'R_{10s, 50% SOC}, 70% (m\Omega)', ...
              'R_{10s, 5% SOC}, 70% (m\Omega)'};

    varnames = {'dcr_10s_90_soc_at_70_pct_mohm', ...
                'dcr_10s_50_soc_at_70_pct_mohm', ...
                'dcr_10s_5_soc_at_70_pct_mohm'};

    plot_distribution_two_temps(tbl, varnames, labels, 'dcr_at_c400');


    labels = {'Cycles to 70%', ...
              'Cycles to 80%', ...
              'Swelling Severity (Rank)'};

    varnames = {'cycles_to_70_pct', ...
                'cycles_to_80_pct', ...
                'swelling_severity'};

    plot_distribution_two_temps(tbl, varnames, labels, 'cycles_to_eol_and_swell');

end

function plot_distribution_two_temps(tbl, varnames, labels, fig_title, ylims)

    global ORANGE
    global BLUE
    global GREEN
    

    num_vars = numel(varnames);
    
    if nargin == 4
	    ylims = [];
    end 
	    
    fh = figure('Position', [1 1 1200 800].*1.2);

    legend_varname = {'a)', 'b)', 'c)', 'd)', 'e)', 'f)'};

    counter = 0;

    % Loop over temperatures
    for i = 1:2

        % OVERRIDE COLOR SCHEMA TO MATCH TEMPERATURES
        if i == 1
            fast_form_color = [0 0 1];
        else
            fast_form_color = [1 0 0];
        end
        
%         fast_form_color = 'k';

        % Loop over variables
        for j = 1:num_vars

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


%             idx_of_interest_1 = find((tbl_fast.cellid == 35) | ...
%                                (tbl_fast.cellid == 37) );
% 
%             idx_of_interest_2 = find((tbl_fast.cellid == 36) | ...
%                                      (tbl_fast.cellid == 38));
% 
            tbl_fast_set_1 = tbl_fast;
%             tbl_fast_set_1([idx_of_interest_1 ; idx_of_interest_2], :) = [];
%             tbl_fast_set_2 = tbl_fast(idx_of_interest_1, :);
%             tbl_fast_set_3 = tbl_fast(idx_of_interest_2, :);


            ax(counter) = subplot(2, num_vars, counter); box on;

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
                    'MarkerFaceColor', fast_form_color, ...
                    'LineStyle', 'none', ...
                    'Color', fast_form_color);

            % Add the interesting cells
%             s = line(add_noise(0.*ones(size(tbl_fast_set_2, 1))), ...
%                     tbl_fast_set_2.(curr_var), ...
%                     'Marker', 'o', ...
%                     'MarkerFaceColor', ORANGE, ...
%                     'LineStyle', 'none', ...
%                     'Color', ORANGE);
% 
%             s = line(add_noise(0.*ones(size(tbl_fast_set_3, 1))), ...
%                     tbl_fast_set_3.(curr_var), ...
%                     'Marker', 'o', ...
%                     'MarkerFaceColor', GREEN, ...
%                     'LineStyle', 'none', ...
%                     'Color', GREEN);

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

            if i == 1
                fprintf('ROOM TEMP\n')
            else
                fprintf('45C\n')
            end
            
            fprintf('%s:\n', curr_var)
            fprintf('  base: %g (%g)\n', mean(tbl_base.(curr_var)), std(tbl_base.(curr_var)))
            fprintf('  fast: %g (%g)\n', mean(tbl_fast.(curr_var)), std(tbl_fast.(curr_var)))
            fprintf(' p = %g \n\n', p_value)

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

end

function fig_formation_performance_distributions()

    % Plot the figure containing initial performance metrics from the
    % formation cycle AND from other parts of the test

    path = 'output/2021-03-fast-formation-esoh-fits/correlation_data.csv';

    tbl = readtable(path);

    % Better packaging of variables
    tbl.form_6hr_rest_delta_voltage_mv = tbl.form_6hr_rest_delta_voltage_v.*1000;
    tbl.form_coulombic_efficiency_pct = tbl.form_coulombic_efficiency.*100;
    tbl.initial_cell_dcr_50_soc_mohm = tbl.dcr_10s_50_soc_at_c3.*1000;
    tbl.initial_cell_dcr_0_soc_mohm = tbl.dcr_10s_5_soc_at_c3.*1000;

   
    % Exclude the outlier cell
    tbl = remove_from_table(tbl, 'cellid', 9);
    
    % Begin plotting
    labels = {'Q_d (Ah)', ...
              'CE_f (%)', ...
              'Q_c (Ah)', ...
              'Q_{LLI} = Q_c - Q_d (Ah)'};

    varnames = {'form_final_discharge_capacity_ah', ...
                'form_coulombic_efficiency_pct', ...
                'form_first_charge_capacity_ah', ...
                'form_qc_minus_qd_ah'};

    plot_distribution_one_temp(tbl, varnames, labels);


end

function plot_distribution_one_temp(tbl, varnames, labels)

    global ORANGE
    global BLUE
    global GREEN

    fh = figure('Position', [1 1 1200 600].*1.2);

    for i = 1:numel(varnames)

        curr_var = varnames{i};

        tbl_base = tbl(find(tbl.is_baseline_formation == 1), :);
        tbl_fast = tbl(find(tbl.is_baseline_formation == 0), :);

%         % Current bump cells
%         idx_of_interest_1 = find((tbl_fast.cellid == 35) | ...
%                                 (tbl_fast.cellid == 37) );
% 
%         % Blah cells
%         idx_of_interest_2 = find((tbl_fast.cellid == 36) | ...
%                                  (tbl_fast.cellid == 38));

        tbl_fast_set_1 = tbl_fast;
%         tbl_fast_set_1([idx_of_interest_1 ; idx_of_interest_2], :) = [];
%         tbl_fast_set_2 = tbl_fast(idx_of_interest_1, :);
%         tbl_fast_set_3 = tbl_fast(idx_of_interest_2, :);

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
                'MarkerFaceColor', 'k', ...
                'LineStyle', 'none', ...
                'Color', 'k');

%         % Add the interesting cells
%         s = line(add_noise(0.*ones(size(tbl_fast_set_2, 1))), ...
%                 tbl_fast_set_2.(curr_var), ...
%                 'Marker', 'o', ...
%                 'MarkerFaceColor', ORANGE, ...
%                 'LineStyle', 'none', ...
%                 'Color', ORANGE);
% 
%         s = line(add_noise(0.*ones(size(tbl_fast_set_3, 1))), ...
%                 tbl_fast_set_3.(curr_var), ...
%                 'Marker', 'o', ...
%                 'MarkerFaceColor', GREEN, ...
%                 'LineStyle', 'none', ...
%                 'Color', GREEN);

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
        fprintf('  fast: %g (%g)\n', mean(tbl_fast.(curr_var)), std(tbl_fast.(curr_var)))
        fprintf(' p = %g \n\n', p_value)

    end

    tightfig();

end


function fig_formation_protocol()

    fig_title = 'formation_protocol';
    
    global BLUE
    global GREEN
    
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
    xlabel('Time (hours)')
    ylabel('Potential (V)')
    
    line(time_fast, tbl_fast.Potential_V_, ...
        'LineWidth', 2', 'LineStyle', '-', ...
        'DisplayName', 'Fast Formation',...
        'Color', 'k', 'Parent', ax1)

    idx = find(tbl_fast.CycleNumber == 6);
    
    line(time_fast(idx), tbl_fast.Potential_V_(idx), ...
        'LineWidth', 4, 'LineStyle', '-', ...
        'HandleVisibility', 'off', ...
        'Color', GREEN, 'Parent', ax1)
    
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
        'Color', GREEN, 'Parent', ax3)
    
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

    print(fh, '-dtiff', '-r300', sprintf('fig_%s.tiff', fig_title))
    
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

    ax1 = subplot(211); grid off; box on;
    xlabel('Cycle Number')
    ylabel(config.ylabel)
    title('Room Temperature Cycling')

    ax2 = subplot(212); grid off; box on;
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


function [x,y] = remove_nans(x, y)
    % Gets rid of nans from a pair of vectors

    idx = find(isnan(x));
    x(idx) = [];
    y(idx) = [];

    idx = find(isnan(y));
    x(idx) = [];
    y(idx) = [];

end
            
function [r2, rho, xx, yy] = get_fit(x, y)
    % Make a fit of the two variables x and y
    %
    % Outputs:
    % - R2: ordinary least squares (= rho^2)
    % - rho: correlation coefficient
    % - xx: fitted vec x
    % - yy: fitted vec y
    
    model = fitlm(x, y);
    [x, y] = remove_nans(x, y);
    
    if isempty(x)
        r2 = [];
        rho = [];
        xx = [];
        yy = [];
        return
    end    

    a = model.Coefficients.Estimate(2);
    b = model.Coefficients.Estimate(1);

    % Ordinary R-squared
    r2 = model.Rsquared.Ordinary;

    % Correlation coefficient
    rho = corrcoef(x, y);
    rho = rho(1, 2);

    xx = linspace(min(x), max(x), 100);
    yy = a.*xx + b;

end
