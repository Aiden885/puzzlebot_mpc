function p = intersect_ray_lineSeg(ray, line_segment, mode)
% -------------------------------------------------------------------------
% INTERSECT_RAY_LINESEG    find the point of intersection of ray and line
% segment.
% Rays and line segments are defined in 2D in point-direction form.
% Rays:             p(s) = p0 + s*v0,   0 <= s
% Line segments:    p(t) = p1 + t*v1,   0 <= t <= 1
% Interpretation of the intersection is as follows:
%   both numbers are real   --> unique intersction,
%   both numbers are NaN    --> coincident lines,
%   otherwise               --> intersection at infinity.
%
% Usage
%   p = INTERSECT_RAY_LINESEG(ray, line_segments, mode);
%
% Parameters
%   ray             (4, n)  ray array.
%   line_segment    (4, n) or (4, m)    line segment array.
%   mode            char    'equal': find intersection of corresponding
%                                    columns in ray and line_segment.
%                           'full': find intersection of all combinations.
%
% Returns
%   p               (2, n) or (2, n, m) intersection points. 
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
[d2, m] = size(line_segment);
if d1 ~= 4 || d2 ~= 4
    error('ray or line segment is not in point-direction form in 2D!')
end
% Put rays and line segments in general form
ray_gf = line_pd2gf(ray);
line_segment_gf = line_pd2gf(line_segment);
% Find intersection assuming both ray and line segments are LINES
p = intersect_two_lines(ray_gf, line_segment_gf, mode);
% Extract point-direction form parameters
p0 = ray(1:2, :);               v0 = ray(3:4, :);
p1 = line_segment(1:2, :);      v1 = line_segment(3:4, :);
% Consider different modes
if strcmp(mode, 'equal')
    if n ~= m
        error('Invalid dimensions! In `equal` mode ray and line_segment must have the same number of columns.')
    end
    tmp = [2, 1];
elseif strcmp(mode, 'full')
    tmp = [2, 1, 1];
    % Since MATLAB R2014b does not support broadcasting we use reshape and
    % repmat functions.
    dim = [1 3 2];  % for permulation function below    
    p0 = repmat(p0, [1, 1, m]);
    v0 = repmat(v0, [1, 1, m]);
    p1 = permute(repmat(p1, [1, 1, n]), dim);
    v1 = permute(repmat(v1, [1, 1, n]), dim);
else
    error(['Invalid flag: ' mode, '!'])
end
% normalize directions
[v0_unit, v0_len] = unit_vector(v0);
[v1_unit, v1_len] = unit_vector(v1);
% Find t and s where intersection happens
s = dot(p - p0, v0_unit) ./ v0_len;
t = dot(p - p1, v1_unit) ./ v1_len;
% Amend intersection points based on s and t
ind = repmat(s<0 | t<0 | t>1, tmp);
p(ind) = inf;
end