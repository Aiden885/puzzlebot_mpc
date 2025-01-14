clear all, close all, clc


sonar_angle_span = 30;
n_rotations = 5; n_angles = 100;

r_max = sin(deg2rad(sonar_angle_span) / 2);

n_angles_2 = round(n_angles / (n_rotations - 1));
n_angles_1 = n_angles - n_angles_2;

angles_1 = linspace(0, (n_rotations - 1) * 2 * pi, n_angles_1);
angles_2 = linspace(0, 2 * pi, n_angles_2);

r_1 = angles_1 / ((n_rotations - 1) * 2 * pi) * r_max;
r_2 = repmat(r_max, [1, n_angles_2]);

angles = [angles_1, angles_2];   r = [r_1, r_2];
x = r .* cos(angles);
y = r .* sin(angles);
z = ones([1, n_angles]);
close all
plot3(x,y,z,'r.')
hold on
plot3(0,0,0,'r.')
hold off
axis equal