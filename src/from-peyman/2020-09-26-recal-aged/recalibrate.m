function [Un_modified, Up_modified] = recalibrate(Voltage, Q, Xt, Un, Up)

    y100 = Xt(1);
    Cp = Xt(2);
    x100 = Xt(3);
    Cn = Xt(4);

    x0 = x100 - max(Q) ./ Cn;

    Un_data = -Voltage + Up(y100 + (max(Q) - Q) ./ Cp);

    Xi = [0.063; -75; 0];

    Un_reduced = @(X, x) X(1) + 1 * exp(X(2) * x + X(3)) + ...
        -0.0120 * tanh((x - 0.127 + 0.015) / 0.016) + ...
        -0.0118 * tanh((x - 0.155 + 0.015) / 0.016) + ...
        -0.0035 * tanh((x - 0.230 + 0.015) / 0.015) + ...
        -0.0095 * tanh((x - 0.190 + 0.015) / 0.013) + ...
        -0.0145 * tanh((x - 0.500) / 0.018) + ...
        -0.0800 * tanh((x - 1.030 + 0.015) / 0.055);

    xtarg_g = x0 + (Q) ./ Cn;
    xtarg = xtarg_g(1:100);
    Vtarg = Un_data(1:100);

    fun = @(X) norm(Un_reduced(X, xtarg) - Vtarg, 1);

    options = optimoptions('fmincon', 'Display', 'iter', ...
        'Algorithm', 'interior-point', ...
        'OptimalityTolerance', 1e-7, ...
        'MaxFunctionEvaluations', 9000);

    [Xr, fval, exitflag] = fmincon(fun, Xi, [], [], [], [], ...
                    [], [], [], options);

    Un_modified = @(x) Un_reduced(Xr, x);

    Up_data = Voltage + Un_modified(x0 + Q ./ Cn);

    Xi = [4.35; -1.9762; 2.3514; 2.1042; -1.3877; -1.9123; 0; 100; -100];
    Up = @(X, y) X(1) + X(2) * (y) + X(3) * (y).^2 + X(4) * (y).^3 + X(5) * y.^4 + X(6) * y.^5 + X(7) * exp(X(8) * (y) + X(9)); % NMC

    ytarg = y100 + (max(Q) - Q) ./ Cp;

    ytarg = ytarg(100:end);
    Vtarg = Up_data(100:end);

    S = [1; 1; 1; 1; 1; 1; 1e4; 1/100; 1/100];
    fun = @(X) (Up(X ./ S, ytarg) - Vtarg)' * (Up(X ./ S, ytarg) - Vtarg);

    options = optimoptions('fmincon', 'Display', 'iter', ...
        'Algorithm', 'interior-point', ...
        'OptimalityTolerance', 1e-7, ...
        'MaxFunctionEvaluations', 9000);

    [Xr, fval, exitflag] = fmincon(fun, Xi .* S, [], [], [], [], ...
                 [], [], [], options);

    Up_modified = @(y) Up(Xr ./ S, y);

end
