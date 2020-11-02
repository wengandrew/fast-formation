function [Xt, RMSE_V, Q, Vt, dVdQ] = diagnostics_Qs_voltage_only(Q_data, V_data, Un, Up)
    % Takes in charge data and returns electrode-level parameters
    %
    % Args:
    %   Q_data:  charge capacity
    %   V_data: voltage data
    %   type: 'original', 'formation_ht', 'formation_rt'
    %
    % Outputs:
    %   Xt: output vector of parameters (5 x 1)
    
    SOLVE_USING_PEAK_FIND = false;

    % Get neg electrode params directly using PeakFind method
    if SOLVE_USING_PEAK_FIND
        [Cn, x100] = solve_using_peak_find(Q_data, V_data);
    end

    % Flip the vectors so that the "charge" becomes a "discharge"
    % After this, Q = 0 corresponds to Vmax ~ 4.2V
    V_data = flipud(V_data);
    Q_data = flipud(max(Q_data) - Q_data);

    % OCV model for discharge
    %   Up is the positive electrode OCP
    %   Un is the negative electrode OCP
    %
    % Intuition:
    %   if Q = 0 --> X(1) and X(3) are left
    %
    % X(1): positive stoic at Q = 0
    % X(2): positive electrode capacity, Cp (Ah)
    % X(3): negative stoic at Q = 0
    % X(4): negative electrode capacity, Cn (Ah)
    % X(5): Q_compensation for V_min constraint, e.g. Vmin is actually 3.05V and it needs to be 3.00V

    % This is the voltage model
    V = @(X, Q) Up(X(1) + Q / X(2)) - Un(X(3) - Q / X(4));

    % Scaling the input params which have different units
    S = [1; 1/6; 1; 1/6; 1];

    % Get neg electrode params directly using PeakFind method
    [Cn, x100] = solve_using_peak_find(Q_data, V_data);

    if SOLVE_USING_PEAK_FIND
        Xi = [0.03; 2.70; x100 ; Cn ; 0.00] .* S;
        lb = [0.00; 1.00; x100 ; Cn ; 0.00] .* S;
        ub = [0.10; 3.00; x100 ; Cn ; 0.10] .* S;
    else
        Xi = [0.03; 2.70; 0.80 ; 2.7 ; 0.00] .* S;
        lb = [0.00; 1.00; 0.00 ; 1.0 ; 0.00] .* S;
        ub = [0.10; 3.5; 1.00 ; 3.5 ; 0.00] .* S;
    end

    % Regularization
    L = 0;

    % V: model
    % Vt_data: data

    % Cost function: sum-squared error + regularization
    idx = find(V_data > 3.38);
    V_fit = V_data(idx);
    Q_fit = Q_data(idx);

    fun = @(X) (V(X ./ S, Q_fit) - V_fit)' * ...
               (V(X ./ S, Q_fit) - V_fit) + ...
                  L * norm((X - Xi) ./ S, 2);

    nonCon = @(X) connon(X ./ S, 4.20, 3.0, max(Q_fit), Up, Un);

    options = optimoptions('fmincon', ...
                            'Display', 'none', ...
                            'Algorithm', 'sqp', ...
                            'OptimalityTolerance', 1e-7, ...
                            'MaxFunctionEvaluations', 9000);

    % Procedure for finding local minimum
    % [Xr, fval, exitflag] = fmincon(fun, Xi, [], [], [], [], lb, ub, ...
                            % nonCon, options);

    % Procedure for finding global minimum
    problem = createOptimProblem('fmincon', 'x0', Xi, ...
                'objective', fun, ...
                'lb', lb, 'ub', ub, ...
                'nonlcon', nonCon, ...
                'options', options);

    gs = GlobalSearch;
    [Xr, fval, exitflag, output, manymins] = run(gs, problem);

    RMSE_V = sqrt((V(Xr ./ S, Q_data) - V_data)' * ...
                  (V(Xr ./ S, Q_data) - V_data) / length(Q_data));

    % Revert scaling
    Xt = Xr ./ S;

    % Add the Qs (compensation)
    Q = 0:0.01:(max(Q_data) + Xt(5));

    % Return the results
    Vt = V(Xt, Q); % The modeled voltage prediction
    dVdQ = gradient(Vt) ./ gradient(Q);

    % Flip back to charge curve
    Vt = fliplr(Vt);
    dVdQ = fliplr(dVdQ);


end

function [c, ceq] = connon(X, Vmax, Vmin, Qmax, Up, Un)
    % Non-linear constraints for fmincon

    % Equality constraints

    % Vmax constraint
    ceq(1) = Up(X(1)) - Un(X(3)) - Vmax;

    % Vmin constraint
    % ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - ...
    %          Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    % Inequality constraint (nothing here)
    c = [];

end

function [Cn, x100] = solve_using_peak_find(capacity, voltage)
    %
    % Args
    %  capacity: CHARGE capacity curve
    %  voltage: CHARGE voltage curve

    Q1_REF = 0.129; % Peak 1 position based on 'original' Un
    Q2_REF = 0.49 ; % Peak 2 position based on 'original' Un

    [p1_idx, p2_idx] = find_peaks(capacity, voltage);

    Cn = (capacity(p2_idx) - capacity(p1_idx)) / (Q2_REF - Q1_REF);

    x100 = Q2_REF + (max(capacity) - capacity(p2_idx))./Cn;

end
