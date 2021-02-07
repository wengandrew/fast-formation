function result = run_esoh(tbl, Un, Up)
    % Run electrode-level SOH algorithm on a dataset.
    % Also do some post-processing.
    %
    % Args
    %   tbl: the dataset as a MATLAB table
    %   Un: negative electrode model function
    %   Up: positive electrode model function
    %
    % Returns
    %   result: a struct holding results

    voltage = tbl.chg_voltage;
    capacity = tbl.chg_capacity;

    [Xt, RMSE_V, ful_cap, ful_pot, ful_dvdq_pot] = ...
        diagnostics_Qs_voltage_only(capacity, voltage, Un, Up);

    [pos_pot, pos_pot_dvdq] = calculate_pos(ful_cap, Xt, Up);
    [pos_pot, pos_cap, pos_pot_dvdq] = expand_pos(pos_pot, ful_cap, Xt, Up);

    [neg_pot, neg_pot_dvdq] = calculate_neg(ful_cap, Xt, Un);
    [neg_pot, neg_cap, neg_pot_dvdq] = expand_neg(neg_pot, ful_cap, Xt, Un);
    
    C = max(ful_cap);

    x100 = Xt(3);
    y100 = Xt(1);
    Cp = Xt(2);
    Cn = Xt(4);
    y0 = y100 + C/Cp;
    x0 = x100 - C/Cn; 
    np_ratio = Cn/Cp;

    % Get positive and negative electrode excess values
    Vn100 = interp1(neg_cap, neg_pot, max(ful_cap));
    Cn100 = interp1(neg_pot, neg_cap, Vn100);
    Cn_excess = max(neg_cap) - Cn100;
    Cp_excess = abs(min(pos_cap));
    
    n_li = 3600/96485 .* (y100 .* Cp + x100 .* Cn);

    % Package results
    result.Xt = Xt;
    result.np_ratio = np_ratio;
    result.Cp = Xt(2);
    result.Cn = Xt(4);
    result.y100 = y100;
    result.y0 = y0;
    result.x0 = x0;
    result.x100 = x100;
    result.n_li = n_li;
    result.Cn_excess = Cn_excess;
    result.Cp_excess = Cp_excess;
    result.Cf = max(ful_cap);
    result.RMSE_mV = RMSE_V*1000;
    
    % Full cell model curves
    result.ful.Q = ful_cap;
    result.ful.V = ful_pot;
    result.ful.dVdQ = abs(ful_dvdq_pot);

    % Positive electrode curves
    result.pos.Q = pos_cap;
    result.pos.V = pos_pot;
    result.pos.dVdQ = abs(pos_pot_dvdq);

    % Negative electrode curves
    result.neg.Q = neg_cap;
    result.neg.V = neg_pot;
    result.neg.dVdQ = abs(neg_pot_dvdq);

    % Original full cell data curves
    result.orig.Q = capacity;
    result.orig.V = voltage;
    result.orig.dVdQ = gradient(voltage)./gradient(capacity);
    
end


function [pot_full, cap_full, pot_dvdq_full] = expand_pos(pot, cap, Xt, Up)
    % Expands a positive potential vector given a capacity-potential curve in
    % the charge direction

    POS_MAX_VOLTAGE = 4.5;
    POS_MIN_VOLTAGE = 2.5;

    diff = cap(2) - cap(1);

    min_cap = min(cap);
    while Up(Xt(1) + min_cap / Xt(2)) < POS_MAX_VOLTAGE
        min_cap = min_cap - diff;
    end

    max_cap = max(cap);
    while Up(Xt(1) + max_cap / Xt(2)) > POS_MIN_VOLTAGE
        max_cap = max_cap + diff;
    end

    cap_full = min_cap:diff:max_cap;

    [pot_full, pot_dvdq_full] = calculate_pos(cap_full, Xt, Up);

    % Translate the capacity to curve to align with orig data
    Q1 = min(cap_full);
    Q2 = cap_full(abs(pot_full - min(pot)) < 1e-9) - ...
         cap_full(abs(pot_full - min(pot_full)) < 1e-9);
    cap_full = cap_full - Q1 - Q2;

end

function [pot_full, cap_full_shifted, pot_dvdq_full] = expand_neg(pot, cap, Xt, Un)
    % Expand a negative potential vector given a capacity-potential curve in the
    % charge direction

    NEG_MAX_VOLTAGE = 1.0;
    NEG_MIN_VOLTAGE = 0;

    diff = cap(2) - cap(1);

    min_cap = min(cap);
    while Un(Xt(3) - min_cap / Xt(4)) > NEG_MIN_VOLTAGE
        min_cap = min_cap - diff;
    end

    max_cap = max(cap);
    while Un(Xt(3) - max_cap / Xt(4)) < NEG_MAX_VOLTAGE
        max_cap = max_cap + diff;
    end

    cap_full = min_cap:diff:max_cap;

    [pot_full, pot_dvdq_full] = calculate_neg(cap_full, Xt, Un);

    % Translate the capacity to curve to align with orig data
    Q1 = min(cap_full);
    
    if max(pot) > max(pot_full)
        % No expansion needed
        Q2 =  0;
    else
        Q2 = cap_full(abs(pot_full - max(pot)) < 1e-9) - ...
         cap_full(abs(pot_full - max(pot_full)) < 1e-9);
    end
    cap_full_shifted = cap_full - Q1 - Q2;

end


function [pot, dvdq] = calculate_neg(cap, Xt, Un)
    % Returns a negative potential vector in the charge direction

    pot = Un(Xt(3) - cap / Xt(4));

    dVdQn = gradient(pot) ./ gradient(cap);

    % Convert curve from discharge to charge
    pot = fliplr(pot);
    dvdq = fliplr(dVdQn);

end

function [pot, dvdq] = calculate_pos(cap, Xt, Up)
    % Returns a positive potential vector in the charge direction

    pot = Up(Xt(1) + cap / Xt(2));

    dvdq = gradient(pot) ./ gradient(cap);

    % Convert curve from discharge to charge
    pot = fliplr(pot);
    dvdq = fliplr(dvdq);

end
