function my_alg = ProbabilisticMapping(my_alg, robot)

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
%% ==== Coursework 2 - Tasks 6 - Occupancy Grid Probabilistic Mapping =====
% ===== Start Here ========================================================
P_Z_Occupied = 0.85;
P_F_Occupied = 0.3;
P_Z_UnOccupied = 0.2;
P_F_UnOccupied = 0.9;

%Write youir code here
    for i = 1:360
        if Range(i) ~= inf
            Obstacle_x = S(1) + Range(i)*cos(S(3)+(Theta(i)));
            Obstacle_y = S(2) + Range(i)*sin(S(3)+(Theta(i)));

            Cell_Obstacle_x = floor((Obstacle_x - map.ll_corner(1))/map.res) + 1;
            Cell_Obstacle_y = floor((Obstacle_y - map.ll_corner(2))/map.res) + 1;
            
            rc_empty = getBresenhamLine(map,[S(1) S(2)]',[Obstacle_x Obstacle_y]');

           % Empty sapce
            for j = 1:size(rc_empty, 2)-1
                lx = rc_empty(2, j);
                ly = rc_empty(1, j);
                % Empty plot
                P_UnOccupied = 1-map.OGrid(ly,lx);
                P_Occupied = map.OGrid(ly,lx);
                P_F = P_F_Occupied*P_Occupied + P_F_UnOccupied*(1-P_Occupied);
                map.OGrid(ly,lx) = 1 - P_F_UnOccupied*P_UnOccupied/P_F;
            end

            % Obstacle plot
            P_Occupied = map.OGrid(Cell_Obstacle_y,Cell_Obstacle_x);
            P_Z = P_Z_Occupied*P_Occupied + P_Z_UnOccupied*(1-P_Occupied);
            map.OGrid(Cell_Obstacle_y,Cell_Obstacle_x) = P_Z_Occupied*P_Occupied/P_Z;

            my_alg('LastObstacle_x') = Cell_Obstacle_x;
            my_alg('LastObstacle_x') = Cell_Obstacle_y;
        end

        if Range(i) == inf
            Range(i) = max_range;
            Obstacle_x = S(1) + Range(i)*cos(S(3)+(Theta(i)));
            Obstacle_y = S(2) + Range(i)*sin(S(3)+(Theta(i)));

            rc_empty = getBresenhamLine(map,[S(1) S(2)]',[Obstacle_x Obstacle_y]');
            
            %Empty space
            for j = 1:size(rc_empty, 2)-1
                lx = rc_empty(2, j);
                ly = rc_empty(1, j);
                % Empty plot
                P_UnOccupied = 1-map.OGrid(ly,lx);
                P_Occupied = map.OGrid(ly,lx);
                P_F = P_F_Occupied*P_Occupied + P_F_UnOccupied*(1-P_Occupied);
                map.OGrid(ly,lx) = 1 - P_F_UnOccupied*P_UnOccupied/P_F;
            end
        end
    end

% ===== Finish Here =======================================================
% ===== Coursework 2 - Tasks 6 - Occupancy Grid Probabilistic Mapping =====
% =========================================================================    

    % save map object
    my_alg('map') = map;

    % plot the estimated map
    figure(2), clf
    worldPlot2( map,1);
    title('Binary Mapping');
   
return