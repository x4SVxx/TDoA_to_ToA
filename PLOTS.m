function [] = PLOTS(config,...
                    delta,...
                    times_send_user,...
                    times_send_system,...
                    ranges_AKF_PR,...
                    ranges_true,...
                    state_vectors_LSM_R,...
                    state_vectors_LSM_PR,...
                    state_vectors_LSM_DR,...
                    state_vectors_EKF_PR,...
                    state_vectors_EKF_DR,...
                    GDOP_R_matrix,...
                    GDOP_PR_matrix,...
                    GDOP_DR_matrix)
    %% FIGURE POSITION          
    figure_position = [300, 150, 800, 600];
    
    %% PLOTS RANGES AFTER EKF PR + TRUE RANGES
    figure('Position', figure_position)
    hold on
    title('Ranges after EKF PR + true ranges', 'FontSize', config.title_font_size)
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Дальности, м', 'FontSize', config.axes_font_size)
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    for i = 1:length(config.anchors)
        plot(times_send_user, ranges_AKF_PR(i, :), 'ro', 'LineWidth', 2, 'MarkerSize', 1)
        plot(times_send_user, ranges_true(i, :), 'ko', 'LineWidth', 1, 'MarkerSize', 1)
    end
    legend('Оценка дальностей ПД РФК', 'Истинные дальности')
    
    
    
    
    
    
    
    
   
%     %% HISTOGRAMS
%     figure('Position', figure_position)
%     set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     for i = 1:length(config.anchors)
%         subplot(length(config.anchors) / 2,2,i)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         hold on
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hist(ranges_AKF_PR(i, :), 1000)
%         plot(ranges_true(i, 1), 1:10, 'rs', 'MarkerSize', 3)
%         plot(ranges_true(i, 1) - config.sigma_R * 3, 1:10, 'rs', 'MarkerSize', 3)
%         plot(ranges_true(i, 1) + config.sigma_R * 3, 1:10, 'rs', 'MarkerSize', 3)
%         xlim([ranges_true(i, 1) - config.sigma_R * 4, ranges_true(i, 1) + config.sigma_R * 4])
%     end
    
    
    
    
    
    
    
    
    
    
%     %% PLOTS TIMESCALES DIVERGENCE
%     figure('Position', figure_position)
%     title('Timescale divergence', 'FontSize', config.title_font_size)
%     hold on
%     grid on
%     xlabel('User timescale / System timescale', 'FontSize', config.axes_font_size)
%     ylabel('User timescale', 'FontSize', config.axes_font_size)
%     xlim([-1 config.time_simulation + 2])
%     ylim([-1 config.time_simulation + 2])
%     plot(times_send_user, times_send_system, 'r', 'LineWidth', 2)
%     plot(times_send_user, times_send_system, 'g', 'LineWidth', 2)
    
    
    
    
    
    
    
    
    
    
%% PLOTS DELTA
    figure('Position', figure_position)
    title('Δ', 'FontSize', config.title_font_size)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Delta, с', 'FontSize', config.axes_font_size)
    xlim([-1 config.time_simulation + 2])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(times_send_user, delta(1, :), 'b', 'LineWidth', 2)
    if config.static_dynamic_flag == 0
        plot(times_send_user, state_vectors_EKF_PR(4, :), 'g', 'LineWidth', 2)
    end
    if config.static_dynamic_flag == 1
        plot(times_send_user, state_vectors_EKF_PR(10, :), 'g', 'LineWidth', 2)
    end
    legend('Истинные значения', 'Оценка ПД РФК')

    %% PLOTS DELTA WITH DOT
    figure('Position', figure_position)
    title('Δ.', 'FontSize', config.title_font_size)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('DeltaDOT, с', 'FontSize', config.axes_font_size)
    xlim([-1 config.time_simulation + 2])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(times_send_user, delta(2, :), 'b', 'LineWidth', 2)
    if config.static_dynamic_flag == 0
        plot(times_send_user, state_vectors_EKF_PR(5, :), 'g', 'LineWidth', 2)
    end
    if config.static_dynamic_flag == 1
        plot(times_send_user, state_vectors_EKF_PR(11, :), 'g', 'LineWidth', 2)
    end
    legend('Истинные значения', 'Оценка ПД РФК')
    
    %% PLOTS DIFF DELTA
    figure('Position', figure_position)
    title('Δ разность истины и оценки', 'FontSize', config.title_font_size)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Время, с', 'FontSize', config.axes_font_size)
    xlim([-1 config.time_simulation + 2])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    if config.static_dynamic_flag == 0
        plot(times_send_user, delta(1, :) - state_vectors_EKF_PR(4, :), 'b', 'LineWidth', 2)
    end
    if config.static_dynamic_flag == 1
        plot(times_send_user, delta(1, :) - state_vectors_EKF_PR(10, :), 'b', 'LineWidth', 2)
    end
    
    %% PLOTS DIFF DELTA DOT
    figure('Position', figure_position)
    title('Δ. разность истины и оценки', 'FontSize', config.title_font_size)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Время, с', 'FontSize', config.axes_font_size)
    xlim([-1 config.time_simulation + 2])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    if config.static_dynamic_flag == 0
        plot(times_send_user, delta(2, :) - state_vectors_EKF_PR(5, :), 'b', 'LineWidth', 2)
    end
    if config.static_dynamic_flag == 1
        plot(times_send_user, delta(2, :) - state_vectors_EKF_PR(11, :), 'b', 'LineWidth', 2)
    end
    
    
    

    
    
    

