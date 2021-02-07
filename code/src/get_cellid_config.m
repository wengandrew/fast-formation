function aes = get_cellid_config(cellid)
    % Returns a struct containing plotting options which depend on what
    % test set the cellid belongs to

    if ismember(cellid, [1, 10, 2, 3, 4, 5, 6, 7, 8, 9])
        aes.temperature = 'HT';
        aes.group = 'Baseline, 45°C';
        aes.electrode_model = 'formation_ht';
        aes.linestyle = '-';
        aes.color = [0 0 0];
    elseif ismember(cellid, [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
        aes.temperature = 'RT';
        aes.group = 'Baseline, Room Temp';
        aes.electrode_model = 'formation_rt';
        aes.linestyle = '-';
        aes.color = [0 0 0];
    elseif ismember(cellid, [31, 32, 33, 34, 35, 36, 37, 38, 39, 40])
        aes.temperature = 'HT';
        aes.group = 'Fast, 45°C';
        aes.electrode_model = 'formation_ht';
        aes.linestyle = '-';
        aes.color = [1 0 0];
    elseif ismember(cellid, [21, 22, 23, 24, 25, 26, 27, 28, 29, 30])
        aes.temperature = 'RT';
        aes.group = 'Fast, Room Temp';
        aes.electrode_model = 'formation_rt';
        aes.linestyle = '-';
        aes.color = [0 0 1];
    end

    % if ismember(aes.group, {'Baseline HT', 'Baseline RT'})
    %     aes.linestyle = '-';  % baseline formation
    % else
    %     aes.linestyle = '--'; % micro-formation
    % end

    % if ismember(aes.group, {'Baseline HT', 'MicroForm HT'})
    %     aes.color = [1 0 0];
    % else
    %     aes.color = [0 0 1];
    % end

end
