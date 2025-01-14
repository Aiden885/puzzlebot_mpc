clc
clear all

% build polygon
polygon = [1 2 2 1.5 1; 1 1 2 2.5 2];

%point = [0 0 1.5 1 1.5 0; 0 1 1.5 1 2 2.5];     % controlled test points

% generate random points
np = 1e2;
point = 0.5 + rand(2, np) * 2;

% get indices of inside points
ind = is_point_inside_simple_polygon(point, polygon);

% plot inside as green and outside as red
figure(1), clf
% polygon (green)
tmp = [polygon, polygon(:, 1)];
plot(tmp(1, :), tmp(2, :), 'g-')
axis equal
hold on
% Inside points (green)
in_points = point(:, ind);
plot(in_points(1, :), in_points(2, :), 'go')
% outside points (red)
out_points = point(:, ~ind);
plot(out_points(1, :), out_points(2, :), 'ro')
hold off

