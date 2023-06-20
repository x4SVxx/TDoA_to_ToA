%% START CLEAR AND CONFIG
clear all
close all
clc
warning('off')
config = CONFIG();

% std_mas_LSM_DR_x =[];
% std_mas_LSM_DR_y =[];
% 
% std_mas_LSM_R_x =[];
% std_mas_LSM_R_y =[];
% 
% std_mas_EKF_DR_x =[];
% std_mas_EKF_DR_y =[];
% 
% std_mas_EKF_PR_x =[];
% std_mas_EKF_PR_y =[];
% 
% for k = 1:100

    %% TIMESCALES
    times_send_user = linspace(1.0, config.time_simulation + 1, config.time_simulation / config.period_simulation + 1);
    delta = [config.start_delta;
             config.start_delta_dot];
    times_send_system(1) = times_send_user(1) + delta(1, 1);

    for step_simulation = 2:config.count_steps_simulation
       times_send_system(step_simulation) = times_send_system(step_simulation - 1) + (times_send_user(step_simulation) - times_send_user(step_simulation - 1)) / (1 - delta(2, step_simulation - 1));
       dt = times_send_system(step_simulation) - times_send_system(step_simulation - 1);
       F = [1, dt;
            0, 1];
       G = [0;
            dt];
       delta = [delta, F * delta(:, step_simulation - 1) + G * normrnd(0, config.sigma_delta)];
    end

    %% TIMES RECEIVING
    for step_simulation = 1:config.count_steps_simulation
        for anchor_number = 1:length(config.anchors)
            config.anchors(anchor_number).times_receiving(step_simulation) = times_send_system(step_simulation) + norm([config.anchors(anchor_number).x, config.anchors(anchor_number).y, config.anchors(anchor_number).z] - [config.path_tag_x(step_simulation), config.path_tag_y(step_simulation), config.pos_tag_z]) / config.c + normrnd(0, config.sigma_R / config.c); 
        end
    end
    
