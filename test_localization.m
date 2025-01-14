function my_alg = test_localization(my_alg, robot)
% This function drives the robot in a straight line for 10 seconds.
% Then, it stops.
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

%% Initialise all variables and settings
if my_alg('is_first_time')
    
    % change if necessary to 'voltage_pwm'
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     
    % Initialise sequence to store estimated robot pose at each time step
    my_alg('path_x')=[];
    my_alg('path_y')=[];
    
    % Based on the selected robot model define if the on-board sensor is
    % sonar/LiDAR/Laser
    if strfind(robot.description,'sonar')
        my_alg('Sensor')    = 1;
    elseif strfind(robot.description,'Lidar')
        my_alg('Sensor')    = 2;
    elseif strfind(robot.description,'laser')
        my_alg('Sensor')    = 3;
    end
    
    % Based on the sensor used initialise localisation object
    if my_alg('Sensor') == 1 || my_alg('Sensor') == 3
        my_alg('localizer') = LocalizationClass(...
                            'method', 'wv',...  % 'wv' is dead-reckoning localisation alg
                            'robot', robot,...  % insert the robot object
                            'pose', [0 0 0],... % Initial robot pose (must be the same as in GUI)
                            ... % Not specified for dead-reckoning
                            ... % Not specified for dead-reckoning
                            'ext_sensor_label', 'range'); % specify sensor 'range' -> sonar/Laser
    elseif my_alg('Sensor') == 2
        my_alg('localizer') = LocalizationClass(...
                            'method', 'wv',...  % 'wv' is dead-reckoning localisation alg
                            'robot', robot,...  % insert the robot object
                            'pose', [0 0 0],... % Initial robot pose (must be the same as in GUI)
                            ... % Not specified for dead-reckoning
                            ... % Not specified for dead-reckoning
                            'ext_sensor_label', 'lidar'); % specify sensor 'lidar' -> LiDAR
    end
end

%% Apply the localisation test
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
% Get time since start of session
time = toc(my_alg('tic'));
if time < 20
    % apply right wheel angular velocity (rad/s)
    my_alg('right motor') = 5;
    % apply left wheel angular velocity (rad/s)
    my_alg('left motor') = 4.5;
else
    % Stop motors
    my_alg('right motor') = 0;
    my_alg('left motor') = 0;
    % Stop session
    my_alg('is_done') = true;
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