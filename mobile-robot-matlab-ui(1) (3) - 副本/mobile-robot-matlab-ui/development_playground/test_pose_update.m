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

d_t = 1e-1;     % time step

% set pose
th = deg2rad(0);
T = R1.transformation;
T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
R1.set_transformation(T)

for i=1:100
    tic
    
    % Update motors
    R1.update_component('right motor', 'voltage_pwm', 0.5, 'delta_time', d_t)
    R1.update_component('left motor', 'voltage_pwm', 0.5, 'delta_time', d_t)
    %[R1.components_tree.get(4).omega, R1.components_tree.get(5).omega]

    % Update pose
    R1.update_pose('kinematics', d_t)
    
    % Update lidar/sonar
    R1.update_component('range', 'world', W)

    % Plot all
    try
        delete([h_r, h_s])
    catch
    end
    h_r = R1.plot('simple');
    h_s = R1.plot_measurements('range');
    pause(0.001)
    
    toc
end


