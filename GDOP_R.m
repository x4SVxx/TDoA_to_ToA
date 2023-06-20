function GDOP_matrix = GDOP_R(config)
    x_array = [];
    for i = 0:((max([config.anchors(:).x]) + config.zone_zoom) - (min([config.anchors(:).x]) - config.zone_zoom)) / config.GDOP_step
        x_array = [x_array, (min([config.anchors(:).x]) - config.zone_zoom) + i * config.GDOP_step];
    end
    y_array = [];
    for i = 0:((max([config.anchors(:).y]) + config.zone_zoom) - (min([config.anchors(:).y]) - config.zone_zoom)) / config.GDOP_step
        y_array = [y_array, (min([config.anchors(:).y]) - config.zone_zoom) + i * config.GDOP_step];
    end
    
    for x = 1:((max([config.anchors(:).x]) + config.zone_zoom) - (min([config.anchors(:).x]) - config.zone_zoom)) / config.GDOP_step + 1
        for y = 1:((max([config.anchors(:).y]) + config.zone_zoom) - (min([config.anchors(:).y]) - config.zone_zoom)) / config.GDOP_step + 1
            for i = 1:length(config.anchors)
               H(i, 1) = (x_array(x) - config.anchors(i).x) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
               H(i, 2) = (y_array(y) - config.anchors(i).y) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
               H(i, 3) = (config.pos_tag_z - config.anchors(i).z) / sqrt((x_array(x) - config.anchors(i).x)^2 + (y_array(y) - config.anchors(i).y)^2 + (config.pos_tag_z - config.anchors(i).z)^2);
            end
            GDOP_matrix(y, x) = sqrt(trace((H' * H)^-1));
        end
    end
end

