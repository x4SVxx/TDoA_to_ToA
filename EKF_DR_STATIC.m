function [state_vector_triangle, D, t] = EKF_DR_STATIC(config, anchors, times_receiving, past_state_vector_triangle, past_D, past_t)
    P = eye(length(anchors) - 1);
    for i = 1:length(anchors) - 1
        P(i, length(anchors)) = -1;
    end
    
    D_n = eye(length(anchors)) * config.sigma_n_EKF_DR^2;
    
    D_ksi = [config.sigma_ksi_x_EKF_DR^2, 0, 0;
             0, config.sigma_ksi_y_EKF_DR^2, 0;
             0, 0, config.sigma_ksi_z_EKF_DR^2];

    t = max(times_receiving);
    T = t - past_t;

    F = [1, 0, 0;
         0, 1, 0;
         0, 0, 1];

    G = [T, 0, 0;
         0, T, 0
         0, 0, T];

    state_vector_wave = F * past_state_vector_triangle;

    S = S_EKF_RD(state_vector_wave, anchors);
    H = H_EKF_RD(state_vector_wave, anchors);

    D_wave = F * past_D * F' + G * D_ksi * G';
    K = D_wave * H' * P' * (P * H * D_wave * H' * P' + P * D_n * P')^-1;
    D = D_wave - K * P * H * D_wave;
    state_vector_triangle = state_vector_wave + K * (P * times_receiving * config.c - P * S);
end

function S = S_EKF_RD(state_vector, anchors)
    for i = 1:length(anchors)
        S(i, 1) = norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
    end
end

function H = H_EKF_RD(state_vector, anchors)
    for i = 1:length(anchors)
        H(i, 1) = -(anchors(i).x - state_vector(1, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 2) = -(anchors(i).y - state_vector(2, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 3) = -(anchors(i).z - state_vector(3, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
    end
end

