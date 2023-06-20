function GDOP_matrix = GDOP_DR(config, max_GDOP_R)
    x_array = [];
    for i = 0:(((max([config.anchors(:).x]) + config.zone_zoom) - (min([config.anchors(:).x]) - config.zone_zoom)) / config.GDOP_step + 1) - 1
        x_array = [x_array, (min([config.anchors(:).x]) - config.zone_zoom) + i * config.GDOP_step];
    end
    y_array = [];
    for i = 0:(((max([config.anchors(:).y]) + config.zone_zoom) - (min([config.anchors(:).y]) - config.zone_zoom)) / config.GDOP_step + 1) - 1
        y_array = [y_array, (min([config.anchors(:).y]) - config.zone_zoom) + i * config.GDOP_step];
    end
    
    P = eye(length(config.anchors) - 1);
    for i = 1:length(config.anchors) - 1
        P(i, length(config.anchors)) = -1;
    end
    W = P * P';
    
    for x = 1:((max([config.anchors(:).x]) + config.zone_zoom) - (min([config.anchors(:).x]) - config.zone_zoom)) / config.GDOP_step + 1
        for y = 1:((max([config.anchors(:).y]) + config.zone_zoom) - (min([config.anchors(:).y]) - config.zone_zoom)) / config.GDOP_step + 1
            for i = 1:length(config.anchors)
               H(i, 1) = (x_array(x) - config.anchors(i).x) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
               H(i, 2) = (y_array(y) - config.anchors(i).y) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
               H(i, 3) = (config.pos_tag_z - config.anchors(i).z) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
            end
            GDOP = sqrt(trace((H' * P' * W^-1 * P * H)^-1));
            if GDOP < max_GDOP_R
                GDOP_matrix(y, x) = GDOP;
            else
                GDOP_matrix(y, x) = max_GDOP_R;
            end
        end
    end
end

