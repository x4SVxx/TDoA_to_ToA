%% START CLEAR AND CONFIG
clear all
close all
clc
config = CONFIG();

%% READ LOG
dw_unit = (1.0 / 499.2e6 / 128.0);
T_max = 2^40 * dw_unit;

anchors = [];
anchors_config = readlines('anchors.json');
for anchor_number = 1:length(anchors_config)
    anchors = [anchors, jsondecode(anchors_config(anchor_number))];
end
logs = readlines('logs\DINAMIC_4_TAGS.log');
tags = [];

for log_number = 1:length(logs)
    if log_number > length(logs) * 67 / 100 && log_number < length(logs) * 75 / 100
        split_line = strsplit(logs(log_number));
        if length(split_line) > 1
            if split_line(2) == "CLE:" && split_line(3) == "TAG" && split_line(5) == "1"
                tag_check_flag = 0;
                for tag_number = 1:length(tags)
                    if split_line(4) == tags(tag_number).name
                        tag_check_flag = 1;
                        tags(tag_number).x = [tags(tag_number).x, str2double(split_line(6))];
                        tags(tag_number).y = [tags(tag_number).y, str2double(split_line(7))];
                        tags(tag_number).z = [tags(tag_number).z, str2double(split_line(8))];

                        for anchor_number = 1:length(tags(tag_number).anchors)
                            tags(tag_number).anchors(anchor_number).BLINK = [tags(tag_number).anchors(anchor_number).BLINK, -1];
                        end

                        for word_number = 1:str2double(split_line(9)) * 2 - 1
                            if mod(word_number, 2) ~= 0
                                for anchor_number = 1:length(tags(tag_number).anchors)
                                    if str2double(split_line(9 + word_number)) == tags(tag_number).anchors(anchor_number).number
                                        if str2double(split_line(9 + word_number + 1)) > 0
                                            if max(tags(tag_number).anchors(anchor_number).BLINK) - (str2double(split_line(9 + word_number + 1)) + tags(tag_number).anchors(anchor_number).full_count * T_max) > T_max - 2 
                                                tags(tag_number).anchors(anchor_number).full_count = tags(tag_number).anchors(anchor_number).full_count + 1;
                                            end
                                            tags(tag_number).anchors(anchor_number).BLINK(length(tags(tag_number).anchors(anchor_number).BLINK)) = str2double(split_line(9 + word_number + 1)) + tags(tag_number).anchors(anchor_number).full_count * T_max;
                                        else
                                            if max(tags(tag_number).anchors(anchor_number).BLINK) - (str2double(split_line(9 + word_number + 1)) + T_max  + tags(tag_number).anchors(anchor_number).full_count * T_max) > T_max - 2  
                                                tags(tag_number).anchors(anchor_number).full_count = tags(tag_number).anchors(anchor_number).full_count + 1;
                                            end
                                            tags(tag_number).anchors(anchor_number).BLINK(length(tags(tag_number).anchors(anchor_number).BLINK)) = str2double(split_line(9 + word_number + 1)) + T_max  + tags(tag_number).anchors(anchor_number).full_count * T_max;
                                        end
                                    end
                                end
                            end
                        end

                    end
                end
                if tag_check_flag == 0
                    new_tag = Tag;
                    new_tag.name = split_line(4);
                    new_tag.x = [new_tag.x, str2double(split_line(6))];
                    new_tag.y = [new_tag.y, str2double(split_line(7))];
                    new_tag.z = [new_tag.z, str2double(split_line(8))];
                    new_tag.anchors = anchors;
                    for anchor_number = 1:length(new_tag.anchors)
                        new_tag.anchors(anchor_number).BLINK = [-1];
                        new_tag.anchors(anchor_number).full_count = 0;
                        new_tag.anchors(anchor_number).name = '';
                    end
                    for word_number = 1:str2double(split_line(9)) * 2 - 1
                        if mod(word_number, 2) ~= 0
                            for anchor_number = 1:length(new_tag.anchors)
                                if str2double(split_line(9 + word_number)) == new_tag.anchors(anchor_number).number
                                    if str2double(split_line(9 + word_number + 1)) > 0
                                        new_tag.anchors(anchor_number).BLINK(1) = str2double(split_line(9 + word_number + 1));
                                    else
                                        new_tag.anchors(anchor_number).BLINK(1) = str2double(split_line(9 + word_number + 1)) + T_max;
                                    end
                                end
                            end
                        end
                    end
                    tags = [tags, new_tag];
                end

                split_line_past = strsplit(logs(log_number - 1));
                if split_line_past(2) == 'BLINK'
                    for tag_number = 1:length(tags)
                        if tags(tag_number).name == split_line(4)
                            if isempty(tags(tag_number).BLINK)
                                tags(tag_number).BLINK = [tags(tag_number).BLINK, str2double(split_line_past(7))];
                            else
                                if max(tags(tag_number).BLINK) - (str2double(split_line_past(7)) + tags(tag_number).full_count * T_max) > T_max - 2
                                    tags(tag_number).full_count = tags(tag_number).full_count + 1;
                                end
                                tags(tag_number).BLINK = [tags(tag_number).BLINK, str2double(split_line_past(7)) + tags(tag_number).full_count * T_max];
                            end
                        end
                    end
                end

            end
        end
    end
