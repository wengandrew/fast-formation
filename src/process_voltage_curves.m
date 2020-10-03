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

        for idx = 1:numel(file_list)

            input_filename = file_list{idx};

            cyc_id = parse_cycle_index_from_filename(input_filename);

            output_filename = sprintf('cell_%g_cyc_%g.png', cellid, ...
                                cyc_id);

            raw_data = readtable(input_filename);
            [Cn(idx), x100(idx)] = solve_using_peak_find(raw_data.charge_capacity, raw_data.voltage);
            if idx == 1 % recalibrate the Up Un for the fresh cell
                
                y100(idx) = 0.023;
                Cp(idx) = Cn(idx)*0.995;
                [Up_modified, Un_modified] = recalibrate(raw_data.charge_capacity, raw_data.voltage, Cn(idx), x100(idx), Cp(idx), y100(idx));

                type.Un_modified = Un_modified;
                type.Up_modified = Up_modified;
                type.x100 = x100(idx);
                type.Cn = Cn(idx);
%                 y0(idx) = y100(idx) + (max(Q))/Cp(idx);
%                 x0(idx) = max(x100(idx) - (max(Q))/Cn(idx),0);
% 
%                 Xi = [y100(idx);Cp(idx)];
                
            else
                res = run_esoh(raw_data, type);
                
%                 id1 = (find(Voltage>3.38,1):length(Voltage));
%                 [Xt,RMSE_V,Q_s,Vt,Qd,dVdQ] = diagnostics_recal(Q(id1),Voltage(id1),Up_modified,Un_modified,Xi,i,Cn,x100);

                y100(i) = Xt(1);
                Cp(i) = Xt(2);

                % Xt(5) = 0;

                y0(i) = y100(i) + (max(Q))/Cp(i);
                x0(i) = max(x100(i) - (max(Q))/Cn(i),0);

                Xi = Xt;

                RMSE_V_out(i) = RMSE_V;
                
                
            end

            fh = figure();

            ax1 = subplot(211);
            line(raw_data.charge_capacity, raw_data.voltage, 'Color', 'k')
            line(res.ful.Q, res.ful.V, 'Color', 'k', 'LineStyle', '--')
            line(res.pos.Q, res.pos.V, 'Color', 'b', 'LineStyle', '--')
            line(res.neg.Q, res.neg.V, 'Color', 'r', 'LineStyle', '--')
            xlabel('Capacity (Ah)')
            ylabel('Voltage (V)')
            xlim([-1 3])
            title({sprintf('cell %g (%s), cycle %g', ...
                cellid, cell_config.group, cyc_id), ...
                soh_parameters_to_string(res.Xt), ...
                sprintf('RMSE = %.1f mV', res.RMSE_mV)})

            ax2 = subplot(212);
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
%             all_x100 = [all_x100 ; res.Xt(3)];
%             all_Cn = [all_Cn ; res.Xt(4)];
%             all_Qcomp = [all_Qcomp ; res.Xt(5)];
            all_x100 = [all_x100 ; x100(idx)];
            all_Cn = [all_Cn ; Cn(idx)];
            all_Qcomp = [all_Qcomp ; max(raw_data.charge_capacity)];
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
        Xt(1), Xt(2), Xt(3), Xt(4), Xt(5))

end