%     %% FAIL TIMES RECEIVING
%     for step_simulation = 1:config.count_steps_simulation
%         for anchor_number = 1:length(config.anchors)
%             if step_simulation > config.count_steps_simulation * 4 / 10 && step_simulation < config.count_steps_simulation * 6 / 10
%                 if anchor_number == 1 || anchor_number == 5 || anchor_number == 3 || anchor_number == 2 || anchor_number == 6
%                     config.anchors(anchor_number).times_receiving(step_simulation) = -1; 
%                 end
%             end
%         end
%     end

    %% LSM - LEAST SQUARES METHOD
    state_vectors_LSM_PR = [];
    state_vectors_LSM_DR = [];
    for step_simulation = 1:config.count_steps_simulation
        times_receiving = [];
        anchors_receiving = [];
        for anchor_number = 1:length(config.anchors)
            if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                times_receiving = [times_receiving , config.anchors(anchor_number).times_receiving(step_simulation)];
                anchors_receiving = [anchors_receiving , config.anchors(anchor_number)];
            end
        end
        state_vectors_LSM_PR = [state_vectors_LSM_PR, LSM_PR(config, anchors_receiving, times_receiving', times_send_user(step_simulation))];
        state_vectors_LSM_DR = [state_vectors_LSM_DR, LSM_DR(config, anchors_receiving, times_receiving')];
    end


    %% EKF - EXTENDED KALMAN FILTER
    if config.static_dynamic_flag == 0
        %% DR EKF STATIC
        state_vectors_EKF_DR = [state_vectors_LSM_DR(1,1);
                                state_vectors_LSM_DR(2,1);
                                state_vectors_LSM_DR(3,1)];
        D = [1e-1^2, 0, 0;
             0, 1e-1^2, 0;
             0, 0, 1e-1^2];
        t = 1;
        for step_simulation = 2:config.count_steps_simulation
            times_receiving = [];
            anchors_receiving = [];
            for anchor_number = 1:length(config.anchors)
                if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                    times_receiving = [times_receiving , config.anchors(anchor_number).times_receiving(step_simulation)];
                    anchors_receiving = [anchors_receiving , config.anchors(anchor_number)];
                end
            end
            [state_vector, past_D, past_t] = EKF_DR_STATIC(config, anchors_receiving, times_receiving', state_vectors_EKF_DR(:, step_simulation - 1), D, t);
            state_vectors_EKF_DR = [state_vectors_EKF_DR, state_vector];
            D = past_D;
            t = past_t;
        end
        %% PR EKF STATIC
        state_vectors_EKF_PR = [state_vectors_LSM_PR(1,1);
                                state_vectors_LSM_PR(2,1);
                                state_vectors_LSM_PR(3,1);
                                config.start_delta;
                                config.start_delta_dot];
            D = [1e-1^2, 0, 0, 0, 0;
                 0, 1e-1^2, 0, 0, 0;
                 0, 0, 1e-1^2, 0, 0;
                 0, 0, 0, (1e-9)^2, 0;
                 0, 0, 0, 0, (1e-10)^2];
        for step_simulation = 2:config.count_steps_simulation
            times_receiving = [];
            anchors_receiving = [];
            for anchor_number = 1:length(config.anchors)
                if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                    times_receiving = [times_receiving , config.anchors(anchor_number).times_receiving(step_simulation)];
                    anchors_receiving = [anchors_receiving , config.anchors(anchor_number)];
                end
            end
            [state_vector, past_D] = EKF_PR_STATIC(config, anchors_receiving, times_receiving', times_send_user(step_simulation), times_send_user(step_simulation - 1), state_vectors_EKF_PR(:, step_simulation - 1), D);
            state_vectors_EKF_PR = [state_vectors_EKF_PR, state_vector];
            D = past_D;
        end
    elseif config.static_dynamic_flag == 1
        %% DR EKF DYNAMIC
        state_vectors_EKF_DR = [state_vectors_LSM_DR(1,1);
                                state_vectors_LSM_DR(2,1);
                                state_vectors_LSM_DR(3,1);
                                0;
                                0;
                                0;
                                0;
                                0;
                                0];
        D = [0.1^2, 0, 0, 0, 0, 0, 0, 0, 0;
             0, 0.1^2, 0, 0, 0, 0, 0, 0, 0;
             0, 0, 0.1^2, 0, 0, 0, 0, 0, 0;
             0, 0, 0, 0.1^2, 0, 0, 0, 0, 0;
             0, 0, 0, 0, 0.1^2, 0, 0, 0, 0;
             0, 0, 0, 0, 0, 0.1^2, 0, 0, 0;
             0, 0, 0, 0, 0, 0, 0.1^2, 0, 0;
             0, 0, 0, 0, 0, 0, 0, 0.1^2, 0;
             0, 0, 0, 0, 0, 0, 0, 0, 0.1^2;];
        t = 1;
        for step_simulation = 2:config.count_steps_simulation
            times_receiving = [];
            anchors_receiving = [];
            for anchor_number = 1:length(config.anchors)
                if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                    times_receiving = [times_receiving , config.anchors(anchor_number).times_receiving(step_simulation)];
                    anchors_receiving = [anchors_receiving , config.anchors(anchor_number)];
                end
            end
            [state_vector, past_D, past_t] = EKF_DR_DYNAMIC(config, anchors_receiving, times_receiving', state_vectors_EKF_DR(:, step_simulation - 1), D, t);
            state_vectors_EKF_DR = [state_vectors_EKF_DR, state_vector];
            D = past_D;
            t = past_t;
        end
        %% PR EKF DYNAMIC
        state_vectors_EKF_PR = [state_vectors_LSM_PR(1,1);
                                state_vectors_LSM_PR(2,1);
                                state_vectors_LSM_PR(3,1);
                                0;
                                0;
                                0;
                                0;
                                0;
                                0;
                                config.start_delta;
                                config.start_delta_dot];
            D = [0.1^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                 0, 0.1^2, 0, 0, 0, 0, 0, 0, 0, 0, 0;
                 0, 0, 0.1^2, 0, 0, 0, 0, 0, 0, 0, 0;
                 0, 0, 0, 0.1^2, 0, 0, 0, 0, 0, 0, 0;
                 0, 0, 0, 0, 0.1^2, 0, 0, 0, 0, 0, 0;
                 0, 0, 0, 0, 0, 0.1^2, 0, 0, 0, 0, 0;
                 0, 0, 0, 0, 0, 0, 0.1^2, 0, 0, 0, 0;
                 0, 0, 0, 0, 0, 0, 0, 0.1^2, 0, 0, 0;
                 0, 0, 0, 0, 0, 0, 0, 0, 0.1^2, 0, 0;
                 0, 0, 0, 0, 0, 0, 0, 0, 0, (1e-9)^2, 0;
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (1e-10)^2;];
        for step_simulation = 2:config.count_steps_simulation
            times_receiving = [];
            anchors_receiving = [];
            for anchor_number = 1:length(config.anchors)
                if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                    times_receiving = [times_receiving , config.anchors(anchor_number).times_receiving(step_simulation)];
                    anchors_receiving = [anchors_receiving , config.anchors(anchor_number)];
                end
            end
            [state_vector, past_D] = EKF_PR_DYNAMIC(config, anchors_receiving, times_receiving', times_send_user(step_simulation), times_send_user(step_simulation - 1), state_vectors_EKF_PR(:, step_simulation - 1), D);
            state_vectors_EKF_PR = [state_vectors_EKF_PR, state_vector];
            D = past_D;
        end
    end

    %% RANGES
    if config.static_dynamic_flag == 0
        times_send_system_EKF_PR = times_send_user + state_vectors_EKF_PR(4, :);
    elseif config.static_dynamic_flag == 1
        times_send_system_EKF_PR = times_send_user + state_vectors_EKF_PR(10, :);
    end
    ranges_EKF_PR = [];
    for step_simulation = 1:config.count_steps_simulation
        ranges = [];
        for anchor_number = 1:length(config.anchors)
            if config.anchors(anchor_number).times_receiving(step_simulation) ~= -1
                ranges = [ranges, ([config.anchors(anchor_number).times_receiving(step_simulation)]' - times_send_system_EKF_PR(1, step_simulation)) * config.c];
            else
                ranges = [ranges, -1];
            end
            ranges_true(anchor_number, step_simulation) = norm([config.anchors(anchor_number).x, config.anchors(anchor_number).y, config.anchors(anchor_number).z] - [config.path_tag_x(step_simulation), config.path_tag_y(step_simulation), config.pos_tag_z]);
        end
        ranges = ranges';
        ranges_EKF_PR = [ranges_EKF_PR, ranges];
    end
    
    
    %% LSM - LEAST SQUARES METHOD
    state_vectors_LSM_R = [];
    for step_simulation = 1:config.count_steps_simulation
        ranges = [];
        anchors_ranges = [];
        for anchor_number = 1:length(config.anchors)
            if ranges_EKF_PR(anchor_number, step_simulation) ~= -1
                ranges = [ranges, ranges_EKF_PR(anchor_number, step_simulation)];
                anchors_ranges = [anchors_ranges, config.anchors(anchor_number)];
            end
        end
        state_vectors_LSM_R = [state_vectors_LSM_R, LSM_R(config, anchors_ranges, ranges')];
    end

    %% GDOP
    GDOP_R_matrix = [];
    GDOP_PR_matrix = [];
    GDOP_DR_matrix = [];
%     GDOP_R_matrix = GDOP_R(config);
%     GDOP_PR_matrix = GDOP_PR(config, max(max(GDOP_R_matrix)));
%     GDOP_DR_matrix = GDOP_DR(config, max(max(GDOP_R_matrix)));

% %% STD - STANDARD DEVIATION
% if config.static_dynamic_flag == 0
%     std_LSM_DR = [std(state_vectors_LSM_DR(1, length(config.path_tag_x)/2:end)), std(state_vectors_LSM_DR(2, length(config.path_tag_x)/2:end))];
%     std_LSM_R = [std(state_vectors_LSM_R(1, length(config.path_tag_x)/2:end)), std(state_vectors_LSM_R(2, length(config.path_tag_x)/2:end))];
%     std_EKF_DR = [std(state_vectors_EKF_DR(1, length(config.path_tag_x)/2:end)), std(state_vectors_EKF_DR(2, length(config.path_tag_x)/2:end))];
%     std_EKF_PR = [std(state_vectors_EKF_PR(1, length(config.path_tag_x)/2:end)), std(state_vectors_EKF_PR(2, length(config.path_tag_x)/2:end))];
%     DRMS_LSM_DR = sqrt(std_LSM_DR(1)^2 + std_LSM_DR(2)^2);
%     DRMS_LSM_R = sqrt(std_LSM_R(1)^2 + std_LSM_R(2)^2);
%     DRMS_EKF_DR = sqrt(std_EKF_DR(1)^2 + std_EKF_DR(2)^2);
%     DRMS_EKF_PR = sqrt(std_EKF_PR(1)^2 + std_EKF_PR(2)^2);
% end
% 
% config.pos_tag_x_static = config.pos_tag_x_static + 1;
% config.pos_tag_y_static = config.pos_tag_y_static + 1;
% for i = 1:config.count_steps_simulation
%     config.path_tag_x(i) = config.pos_tag_x_static;
%     config.path_tag_y(i) = config.pos_tag_y_static;
% end
% 
% std_mas_LSM_DR_x = [std_mas_LSM_DR_x, std_LSM_DR(1)];
% std_mas_LSM_DR_y = [std_mas_LSM_DR_y, std_LSM_DR(2)];
% 
% std_mas_LSM_R_x = [std_mas_LSM_R_x, std_LSM_R(1)];
% std_mas_LSM_R_y = [std_mas_LSM_R_y, std_LSM_R(2)];
% 
% std_mas_EKF_DR_x = [std_mas_EKF_DR_x, std_EKF_DR(1)];
% std_mas_EKF_DR_y = [std_mas_EKF_DR_y, std_EKF_DR(2)];
% 
% std_mas_EKF_PR_x = [std_mas_EKF_PR_x, std_EKF_PR(1)];
% std_mas_EKF_PR_y = [std_mas_EKF_PR_y, std_EKF_PR(2)];
% end
% 
% figure()
% hold on
% set(gca,'FontSize',18,'fontWeight','bold')
% xlabel('X, Метры')
% ylabel('СКО оценок координат, Метры')
% plot(1:k, std_mas_LSM_DR_x, 'yellow', 'LineWidth', 3)
% plot(1:k, std_mas_LSM_R_x, 'blue', 'LineWidth', 3)
% plot(1:k, std_mas_EKF_DR_x, 'red', 'LineWidth', 3)
% plot(1:k, std_mas_EKF_PR_x, 'green', 'LineWidth', 3)
% legend('РД МНК', 'Р МНК', 'РД РФК', 'ПД РФК')
% figure()
% hold on
% set(gca,'FontSize',18,'fontWeight','bold')
% xlabel('Y, Метры')
% ylabel('СКО оценок координат, Метры')
% plot(1:k, std_mas_LSM_DR_y, 'yellow', 'LineWidth', 3)
% plot(1:k, std_mas_LSM_R_y, 'blue', 'LineWidth', 3)
% plot(1:k, std_mas_EKF_DR_y, 'red', 'LineWidth', 3)
% plot(1:k, std_mas_EKF_PR_y, 'green', 'LineWidth', 3)
% legend('РД МНК', 'Р МНК', 'РД РФК', 'ПД РФК')




%% PLOTS
PLOTS(config,...
      delta,...
      times_send_user,...
      times_send_system,...
      ranges_EKF_PR,...
      ranges_true,...
      state_vectors_LSM_R,...
      state_vectors_LSM_PR,...
      state_vectors_LSM_DR,...
      state_vectors_EKF_PR,...
      state_vectors_EKF_DR,...
      GDOP_R_matrix,...
      GDOP_PR_matrix,...
      GDOP_DR_matrix)