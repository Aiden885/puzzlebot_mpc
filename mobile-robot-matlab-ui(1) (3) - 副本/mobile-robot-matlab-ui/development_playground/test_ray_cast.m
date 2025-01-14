clc
clear all
figure(1), clf

% Create World
W = WorldClass('fname', 'world_0002.json');

% Shapes
rays_pd = [-5 3.25 2 0; 3.5 -4 0 2; -5 4 3 -1]';
%rays_pd = [-5 3 2 0; 3.5 -4 0 2]';
line_segments_pd = W.primitives.line_segments;
conics = circle_to_conic(W.primitives.circles);
points = W.primitives.points;

% number of each shape
nr = size(rays_pd, 2);
nls = size(line_segments_pd, 2);
nc = size(conics, 2);
np = size(points, 2);

% extract information
p0 = rays_pd(1:2, :);       v0 = rays_pd(3:4, :);

% intersection ray and line segments
p = intersect_ray_lineSeg(rays_pd, line_segments_pd, 'full');
% interection ray and circles
[pc1, pc2] = intersect_ray_conic(rays_pd, conics, 'full');
% intersection ray and points
[~, ~, p_proj] = distance_line_point(rays_pd, points, 'full');
% Filter valid p_proj based on angle threshold
threshold_angle = deg2rad(5);       % input parameter
v0_ = repmat(v0, [1, 1, np]);
p0_ = repmat(p0, [1, 1, np]);
points_ = permute(repmat(points, [1, 1, nr]), [1, 3, 2]);
v1 = points_ - p0_;
angles = angle_two_vectors(v0_, v1);
invalid_inds = permute(repmat(angles > threshold_angle, [1, 1, 2]), [3, 1, 2]);
p_proj_ = p_proj;       % keep old only for plotting
p_proj_(invalid_inds) = inf;

% distance from initial point of rays to  all points of intersection
p_intersection_all = cat(3, p, pc1, pc2, p_proj_);
p0_ = repmat(p0, [1, 1, size(p_intersection_all, 3)]);
dist = distance_two_points(p_intersection_all, p0_);

% Find min dist to all objects
min_dist = min(dist, [], 2);

% Plot all
figure(1), clf
h_w = W.plot();     % world
hold on
% rays
for i = 1:nr
    v_unit = unit_vector(rays_pd(3:4, i));
    if isfinite(min_dist(i))
        x = [rays_pd(1, i), rays_pd(1, i) + v_unit(1) * min_dist(i)];
        y = [rays_pd(2, i), rays_pd(2, i) + v_unit(2) * min_dist(i)];
    else
        x = [rays_pd(1, i), rays_pd(1, i) + rays_pd(3, i)];
        y = [rays_pd(2, i), rays_pd(2, i) + rays_pd(4, i)];
    end
    plot(x, y, 'b-')
    plot(rays_pd(1, i), rays_pd(2, i), 'b*', 'MarkerSize', 10)
    
    % ray extension (dotted lines)
    x = [rays_pd(1, i), rays_pd(1, i) + v_unit(1) * 20];
    y = [rays_pd(2, i), rays_pd(2, i) + v_unit(2) * 20];
    plot(x, y, 'b--')
end
% intersection points
p_ = reshape(p_intersection_all, 2, []);
np = size(p_, 2);
for i = 1:np
    if isfinite(p_(1, i))
        plot(p_(1, i), p_(2, i), 'r.', 'MarkerSize', 20)
    end
end

% projection points
plot(p_proj(1, :), p_proj(2, :), 'go', 'MarkerSize', 10)
