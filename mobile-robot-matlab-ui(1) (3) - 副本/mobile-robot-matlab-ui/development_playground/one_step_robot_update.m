clc, clear all, close all


% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');

% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
h_w = W.plot();
xlabel('x'); ylabel('y'); zlabel('z')

% set initial pose
R1.set_transformation(eye(4))

% Move for one step
dt = 1;

% Update robot in this order: actuators, pose (in simulation), sensors
actuator_signals = {'right motor', 0.5, 'left motor', 0.5, 'servo', deg2rad(50)};
sensor_readings = R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});

% Plot everything
h_r = R1.plot('simple');
h_s = R1.plot_measurements('range');

