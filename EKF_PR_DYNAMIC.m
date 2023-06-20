function [state_vector_triangle, D] = EKF_PR_DYNAMIC(config, anchors, times_receiving, times_send_user, past_times_send_user, past_state_vector_triangle, past_D)
    D_n = eye(length(anchors)) * config.sigma_n_EKF_PR_DYNAMIC^2;

    D_ksi = [config.sigma_ksi_ax_EKF_PR_DYNAMIC^2, 0, 0, 0;
             0, config.sigma_ksi_ay_EKF_PR_DYNAMIC^2, 0, 0;
             0, 0, config.sigma_ksi_az_EKF_PR_DYNAMIC^2, 0;
             0, 0, 0, config.sigma_ksi_drift_EKF_PR_DYNAMIC^2];

    T = times_send_user - past_times_send_user;

    F = [1, 0, 0, T, 0, 0, 0, 0, 0, 0, 0;
         0, 1, 0, 0, T, 0, 0, 0, 0, 0, 0;
         0, 0, 1, 0, 0, T, 0, 0, 0, 0, 0;
         0, 0, 0, 1, 0, 0, T, 0, 0, 0, 0;
         0, 0, 0, 0, 1, 0, 0, T, 0, 0, 0;
         0, 0, 0, 0, 0, 1, 0, 0, T, 0, 0;
         0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 0, 1, T;
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1;];

    G = [0, 0, 0, 0;
         0, 0, 0, 0;
         0, 0, 0, 0;
         0, 0, 0, 0;
         0, 0, 0, 0;
         0, 0, 0, 0;
         T, 0, 0, 0;
         0, T, 0, 0;
         0, 0, T, 0;
         0, 0, 0, 0;
         0, 0, 0, T];

    state_vector_wave = F * past_state_vector_triangle;

    S = S_EKF_PD(state_vector_wave, config, anchors);
    H = H_EKF_PD(state_vector_wave, config, anchors);

    D_wave = F * past_D * F' + G * D_ksi * G';
    K = D_wave * H' * (H * D_wave * H' + D_n)^-1;
    D = D_wave - K * H * D_wave;
    state_vector_triangle = state_vector_wave + K * ((times_receiving - times_send_user) * config.c - S);
end

function S = S_EKF_PD(state_vector, config, anchors)
    for i = 1:length(anchors)
        S(i, 1) = norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]) + state_vector(10, 1) * config.c;
    end
end

function H = H_EKF_PD(state_vector, config, anchors)
    for i = 1:length(anchors)
        H(i, 1) = -(anchors(i).x - state_vector(1, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 2) = -(anchors(i).y - state_vector(2, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 3) = -(anchors(i).z - state_vector(3, 1)) / norm([anchors(i).x, anchors(i).y, anchors(i).z] - [state_vector(1, 1), state_vector(2, 1), state_vector(3, 1)]);
        H(i, 4) = 0;
        H(i, 5) = 0;
        H(i, 6) = 0;
        H(i, 7) = 0;
        H(i, 8) = 0;
        H(i, 9) = 0;
        H(i, 10) = config.c;
        H(i, 11) = 0;
    end
end

