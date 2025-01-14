function my_alg = driveToMultipleGoals(my_alg, robot)
% This function drives the robot in a square with localization
% activated.
%
% Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

%% Initialise all variables and settings
if my_alg('is_first_time')
    % =========================Initialization==============================
    %======================Initial the variables here====================== 
    % change if necessary to 'voltage_pwm'
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     
    % Initialise sequence to store estimated robot pose at each time step
    my_alg('path_x')=[];
    my_alg('path_y')=[];
    % initialise the right and left wheel angular velocity to 0
    my_alg('right motor')   = 0;
    my_alg('left motor')    = 0;
    % initialise the index of the goal point
    my_alg('k')             = 1;
    
    %======================Set your goals here=============================

    my_alg('goal')          = [%8 0;...

                               %  8    3;...
                               % -1   4;...
                               % 0    0
                               2 1;
                               8 0
                               ];

    %======================================================================    
    
    % =================== Set localisation alg ============================
    % =====================================================================
    % Select 1 for Deadreckoning and 2 for Particle Filter
    my_alg('localiser_type') = 2;  
    % =====================================================================
    % ======================================================================
    
    % Based on the selected robot model define if the on-board sensor is
    % sonar/LiDAR/Laser
    if strfind(robot.description,'sonar')
        my_alg('Sensor')    = 1;
    elseif strfind(robot.description,'Lidar')
        my_alg('Sensor')    = 2;
    elseif strfind(robot.description,'laser')
        my_alg('Sensor')    = 3;
    end
    
    % Dead-reckoning
    if my_alg('localiser_type') == 1
        my_alg('localizer') = LocalizationClass(...
            'method', 'wv',...  % 'wv' is dead-reckoning localisation alg
            'robot', robot,...  % insert the robot object
            'pose', [0 0 0],... % Initial robot pose (must be the same as in GUI)
            ... % Not specified for dead-reckoning
            ... % Not specified for dead-reckoning
            'ext_sensor_label', 'range');   % specify sensor 'range' -> sonar/Laser
    elseif my_alg('localiser_type') == 2
    % Particle filter
        my_alg('localizer') = LocalizationClass(...
            'method', 'pf',... % 'pf' is particle filter localisation alg
            'robot', robot,... % insert the robot object
            'pose', [0 0 0],...% Initial robot pose (must be the same as in GUI)
            'n_particles', 30,...   % specify the number of particles
            'map', WorldClass('fname','obstacle_simple_1.mat'),... % Specify the map
            'ext_sensor_label', 'lidar');   % specify sensor 'lidar' -> LiDAR
    end
end

%% Apply Dead reckoning
% create an object that contains encoder reading for both right and left
% wheels
omegas_map = containers.Map({'right wheel', 'left wheel'},...
    [my_alg('right encoder'), my_alg('left encoder')]);
% Based on the localisation alg statement apply either dead-reckoning
% localisation or particle filter localisation
if strfind(my_alg('localizer').method,'wv')
    my_alg('localizer') = Deadreckoning(my_alg('localizer'),omegas_map);
elseif strfind(my_alg('localizer').method,'pf')
    my_alg('localizer') = ParticleFilter(my_alg('localizer'),omegas_map);
end

%% Call required state variables and system constants

% Varaibles that can be used for Coursework 1 - Task 3
% Robot pose estimation [(m) (m) (rad)]'
S                   = my_alg('localizer').pose;
% Goal point (m)
goal                = my_alg('goal');
% right wheel angular velocity (rad/s)
w_r                 = omegas_map('right wheel');
% Left wheel angular velocity (rad/s)
w_l                 = omegas_map('left wheel'); 
% From the selected robot model call the distance between the two wheels(m)
l                   = 2*robot.components_tree.get('left motor').transformation(2,end);
% From the selected robot model call the radius of the wheel (m)
r                   = robot.components_tree.get('left wheel').shape.diameter/2;
% maximum angular velocity of the motor (rad/s)
w_sat               = 12.7;
% The index of the current goal point
K                   = my_alg('k');
% Boolen varaiable that indicates the end of simulation (true/false)
% (finish simulation/continue simulation)
my_alg('is_done')   = false;

