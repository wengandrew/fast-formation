function test_get_electrode_models()

    types = {'original', 'formation_rt', 'formation_ht'};
    colors = {'k', 'b', 'r'};

    set_default_plot_settings()

    fh = figure;
    ax1 = subplot(211);
    ylim([3.5, 4.4])
    xlabel('y')
    ylabel('Potential vs Li/Li^+ (V)')
    set(ax1, 'xdir', 'reverse')
    title('Positive Electrode')

    ax2 = subplot(212);
    ylim([0, 1.5])
    xlabel('x')
    ylabel('Potential vs Li/Li^+ (V)')
    title('Negative Electrode')

    x = linspace(0, 1, 100);
    y = linspace(0, 1, 100);

    for i = 1:numel(types)

        [Un, Up] = get_electrode_models(types{i});

        line(y, Up(y), 'parent', ax1, 'color', colors{i}, ...
                'displayname', get_label(types{i}))
        line(x, Un(x), 'parent', ax2, 'color', colors{i})

    end

    legend(ax1, 'show', 'interpreter', 'none')


    fh = figure;
    ax1 = subplot(211);
    xlabel('y')
    ylabel('dV/dy (V)')
    ylim([0 2])
    title('Positive Electrode')
    set(ax1, 'xdir', 'reverse')

    ax2 = subplot(212);
    xlabel('x')
    ylabel('dV/dx (V)')'
    ylim([0 2])
    title('Negative Electrode')

    x = linspace(0, 1, 100);
    y = linspace(0, 1, 100);

    for i = 1:numel(types)

        [Un, Up] = get_electrode_models(types{i});

        dvdy = abs(gradient(Up(y))./gradient(y));
        dvdx = abs(gradient(Un(x))./gradient(x));
        line(y, dvdy, 'parent', ax1, 'color', colors{i}, ...
            'displayname', get_label(types{i}))
        line(x, dvdx, 'parent', ax2, 'color', colors{i})

    end

    legend(ax1, 'show', 'interpreter', 'none')


end

function label =  get_label(type)

    switch type
        case 'original'
            label = 'Original';
        case 'formation_ht'
            label = 'Formation, 45C';
        case 'formation_rt'
            label = 'Formation, Room Temp';
    end

end
