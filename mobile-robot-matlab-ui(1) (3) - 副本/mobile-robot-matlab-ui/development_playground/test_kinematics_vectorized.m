% Use all motors even if they have zero value
clc, clear all, close all

% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
wheel_labels = {'right wheel', 'left wheel'};
omegas = [120, 120];

% R1 = RobotClass('json_fname', 'robot_0005.json');
% wheel_labels = {'wheel 1', 'wheel 2', 'wheel 3'};
% omegas = [120, 0, -120];

% time step
d_t = 1e-1;

% prepare the inputs
pose_old = rand(3, 50);
omegas_map = containers.Map(wheel_labels, omegas);    % with labels

% Get kinematics model (closed form Jacobians)
tic
[pose_new, D_p, D_w, omegas_rhr] = kinematics_pose_estimation(R1, pose_old, d_t, omegas_map);
toc
