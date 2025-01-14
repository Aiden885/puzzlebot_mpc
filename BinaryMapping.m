function my_alg = BinaryMapping(my_alg, robot)

%% Initialisation
    if my_alg('is_first_time')
        % signal form used for controlling the motor change if necessary to 'voltage_pwm'
        my_alg('dc_motor_signal_mode') = 'omega_setpoint';
        
        map.ll_corner = [-10 -5];   % left lower corner coordinate
        map.ur_corner = [10 5];     % upper right corner coordinate
        map.res = 0.1;              % grid map resolution
        % number of grids in for row and column
        map_size = floor(map.ur_corner - map.ll_corner)./map.res+1;
        % set each grid in the map to 50% probability
        map.OGrid = 0.5* ones(map_size(2),map_size(1));
        % the type of mapping algorithm 'binary' or 'log_odds'
        map.type = 'binary';
        % Save the object map into the main algorithm
        my_alg('map') = map;
        
        % From the selected robot model access the angle Span of LiDAR
        Angle_span              = robot.components_tree.get('lidar').angle_span/360*2*pi;
        % From the selected robot model access the angle resolution of LiDAR
        Angle_resolution        = robot.components_tree.get('lidar').angle_resolution/360*2*pi;
        % create a vector of the set of all possible bearings of LiDAR in order
        my_alg('Th')            = -(Angle_span/2)+Angle_resolution:Angle_resolution:(Angle_span/2);
    end
    
%% Use driveToGoal to move the robot (change to driveToMultipleGoals if necessary)
    my_alg = driveToGoal(my_alg, robot);

%% Required variables
    % Robot pose estimation [(m) (m) (rad)]'
    S                   = my_alg('localizer').pose;
    % Vector of the set of all possible bearings of LiDAR in order
    Theta               = my_alg('Th');
    % Vectoe of range measurements with respect to 'Theta'
    Range               = my_alg('lidar');
    % From the selected robot model access the maximum range measurement
    max_range           = robot.components_tree.get('lidar').max_range;
    % map object
    map                 = my_alg('map');
    
% =========================================================================
%% ==== Coursework 2 - Task 5 - Occupancy Grid Binary Mapping =============
% ===== Start Here ========================================================

%% Mapping process
for i = 1:360
    % Check if the LiDAR reading indicates a detected obstacle (not at infinity)
    if Range(i) ~= inf
        % Calculate the real-world x and y coordinates of the detected obstacle
        % based on the robot's current position (S) and the bearing (Theta(i))
        Obstacle_x = S(1) + Range(i) * cos(S(3) + Theta(i));
        Obstacle_y = S(2) + Range(i) * sin(S(3) + Theta(i));
        
        % Convert these real-world coordinates into grid indices based on the map's resolution
        Cell_Obstacle_x = floor((Obstacle_x - map.ll_corner(1)) / map.res) + 1;
        Cell_Obstacle_y = floor((Obstacle_y - map.ll_corner(2)) / map.res) + 1;
        
        % Use Bresenham's line algorithm to compute grid cells from the robot's
        % current position to the obstacle, depicting the line of sight
        rc_empty = getBresenhamLine(map, [S(1) S(2)]', [Obstacle_x Obstacle_y]');
        
        % Mark all cells along this line as free (except for the cell containing the obstacle itself)
        for j = 2:size(rc_empty, 2) - 1
            lx = rc_empty(2, j);  % x-coordinate in the grid
            ly = rc_empty(1, j);  % y-coordinate in the grid
            % Set the cell as free only if it is not already marked as occupied
            if map.OGrid(ly, lx) ~= 1
                map.OGrid(ly, lx) = 0;
            end
        end
        % Mark the grid cell that contains the obstacle as occupied
        map.OGrid(Cell_Obstacle_y, Cell_Obstacle_x) = 1;
    end
    
    % If the LiDAR reading is infinity (no obstacle detected within the sensor range)
    if Range(i) == inf
        % Treat this infinity as the maximum measurable range
        Range(i) = max_range;
        % Calculate the coordinates where the LiDAR's range effectively ends
        Obstacle_x = S(1) + Range(i) * cos(S(3) + Theta(i));
        Obstacle_y = S(2) + Range(i) * sin(S(3) + Theta(i));
        % Compute the line of cells that this range touches using Bresenham's line algorithm
        rc_empty = getBresenhamLine(map, [S(1) S(2)]', [Obstacle_x Obstacle_y]');
        
        % Set all cells along this path as free since no obstacle is detected
        for j = 4:size(rc_empty, 2) - 3  % starting from index 4 to exclude the robot's immediate vicinity
            lx = rc_empty(2, j);
            ly = rc_empty(1, j);
            if map.OGrid(ly, lx) ~= 1  % only change to free if not already marked as occupied
                map.OGrid(ly, lx) = 0;
            end
        end
    end
end

% ===== Finish Here =======================================================
% ===== Coursework 2 - Task 5 - Occupancy Grid Binary Mapping =============
% =========================================================================
    
    % save map object
    my_alg('map') = map;

    % plot the estimated map
    figure(2), clf
    worldPlot2( map,1);
    title('Binary Mapping');
return