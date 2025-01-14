% Test figure, axes, hold on, and children
clc, clear all, close all


% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');    % Use 2 for lidar and 3 for sonar
R1.components_tree.tostring

% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
tic
h_w = W.plot();
toc

for i=1:100
    if ~ishold
        hold on
    end
    % set pose
    th = deg2rad(i*10);
    T = R1.transformation;
    T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
    R1.set_transformation(T);
    
    % Update servo
    R1.update_component('servo', 'angle', deg2rad(60))
    R1.update_component('range', 'world', W)
    
    if i>1
        delete([h_r, h_s])
    end
    tic
    h_r = R1.plot('simple');
    h_s = R1.plot_measurements('range');
    
    toc
    xlabel('x');ylabel('y');zlabel('z')
    pause(0.05)
end
hold off