% =====================================================================
%% ==== Coursework 1 - Task 4 - Motion Control (Part 2) ===============
% ===== Start Here ====================================================
% Constants for controller
K_rho =1; % Proportional gain for distance
K_alpha = 15;
goal_tolerance = 0.5; % How close we need to get to the goal to consider it reached (m)

% Get the goals array from the my_alg object
goals_array = my_alg('goal');

% Current goal
if K >=2
    pre_k = goals_array(K-1,:)';
else
    pre_k = [0 0]';
end
current_goal = goals_array(K, :)';

my_alg('current_k') = (current_goal(2)-pre_k(2))/(current_goal(1)-pre_k(1));

% Compute the vector from the robot to the current goal
dx = current_goal(1) - S(1);
dy = current_goal(2) - S(2);

% Compute the distance (rho) and the angle (alpha) to the current goal
rho = sqrt(dx^2 + dy^2);
alpha = atan2(dy, dx) - S(3);

% Normalize alpha to be within -pi to pi
alpha = atan2(sin(alpha), cos(alpha));

% % Adjust K_alpha based on the magnitude of alpha
% if abs(alpha) > pi/2 % Greater than 90 degrees or less than -90 degrees
%     K_alpha = 20;
% elseif abs(alpha) <= pi/4 && abs(alpha) > pi/6 % Between -45 and 45 degrees, excluding -30 to 30 degrees
%     K_alpha = 15;
% elseif abs(alpha) <= pi/6 && abs(alpha) > pi/18 % Between -30 and 30 degrees, excluding -10 to 10 degrees
%     K_alpha = 12;
% elseif abs(alpha) <= pi/18 % Between -10 and 10 degrees
%     K_alpha = 8;
% end

% Compute control signals
v = K_rho * rho; % Linear velocity
omega = K_alpha * alpha; % Angular velocity

% Compute wheel speeds before saturation
w_r_unsat = v/r + omega*l/(2*r);
w_l_unsat = v/r - omega*l/(2*r);

% Scale the speeds if any of them exceeds the maximum speed
max_speed = max(abs([w_r_unsat, w_l_unsat]));
if max_speed > w_sat
    scale =(w_sat) / max_speed;
    w_r = scale * w_r_unsat;
    w_l = scale * w_l_unsat;
else
    w_r = w_r_unsat;
    w_l = w_l_unsat;
end
my_alg('omega') = omega;
my_alg('v') = v;
my_alg('distance') = rho;
my_alg('l') =l;
my_alg('r') =r;
my_alg('alpha') =alpha;
% Check if the current goal is reached
if rho < goal_tolerance
    K = K + 1; % Move to the next goal
    if K > size(my_alg('goal'), 1)
        my_alg('is_done') = true; % End if all goals are reached
        w_r = 0; % Stop the robot
        w_l = 0;
    end
end

disp(current_goal)

% ===== Finish Here ===================================================
% ===== Coursework 1 - Task 4 - Motion Control (Part 2) ===============
% =====================================================================
%% Acquire robot input
my_alg('k')             = K;
my_alg('right motor')   = w_r;
my_alg('left motor')    = w_l;

% Apply obstacle avoidance
if my_alg('Sensor') == 2
    my_alg = ObstacleAvoidanceLiDAR(my_alg, robot);
elseif my_alg('Sensor') == 1 || my_alg('Sensor') == 3
    my_alg = ObstacleAvoidanceRange(my_alg, robot);
end


%% Display results in GUI
% update the path sequence
my_alg('path_x')=[my_alg('path_x') my_alg('localizer').pose(1)];
my_alg('path_y')=[my_alg('path_y') my_alg('localizer').pose(2)];
% plot actual pose estimation in the main figure
my_alg = add_plot(my_alg, 'plot(my_alg(''localizer''))');
% plot pose estimation in the main figure
my_alg = add_plot(my_alg, 'plot(my_alg(''path_x''),my_alg(''path_y''),''k--'')');
% plot Robot covariance circle
my_alg = add_plot(my_alg, 'plot(my_alg(''obj,cov''))');


return