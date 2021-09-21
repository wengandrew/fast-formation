function plot_voltage_curves_before_formation()
% Use the equilibrium potential curves to plot the voltage profile before
% formation.

% Load the reference potential curves
[Un, Up] = get_electrode_models('original');

% Initialize the electrode specific capacities. This is a toy model so the
% values don't need to be exact. These specific values reference eSOH 
% results from fast formation cell #33.
Cp = 2.7397734876546456; % Ah
Cn = 2.734355150767673;  % Ah

% Full cell capacity reference
q_full_cell = 2.83; % Ah

% Expand the curves to complete the voltage curve

% Define anode and cathode stoichiometries
% - expand to include more complete voltage range 
% - find the ranges through trial and error
x = linspace(-0.020, 1.038, 1000);
y = linspace(-0.03208, 1.004, 1000);

q_shared = linspace(0, q_full_cell, 1000);

Un_interp = interp1((x - min(x)) .* Cn, Un(x), q_shared);
Up_interp = interp1((max(y) - y) .* Cp, Up(y), q_shared);

% Build the full cell voltage curve.
% Restrict the voltage range we want to plot

U_full = Up_interp - Un_interp;
q_shared(U_full < 0.0) = [];
U_full(U_full < 0.0) = [];
q_shared(U_full > 4.2) = [];
U_full(U_full > 4.2) = [];


Q_offs = min(q_shared);

Q_neg = (x - min(x)) .* Cn - Q_offs;
V_neg = Un(x);

Q_pos = (max(y) - y) .* Cp - Q_offs;
V_pos = Up(y);

q_full = q_shared - Q_offs;

% Make the figure
figure(); 

plot(Q_neg, V_neg, 'Color', 'r'); hold all;
plot(Q_pos , V_pos, 'Color', 'b'); hold all;
plot(q_full, U_full, 'DisplayName', 'Full Cell', 'Color', 'k')

xlim([-0.1 3])
xlabel('Capacity (Ah)', 'Interpreter', 'Latex')
ylabel('Potential (V vs Li/Li$^+$)', 'Interpreter', 'Latex')

% Package results and export to json
res.q_neg = Q_neg;
res.v_neg = V_neg;
res.q_pos = Q_pos;
res.v_pos = V_pos;
res.q_full = q_full;
res.v_full = U_full;

fid = fopen(sprintf('output/voltage_curves_before_formation.json'), 'w');
encoded_json = jsonencode(res);
fprintf(fid, encoded_json);  
fclose(fid);

end