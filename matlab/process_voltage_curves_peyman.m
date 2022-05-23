function process_voltage_curves_peyman()
    % Process voltage curves from Peyman's dataset.

    set_default_plot_settings_manuscript();

    % Set paths
    root_path = 'C:/Users/wenga/Documents/expansion-peyman-2021/';
    input_path = [root_path 'data/'];
    output_path = [root_path 'outputs/2022-05-18-esoh-fits/'];

    if ~exist(output_path)
        mkdir(output_path)
    end

    cellid_array = 1:1:21;

    % Initialize accumulator arrays
    all_cellid = [];
    all_cyc_id = [];
    all_y100 = [];
    all_Cp = [];
    all_x100 = [];
    all_Cn = [];
    all_Qcomp = [];
    all_Qfull = [];
    all_y0 = [];
    all_x0 = [];
    all_pos_excess = [];
    all_neg_excess = [];
    all_RMSE_mV = [];
    all_np_ratio = [];
    all_n_li = [];
    all_LLI = [];
    all_LAM_PE = [];
    all_LAM_NE = [];
    all_Cn_pf = [];
    all_x100_pf = [];
    all_c20_loss = [];

    for jdx = 1:numel(cellid_array)

        cellid = cellid_array(jdx);
        
        file_name = sprintf('%02d/OCV_wExpansion.csv', cellid);
        
        data = readtable([input_path file_name]);
        
        unique_cycles = unique(data.CycleNumber);
        
        [Un, Up] = get_electrode_models('original');

        curr_n_li = [];
        curr_Cp = [];
        curr_Cn = [];
        curr_c20_cap = [];
        
        for idx = 1:numel(unique_cycles)

            cyc_id = unique_cycles(idx);

            output_filename = sprintf('cell_%g_cyc_%g', cellid, ...
                                cyc_id);

            % Filter for charge data for current cycle
            curr_data = data(find(data.CycleNumber == cyc_id), :);
            curr_data = curr_data(find(curr_data.Current_mA_ > 0), :);


            % Run the eSOH algorithm(s) to get the results file
            res = run_esoh(curr_data.Capacity_Ah_, curr_data.Voltage_V_, Un, Up);

            write_to_json(res, output_path, output_filename)

            fh = figure();

            ax1 = subplot(211); grid on; box on;
            line(curr_data.Capacity_Ah_, curr_data.Voltage_V_, 'Color', 'k')
            line(res.ful.Q, res.ful.V, 'Color', 'k', 'LineStyle', '--')
            line(res.pos.Q, res.pos.V, 'Color', 'b', 'LineStyle', '-')
            line(res.neg.Q, res.neg.V, 'Color', 'r', 'LineStyle', '-')
            xlabel('Capacity (Ah)')
            ylabel('Voltage (V)')
            ylim([0 5])
            title({sprintf('cell %g, cycle %g', ...
                cellid, cyc_id), ...
                soh_parameters_to_string_1(res), ...
                soh_parameters_to_string_2(res)}, ...
                'FontWeight', 'normal', ...
                'FontSize', 12)
            lh = legend('Experiment', 'Model', 'Model (Pos)', 'Model (Neg)');
            set(lh, 'Location', 'East', 'Color', 'w')

            n = round(numel(curr_data.Voltage_V_)/300);
            voltage = downsample(curr_data.Voltage_V_, n);
            capacity = downsample(curr_data.Capacity_Ah_, n);
            dvdq = gradient(voltage) ./ gradient(capacity);

            ax2 = subplot(212); grid on; box on;
            line(capacity, dvdq, 'Color', 'k')
            line(res.ful.Q, res.ful.dVdQ, 'Color', 'k', 'LineStyle', '--')
            line(res.pos.Q, res.pos.dVdQ, 'Color', 'b', 'LineStyle', '-')
            line(res.neg.Q, res.neg.dVdQ, 'Color', 'r', 'LineStyle', '-')
            ylim([0 0.8])
            xlabel('Capacity (Ah)')
            ylabel('|dV/dQ|')
            xlim([-2 7])


            linkaxes([ax1 ax2], 'x')

            tightfig();

            saveas(fh, sprintf('%s%s.png', output_path, output_filename))
            saveas(fh, sprintf('%s%s.fig', output_path, output_filename))

            close(fh)

            % Accumulate summary results
            all_cellid = [all_cellid ; cellid];
            all_cyc_id = [all_cyc_id ; cyc_id];
            all_y100 = [all_y100 ; res.Xt(1)];
            all_Cp = [all_Cp ; res.Xt(2)];
            all_x100 = [all_x100 ; res.Xt(3)];
            all_Cn = [all_Cn ; res.Xt(4)];
            all_Qcomp = [all_Qcomp ; res.Xt(5)];
            all_RMSE_mV = [all_RMSE_mV ; res.RMSE_mV];
            all_y0 = [all_y0 ; res.y0];
            all_x0 = [all_x0 ; res.x0];
            all_Qfull = [all_Qfull ; res.Cf];
            all_pos_excess = [all_pos_excess ; res.Cp_excess];
            all_neg_excess = [all_neg_excess ; res.Cn_excess];
            all_np_ratio = [all_np_ratio ; res.np_ratio];
            all_n_li = [all_n_li ; res.n_li];
            all_Cn_pf = [all_Cn_pf ; res.Cn_pf];
            all_x100_pf = [all_x100_pf ; res.x100_pf];
            
            curr_Cp(idx, 1) = res.Cp;
            curr_Cn(idx, 1) = res.Cn;
            curr_n_li(idx, 1) = res.n_li;
            curr_c20_cap(idx, 1) = max(res.ful.Q);

        end % loop over cycle index
        
        all_LLI = [all_LLI ; curr_n_li ./ curr_n_li(1)];
        all_LAM_PE = [all_LAM_PE ; 1 - curr_Cp ./ curr_Cp(1)];
        all_LAM_NE = [all_LAM_NE ; 1 - curr_Cn ./ curr_Cn(1)];
        all_c20_loss = [all_c20_loss ; curr_c20_cap ./ curr_c20_cap(1)];

    end % loop over cellids

    % Aggregate and export results in a table
    results_table = table(all_cellid, all_cyc_id, ...
         all_y100, all_Cp, ...
         all_x100, all_Cn, ...
         all_Qcomp, all_x0, all_y0, ...
         all_Qfull, all_pos_excess, all_neg_excess, ...
         all_RMSE_mV, all_np_ratio, all_n_li, ...
         all_LLI, all_LAM_PE, all_LAM_NE, all_c20_loss, ...
         all_Cn_pf, all_x100_pf, ...
         'VariableNames', {'cellid', 'cycle_number', ...
            'y100', 'Cp', ...
            'x100', 'Cn', ...
            'Qcomp', 'x0', 'y0', ...
            'Qfull', 'pos_excess', 'neg_excess', ...
            'RMSE_mV', 'np_ratio', 'n_li', ...
            'LLI', 'LAM_PE', 'LAM_NE', 'C20_loss', ...
            'Cn_pf', 'x100_pf'});

    writetable(results_table, [output_path 'summary_esoh_table.csv']);

    plot_summary_esoh_table();

