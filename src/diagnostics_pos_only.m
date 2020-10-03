function [Xt, RMSE_V, Q, Vt, dVdQ] = diagnostics_pos_only(Q_data, V_data, type)
    % Takes in charge data and returns electrode-level parameters
    %
    % Args:
    %   Q_data:  charge capacity
    %   V_data: voltage data
    %   type: 'original', 'formation_ht', 'formation_rt'
    %
    % Outputs:
    %   Xt: output vector of parameters (5 x 1)

%     [Un, Up] = get_electrode_models(type);
    Un = type.Un_modified;
    Up = type.Up_modified;
    Cn = type.Cn;
    x100 = type.x100;
    % Flip the vectors so that the "charge" becomes a "discharge"
    % After this, Q = 0 corresponds to Vmax ~ 4.2V
    V_data = flipud(V_data);
    Q1 = Q_data(1);
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
    V = @(X, Q) Up(X(1) + Q / X(2)) - Un(x100 - Q / Cn);

    % Scaling the input params which have different units
    S = [20;1/5];

    % Get neg electrode params directly using PeakFind method
%     [Cn, x100] = solve_using_peak_find(Q_data, V_data);

    % Initial condition
    Xi = [0.03 ; 2.7] .* S;

    % Regularization
    L = 0;

    % Bounds
    lb = [0.00; 1.00] .* S;
    ub = [0.10; 3.00] .* S;

    % V: model
    % Vt_data: data

    % Cost function: sum-squared error + regularization
    fun = @(X) (V(X ./ S, Q_data) - V_data)' * ...
               (V(X ./ S, Q_data) - V_data) + ...
                  L * norm((X - Xi) ./ S, 2);

    nonCon = @(X) connon(X ./ S, 4.20, 3.0, max(Q_data), Up, Un);

    options = optimoptions('fmincon', ...
                            'Display', 'iter', ...
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
    Q = 0:0.01:(max(Q_data) -Q1);

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
%     ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - ...
%              Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    % Inequality constraint (nothing here)
    c = [];

end

function [Cn, x100] = solve_using_peak_find(capacity, voltage)

    Q1_REF = 0.129; % Peak 1 position based on 'original' Un
    Q2_REF = 0.49 ; % Peak 2 position based on 'original' Un

    [p1_idx, p2_idx] = find_peaks(capacity, voltage);

    Cn = (capacity(p2_idx) - capacity(p1_idx)) / (Q2_REF - Q1_REF);
    x100 = Q2_REF + (max(capacity) - capacity(p2_idx))./Cn;

end
