function ind = is_point_inside_simple_polygon(point, polygon)
% -------------------------------------------------------------------------
% IS_POINT_INSIDE_SIMPLE_POLYGON    find a point is inside a simple
% polygon, i.e. with no self-intersection and no holes.
% 
% This function only works in 2D since polygon is defined in 2D.
%
% Usage
%   ind = IS_POINT_INSIDE_SIMPLE_POLYGON(point, polygon);
%
% Parameters
%   point       (2, n) 	point array in 2D
%   polygon     (2, m)  simple polygon define by m 2D vertices
%
% Returns
%   ind         (1, n)  true point is inside polygon
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

% Check dimensions
[d, n] = size(point);
[d2, m] = size(polygon);
if d ~= 2 || d2 ~= 2
    error('Invalid dimensions! Both point and polygon should be in 2D.')
end

% Convert polgyon to set of line segments (point-direction form)
line_segments = [polygon;       circshift(polygon, -1, 2) - polygon];
% Create rays from point
th = rand(1, n) * 2 * pi;           % random angles
direction = [cos(th);   sin(th)];   % random unit vectors
ray = [point;  direction];
% Find number of intersections per ray (for each line segment)
p = intersect_ray_lineSeg(ray, line_segments, 'full');
n_intersections_per_ray = sum(all(isfinite(p), 1), 3);
ind = logical(mod(n_intersections_per_ray, 2));
% Check whether point is coincide with polygon vertices
point_hat = repmat(point, [1, 1, m]);
polygon_hat = permute(repmat(polygon, [1, 1, n]), [1 3 2]);
ind(any(is_close(distance_two_points(point_hat, polygon_hat), 0), 2)) = true;
end