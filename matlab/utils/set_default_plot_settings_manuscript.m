function set_default_plot_settings_manuscript()
    % Format plot for submission to manuscripts
    
    set(0, 'DefaultAxesLineWidth', 1.5)
    set(0, 'DefaultLineLineWidth', 1.5)

    set(0, 'DefaultAxesFontSize', 20)
    set(0, 'DefaultAxesFontName', 'Times New Roman')

    set(0, 'DefaultFigureColor', [1 1 1])
    set(0, 'DefaultFigurePosition', [400 250 900 750])

    set(0, 'defaultAxesTickLabelInterpreter','latex'); 
    set(0, 'defaultLegendInterpreter','latex');


end
