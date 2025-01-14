function p = intersect_two_lineSegs(line_segment1, line_segment2, mode)
% -------------------------------------------------------------------------
% INTERSECT_TWO_LINESEGS    find the point of intersection of two sets of 
% line segments.
% Line segments are defined in 2D in point-direction form such that:
%   p(t) = p + s*v,   0 <= s <= 1
% Interpretation of the intersection is as follows:
%   both numbers are real   --> unique intersction,
%   both numbers are NaN    --> coincident lines,
%   otherwise               --> intersection at infinity.
%
% Usage
%   p = INTERSECT_TWO_LINESEGS(line_segment1, line_segment2, mode);
%
% Parameters
%   line_segment1   (4, n)  first line segment array.
%   line_segment2   (4, n) or (4, m)    second line segment array.
%   mode            char    'equal': find intersection of corresponding
%                                    columns in both sets.
%                           'full': find intersection of all combinations.
%
% Returns
%   p               (2, n) or (2, n, m) intersection points. 
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

% Default values
if nargin < 3
    mode = 'equal';
end
% Sanity check
[d1, n] = size(line_segment1);
[d2, m] = size(line_segment2);
if d1 ~= 4 || d2 ~= 4
    error('Line segment is not in point-direction form in 2D!')
end
% Put rays and line segments in general form
line_segment1_gf = line_pd2gf(line_segment1);
line_segment2_gf = line_pd2gf(line_segment2);
% Find intersection assuming both ray and line segments are LINES
p = intersect_two_lines(line_segment1_gf, line_segment2_gf, mode);
% Extract point-direction form parameters
p1 = line_segment1(1:2, :);     v1 = line_segment1(3:4, :);
p2 = line_segment2(1:2, :);     v2 = line_segment2(3:4, :);
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
    p1 = repmat(p1, [1, 1, m]);
    v1 = repmat(v1, [1, 1, m]);
    p2 = permute(repmat(p2, [1, 1, n]), dim);
    v2 = permute(repmat(v2, [1, 1, n]), dim);
else
    error(['Invalid flag: ' mode, '!'])
end
% normalize directions
[v1_unit, v1_len] = unit_vector(v1);
[v2_unit, v2_len] = unit_vector(v2);
% Find t and s where intersection happens
s1 = dot(p - p1, v1_unit) ./ v1_len;
s2 = dot(p - p2, v2_unit) ./ v2_len;
% Amend intersection points based on s and t
ind = repmat(s1<0 | s1>1 | s2<0 | s2>1, tmp);
p(ind) = inf;
end