%     figure('Position', figure_position)
%     set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     hold on
%     grid on
%     xlabel('X, метры', 'FontSize', config.axes_font_size)
%     ylabel('Y, метры', 'FontSize', config.axes_font_size)
%     zlabel('Z, метры', 'FontSize', config.axes_font_size)
%     plot3([config.anchors(:).x], [config.anchors(:).y], [config.anchors(:).z], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
% 
%     figure('Position', figure_position)
%     set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     hold on
%     grid on
%     xlabel('X, метры', 'FontSize', config.axes_font_size)
%     ylabel('Y, метры', 'FontSize', config.axes_font_size)
%     plot([config.anchors(:).x], [config.anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
%     if config.static_dynamic_flag == 0
%         plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 7, 'MarkerFaceColor','black')
%         legend('Положение опорных точек', 'Положение объекта')
%     else
%         plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 2, 'MarkerFaceColor','black')
%         legend('Положение опорных точек', 'Траектория движения объекта')
%     end

    
    
    
    figure('Position', figure_position)
    hold on
    grid on
    xlabel('X, м', 'FontSize', config.axes_font_size)
    ylabel('Y, м', 'FontSize', config.axes_font_size)
    xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(state_vectors_LSM_PR(1, :), state_vectors_LSM_PR(2, :), 'yo', 'MarkerSize', 3, 'MarkerFaceColor', 'yellow')
    plot(state_vectors_LSM_R(1, :), state_vectors_LSM_R(2, :), 'bo', 'MarkerSize', 3, 'MarkerFaceColor','blue')
    plot(state_vectors_EKF_DR(1, :), state_vectors_EKF_DR(2, :), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'red')
    plot(state_vectors_EKF_PR(1, :), state_vectors_EKF_PR(2, :), 'go', 'MarkerSize', 3, 'MarkerFaceColor', 'green')
    plot([config.anchors(:).x], [config.anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
    if config.static_dynamic_flag == 0
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 7, 'MarkerFaceColor','black')
    else
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 2, 'MarkerFaceColor','black')
    end

%     legend('ПД МНК', 'Р МНК', 'ПД РФК', 'ПД РФК', 'Истинное положение объекта', 'Положение опорных точек')
%     legend('ToA LSM', 'ToF LSM', 'TDoA EKF', 'ToA EKF', 'True position', 'Anchors position')
    legend('ПД МНК', 'Р МНК', 'РД РФК', 'ПД РФК', 'Положение объекта', 'Положение опорных точек')
    
    
    figure('Position', figure_position)
    hold on
    grid on
    xlabel('X, м', 'FontSize', config.axes_font_size)
    ylabel('Y, м', 'FontSize', config.axes_font_size)
    xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(state_vectors_EKF_DR(1, :), state_vectors_EKF_DR(2, :), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'red')
    plot([config.anchors(:).x], [config.anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
    if config.static_dynamic_flag == 0
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 7, 'MarkerFaceColor','black')
    else
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 1, 'MarkerFaceColor','black')
    end
    legend('РД РФК', 'Траектория движения объекта', 'Положение опорных точек')
    
    figure('Position', figure_position)
    hold on
    grid on
    xlabel('X, м', 'FontSize', config.axes_font_size)
    ylabel('Y, м', 'FontSize', config.axes_font_size)
    xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(state_vectors_EKF_PR(1, :), state_vectors_EKF_PR(2, :), 'go', 'MarkerSize', 3, 'MarkerFaceColor', 'green')
    plot([config.anchors(:).x], [config.anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
    if config.static_dynamic_flag == 0
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 7, 'MarkerFaceColor','black')
    else
        plot(config.path_tag_x, config.path_tag_y, 'ko', 'MarkerSize', 1, 'MarkerFaceColor','black')
    end
    legend('ПД РФК', 'Траектория движения объекта', 'Положение опорных точек')
    
    
    figure('Position', figure_position)
    hold on
    grid on
    xlabel('X, м', 'FontSize', config.axes_font_size)
    ylabel('Y, м', 'FontSize', config.axes_font_size)
    xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(config.path_tag_x, config.path_tag_y, 'k', 'LineWidth', 2,  'MarkerSize', 4, 'MarkerFaceColor','black')
    plot([config.anchors(:).x], [config.anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
    legend('Истинная траектория объекта', 'Положение опорных точек')
   
    
    
    
    
    
    
    %% DIFF TRUE AND ESTIMATIONS
    figure('Position', figure_position)
    subplot(1,2,1)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Разность оценки и истины, м', 'FontSize', config.axes_font_size)
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(times_send_user, state_vectors_LSM_PR(1, :) - config.path_tag_x, 'y', 'LineWidth', 3)
    plot(times_send_user, state_vectors_EKF_DR(1, :) - config.path_tag_x, 'r', 'LineWidth', 3)
    plot(times_send_user, state_vectors_LSM_R(1, :) - config.path_tag_x, 'b', 'LineWidth', 3)
    plot(times_send_user, state_vectors_EKF_PR(1, :) - config.path_tag_x, 'g', 'LineWidth', 3)
    ylim([-20 20])
    legend('ПД МНК', 'ПД РФК', 'Р МНК', 'ПД РФК')
    
    subplot(1,2,2)
    hold on
    grid on
    xlabel('Время, с', 'FontSize', config.axes_font_size)
    ylabel('Разность оценки и истины, м', 'FontSize', config.axes_font_size)
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    plot(times_send_user, state_vectors_LSM_PR(2, :) - config.path_tag_y, 'y', 'LineWidth', 3)
    plot(times_send_user, state_vectors_EKF_DR(2, :) - config.path_tag_y, 'r', 'LineWidth', 3)
    plot(times_send_user, state_vectors_LSM_R(2, :) - config.path_tag_y, 'b', 'LineWidth', 3)
    plot(times_send_user, state_vectors_EKF_PR(2, :) - config.path_tag_y, 'g', 'LineWidth', 3)
    ylim([-20 20])
    legend('ПД МНК', 'ПД РФК', 'Р МНК', 'ПД РФК')
    
    
    
    
    
    
    
    
    
    
      
%     %% HISTOGRAMS MNK + RFK
%     if config.static_dynamic_flag == 0
%         figure('Position', figure_position)
%         title('Плотность распределения оценки координат РД МНК')
%         subplot(1,2,1)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_LSM_PR(1, :), 1000)
%         xlim([config.pos_tag_x_static - config.sigma_R * 35, config.pos_tag_x_static + config.sigma_R * 35])
%         subplot(1,2,2)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_LSM_PR(2, :), 1000)
%         xlim([config.pos_tag_y_static - config.sigma_R * 35, config.pos_tag_y_static + config.sigma_R * 35])
%         figure('Position', figure_position)
%         title('Плотность распределения оценки координат Р МНК')
%         subplot(1,2,1)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_LSM_R(1, :), 1000)
%         xlim([config.pos_tag_x_static - config.sigma_R * 35, config.pos_tag_x_static + config.sigma_R * 35])
%         subplot(1,2,2)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_LSM_R(2, :), 1000)
%         xlim([config.pos_tag_y_static - config.sigma_R * 35, config.pos_tag_y_static + config.sigma_R * 35])
%         figure('Position', figure_position)
%         title('Плотность распределения оценки координат РД РФК')
%         subplot(1,2,1)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_EKF_DR(1, :), 1000)
%         xlim([config.pos_tag_x_static - config.sigma_R * 35, config.pos_tag_x_static + config.sigma_R * 35])
%         subplot(1,2,2)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_EKF_DR(2, :), 1000)
%         xlim([config.pos_tag_y_static - config.sigma_R * 35, config.pos_tag_y_static + config.sigma_R * 35])
%         figure('Position', figure_position)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         title('Плотность распределения оценки координат ПД МНК')
%         subplot(1,2,1)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_EKF_PR(1, :), 1000)
%         plot(config.pos_tag_x_static, 1:10, 'rs', 'MarkerSize', 3)
%         xlim([config.pos_tag_x_static - config.sigma_R * 35, config.pos_tag_x_static + config.sigma_R * 35])
%         subplot(1,2,2)
%         set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%         xlabel('Значение, Метры', 'FontSize', config.axes_font_size)
%         ylabel('Плотность', 'FontSize', config.axes_font_size)
%         hold on
%         grid on
%         hist(state_vectors_EKF_PR(2, :), 1000)
%         xlim([config.pos_tag_y_static - config.sigma_R * 35, config.pos_tag_y_static + config.sigma_R * 35])
%     end
    
    
    
    
    
    
    
    
    
      
    %% PLOTS GDOP
    if ~isempty(GDOP_R_matrix) && ~isempty(GDOP_DR_matrix) && ~isempty(GDOP_PR_matrix)
        figure('Position', figure_position)
        hold on
        xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        [X,Y] = meshgrid([(min([config.anchors(:).x]) - config.zone_zoom):config.GDOP_step:(max([config.anchors(:).x]) + config.zone_zoom)],[(min([config.anchors(:).y]) - config.zone_zoom):config.GDOP_step:(max([config.anchors(:).y]) + config.zone_zoom)]);
        surf(X,Y,GDOP_R_matrix)
        colorbar
        plot3([config.anchors(:).x], [config.anchors(:).y], [config.anchors(:).z], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
        shading interp
        xlabel('X, м')
        ylabel('Y, м')
        set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)

        figure('Position', figure_position)
        hold on
        xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        surf(X,Y,GDOP_PR_matrix)
        colorbar
        plot3([config.anchors(:).x], [config.anchors(:).y], [config.anchors(:).z], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
        shading interp
        xlabel('X, м')
        ylabel('Y, м')
        set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)

        figure('Position', figure_position)
        hold on
        xlim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        ylim([((min([config.anchors(:).x]) - config.zone_zoom) + 1), ((max([config.anchors(:).x]) + config.zone_zoom) - 1)])
        surf(X,Y,GDOP_DR_matrix)
        colorbar
        plot3([config.anchors(:).x], [config.anchors(:).y], [config.anchors(:).z], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
        shading interp
        xlabel('X, м')
        ylabel('Y, м')
        set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
    end
    
end