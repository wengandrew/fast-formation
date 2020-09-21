function [Xt, RMSE_V, RMSE_E, Q, Vt, Qd, Et, dVdQ] = diagnostics_Qs(...
    Q_data, Vt_data, Qf_data, Dis_data, Xi, i, Cpi, Cni, n)
    % Takes in charge data and returns electrode-level parameters
    %
    % Args:
    %   Q_data:  charge capacity
    %   Vt_data: voltage data 
    %   Qf_data: expansion data from DAQ (LVDT) 
    %   Dis_data: displacement data from DAQ (LVDT) 
    %   Xi: initial guess (5 x 1) 
    %   i: iteration for different files 
    %   Cpi: param related to expansion model and for i > 1
    %   Cni: param related to expansion model and for i > 1 
    %   n: is a selector for the optimization 
    %   1. Voltage only 
    %   2. Expansion only 
    %   3. Voltage + expansion
    %
    % Outputs: 
    %   Xt: output vector of parameters (5 x 1)
    %
    % For Battery Formation data, there is no strain measurements, so comment
    % out everything related to Qf_data, Dis_data. The strain is measured using
    % a LVDT; measure displacement of middle plate using a contact sensor to
    % measure thickness change

    % Negative electrode during lithiation, 25C
    % Graphite
    Un = @(x) 0.063 + 0.8 * exp(-75 * (x + 0.007)) + ...
        -0.0120 * tanh((x - 0.127) / 0.016) + ...
        -0.0118 * tanh((x - 0.155) / 0.016) + ...
        -0.0035 * tanh((x - 0.220) / 0.020) + ...
        -0.0095 * tanh((x - 0.190) / 0.013) + ...
        -0.0145 * tanh((x - 0.490) / 0.018) + ...
        -0.0800 * tanh((x - 1.030) / 0.055);

    % Positive electrode during delithiation, 25C
    Up = @(y) 4.3452 - 1.6518 * (y) + 1.6225 * (y).^2 - ...
              2.0843 * (y).^3 + 3.5146 * y.^4 - 2.2166 * y.^5 - ...
              0.5623e-4 * exp(109.451 * (y) - 100.006);
    ​
    del_n = 62e-6; % Graphite
    del_p = 67e-6; % NMC
    ​
    es_n = 0.610; % Active material ration   Graphite
    es_p = 0.451;

    % Flip the vectors so that the "charge" becomes a "discharge"
    % After this, Q = 0 corresponds to Vmax ~ 4.2V
    Vt_data = flipud(Vt_data);
    Q_data = flipud(max(Q_data) - Q_data);
    ​
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
    ​
    Eq = @(X) E(X, Qf_data);
    [Qf_data, ia] = unique(Qf_data);
    Dis_data = interp1(Qf_data, Dis_data(ia), Q_data, 'pchirp', 'extrap');
    Dis_t = flipud(-Dis_data + Dis_data(end));

    %% Only executed in presence of displacement data
    if isempty(Dis_data) == 1
        n = 1;
    else
        n = 3;
        Qf_data = flipud(max(Qf_data) - Qf_data);
        Dis_data = flipud(max(Dis_data) - Dis_data);

        if i == 1
            % Expansion model
            E = @(X, Q) 30e6 * ((ep(X(1)) - ep(X(1) + Q / X(2))) * es_p * del_p + (en(X(3)) - en(X(3) - Q / X(4))) * es_n * del_n);
        else
            E = @(X, Q) 30e6 * ((ep(X(1)) - ep(X(1) + Q / X(2))) * es_p * del_p * X(2) / Cpi + (en(X(3)) - en(X(3) - Q / X(4))) * es_n * del_n * X(4) / Cni);
        end

    end

    Xi = [0.0354482643944522; 5.85; 0.83; 6.05567731579116; 1.0];
    Xi = [0.0335657819054567; 5.62771935348527; 0.814854000900884; 5.88906550748991; 0.971688659831337];
    Xt = [0.0335103194640638; 5.60732706355212; 0.828331456980839; 5.48683940635039; 0.951688659831337];
    ​
    ​% Regularization
    L = 0;

    % Scaling the input params which have different units
    S = [20; 1/6; 1; 1/6; 1];

    % Bounds
    lb = [0; 0; 0; 0; 0];
    ub = [1; 6; 1; 5; 2.5];
    % ub = [1;Xi(2)*1.01;1;Xi(4)*1.01];
    ​
    ​
    ​% There are three cases
    switch n
        case 1
            % V: model, Vt_data: data
            % cost function: sum-squared error + regularization
            fun = @(X) (V(X ./ S, Q_data) - Vt_data)' * (V(X ./ S, Q_data) - Vt_data) + L * norm((X - Xi) ./ S, 2);

            nonCon = @(X) connon(X ./ S, 4.20, 3.0, max(Q_data), Up, Un);

            options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp', 'OptimalityTolerance', 1e-7, 'MaxFunctionEvaluations', 9000);
            [Xr, fval, exitflag] = fmincon(fun, Xi .* S, [], [], [], [], [], [], nonCon, options);
            %             problem = createOptimProblem('fmincon','x0',Xi.*S,'objective',fun,'lb',lb.*S,'ub',ub.*S,'nonlcon',nonCon,'options',options);
            %             gs = GlobalSearch;
            %             [Xr,fval,exitflag,output,manymins] = run(gs,problem);
            RMSE_V = sqrt((V(Xr ./ S, Q_data) - Vt_data)' * (V(Xr ./ S, Q_data) - Vt_data) / length(Q_data));
            % RMSE_E = sqrt((arrayfun(@(Q) E(Xr./S,Q), Qf_data)-Dis_data)'*(arrayfun(@(Q) E(Xr./S,Q), Qf_data)-Dis_data)/length(Qf_data));
        case 2
            fun = @(X) 1e-4 * ((arrayfun(@(Q) E(X ./ S, Q), Q_data) - Dis_t)' * (arrayfun(@(Q) E(X ./ S, Q), Q_data) - Dis_t)) + L * norm((X - Xi) ./ S, 2);
            options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'interior-point', 'OptimalityTolerance', 1e-7, 'MaxFunctionEvaluations', 9000);
            [Xr, fval, exitflag] = fmincon(fun, Xi .* S, [], [], [], [], [], [], [], options);
            RMSE_V = sqrt((V(Xr ./ S, Q_data) - Vt_data)' * (V(Xr ./ S, Q_data) - Vt_data) / length(Q_data));
            RMSE_E = sqrt((arrayfun(@(Q) E(Xr ./ S, Q), Qf_data) - Dis_data)' * (arrayfun(@(Q) E(Xr ./ S, Q), Qf_data) - Dis_data) / length(Qf_data));
        case 3
            fun = @(X) (V(X ./ S, Q_data) - Vt_data)' * (V(X ./ S, Q_data) - Vt_data) + 1e-7 * ((arrayfun(@(Q) E(X ./ S, Q), Qf_data) - Dis_data)' * (arrayfun(@(Q) E(X ./ S, Q), Qf_data) - Dis_data)) + L * norm((X - Xi) ./ S, 2);
            nonCon = @(X) connon(X ./ S, 4.20, 3.0, max(Q_data), Up, Un);
            options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'interior-point', 'OptimalityTolerance', 1e-7, 'MaxFunctionEvaluations', 9000);
            %         if i == 1
            problem = createOptimProblem('fmincon', 'x0', Xi .* S, 'objective', fun, 'lb', lb .* S, 'ub', ub .* S, 'nonlcon', nonCon, 'options', options);
            gs = GlobalSearch;
            [Xr, fval, exitflag, output, manymins] = run(gs, problem);
            %         else
            %             [Xr,fval,exitflag] = fmincon(fun,Xi.*S,[],[],[],[],lb.*S,ub.*S,nonCon,options);
            %         end
            RMSE_V = sqrt((V(Xr ./ S, Q_data) - Vt_data)' * (V(Xr ./ S, Q_data) - Vt_data) / length(Q_data));
            RMSE_E = sqrt((arrayfun(@(Q) E(Xr ./ S, Q), Qf_data) - Dis_data)' * (arrayfun(@(Q) E(Xr ./ S, Q), Qf_data) - Dis_data) / length(Qf_data));
    end

    % Revert scaling
    Xt = Xr ./ S;
    ​
    % Add the Qs (compensation)
    Q = 0:0.01:(max(Q_data) + Xt(5));
    % Q = 0:0.01:(max(Q_data));
    ​
    % Return the results
    ​
    Vt = V(Xt, Q); % The modeled voltage prediction
    dV = Vt(2:end) - Vt(1:end - 1); % Fitted predictions
    dQ = Q(2:end) - Q(1:end - 1);
    Qd = Q(1:end - 1) + (Q(2:end) - Q(1:end - 1)) ./ 2;
    ​

    if isempty(Dis_data) == 1
        Et = [];
        RMSE_E = [];
    else

        for i = 1:length(Q)
            Et(i) = E(Xt, Q(i));
        end

    end

    dVdQ = dV ./ dQ;
    ​
end

​

function e = en(x)
    ​

    if x < 0.12
        e = 2.4060/0.12 * x;
    elseif 0.12 <= x && x < 0.18
        e = -(2.4060 - 3.3568) / 0.06 * (x - 0.12) + 2.4060;
    elseif 0.18 <= x && x < 0.24
        e = -(3.3568 - 4.3668) / 0.06 * (x - 0.18) + 3.3568;
    elseif 0.24 <= x && x < 0.50
        e = -(4.3668 - 5.583) / 0.26 * (x - 0.24) + 4.3668;
    elseif 0.50 <= x
        e = -(5.583 - 13.0635) / 0.50 * (x - 0.50) + 5.583;
    end

    e = e / 100;
end

​

function e = ep(y)
    ​
    e = -1.10/100 * (1 - y);
    ​
end

​

function [c, ceq] = connon(X, Vmax, Vmin, Qmax, Up, Un)
    % Non-linear constraints for fmincon

    % Equality constraints
    ceq(1) = Up(X(1)) - Un(X(3)) - Vmax;
    ceq(2) = Up(X(1) + (Qmax + X(5)) / X(2)) - Un(X(3) - (Qmax + X(5)) / X(4)) - Vmin;

    % Inequality constraint (nothing here)
    c = [];

end
