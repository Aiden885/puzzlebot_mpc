clc
clear all
figure(1), clf

% Create World
W = WorldClass('fname', 'world_0002.json');

% Sensor max range
max_rho = 10;
% Sensor rays
p0 = [-3, -4]';
th = deg2rad(linspace(-10, 100, 500));
v0 = [cos(th); sin(th)];        % must have length of 1 (for plotting reason)
rays = [repmat(p0, [1 size(v0, 2)]); v0];

% ray cast (speed test)
for i=1:50
    tic
    [min_dist, point] = ray_cast(rays, W.primitives, 'angle_threshold', deg2rad(1));
    toc
end
% Handle distances beyond sensor max range (inf) only for plotting
ind_inf = min_dist > max_rho;
min_dist(ind_inf) = max_rho;
% this is only for plotting
point(:, ind_inf) = repmat(p0, [1, sum(ind_inf)]) + v0(:, ind_inf) * max_rho;



% Plot all
figure(1), clf
h_w = W.plot();     % world
hold on
% rays
%{
nr = size(rays, 2);
for i = 1:nr
    x = [rays(1, i), rays(1, i) + rays(3, i) * min_dist(i)];
    y = [rays(2, i), rays(2, i) + rays(4, i) * min_dist(i)];
    plot(x, y, 'b-')
    plot(rays(1, i), rays(2, i), 'b*', 'MarkerSize', 10)
end
%}

shape.type = 'polygon';
shape.color = 'blue';
shape.vertices = [p0, point];
h_s = plot_shape(shape);
hold off

