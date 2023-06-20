function [config] = CONFIG()
    config.time_simulation = 450;
    config.period_simulation = 0.1;
    config.count_steps_simulation = (config.time_simulation / config.period_simulation + 1);
    
    config.anchors = [];
    anchors_json = readlines('anchors_1.json');
    for anchor_number = 1:length(anchors_json)
        config.anchors = [config.anchors, jsondecode(anchors_json(anchor_number))];
    end
    
    config.sigma_delta = 1e-10;
    config.start_delta = 17;
    config.start_delta_dot = 3e-10;

    config.sigma_R = 0.03;

    config.sigma_n_EKF_DR = config.sigma_R;
    config.sigma_ksi_x_EKF_DR = 1;
    config.sigma_ksi_y_EKF_DR = 1;
    config.sigma_ksi_z_EKF_DR = 1;
    
    config.sigma_n_EKF_DR_DYNAMIC = config.sigma_R;
    config.sigma_ksi_ax_EKF_DR_DYNAMIC = 1;
    config.sigma_ksi_ay_EKF_DR_DYNAMIC = 1;
    config.sigma_ksi_az_EKF_DR_DYNAMIC = 1;

    config.sigma_n_EKF_PR = config.sigma_R;
    config.sigma_ksi_x_EKF_PR = 1;
    config.sigma_ksi_y_EKF_PR = 1;
    config.sigma_ksi_z_EKF_PR = 1;
    config.sigma_ksi_drift_EKF_PR = 1e-10;
    
    config.sigma_n_EKF_PR_DYNAMIC = config.sigma_R;
    config.sigma_ksi_ax_EKF_PR_DYNAMIC = 1;
    config.sigma_ksi_ay_EKF_PR_DYNAMIC = 1;
    config.sigma_ksi_az_EKF_PR_DYNAMIC = 1;
    config.sigma_ksi_drift_EKF_PR_DYNAMIC = 1e-10;
    
    config.c = 299792458;
    
    config.epsilon = 0.001;
    
    config.GDOP_step = 0.1;
    config.zone_zoom = 10;
        
    config.static_dynamic_flag = 0;
    
    config.pos_tag_x_static = 15.0;
    config.pos_tag_y_static = 15.0;
    config.pos_tag_z = 1;
    if config.static_dynamic_flag == 0
        for i = 1:config.count_steps_simulation
            config.path_tag_x(i) = config.pos_tag_x_static;
            config.path_tag_y(i) = config.pos_tag_y_static;
        end
    elseif config.static_dynamic_flag == 1
        config.path_tag_x = 0:0.01:config.time_simulation / 10;
        config.path_tag_x = config.path_tag_x + 1;
        config.path_tag_y = sin(2*pi*(config.path_tag_x / 15)) * 3 + 5;
    end
    
    config.title_font_size = 14;
    config.axes_font_size = 18;
    config.figure_font_text_size = 20;
    config.figure_font_text_type = 'Bold';
    
end

