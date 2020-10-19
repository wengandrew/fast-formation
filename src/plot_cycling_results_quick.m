function plot_cycling_results_quick()
    % Quick and dirty plotter for the cycling results. No time to write
    % nice data structures. Just load all of the data in and plot it
    % together.
    
   
    path = '/Users/aweng/Google Drive File Stream/My Drive/formation';
    directory = 'data/2020-10-aging-test-cycles';
  
    
    full_path = fullfile(path, directory);
   
    files = find_files(full_path, 'UM_Internal');
    
    ref_table = readtable(fullfile(path, 'cell_tracker.xlsx'));
  
    set_default_plot_settings();
    
    
    fh = figure();
    ax1 = subplot(211); grid on; box on;
    xlabel('Cycle Index')
    ylabel('Discharge Capacity (Ah)')
    title('Room Temperature Aging')
    
    ax2 = subplot(212); grid on; box on;
    xlabel('Cycle Index');
    ylabel('Discharge Capacity (Ah)')
    title('High Temperature Aging (45C)')
    
    for i = 1:numel(files)
              
        file = files{i};
        
        [cycle_index, discharge_capacity] = get_capacity_data_from_file(file);
        
        info = get_cell_info(file, ref_table);
    
        if strcmpi(info.formation_protocol, 'baseline')
            color = 'k';
        else
            color = info.color;
        end
        
        if strcmpi(info.aging_test, 'rt')
            parent = ax1;
        else
            parent = ax2;
        end
        
        line(cycle_index, discharge_capacity, 'Color', color, ...
                'Parent', parent, ...
                'LineWidth', 2.0)
             
        cycles_to_50_percent(i) = interp1(discharge_capacity, cycle_index, 1.18);
        
    end
    
    keyboard
    
    linkaxes([ax1, ax2], 'xy');
    ylim(ax1, [0 2.5])
    
    
    keyboard
    
    
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
    
    idx_to_filter = find((tbl.MeanChargeCurrent_time_weighted__A_ < 0.5) | ...
                         (tbl.MeanDischargeCurrent_time_weighted__A_ > -0.5));
    
    
    cycle_index(idx_to_filter) = [];
    discharge_capacity(idx_to_filter) = [];
    
    % Remove last cycle which is not guaranteed to be a full cycle
    cycle_index(end) = [];
    discharge_capacity(end) = [];
    

end