function result = run_esoh(tbl, type)
    % Run electrode-level SOH algorithm on a dataset.
    % Also do some post-processing.
    %
    % Args
    %   tbl: the dataset as a MATLAB table
    %   type: electrode model type ('original', 'formation_rt',
    %   'formation_ht'
    %
    % Returns
    %   result: a struct holding results

    voltage = tbl.voltage;
    capacity = tbl.charge_capacity;

%     [Xt, RMSE_V, ful_cap, ful_pot, ful_dvdq_pot] = ...
%         diagnostics_Qs_voltage_only(capacity, voltage, type);
    id1 = (find(voltage>3.38,1):length(voltage));
    [Xt, RMSE_V, ful_cap, ful_pot, ful_dvdq_pot] = ...
        diagnostics_pos_only(capacity(id1), voltage(id1), type);

    [pos_pot, pos_pot_dvdq] = calculate_pos(ful_cap, Xt, type);
    [pos_pot, pos_cap, pos_pot_dvdq] = expand_pos(pos_pot, ful_cap, Xt, type);

    [neg_pot, neg_pot_dvdq] = calculate_neg(ful_cap, Xt, type);
    [neg_pot, neg_cap, neg_pot_dvdq] = expand_neg(neg_pot, ful_cap, Xt, type);

    % Package results
    result.Xt = Xt;
    result.RMSE_mV = RMSE_V*1000;
    result.ful.Q = ful_cap;
    result.ful.V = ful_pot;
    result.ful.dVdQ = abs(ful_dvdq_pot);
    result.pos.Q = pos_cap;
    result.pos.V = pos_pot;
    result.pos.dVdQ = abs(pos_pot_dvdq);
    result.neg.Q = neg_cap;
    result.neg.V = neg_pot;
    result.neg.dVdQ = abs(neg_pot_dvdq);

end

function [pot, dvdq] = calculate_neg(cap, Xt, type)
    % Returns a negative potential vector in the charge direction

    [neg_func, ~] = get_electrode_models(type);

    pot = neg_func(Xt(3) - cap / Xt(4));

    dVdQn = gradient(pot) ./ gradient(cap);

    % Convert curve from discharge to charge
    pot = fliplr(pot);
    dvdq = fliplr(dVdQn);

end

function [pot, dvdq] = calculate_pos(cap, Xt, type)
    % Returns a positive potential vector in the charge direction

    [~, pos_func] = get_electrode_models(type);

    pot = pos_func(Xt(1) + cap / Xt(2));

    dvdq = gradient(pot) ./ gradient(cap);

    % Convert curve from discharge to charge
    pot = fliplr(pot);
    dvdq = fliplr(dvdq);

end

function [pot_full, cap_full, pot_dvdq_full] = expand_pos(pot, cap, Xt, type)
    % Expands a positive potential vector given a capacity-potential curve in
    % the charge direction

    POS_MAX_VOLTAGE = 4.4;
    POS_MIN_VOLTAGE = 2.5;

    [~, pos_func] = get_electrode_models(type);

    diff = cap(2) - cap(1);

    min_cap = min(cap);
    while pos_func(Xt(1) + min_cap / Xt(2)) < POS_MAX_VOLTAGE
        min_cap = min_cap - diff;
    end

    max_cap = max(cap);
    while pos_func(Xt(1) + max_cap / Xt(2)) > POS_MIN_VOLTAGE
        max_cap = max_cap + diff;
    end

    cap_full = min_cap:diff:max_cap;

    [pot_full, pot_dvdq_full] = calculate_pos(cap_full, Xt, type);

    % Translate the capacity to curve to align with orig data
    Q1 = min(cap_full);
    Q2 = cap_full(abs(pot_full - min(pot)) < 1e-9) - ...
         cap_full(abs(pot_full - min(pot_full)) < 1e-9);
    cap_full = cap_full - Q1 - Q2;

end

function [pot_full, cap_full, pot_dvdq_full] = expand_neg(pot, cap, Xt, type)
    % Expand a negative potential vector given a capacity-potential curve in the
    % charge direction

    NEG_MAX_VOLTAGE = 2.0;
    NEG_MIN_VOLTAGE = 0;

    [neg_func, ~] = get_electrode_models(type);

    diff = cap(2) - cap(1);

    min_cap = min(cap);
    while neg_func(Xt(3) - min_cap / Xt(4)) > NEG_MIN_VOLTAGE
        min_cap = min_cap - diff;
    end

    max_cap = max(cap);
    while neg_func(Xt(3) - max_cap / Xt(4)) < NEG_MAX_VOLTAGE
        max_cap = max_cap + diff;
    end

    cap_full = min_cap:diff:max_cap;

    [pot_full, pot_dvdq_full] = calculate_neg(cap_full, Xt, type);

    % Translate the capacity to curve to align with orig data
    Q1 = min(cap_full);
    Q2 = cap_full(abs(pot_full - max(pot)) < 1e-9) - ...
         cap_full(abs(pot_full - max(pot_full)) < 1e-9);
    cap_full = cap_full - Q1 - Q2;

end

function [Cn, x100] = solve_using_peak_find(capacity, voltage)

    Q1_REF = 0.112; % Peak 1 position based on 'original' Un
    Q2_REF = 0.50 ; % Peak 2 position based on 'original' Un

    [p1_idx, p2_idx] = find_peaks(capacity, voltage);

    Cn = (capacity(p2_idx) - capacity(p1_idx)) / (Q2_REF - Q1_REF);
    x100 = Q2_REF + (max(capacity) - capacity(p2_idx))./Cn;

end
