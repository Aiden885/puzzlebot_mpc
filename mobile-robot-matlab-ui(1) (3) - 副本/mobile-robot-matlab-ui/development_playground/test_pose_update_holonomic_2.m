% Test figure, axes, hold on, and children
clc, clear all, close all


% Create Robot
R1 = RobotClass('json_fname', 'robot_0005.json');
R1.components_tree.tostring

% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
h_w = W.plot();
xlabel('x'); ylabel('y'); zlabel('z')

% delete later
axis equal
axis(0.5 * [-1 1 -1 1])

d_t = 1e-2;     % time step

% set pose
th = deg2rad(0);
T = R1.transformation;
T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
R1.set_transformation(T)

for i=1:100
    % Update motors
    w = 15;
    R1.update_component('motor 1', 'omega_setpoint', w, 'delta_time', d_t)
    %R1.update_component('motor 2', 'omega_setpoint', 0, 'delta_time', d_t)
    R1.update_component('motor 3', 'omega_setpoint', w, 'delta_time', d_t)
        
    % Update pose
    R1.update_pose('kinematics', d_t)
    
    % Plot
    try
        delete([h_r, h_2])
    catch
    end
    h_r = R1.plot('full');
    h_2 = plot(-0.1, 0, 'bo', 'MarkerSize', 10);    % center of rotation
    pause(0.001)
end


