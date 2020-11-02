function [Un, Up] = get_electrode_models(type)
    % Returns half-cell electrode potential functions
    %
    % Args
    %  type (str): 'original', 'formation_rt', 'formation_ht'
    %
    %  formation_rt and formation_ht are recalibrated curves
    %
    % Returns
    %  Un: negative electrode potential funtion Un(x)
    %  Up: positive electrode potential function Up(y)

    Un = negative_electrode_model(type);
    Up = positive_electrode_model(type);

end

function Un = negative_electrode_model(type)
    % Negative electrode charge voltage curve
    %
    % Args
    %  type (str): 'original', 'formation_rt',' formation_ht'
    %
    % Returns
    %  a function: U(x)

    switch type

        case 'original'
            % Original curve from Peyman and Suhak

            Un = @(x) 0.063 + 0.8 * exp(-75 * (x + 0.007)) + ...
                -0.0120 * tanh((x - 0.127) / 0.016) + ...
                -0.0118 * tanh((x - 0.155) / 0.016) + ...
                -0.0035 * tanh((x - 0.220) / 0.020) + ...
                -0.0095 * tanh((x - 0.190) / 0.013) + ...
                -0.0145 * tanh((x - 0.490) / 0.018) + ...
                -0.0800 * tanh((x - 1.030) / 0.055);


        case 'formation_rt'
            % Re-estimation of Un using room-temperature data from cell [x]
            % Thanks Peyman

            Un = @(x) 0.08 + 1 * exp(-130 * (x - 0.02)) + ...
                -0.0120 * tanh((x - 0.127) / 0.016) + ...
                -0.0118 * tanh((x - 0.155) / 0.016) + ...
                -0.0035 * tanh((x - 0.230) / 0.015) + ...
                -0.0095 * tanh((x - 0.190) / 0.013) + ...
                -0.0145 * tanh((x - 0.490) / 0.018) + ...
                -0.0800 * tanh((x - 1.030) / 0.055);

        case 'formation_ht'
            % Re-estimation of Un using high-temperature data from cell 31
            % Thanks Peyman

            Un = @(x) 0.08 + 1 * exp(-75 * (x + 0.00)) + ...
                - 0.0120 * tanh((x - 0.127) / 0.016) + ...
                - 0.0118 * tanh((x - 0.155) / 0.016) + ...
                - 0.0035 * tanh((x - 0.230) / 0.015) + ...
                - 0.0095 * tanh((x - 0.190) / 0.013) + ...
                - 0.0145 * tanh((x - 0.490) / 0.018) + ...
                - 0.0800 * tanh((x - 1.030) / 0.055);

    end

end

function Up = positive_electrode_model(type)
    % Positive electrode voltage charge curve

    switch type

        case 'original'

        Up = @(y) 4.3452 - 1.6518 * (y) + 1.6225 * (y).^2 - ...
                    2.0843 * (y).^3 + 3.5146 * y.^4 - 2.2166 * y.^5 - ...
                    0.5623e-4 * exp(109.451 * (y) - 100.006);

        case 'formation_rt'

            % Re-estimated Up using RT data from cell [x]
            % Thanks Peyman

            Up_fit = @(X, y) X(1) + X(2) * (y) + X(3) * (y).^2 + ...
                    X(4) * (y).^3 + X(5) * y.^4 + X(6) * y.^5 + ...
                    X(7) * exp(X(8) * (y) + X(9)); % NMC

            X_targ = [4.34009327563775; -1.54462232593124; 0.409055823762215; ...
                    2.12073344868274; -1.82451354536166; 0.0218169581321442; ...
                    0; 100; -100];

            Up = @(y) Up_fit(X_targ, y); % NMC RT

        case 'formation_ht'

            % Re-estimated Up using HT data from cell 31
            % Thanks Peyman

            Up_fit = @(X, y) X(1) + X(2) * (y) + X(3) * (y).^2 + ...
                    X(4) * (y).^3 + X(5) * y.^4 + X(6) * y.^5 + ...
                    X(7) * exp(X(8) * (y) + X(9));

            X_targ = [4.33593745970218; -1.39533828457540; -0.363244756326384; ...
                    4.13955937087940; -4.37780665398219; 1.23771708335003; ...
                    0; 100; -100];

            Up = @(y) Up_fit(X_targ, y); % NMC HT

    end

end
