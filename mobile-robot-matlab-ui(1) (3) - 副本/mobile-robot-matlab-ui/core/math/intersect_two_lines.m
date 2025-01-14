function p = intersect_two_lines(line_gf_1, line_gf_2, mode)
% -------------------------------------------------------------------------
% INTERSECT_TWO_LINES    find the point of intersection of two lines.
% Lines are defined in 2D in the general form: ax + by + c = 0.
% For lines in higher dimensions project lines on the 2D plane with normal
% along the shortest distance vector between the lines. This approach
% should be done outside this function.
% Homogeneous coordinates are used to find the intersection. Interpretation
% of the intersection is as follows:
%   both numbers are real   --> unique intersction,
%   both numbers are NaN    --> coincident lines,
%   otherwise               --> intersection at infinity.
%
% Usage
%   p = INTERSECT_TWO_LINES(line_gf_1, line_gf_2, mode);
%
% Parameters
%   line_gf_1   (3, n)  first set of lines.
%   line_gf_2   (3, n) or (3, m)  second set of lines.
%   mode        char    'equal': find intersection of corresponding columns
%                                in line_gf_1 and line_gf_2.
%                       'full': find intersection of all combinations.
%
% Returns
%   p           (2, n) or (2, n, m) intersection points. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin < 3
    mode = 'equal';
end
% Sanity check
[d1, n] = size(line_gf_1);
[d2, m] = size(line_gf_2);
if d1 ~= 3 || d2 ~= 3
    error('Lines are not in general form in 2D!')
end
% Consider different modes
if strcmp(mode, 'equal')
    if n ~= m
        error('Invalid dimensions! In `equal` mode line_gf_1 and line_gf_2 must have the same dimensions.')
    end
    p = homog2cart(cross(line_gf_1, line_gf_2));
elseif strcmp(mode, 'full')
    % Since MATLAB R2014b does not support broadcasting we use reshape and
    % repmat functions.
    dim = [1 3 2];  % for permulation function below
    L1_ = reshape(permute(repmat(line_gf_1, [1, 1, m]), dim), 3, []);
    L2_ = repmat(line_gf_2, 1, n);
    p_ = homog2cart(cross(L1_, L2_));
    p = permute(reshape(p_, [2, m, n]), dim);
else
    error(['Invalid flag: ' mode, '!'])
end
end