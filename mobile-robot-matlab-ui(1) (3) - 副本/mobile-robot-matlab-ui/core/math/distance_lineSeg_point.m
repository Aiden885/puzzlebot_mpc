function [dist, t, p_proj] = distance_lineSeg_point(line_segment, point)
% -------------------------------------------------------------------------
% DISTANCE_LINESEG_POINT    find distance between line segment and point.
% line segment is defined in d-D in point-direction form:
% 	p(t) = p0 + t*v0,   0 <= t <= 1
%
% Usage
%   [dist, t, p_proj] = DISTANCE_LINESEG_POINT(line_segment, point);
%
% Parameters
%   line_segment    (2*d, n)	line array.
%   point           (d, n)      point array.
%
% Returns
%   dist            (1, n)      distance array.
%   t               (1, n)      parameter on line where projection of
%                               point occurs.
%   p_proj          (d, n)      projection point on line.
%
% TODO
%   Add `full` mode to support all combinations.
%   Review and refactor.
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

% Extract data
d = size(point, 1);
% Find distance between line and point
[dist, t, p_proj] = distance_line_point(line_segment, point, 'equal');
% Consider cases where `t < 0` or `t > 1`
ind1 = t < 0;
p_proj(:, ind1) = line_segment(1:d, ind1);
dist(ind1) = distance_two_points(point(:, ind1), p_proj(:, ind1));
t(ind1) = -inf;

ind2 = t > 1;
p_proj(:, ind2) = line_segment(1:d, ind2) + line_segment(d+1:end, ind2);
dist(ind2) = distance_two_points(point(:, ind2), p_proj(:, ind2));
t(ind2) = inf;
end