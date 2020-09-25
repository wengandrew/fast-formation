function [Xt, RMSE_V, Q, Vt, dVdQ] = diagnostics_Qs_voltage_only(Q_data, Vt_data, type)
    % Takes in charge data and returns electrode-level parameters
    %
    % Args:
    %   Q_data:  charge capacity
    %   Vt_data: voltage data
    %   type: 'original', 'formation_ht', 'formation_rt'
    %
    % Outputs:
    %   Xt: output vector of parameters (5 x 1)

    [Un, Up] = get_electrode_models(type);

    % Flip the vectors so that the "charge" becomes a "discharge"
    % After this, Q = 0 corresponds to Vmax ~ 4.2V
    Vt_data = flipud(Vt_data);
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

    % Initial condition
    Xi = [0.03 ; 2.70 ; 0.88 ; 2.75 ; 0.01] .* S;
    Xi = [0.01 ; 1.00 ; 0.88 ; 2.75 ; 0.01] .* S;
    Xi = [0.03 ; 2.7 ; 0.5 ;  2.00 ; 0.01] .* S;

    % Regularization
    L = 0;

    % Bounds
    lb = [0.00; 1.00; 0; 2.00; 0.0] .* S;
    ub = [0.10; 3.00; 1; 3.00; 0.1] .* S;

    % V: model
    % Vt_data: data

    % Cost function: sum-squared error + regularization
    fun = @(X) (V(X ./ S, Q_data) - Vt_data)' * ...
               (V(X ./ S, Q_data) - Vt_data) + ...
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

    RMSE_V = sqrt((V(Xr ./ S, Q_data) - Vt_data)' * ...
                  (V(Xr ./ S, Q_data) - Vt_data) / length(Q_data));

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

    % Vmin constraint
    ceq(1) = Up(X(1)) - Un(X(3)) - Vmax;

    % Vmax constraint
    ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - ...
             Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    % Inequality constraint (nothing here)
    c = [];

end

