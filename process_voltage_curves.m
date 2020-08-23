function process_voltage_curves()
    % Takes in voltage data and run it through the eSOH model to get POS,
    % NEG, and LLI losses

    % Set defaults
    set(0, 'DefaultLineLineWidth', 1.5)
    set(0, 'DefaultAxesFontSize', 20)
    set(0, 'DefaultFigureColor', [1 1 1])
    set(0, 'DefaultFigurePosition', [400 250 900 750])
    
    input_path = 'output/2020-08-microformation-voltage-curves';
    output_path = 'output/2020-08-microformation-esoh-fits';
    
    cellids = 1:1:40;
    
    % Initialize plot

    fh = figure();
    
    ax1 = subplot(2, 2, 1);
    ylabel('y_{100}')

    ax2 = subplot(2, 2, 2);
    ylabel('C_p')

    ax3 = subplot(2, 2, 3);

    ylabel('x_{100}')
    xlabel('Cycle Number')

    ax4 = subplot(2, 2, 4);
    ylabel('C_n')
    xlabel('Cycle Number')

    
    for i = 1:numel(cellids)
        
        cellid = cellids(i);
        regex = sprintf('diagnostic_test_cell_%g_', cellid);

        file_list = find_files(input_path, regex);

        % Loop over and plot the results

        % Initialize (5 x n) matrix holding results for each of the n cycles
        Xt_matrix = [];
        for i = 1:numel(file_list)

            raw_data{i} = readtable(file_list{i});
            cyc(i) = parse_cycle_index_from_filename(file_list{i});
            res(i) = run_esoh(raw_data{i});

            Xt_matrix = [Xt_matrix res(i).Xt];

        end

        % Sort the results by increasing cycle index
        [~, i] = sort(cyc);
        cyc = cyc(i);
        res = res(i);
        raw_data = raw_data(i);
        Xt_matrix = Xt_matrix(:, i);

        % Plot the voltage curve fits
        fh = figure();

        ax_voltage = subplot(2, 1, 1);
        cols = lines(numel(cyc));
        for i = 1:numel(cyc)

            line(raw_data{i}.charge_capacity, raw_data{i}.voltage, ...
                    'LineWidth', 1.5, ...
                    'Color', cols(i, :), ...
                    'DisplayName', sprintf('Cycle %g, RMSE = %.3f', cyc(i), res(i).RMSE_V), ...
                    'Parent', ax_voltage)
            line(res(i).Q, res(i).Vt, ...
                'Color', cols(i, :), ...
                'LineStyle', '--', ...
                'HandleVisibility', 'off', ...
                'Parent', ax_voltage)

        end

        grid on
        lh = legend('show'); set(lh, 'Location', 'Best')
        xlabel('Capacity (Ah)')
        ylabel('Voltage (V)')
        ylim([3, 4.2])
        title(sprintf('Cell %g', cellid))

        % Plot the dV/dQ model vs actual
        ax_dvdq = subplot(2, 1, 2);
        cols = lines(numel(cyc));
        for i = 1:numel(cyc)

            line(raw_data{i}.charge_capacity, raw_data{i}.dvdq, ...
                    'LineWidth', 1.5, ...
                    'Color', cols(i, :), ...
                    'Parent', ax_dvdq)
            line(res(i).Qd, res(i).dVdQ, ...
                'Color', cols(i, :), ...
                'LineStyle', '--', ...
                'HandleVisibility', 'off', ...
                'Parent', ax_dvdq)

        end

        grid on
        xlabel('Capacity (Ah)')
        ylabel('dV/dQ (V/Ah)')
        ylim([0 0.7])

        linkaxes([ax_voltage, ax_dvdq], 'x')
        
        saveas(fh, sprintf('%s/esoh_fits_cell_%g.png', output_path, cellid))
        close(fh)

        % Append to the eSOH metrics plot
        
        aes = get_cellid_aesthetics(cellid);
        
        line(cyc, Xt_matrix(1, :), 'Marker', 'o', 'Parent', ax1, 'Color', aes.color, 'MarkerFaceColor', aes.color, 'LineStyle', aes.linestyle)
        line(cyc, Xt_matrix(2, :), 'Marker', 'o', 'Parent', ax2, 'Color', aes.color, 'MarkerFaceColor', aes.color, 'LineStyle', aes.linestyle)
        line(cyc, Xt_matrix(3, :), 'Marker', 'o', 'Parent', ax3, 'Color', aes.color, 'MarkerFaceColor', aes.color, 'LineStyle', aes.linestyle)
        line(cyc, Xt_matrix(4, :), 'Marker', 'o', 'Parent', ax4, 'Color', aes.color, 'MarkerFaceColor', aes.color, 'LineStyle', aes.linestyle)
        
    end % loop over cellids
    
    linkaxes([ax1, ax2, ax3, ax4], 'x')
    
    saveas(fh, sprintf('%s/esoh_features_all_cells.png', output_path))
    
    
end

function aes = get_cellid_aesthetics(cellid)
    % Returns a struct containing plotting options which depend on what
    % test set the cellid belongs to
    
    if ismember(cellid, [1, 10, 2, 3, 4, 5, 6, 7, 8, 9])
        aes.group = 'Baseline HT';
    elseif ismember(cellid, [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
        aes.group = 'Baseline RT';
    elseif ismember(cellid, [31, 32, 33, 34, 35, 36, 37, 38, 39, 40])
        aes.group = 'MicroForm HT';
    elseif ismember(cellid, [21, 22, 23, 24, 25, 26, 27, 28, 29, 30])
        aes.group = 'MicroForm RT';
    end
    
    if ismember(aes.group, {'Baseline HT', 'Baseline RT'})
        aes.linestyle = '-';
    else
        aes.linestyle = '--';
    end
    
    if ismember(aes.group, {'Baseline HT', 'Microform HT'})
        aes.color = [1 0 0];
    else
        aes.color = [0 0 1];
    end

end

function cyc_index = parse_cycle_index_from_filename(file_fullpath)

    [~, filename, ~] = fileparts(file_fullpath);
    
    parts = strsplit(filename, '_');
    
    cyc_index = str2num(parts{6});
   

end

function result = run_esoh(tbl)
    % Run electrode-level SOH algorithm on a dataset
    %
    % Args
    %   tbl: the dataset as a MATLAB table
    %
    % Returns
    %   result: a struct holding results
    
    voltage = tbl.voltage;
    capacity = tbl.charge_capacity;
    
    [Xt, RMSE_V, Q, Vt, Qd, dVdQ] = ...
        diagnostics_Qs_voltage_only(capacity, voltage);
    
    % Revert to a charge curve
    Q = fliplr(Q); 
    Qd = fliplr(Qd);
    dVdQ = abs(dVdQ);
    
    % Package results
    result.Xt = Xt;
    result.RMSE_V = RMSE_V;
    result.Q = Q;
    result.Vt = Vt;
    result.Qd = Qd;
    result.dVdQ = dVdQ;  
  
end

function file_list = find_files(path, regex)
    % Returns files in directory matching regular expression
    %
    % Args:
    %  path: directory name
    %  regex: regular expression
    %
    % Returns:
    %  file_list: cell array of strings
    
    listing = dir(path);
    
    file_list = {};
    
    for i = 1:numel(listing)
       
        curr_listing = listing(i);
        
        % Skip directories
        if curr_listing.isdir == 1
            continue
        end
        
        % Skip files that do not match regular expression
        if isempty(regexpi(curr_listing.name, regex))
            continue
        end
        
        file_full_path = [curr_listing.folder '/' curr_listing.name];
        file_list = [file_list; file_full_path];
        
    end

end