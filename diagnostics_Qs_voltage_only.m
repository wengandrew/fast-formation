function [Xt, RMSE_V, Q, Vt, Qd, dVdQ] = diagnostics_Qs_voltage_only(Q_data, Vt_data)
    % Takes in charge data and returns electrode-level parameters
    %
    % Args:
    %   Q_data:  charge capacity
    %   Vt_data: voltage data 
    %
    % Outputs: 
    %   Xt: output vector of parameters (5 x 1)

    Un = negative_electrode_model();
    Up = positive_electrode_model();

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
    % X(2): positive electrode capacity, Cp
    % X(3): negative stoic at Q = 0
    % X(4): negative electrode capacity, Cn
    % X(5): Q_compensation for V_min constraint, e.g. Vmin is actually 3.05V and it needs to be 3.00V

    % This is the voltage model
    V = @(X, Q) Up(X(1) + Q / X(2)) - Un(X(3) - Q / X(4));

    Xi = [0.0354482643944522; 5.85; 0.83; 6.05567731579116; 1.0];
    Xi = [0.0335657819054567; 5.62771935348527; 0.814854000900884; 5.88906550748991; 0.971688659831337];
    Xt = [0.0335103194640638; 5.60732706355212; 0.828331456980839; 5.48683940635039; 0.951688659831337];
    
    % Regularization
    L = 0;

    % Scaling the input params which have different units
    S = [20; 1/6; 1; 1/6; 1];

    % Bounds
    lb = [0; 0; 0; 0; 0];
    ub = [1; 6; 1; 5; 2.5];
    % ub = [1;Xi(2)*1.01;1;Xi(4)*1.01];

    % There are three cases
    % V: model, Vt_data: data
    % cost function: sum-squared error + regularization
    fun = @(X) (V(X ./ S, Q_data) - Vt_data)' * (V(X ./ S, Q_data) - Vt_data) + L * norm((X - Xi) ./ S, 2);

    nonCon = @(X) connon(X ./ S, 4.20, 3.0, max(Q_data), Up, Un);

    options = optimoptions('fmincon', ...
                            'Display', 'iter', ...
                            'Algorithm', 'sqp', ...
                            'OptimalityTolerance', 1e-7, ...
                            'MaxFunctionEvaluations', 9000);

    [Xr, fval, exitflag] = fmincon(fun, Xi .* S, [], [], [], [], [], [], nonCon, options);
    %  problem = createOptimProblem('fmincon','x0',Xi.*S,'objective',fun,'lb',lb.*S,'ub',ub.*S,'nonlcon',nonCon,'options',options);
    %  gs = GlobalSearch;
    %  [Xr,fval,exitflag,output,manymins] = run(gs,problem);
    RMSE_V = sqrt((V(Xr ./ S, Q_data) - Vt_data)' * (V(Xr ./ S, Q_data) - Vt_data) / length(Q_data));

    % Revert scaling
    Xt = Xr ./ S;

    % Add the Qs (compensation)
    Q = 0:0.01:(max(Q_data) + Xt(5));
    % Q = 0:0.01:(max(Q_data));

    % Return the results

    Vt = V(Xt, Q); % The modeled voltage prediction
    dV = Vt(2:end) - Vt(1:end - 1); % Fitted predictions
    dQ = Q(2:end) - Q(1:end - 1);
    Qd = Q(1:end - 1) + (Q(2:end) - Q(1:end - 1)) ./ 2;

    dVdQ = dV ./ dQ;

end

function [c, ceq] = connon(X, Vmax, Vmin, Qmax, Up, Un)
    % Non-linear constraints for fmincon

    % Equality constraints
    ceq(1) = Up(X(1)) - Un(X(3)) - Vmax;
    ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    % Inequality constraint (nothing here)
    c = [];

end

function Un = negative_electrode_model()
    % Negative electrode during lithiation, 25C
    % Graphite

    Un = @(x) 0.063 + 0.8 * exp(-75 * (x + 0.007)) + ...
        -0.0120 * tanh((x - 0.127) / 0.016) + ...
        -0.0118 * tanh((x - 0.155) / 0.016) + ...
        -0.0035 * tanh((x - 0.220) / 0.020) + ...
        -0.0095 * tanh((x - 0.190) / 0.013) + ...
        -0.0145 * tanh((x - 0.490) / 0.018) + ...
        -0.0800 * tanh((x - 1.030) / 0.055); 
    
end

function Up = positive_electrode_model()
    % Positive electrode during delithiation, 25C
    
    Up = @(y) 4.3452 - 1.6518 * (y) + 1.6225 * (y).^2 - ...
              2.0843 * (y).^3 + 3.5146 * y.^4 - 2.2166 * y.^5 - ...
              0.5623e-4 * exp(109.451 * (y) - 100.006);

end
