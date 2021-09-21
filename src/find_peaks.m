function [p1_idx, p2_idx, dvdq] = find_peaks(capacity, voltage)
    % Returns indices corresponding to peak 1 and peak 2 given a
    % capacity vs voltage charge curve
    %
    % Args
    %   capacity: charge capacity curve
    %   voltage: charge voltage curve
    %
    % Returns
    %   p1_idx: index for peak 1
    %   p2_idx: index for peak 2
    %   dvdq: dV/dQ curve used during the processing

    set_default_plot_settings();
    
    assert(is_charge_curve(capacity, voltage))

    dvdq = golay_filter(capacity, voltage);

    [p1_idx, p1_dvdq] = find_peak_1(capacity, dvdq);
    [p2_idx, p2_dvdq] = find_peak_2(capacity, dvdq);

end

function tf = is_charge_curve(capacity, voltage)
    % Returns true if the inputs represent a charge curve (and not a
    % discharge curve)
    
    idx_max_cap = find(capacity == max(capacity));
    idx_min_cap = find(capacity == min(capacity));
    
    tf = voltage(idx_max_cap) > voltage(idx_min_cap);

end

function dvdq = golay_filter(capacity, voltage)
    % Return a smoothed dvdq curve

    N1 = 3; % Order of polynomial fit
    F1 = 7; % Window length

    [b1, g1] = sgolay(N1, F1);

    HalfWin = (F1 + 1) / 2 - 1;

    for n = (F1 + 1) / 2:length(voltage) - (F1 + 1) / 2

        % Zeroth derivative (smoothing only)
        SG0(n) = dot(g1(:, 1), capacity(n - HalfWin:n + HalfWin));

        % 1st differential
        SG1y(n) = dot(g1(:, 2), capacity(n - HalfWin:n + HalfWin));
        SG1x(n) = dot(g1(:, 2), voltage(n - HalfWin:n + HalfWin));

    end

    capacity_filtered = SG0(HalfWin + 1:end);
    dvdq_filtered = SG1x(HalfWin + 1:end) ./ SG1y(HalfWin + 1:end);

    dvdq = interp1(capacity_filtered, dvdq_filtered, capacity, ...
        'linear', 'extrap');

end

function [peak_idx, peak_dvdq] = find_peak_2(capacity, dvdq)

    SOC_MIN = 0.4;
    SOC_MAX = 0.8;

    soc = capacity ./ max(capacity);

    idx_min = find(soc > SOC_MIN, 1);
    idx_max = find(soc > SOC_MAX, 1);

    soc = soc(idx_min:idx_max);
    dvdq = dvdq(idx_min:idx_max);

    m = (dvdq(end) - dvdq(1)) / (soc(end) - soc(1));
    b = dvdq(end) - m * soc(1);
    dvdq_baseline = m * soc + b;

    dvdq_adjusted = dvdq - dvdq_baseline;

    [peak_dvdq_adjusted, peak_idx] = max(dvdq_adjusted);

    peak_dvdq = peak_dvdq_adjusted + dvdq_baseline(peak_idx);

    peak_idx = peak_idx + idx_min;

end

function [peak_idx, peak_dvdq] = find_peak_1(capacity, dvdq)

    SOC_MIN = 0.1;
    SOC_MAX = 0.4;

    soc = capacity ./ max(capacity);

    idx_min = find(soc > SOC_MIN, 1);
    idx_max = find(soc > SOC_MAX, 1);

    dvdq = dvdq(idx_min:idx_max);
    [peak_dvdq, peak_idx] = max(dvdq);
    peak_idx = peak_idx + idx_min;

end
