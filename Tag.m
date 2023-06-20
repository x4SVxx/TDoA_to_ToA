classdef Tag
    properties
        name = " "
        x = []
        y = []
        z = []
        anchors = []
        BLINK = []
        full_count = 0
        state_vectors_LSM_DR = []
        state_vectors_LSM_PR = []
        state_vectors_LSM_R = []
        state_vectors_EKF_DR = []
        state_vectors_EKF_PR = []
        BLINK_EKF_PR = []
    end
end