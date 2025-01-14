% Test figure, axes, hold on, and children
clc
clear all
close all


% Create components
h1 = figure(10);
M1 = ComponentClass('json_fname', 'motor_0001.json');
S1 = ComponentClass('json_fname', 'encoder_0001.json');
S2 = ComponentClass('json_fname', 'lidar_0001.json');
T1 = [rotationVector2Matrix([1 0 0]*-pi/2) [0 0.075 0]';0 0 0 1];
T2 = eye(4);
T3 = [rotationVector2Matrix([0 0 1]*pi/6) [0.5 0.5 0]';0 0 0 1];

% plot
h = plot_shape(M1.shape, 'transformation', T1);
hold on
h = [h plot_shape(S1.shape, 'transformation', T2)];
h = [h plot_shape(S2.shape, 'transformation', T3)];
hold off
axis equal
xlabel('x')
ylabel('y')
zlabel('z')