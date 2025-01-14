% Use all motors even if they have zero value
clc, clear all, close all

% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
%R1.components_tree.tostring
wheel_inds = [4, 5];    % right, left
wheel_labels = {'right wheel', 'left wheel'};
omegas = [120, 120.001];

% R1 = RobotClass('json_fname', 'robot_0005.json');
% R1.components_tree.tostring
% wheel_inds = [5, 6, 7];
% wheel_labels = {'wheel 1', 'wheel 2', 'wheel 3'};
% omegas = [120, 0, -120];

% set pose
th = deg2rad(135);
T = R1.transformation;
T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
R1.set_transformation(T)

% plot robot
%R1.plot('full');    axis equal

% time step
d_t = 1e-1;

% prepare the inputs
pose_old = transformation3d_to_pose2d(R1.transformation);
%omegas_map = containers.Map(wheel_inds, omegas);   % with indices
omegas_map = containers.Map(wheel_labels, omegas);    % with labels

% Get kinematics model (closed form Jacobians)
[pose_new, D_p, D_w, omegas_rhr] = kinematics_pose_estimation(R1, pose_old, d_t, omegas_map);
[D_p, D_w]

% Estimate Jacobians numerically
% NOTE: if D_w below has different sign of entries it's because omega
% changes sign to those wheel with lhr in JSON file
e = 1e-6;   % small number
x = [pose_old; omegas'];
n = length(x);
D = e * eye(n);
X0 = repmat(x, 1, n);
X1 = X0 + D;
dif = [];
for i=1:n
    % at X0
    pose_old0 = X0(1:3, i);
    omegas_map0 = containers.Map(wheel_labels, X0(4:end, i));
    pose_new0 = kinematics_pose_estimation(R1, pose_old0, d_t, omegas_map0);
    
    % at X1
    pose_old1 = X1(1:3, i);
    omegas_map1 = containers.Map(wheel_labels, X1(4:end, i));
    pose_new1 = kinematics_pose_estimation(R1, pose_old1, d_t, omegas_map1);
    
    dif = [dif, (pose_new1 - pose_new0)];
end
D = dif / e
