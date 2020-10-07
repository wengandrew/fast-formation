function process_voltage_curves()
    % Takes in voltage data and run it through the eSOH model to get POS,
    % NEG, and LLI losses

    set_default_plot_settings();

    % Set paths
    input_path = 'output/2020-08-microformation-voltage-curves';
    output_path = 'output/2020-08-microformation-esoh-fits';
    file_path = 'output/2020-08-microformation-voltage-curves';

    cellid_array = 1:1:40;

    % Initialize accumulator arrays
    all_cellid = [];
    all_cyc_id = [];
    all_y100 = [];
    all_Cp = [];
    all_x100 = [];
    all_Cn = [];
    all_Qcomp = [];
    all_RMSE_mV = [];

    for jdx = 1:numel(cellid_array)

        cellid = cellid_array(jdx);
        regex = sprintf('diagnostic_test_cell_%g_', cellid);
        file_list = find_files(input_path, regex);
        cell_config = get_cellid_config(cellid);

        [Un, Up] = get_electrode_models(cell_config.electrode_model);
        
        for idx = 1:numel(file_list)

            input_filename = file_list{idx};

            cyc_id = parse_cycle_index_from_filename(input_filename);

            output_filename = sprintf('cell_%g_cyc_%g.png', cellid, ...
                                cyc_id);

            raw_data = readtable(input_filename);
                
            res = run_esoh(raw_data, Un, Up);
            
            % Do the recalibration
%             [Un, Up] = recalibrate(raw_data.voltage, raw_data.charge_capacity, ...
%                 res.Xt, Un, Up);

            fh = figure();

            ax1 = subplot(211); grid on; box on;
            line(raw_data.charge_capacity, raw_data.voltage, 'Color', 'k')
            line(res.ful.Q, res.ful.V, 'Color', 'k', 'LineStyle', '--')
            line(res.pos.Q, res.pos.V, 'Color', 'b', 'LineStyle', '--')
            line(res.neg.Q, res.neg.V, 'Color', 'r', 'LineStyle', '--')
            xlabel('Capacity (Ah)')
            ylabel('Voltage (V)')
            ylim([0 5])
            xlim([-1 3])
            title({sprintf('cell %g (%s), cycle %g', ...
                cellid, cell_config.group, cyc_id), ...
                soh_parameters_to_string(res.Xt), ...
                sprintf('RMSE = %.1f mV', res.RMSE_mV)})
            lh = legend('Experiment', 'Model', 'Model (POS)', 'Model (NEG)');
            set(lh, 'Location', 'East', 'Color', 'w')

            ax2 = subplot(212); grid on; box on;
            line(raw_data.charge_capacity, raw_data.dvdq, 'Color', 'k')
            line(res.ful.Q, res.ful.dVdQ, 'Color', 'k', 'LineStyle', '--')
            line(res.pos.Q, res.pos.dVdQ, 'Color', 'b', 'LineStyle', '--')
            line(res.neg.Q, res.neg.dVdQ, 'Color', 'r', 'LineStyle', '--')
            ylim([0 0.5])
            xlabel('Capacity (Ah)')
            ylabel('dV/dQ')

            linkaxes([ax1 ax2], 'x')


            saveas(fh, sprintf('%s/%s', output_path, output_filename))
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

        end % loop over cycle index

    end % loop over cellids

    % Aggregate and export results in a table
    results_table = table(all_cellid, all_cyc_id, ...
         all_y100, all_Cp, all_x100, ...
         all_Cn, all_Qcomp, all_RMSE_mV, ...
         'VariableNames', {'cellid', 'cycle_number', 'y100', 'Cp', ...
         'x100', 'Cn', 'Qcomp', 'RMSE_mV'});

    writetable(results_table, 'summary_esoh_table.csv');

    plot_summary_esoh_table();


end

function cyc_index = parse_cycle_index_from_filename(file_fullpath)

    [~, filename, ~] = fileparts(file_fullpath);
    parts = strsplit(filename, '_');
    cyc_index = str2num(parts{6});


end

function result = soh_parameters_to_string(Xt)
    % Return a string representation of Xt

    result = sprintf(['y_{100} = %.2f, C_p = %.2f Ah, '...
                      'x_{100} = %.2f, C_n = %.2f Ah, '...
                      'Q_{comp} = %.2f Ah'], ...
        Xt(1), Xt(2), Xt(3), Xt(4), Xt(5));

end
