% Test figure, axes, hold on, and children
clc, clear all, close all


% Create Robot
R1 = RobotClass('json_fname', 'robot_0004.json');
R1.components_tree.tostring

% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
tic
h_w = W.plot();
toc

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
    if ~ishold
        hold on
    end
    
    % Update motors
    om = 1;
    R1.update_component('motor 1', 'voltage_pwm', -om, 'delta_time', d_t)
    R1.update_component('motor 2', 'voltage_pwm', -om, 'delta_time', d_t)
    R1.update_component('motor 3', 'voltage_pwm', om, 'delta_time', d_t)
    R1.update_component('motor 4', 'voltage_pwm', om, 'delta_time', d_t)
    
    
    
    % Update pose
    R1.update_pose('kinematics', d_t)
    
    if i>1
        delete([h_r])
    end
    tic
    h_r = R1.plot('full');
    
    toc
    xlabel('x');ylabel('y');zlabel('z')
    pause(0.05)
end
hold off


