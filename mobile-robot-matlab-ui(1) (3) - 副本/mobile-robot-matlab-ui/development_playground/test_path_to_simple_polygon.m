% path to simple polygon test 
% Self-intersecting polygon is not allowed.
% To simulated self-intersection for line following, create a second
% polygon that intersect the first. This way we can use
% point_inside_simple_polygon safely.
% In the GUI create new polygon if self-intersection is detected.

clear all, clc

path = [1 1 2 3 4; -1 1 1 2 0 ];
path = rand(2, 4)
width = 0.2;    % width of the line (polygon)

polygon = path_to_simple_polygon(path, width);

% plot path
figure(1), clf
plot(path(1, :), path(2, :), 'r-')
hold on
% plot(p_1(1, :), p_1(2, :), 'b--')
% plot(p_2(1, :), p_2(2, :), 'b--')

shape.type = 'polygon';
shape.color = 'green';
shape.vertices = polygon;
plot_shape(shape);

hold off
axis equal

