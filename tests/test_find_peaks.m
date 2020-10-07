function test_find_peaks()

    set_default_plot_settings()
    files = load_files();

    cmap = parula(numel(files));

    fh = figure();

    offs = 0;            % vertical offset in dvdq
    DELTA_OFFSET = 0.07; % delta offset in units of dvdq

    cmap = parula(numel(files));

    for i = 1:numel(files)

        file = files{i};

        [capacity, voltage, dvdq] = load_data(file);

        [p1_idx, p2_idx] = find_peaks(capacity, voltage);

        offs = offs + DELTA_OFFSET;

        line(capacity, dvdq + offs, 'Color', cmap(i, :));

        line(capacity(p1_idx), dvdq(p1_idx) + offs, ...
            'Color', cmap(i, :), ...
            'Marker', 'o', ...
            'MarkerFaceColor', cmap(i, :));

        line(capacity(p2_idx), dvdq(p2_idx) + offs, ...
            'Color', cmap(i, :), ...
            'Marker', 'o', ...
            'MarkerFaceColor', cmap(i, :));

    end

    xlabel('Charge Capacity (Ah)')
    ylabel('dV/dQ (V/Ah');
    ylim([0 5])


end

function files = load_files()

    files = find_files(...
        'output/2020-08-microformation-voltage-curves', ...
        'diagnostic_test');

end

function [capacity, voltage, dvdq] = load_data(file)

    tbl = readtable(file);

    capacity = tbl.charge_capacity;
    voltage = tbl.voltage;
    dvdq = tbl.dvdq;

end
