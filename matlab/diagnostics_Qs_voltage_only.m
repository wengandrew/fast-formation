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
    %   RMSE_V: 
    

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
    % X(1): y100, positive stoic at Q = 0
    % X(2): Cp,   positive electrode capacity, Cp (Ah)
    % X(3): x100, negative stoic at Q = 0
    % X(4): Cn,   negative electrode capacity, Cn (Ah), 
    % X(5): Q_compensation for V_min constraint, e.g. Vmin is actually 3.05V and it needs to be 3.00V

    % This is the voltage model
    V = @(X, Q) Up(X(1) + Q / X(2)) - Un(X(3) - Q / X(4));

    % Scaling the input params which have different units
    S = [1; 1/6; 1; 1/6; 1];
    
    Xi = [0.0335; 2.70; 0.80 ; 2.7 ; 0.00] .* S;
    lb = [0.0235; 1.00; 0.80 ; 1.0 ; 0.00] .* S;
    ub = [0.0435; 3.5;  0.95 ; 2.85 ; 0.00] .* S;

    % V: model
    % Vt_data: data

    % Cost function: sum-squared error + regularization
    idx = find(V_data > 3.38);
    V_fit = V_data(idx);
    Q_fit = Q_data(idx);

    fun = @(X) (V(X ./ S, Q_fit) - V_fit)' * (V(X ./ S, Q_fit) - V_fit);
    
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
%     ceq(1) = Up(X(1)) - Un(X(3)) - Vmax;

    % Vmin constraint
    % ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - ...
    %          Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    ceq = [];
    
    % Inequality constraint (nothing here)
    c = [];

end

