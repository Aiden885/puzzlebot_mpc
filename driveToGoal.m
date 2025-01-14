function my_alg = driveToGoal(my_alg, robot)


% -------------------------------------------------------------------------

%% Initialise all variables and settings
if my_alg('is_first_time')
    % =========================Initialization==============================
    % =====================Initial the variables here====================== 
    
    % change if necessary to 'voltage_pwm'
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     
    % Initialise sequence to store estimated robot pose at each time step
    my_alg('path_x')=[];
    my_alg('path_y')=[];
    my_alg('omega') = 0;
    my_alg('v') = 0;
    % initialise the right and left wheel angular velocity to 0
    my_alg('right motor')   = 0;
    my_alg('left motor')    = 0;
    my_alg('OperationTime') = 0;
    %======================Set your goal here==============================
    my_alg('goal')=[8 0]';
    % ===================================================================== 
    
    % =================== Set localisation alg ============================
    % =====================================================================
    % Select 1 for Deadreckoning and 2 for Particle Filter
    my_alg('localiser_type') = 2;  
    % =====================================================================
    % =====================================================================
    
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
            'map', WorldClass('fname','world_0006.mat'),... % Specify the map
            'ext_sensor_label', 'lidar');   % specify sensor 'lidar' -> LiDAR
    end
end

%% Apply Dead reckoning or particle filter
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
w_sat               = 12.8;
% Boolen varaiable that indicates the end of simulation (true/false)
% (finish simulation/continue simulation)
my_alg('is_done')   = false;

% =====================================================================
%% ==== Coursework 1 - Task 3 - Motion Control (Part 1) ===============
% ===== Start Here ====================================================
kdistance = 3.5;   % Proportional gain for distance
K_alpha = 40;      % Proportional gain for angle
my_alg('current_k') = (goal(2)-0)/(goal(1)-0);
% Compute the vector from the robot to the target point
dx = goal(1) - S(1);
dy = goal(2) - S(2);

% Calculate the distance (formerly rho) and angle (alpha) to the target point
distance = sqrt(dx^2 + dy^2);
alpha = atan2(dy, dx) - S(3);

% Normalize alpha to be within -pi to pi
alpha = atan2(sin(alpha), cos(alpha));

% Calculate control signals
v = kdistance * distance;  % Linear velocity
omega = K_alpha * alpha;   % Angular velocity
my_alg('omega') = omega;
my_alg('v') = v;
my_alg('distance') = distance;
my_alg('l') =l;
my_alg('r') =r;
my_alg('alpha') =alpha;
% Calculate wheel speeds
w_r = v/r + omega*l/(2*r);
w_l = v/r - omega*l/(2*r);

% Compute the maximum absolute value among wheel speeds
max_speed = max(abs([w_r, w_l]));

% If maximum speed exceeds the saturation limit w_sat, adjust w_r and w_l to not exceed w_sat
if max_speed > w_sat
    scaling_factor = w_sat / max_speed;
    w_r = w_r * scaling_factor;
    w_l = w_l * scaling_factor;
end

% If distance is below a threshold, stop the robot and end the simulation
if distance < 0.1
    w_r = 0;
    w_l = 0;
    my_alg('is_done') = true;
end

% ===== Finish Here ===================================================
% ===== Coursework 1 - Task 3 - Motion Control (Part 1) ===============
% =====================================================================
%% Aquire robot input
my_alg('right motor')   = w_r;
my_alg('left motor')    = w_l;
my_alg('Sensor');
%% Apply obstacle avoidance
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