end

exp_tag = tags(1);
tags = [tags, exp_tag];
exp_tag = tags(2);
tags = [tags, exp_tag];
for tag_number = 1:length(tags)
    if tag_number == length(tags) || tag_number == length(tags) - 1
        for anchor_number = 1:length(tags(tag_number).anchors)
            for BLINK_number = 1:length(tags(tag_number).anchors(anchor_number).BLINK)
                if BLINK_number > length(tags(tag_number).anchors(anchor_number).BLINK) * 10 / 100 && BLINK_number < length(tags(tag_number).anchors(anchor_number).BLINK) * 25 / 100
                    if anchor_number == 3 || anchor_number == 4 || anchor_number == 7 || anchor_number == 2 || anchor_number == 5
                        tags(tag_number).anchors(anchor_number).BLINK(BLINK_number) = -1;
                    end
                end
            end
        end
    end
end


% %% LSM DR & PR
% for tag_number = 1:length(tags)
%     for BLINK_number = 1:length(tags(tag_number).anchors(1).BLINK)
%         BLINKS = [];
%         anchors_BLINK = [];
%         for anchor_number = 1:length(tags(tag_number).anchors)
%             if tags(tag_number).anchors(anchor_number).BLINK(BLINK_number) ~= -1
%                 BLINKS = [BLINKS, tags(tag_number).anchors(anchor_number).BLINK(BLINK_number)];
%                 anchors_BLINK = [anchors_BLINK, tags(tag_number).anchors(anchor_number)];
%             end
%         end
%         tags(tag_number).state_vectors_LSM_DR = [tags(tag_number).state_vectors_LSM_DR, LSM_DR(config, anchors_BLINK, BLINKS')];
%         tags(tag_number).state_vectors_LSM_PR = [tags(tag_number).state_vectors_LSM_PR, LSM_PR(config, anchors_BLINK, BLINKS', tags(tag_number).BLINK(BLINK_number))];
%     end
% end

%% EKF DR
for tag_number = 1:length(tags)
    tags(tag_number).state_vectors_EKF_DR = [0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0];
    BLINKS = [];
    for anchor_number = 1:length(tags(tag_number).anchors)
        if tags(tag_number).anchors(anchor_number).BLINK(1) ~= -1
            BLINKS = [BLINKS, tags(tag_number).anchors(anchor_number).BLINK(1)];
        end
    end

    past_t = max(BLINKS) - 0.1;
    past_D = ones(9, 9);

    for BLINK_number = 2:length(tags(tag_number).anchors(1).BLINK)
        BLINKS = [];
        anchors_BLINK = [];
        for anchor_number = 1:length(tags(tag_number).anchors)
            if tags(tag_number).anchors(anchor_number).BLINK(BLINK_number) ~= -1
                BLINKS = [BLINKS, tags(tag_number).anchors(anchor_number).BLINK(BLINK_number)];
                anchors_BLINK = [anchors_BLINK, tags(tag_number).anchors(anchor_number)];
            end
        end
        [state_vector, D, t] = EKF_DR_DYNAMIC(config, anchors_BLINK, BLINKS', tags(tag_number).state_vectors_EKF_DR(:, BLINK_number - 1), past_D, past_t);
        tags(tag_number).state_vectors_EKF_DR = [tags(tag_number).state_vectors_EKF_DR, state_vector];
        past_t = t;
        past_D = D;
    end
end

%% EKF PR
for tag_number = 1:length(tags)
    tags(tag_number).state_vectors_EKF_PR = [0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0;
                                             0];
                                         
    past_D = [1^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
             0, 1^2, 0, 0, 0, 0, 0, 0, 0, 0, 0;
             0, 0, 1^2, 0, 0, 0, 0, 0, 0, 0, 0;
             0, 0, 0, 1^2, 0, 0, 0, 0, 0, 0, 0;
             0, 0, 0, 0, 1^2, 0, 0, 0, 0, 0, 0;
             0, 0, 0, 0, 0, 1^2, 0, 0, 0, 0, 0;
             0, 0, 0, 0, 0, 0, 1^2, 0, 0, 0, 0;
             0, 0, 0, 0, 0, 0, 0, 1^2, 0, 0, 0;
             0, 0, 0, 0, 0, 0, 0, 0, 1^2, 0, 0;
             0, 0, 0, 0, 0, 0, 0, 0, 0, (3e-3)^2, 0;
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (3e-3)^2];

    for BLINK_number = 2:length(tags(tag_number).anchors(1).BLINK)
        BLINKS = [];
        anchors_BLINK = [];
        for anchor_number = 1:length(tags(tag_number).anchors)
            if tags(tag_number).anchors(anchor_number).BLINK(BLINK_number) ~= -1
                BLINKS = [BLINKS, tags(tag_number).anchors(anchor_number).BLINK(BLINK_number)];
                anchors_BLINK = [anchors_BLINK, tags(tag_number).anchors(anchor_number)];
            end
        end
        [state_vector, D] = EKF_PR_DYNAMIC(config,...
                                          anchors_BLINK,...
                                          BLINKS',...
                                          tags(tag_number).BLINK(BLINK_number),...
                                          tags(tag_number).BLINK(BLINK_number - 1),...
                                          tags(tag_number).state_vectors_EKF_PR(:, BLINK_number - 1),...
                                          past_D);
        tags(tag_number).state_vectors_EKF_PR = [tags(tag_number).state_vectors_EKF_PR, state_vector];
        past_D = D;
    end
end


% %% RANGES
% for tag_number = 1:length(tags)
%     tags(tag_number).BLINK_EKF_PR = tags(tag_number).BLINK + tags(tag_number).state_vectors_EKF_PR(10, :);
% end
% for tag_number = 1:length(tags)
%     for anchor_number = 1:length(anchors)
%         tags(tag_number).anchors(anchor_number).ranges = [];
%         tags(tag_number).anchors(anchor_number).ranges = (tags(tag_number).anchors(anchor_number).BLINK - tags(tag_number).BLINK_EKF_PR) * config.c;
%     end
% end
% 
% %% LSM R
% for tag_number = 1:length(tags)
%     for BLINK_number = 1:length(tags(tag_number).anchors(1).BLINK)
%         ranges = [];
%         anchors_BLINK = [];
%         for anchor_number = 1:length(tags(tag_number).anchors)
%             ranges = [ranges, tags(tag_number).anchors(anchor_number).ranges(BLINK_number)];
%             anchors_BLINK = [anchors_BLINK, tags(tag_number).anchors(anchor_number)];
%         end
%         tags(tag_number).state_vectors_LSM_R = [tags(tag_number).state_vectors_LSM_R, LSM_R(config, anchors_BLINK, ranges)];
%     end
% end

%% PLOTS
% figure()
% hold on
% for tag_number = 1:length(tags)
%     tag_color = [rand(1) rand(1) rand(1)];
%     plot(tags(tag_number).x, tags(tag_number).y, 'ko', 'Color', tag_color, 'LineWidth', 1, 'MarkerEdgeColor', tag_color, 'MarkerFaceColor', tag_color, 'MarkerSize', 3)
% end

% for tag_number = 1:length(tags)
%     figure()
%     title('ANCHORS BLINK TIMES', 'FontSize', config.title_font_size)
%     for anchor_number = 1:length(tags(tag_number).anchors)
%        subplot(2,4,anchor_number)
%        plot(1:length(tags(tag_number).anchors(anchor_number).BLINK), tags(tag_number).anchors(anchor_number).BLINK, 'ko', 'Color', 'black', 'LineWidth', 1, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'MarkerSize', 3)
%     end
% end
% 
% figure()
% title('TAGS BLINK TIMES', 'FontSize', config.title_font_size)
% for tag_number = 1:length(tags)
%     subplot(4, 4, tag_number)
%     plot(1:length(tags(tag_number).BLINK), tags(tag_number).BLINK, 'ro', 'Color', 'red', 'LineWidth', 1, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', 'MarkerSize', 3)
% end



for tag_number = 1:length(tags)
    figure()
    xlim([-1 4])
    ylim([-1 4])
    hold on
    grid on
    xlabel('X, Метры', 'FontSize', config.axes_font_size)
    ylabel('Y, Метры', 'FontSize', config.axes_font_size)
    set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     plot(tags(tag_number).state_vectors_LSM_DR(1,:), tags(tag_number).state_vectors_LSM_DR(2,:), 'yo', 'Color', 'yellow', 'LineWidth', 1, 'MarkerEdgeColor', 'yellow', 'MarkerFaceColor', 'yellow', 'MarkerSize', 3)
    plot(tags(tag_number).state_vectors_EKF_DR(1,:), tags(tag_number).state_vectors_EKF_DR(2,:), 'ro', 'Color', 'red', 'LineWidth', 1, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', 'MarkerSize', 3)
    plot(tags(tag_number).state_vectors_EKF_PR(1,:), tags(tag_number).state_vectors_EKF_PR(2,:), 'go', 'Color', 'green', 'LineWidth', 1, 'MarkerEdgeColor', 'green', 'MarkerFaceColor', 'green', 'MarkerSize', 3)
%     plot(tags(tag_number).state_vectors_LSM_R(1,:), tags(tag_number).state_vectors_LSM_R(2,:), 'bo', 'Color', 'blue', 'LineWidth', 1, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', 'MarkerSize', 3)
    plot(0, 0, 'k-', 'MarkerSize', 10, 'MarkerFaceColor','black');
    plot([anchors(:).x], [anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','black');
    legend('РД РФК', 'ПД РФК', 'Приблизительная траектория', 'Положение опорных точек')
end





% figure()
% xlim([-1 4])
% ylim([-1 4])
% hold on
% grid on
% xlabel('X, Метры', 'FontSize', config.axes_font_size)
% ylabel('Y, Метры', 'FontSize', config.axes_font_size)
% set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
% for tag_number = 1:length(tags)
%     plot(tags(tag_number).state_vectors_EKF_PR(1,:), tags(tag_number).state_vectors_EKF_PR(2,:), 'go', 'Color', 'green', 'LineWidth', 1, 'MarkerEdgeColor', 'green', 'MarkerFaceColor', 'green', 'MarkerSize', 3)
% end
% plot([anchors(:).x], [anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
% legend('РД РФК', 'ПД РФК', 'Положение опорных точек')


% figure()
% xlim([-1 4])
% ylim([-1 4])
% hold on
% grid on
% xlabel('X, Метры', 'FontSize', config.axes_font_size)
% ylabel('Y, Метры', 'FontSize', config.axes_font_size)
% set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
% for tag_number = 1:length(tags)
%     plot(tags(tag_number).state_vectors_EKF_DR(1,:), tags(tag_number).state_vectors_EKF_DR(2,:), 'ro', 'Color', 'red', 'LineWidth', 1, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', 'MarkerSize', 3)
% end
% plot([anchors(:).x], [anchors(:).y], 's', 'MarkerSize', 10, 'MarkerFaceColor','red');
% legend('РД РФК', 'ПД РФК', 'Положение опорных точек')




% for tag_number = 1:length(tags)
%     figure()
%     title('Δ')
%     grid on
%     hold on
%     set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     xlabel('Время, Секунды', 'FontSize', config.axes_font_size)
%     ylabel('Δ, Секунды', 'FontSize', config.axes_font_size)
%     plot(1:length(tags(tag_number).state_vectors_EKF_PR(10,:)), tags(tag_number).state_vectors_EKF_PR(10,:), 'k', 'Color', 'black', 'LineWidth', 1, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'MarkerSize', 3)
%     figure()
%     title('Δ.')
%     grid on
%     hold on
%     set(gca, 'FontSize', config.figure_font_text_size, 'fontWeight', config.figure_font_text_type)
%     xlabel('Время, Секунды', 'FontSize', config.axes_font_size)
%     ylabel('Δ., Секунды', 'FontSize', config.axes_font_size)
%     plot(1:length(tags(tag_number).state_vectors_EKF_PR(11,:)), tags(tag_number).state_vectors_EKF_PR(11,:), 'k', 'Color', 'black', 'LineWidth', 1, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'MarkerSize', 3)
% end




