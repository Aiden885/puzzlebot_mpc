clc, clear all, close all


% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
R1.components_tree.tostring

% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
h_w = W.plot();
xlabel('x'); ylabel('y'); zlabel('z')

% set initial pose
th = deg2rad(0);
T = R1.transformation;
T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
R1.set_transformation(T)

% Simulation parameters
n_steps = 100;                  % Number of simuation steps
t_all = zeros(1, n_steps);      % Processing time array

for i=1:n_steps    
    % Compute change in time for robot update
    try
        dt = toc(t_last_robot_upate);
    catch
        dt = 0;
    end
    t_last_robot_upate = tic;       % reset stopwatch
    t_all(i) = dt;
    
    % Update robot in this order: actuators, pose (in simulation), sensors
    actuator_signals = {'right motor', 1, 'left motor', 0.95, 'servo', deg2rad(i - 50)};
    sensor_readings = R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});

    % Plot all
    try
        delete([h_r, h_s])
    catch
    end
    h_r = R1.plot('simple');
    h_s = R1.plot_measurements('range');
    
    pause(0.001)
end

% Plot statistics
figure(2), clf
hist(t_all, 50)
title(['Mean: ' num2str(mean(t_all)) ',   std: ' num2str(std(t_all))])
xlabel('Processing time per iteration (sec.)')

