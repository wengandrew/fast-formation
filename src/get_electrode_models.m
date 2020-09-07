function [Un, Up] = get_electrode_models()
    
    Un = negative_electrode_model();
    Up = positive_electrode_model();
    
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