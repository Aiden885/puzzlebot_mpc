function [my_alg] = ObstacleAvoidanceLiDAR(my_alg, robot)
%% Initialize all variables and settings

if my_alg('is_first_time') 
% =========================================================================
% ========= Coursework 2 - Task 4 - Obstacle Avoidance using LiDAR =========
% ========= Initialize variables Here =====================================

    % Retrieve the angular span of LiDAR from the selected robot model
    Angle_span = robot.components_tree.get('lidar').angle_span/360*2*pi;
    % Retrieve the angular resolution of LiDAR from the selected robot model
    Angle_resolution = robot.components_tree.get('lidar').angle_resolution/360*2*pi;
    % Create a vector of the set of all possible bearings of LiDAR in order
    my_alg('Th') = -(Angle_span/2) + Angle_resolution:Angle_resolution:(Angle_span/2);

% ========= Finish initialization Here ====================================
% ========= Coursework 2 - Task 4 - Obstacle Avoidance using LiDAR ========
% =========================================================================
end

%% Call required state variables and system constants
% Variables for use in Coursework 1 - Task 5
% Robot pose estimation [x (m), y (m), orientation (rad)]'
S = my_alg('localizer').pose;
% Retrieve the distance between the two wheels (m) from the robot model
L = 2*robot.components_tree.get('left motor').transformation(2,end);
% Retrieve the wheel radius (m) from the robot model
r = robot.components_tree.get('left wheel').shape.diameter/2;
% Maximum angular velocity of the motor (rad/s)
w_sat = 13.8;
% Angular velocity of the right wheel (rad/s)
w_r = my_alg('right motor');
% Angular velocity of the left wheel (rad/s)
w_l = my_alg('left motor');
% Array containing the angles of each LiDAR measurement (rad)
Theta = my_alg('Th');
% Array containing the measurements from the LiDAR (m)
Range = my_alg('lidar');

% =========================================================================
%% ======== Coursework 2 - Task 4 - Obstacle Avoidance - LiDAR ============
% ========= Start Here ====================================================

RotateGain = 0.5;
AngleCompensation = 30;
Achieveable = 0;

    % Identify indices where LiDAR range transitions from finite to infinite, indicating potential edge of obstacle
    finite_to_inf_indices = find(isfinite(Range(1:end-1)) & isinf(Range(2:end)));
    
    % Identify indices where LiDAR range transitions from infinite to finite, marking the start of an obstacle
    inf_to_finite_indices = find(isinf(Range(1:end-1)) & isfinite(Range(2:end)));
    
    % Initialize arrays to store the start and end points of the feasible regions
    feasible_starts = [];
    feasible_ends = [];
    
    % Calculate feasible paths by checking continuity of free space
    for i = 1:length(finite_to_inf_indices)
        start_index = finite_to_inf_indices(i) - 180;
        if start_index < 1
            start_index = 1;
        end
        end_index = inf_to_finite_indices(find(inf_to_finite_indices > finite_to_inf_indices(i), 1)) - 180;
        if isempty(end_index)
            end_index = inf_to_finite_indices(find(inf_to_finite_indices < finite_to_inf_indices(i), 1)) - 180;
        end
        feasible_starts = [feasible_starts, start_index];
        feasible_ends = [feasible_ends, end_index];
    end

    % Find the closest feasible region
    min_difference = inf;
    closest_element = NaN;
    
    for i = 1:length(feasible_starts)
        start_index = feasible_starts(i);
        end_index = feasible_ends(i);
        
        % Determine the feasible region based on index
        if start_index < end_index
            feasible_region = start_index:1:end_index;
        elseif start_index > end_index
            feasible_region1 = start_index:180;
            feasible_region2 = -179:end_index;
            feasible_region = [feasible_region1, feasible_region2];
        end
    end
    
    % Adjust steering based on closest feasible path
    if abs(S(3) - end_index) > abs(S(3) - start_index)
        closest_element = feasible_region(numel(feasible_region)) + AngleCompensation;
    elseif abs(S(3) - end_index) < abs(S(3) - start_index)
        closest_element = feasible_region(numel(feasible_region)) - AngleCompensation;
    end

    ExtraOmega = closest_element * RotateGain;

    % Check if the target point is directly reachable
    for i = 170:190
        if Range(i) ~= inf
            Achieveable = 0;
            break;
        end
        Achieveable = 1;
    end
    if abs(my_alg('alpha')) < 1 && Achieveable == 1
        ExtraOmega = 0;
    end
    
    v = my_alg('v');
    l = my_alg('l');
    r = my_alg('r');

    omega = my_alg('omega');
    omega = omega + ExtraOmega;

    % Calculate wheel speeds
    w_r = v/r + omega*l/(2*r);
    w_l = v/r - omega*l/(2*r);

    % Limit wheel speeds if exceeding saturation
    max_speed = max(abs([w_r, w_l]));
    if max_speed > w_sat
        scaling_factor = w_sat / max_speed;
        w_r = w_r * scaling_factor;
        w_l = w_l * scaling_factor;
    end

    % Check if the target has been reached
    if (my_alg('distance') <= 0.03)
        my_alg('is_done') = true;
    end

% ========= Finish Here ===================================================
% ========= Coursework 2 - Task 4 - Obstacle Avoidance - LiDAR ============
% =========================================================================

%% Acquire robot input
    % Update wheel velocities
    my_alg('right motor') = w_r;
    my_alg('left motor') = w_l;

end
