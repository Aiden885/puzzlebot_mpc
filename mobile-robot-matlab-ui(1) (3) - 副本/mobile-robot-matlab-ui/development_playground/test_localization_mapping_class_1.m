clc, clear all, close all

% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');

% set initial pose
pose2d = [-3.5 -2 deg2rad(30)]';
R1.set_transformation(pose2d_to_transformation3d(pose2d))

% Create World
W = WorldClass('fname', 'world_0002.json');

% Create localization object
L = LocalizationClass('method', 'pf', 'robot', R1, 'pose', pose2d,...
    'n_particles', 30, 'map', W, 'ext_sensor_label', 'range');

% Create mapping object
M = MappingClass('method', 'prob_grid', 'robot', R1,...
    'ext_sensor_label', 'range', 'll_corner', [-10 -5], 'ur_corner', [10 5]);

% Plot all
figure(1)
h_w = W.plot();
xlabel('x'); ylabel('y')

% Simulation parameters
st = tic;
i = 1;
while toc(st) < 9
    % Compute change in time for robot update
    try
        dt = toc(t_last_robot_upate);
    catch
        dt = 0;
    end
    t_last_robot_upate = tic;       % reset stopwatch

    % Update robot in this order: actuators, pose (in simulation), sensors
    actuator_signals = {'right motor', 12, 'left motor', 11.75, 'servo', deg2rad(i - 50)};
    sensor_readings = R1.update(dt, W, 'kinematics', 'omega_setpoint', actuator_signals{:});
    
    % Localization
    wheel_labels = {'right wheel', 'left wheel'};
    omegas = [sensor_readings('right encoder'), sensor_readings('left encoder')];
    omegas_map = containers.Map(wheel_labels, omegas);
    L.update(omegas_map)
    
    % Mapping
    M.update(L.pose)
    
    % Plot all
    figure(1)
    try
        delete(h_r)
        delete(h_s)
        delete(h_l)
        delete(h_m)
    catch
    end
    h_r = R1.plot('simple');
    h_s = R1.plot_measurements('range');
    h_l = L.plot();
    h_m = M.plot(0.5);
    
    pause(1e-3)
    i = i + 1;
end
% Plot map
figure(2)
M.plot();
axis equal