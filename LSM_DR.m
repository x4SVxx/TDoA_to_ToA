function present_state_vector = LSM_DR(config, anchors, times_receiving)
    P = eye(length(anchors) - 1);
    for i = 1:length(anchors) - 1
        P(i, length(anchors)) = -1;
    end
    W = P * P';
    past_state_vector = [(max([config.anchors(:).x]) - min([config.anchors(:).x])) / 2;
                         (max([config.anchors(:).y]) - min([config.anchors(:).y])) / 2;
                         (max([config.anchors(:).z]) - min([config.anchors(:).z])) / 2];
    for j = 1:15
       H = H_LSM_DR(past_state_vector, anchors);
       S = S_LSM_DR(past_state_vector, anchors);
       RD = P * times_receiving * config.c;
       present_state_vector = past_state_vector + (H' * P' * W^-1 * P * H)^-1 * H' * P' * W^-1 * (RD - P * S);
       if sqrt((present_state_vector(1, 1) - past_state_vector(1, 1))^2 + (present_state_vector(2, 1) - past_state_vector(2, 1))^2 + (present_state_vector(3, 1) - past_state_vector(3, 1))^2) < config.epsilon
           break
       end
       past_state_vector = present_state_vector;
    end
end

function S = S_LSM_DR(state_vector, anchors)
    for i = 1:length(anchors)
        S(i, 1) = norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
    end
end

function H = H_LSM_DR(state_vector, anchors)
    for i = 1:length(anchors)
        H(i, 1) = -(anchors(i).x - state_vector(1, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 2) = -(anchors(i).y - state_vector(2, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 3) = -(anchors(i).z - state_vector(3, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
    end
end