function [p1, p2] = intersect_ray_conic(ray, conic, mode)
% -------------------------------------------------------------------------
% INTERSECT_RAY_CONIC    find the point of intersection of ray and conic
% section.
% Rays and line segments are defined in 2D in point-direction form.
% Rays:             p(s) = p0 + s*v0,   0 <= s
% Conic section are also defined in 2D: Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
%
% Usage
%   [p1, p2] = INTERSECT_RAY_CONIC(line_pd, conic, mode);
%
% Parameters
%   ray         (4, n)  rays in point-direction form.
%   conic       (6, n) or (6, m)  conic sections.
%   mode        char    'equal': find intersection of corresponding columns
%                                in ray and conic.
%                       'full': find intersection of all combinations.
%
% Returns
%   p1          (2, n) or (2, n, m) first intersection points. 
%   p2          (2, n) or (2, n, m) second intersection points. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin < 3
    mode = 'equal';
end
% Sanity check
[d1, n] = size(ray);
[d2, m] = size(conic);
if d1 ~= 4
    error('ray is not in point-direction form in 2D!')
end
if d2 ~= 6
    error('Invalid conic section!')
end
% Find intersection with lines
[p1, p2] = intersect_line_conic(ray, conic, mode);
% Extract point-direction form parameters
p0 = ray(1:2, :);               v0 = ray(3:4, :);
% Consider different modes
if strcmp(mode, 'equal')
    if n ~= m
        error('Invalid dimensions! In `equal` mode line_pd and conic must have the number of columns.')
    end
    tmp = [2, 1];
elseif strcmp(mode, 'full')
    tmp = [2, 1, 1];
    % Since MATLAB R2014b does not support broadcasting we use repmat.
    p0 = repmat(p0, [1, 1, m]);
    v0 = repmat(v0, [1, 1, m]);
else
    error(['Invalid flag: ' mode, '!'])
end
% normalize directions
[v0_unit, v0_len] = unit_vector(v0);
% Find t and s where intersection happens
s1 = dot(p1 - p0, v0_unit) ./ v0_len;
s2 = dot(p2 - p0, v0_unit) ./ v0_len;
% Amend intersection points based on s1 and s2
ind1 = repmat(s1<0 | ~isfinite(s1), tmp);
p1(ind1) = inf;
ind2 = repmat(s2<0 | ~isfinite(s2), tmp);
p2(ind2) = inf;
end