end

function cyc_index = parse_cycle_index_from_filename(file_fullpath)

    [~, filename, ~] = fileparts(file_fullpath);
    parts = strsplit(filename, '_');
    cyc_index = str2num(parts{6});


end

function result = soh_parameters_to_string_1(res)
    % Return a string representation of Xt

    Xt = res.Xt;

    result = sprintf(['y_{100} = %.2f, y_{0} = %.2f, C_p = %.2f Ah, '...
                      'x_{100} = %.2f, x_{0} = %.2f, C_n = %.2f Ah, ', ...
                      'C_n/C_p = %.2f'], ...
        res.y100, res.y0, res.Cp, ...
        res.x100, res.x0, res.Cn, res.np_ratio);

end

function result = soh_parameters_to_string_2(res)

 Xt = res.Xt;

    result = sprintf(['Q_{full} = %.2f Ah, C_{n,e} = %.2f Ah, C_{p,e} = %.2f Ah, '...
                      'Q_{comp} = %.2f Ah, RMSE = %.1f mV'], ...
        res.Cf, res.Cn_excess, res.Cp_excess, Xt(5), res.RMSE_mV);

end

function write_to_json(res, output_path, output_filename)
    % Writes the result struct to a json file

    if ~exist(output_path)
        mkdir(output_path)
    end

    fid = fopen(sprintf('%s/%s.json', output_path, output_filename), 'w');
    encoded_json = jsonencode(res);
    fprintf(fid, encoded_json);  
    fclose(fid);

end