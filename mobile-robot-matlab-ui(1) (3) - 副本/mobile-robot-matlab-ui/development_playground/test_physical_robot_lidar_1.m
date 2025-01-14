clc, clear all, close all

% Create Robot
R1 = RobotClass('json_fname', 'puzzle_bot_0003.json');
R1.connect('192.168.1.1', 3141, 'tcp')

% set initial pose
pose2d = [0 0 deg2rad(0)]';
R1.set_transformation(pose2d_to_transformation3d(pose2d))

% Create World
W = WorldClass('fname', 'world_0002.json');
W = WorldClass();

% Plot all
figure(1)
h_w = W.plot();
xlabel('x'); ylabel('y')
axis([-2 2 -2 2])

% Simulation parameters
st = tic;
i = 1;
while toc(st) < 10
    % Compute change in time for robot update
    try
        dt = toc(t_last_robot_upate);
    catch
        dt = 0;
    end
    t_last_robot_upate = tic;       % reset stopwatch

    % Update robot in this order: actuators, pose (in simulation), sensors
    actuator_signals = {'right motor', 0.25, 'left motor', 0.25};
    sensor_readings = R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});

    %[sensor_readings('left encoder') sensor_readings('right encoder')]
    %sensor_readings('lidar')
    
    % Plot all
    figure(1)
    try
        delete(h_r)
        delete(h_s)
    catch
    end
    h_r = R1.plot('simple');
    h_s = R1.plot_measurements('lidar');
    
    pause(1e-3)
    i = i + 1;
end

R1.disconnect()