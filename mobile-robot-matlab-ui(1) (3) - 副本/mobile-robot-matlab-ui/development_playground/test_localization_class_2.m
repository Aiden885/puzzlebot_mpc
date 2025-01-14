clc, clear all, close all

% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
% set initial pose
pose2d = [0 0 0]';
R1.set_transformation(pose2d_to_transformation3d(pose2d))

% Create World
W = WorldClass();

% Create localization object
L = LocalizationClass('method', 'wv', 'robot', R1, 'pose', pose2d);

% Plot all
figure(1)
%h_w = W.plot();
xlabel('x'); ylabel('y')
axis equal, hold on

% Simulation parameters
n_steps = 500;                  % Number of simuation steps
st = tic;
for i=1:n_steps
    % Compute change in time for robot update
    try
        dt = toc(t_last_robot_upate);
    catch
        dt = 0;
    end
    t_last_robot_upate = tic;       % reset stopwatch

    % Update robot in this order: actuators, pose (in simulation), sensors
    if toc(st) < 5
        actuator_signals = {'right motor', 10, 'left motor', 10, 'servo', deg2rad(i - 50)};
    elseif toc(st) < 8
        actuator_signals = {'right motor', 1, 'left motor', -1, 'servo', deg2rad(i - 50)};
    elseif toc(st) < 12
        actuator_signals = {'right motor', 10, 'left motor', 10, 'servo', deg2rad(i - 50)};
    end
    sensor_readings = R1.update(dt, W, 'kinematics', 'omega_setpoint', actuator_signals{:});

    % Localization
    wheel_labels = {'right wheel', 'left wheel'};
    omegas = [sensor_readings('right encoder'), sensor_readings('left encoder')];
    omegas_map = containers.Map(wheel_labels, omegas);
    L.update(omegas_map)
    
    % Plot all
    figure(1)
    try
        delete(h_r)
        delete(h_l)
    catch
    end
    h_r = R1.plot('simple');
    h_l = L.plot();
    
    pause(1e-3)
end
