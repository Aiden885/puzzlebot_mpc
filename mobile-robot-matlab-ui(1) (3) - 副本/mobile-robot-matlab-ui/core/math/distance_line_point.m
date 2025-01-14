function [dist, t, p_proj] = distance_line_point(line, point, mode)
% -------------------------------------------------------------------------
% DISTANCE_LINE_POINT    find distance between line and point.
% line is defined in d-D in point-direction form:
% 	p(s) = p0 + t*v0,   -inf < t < inf
%
% Usage
%   [dist, t, p_proj] = DISTANCE_LINE_POINT(line, point, mode);
%
% Parameters
%   line        (2*d, n)	line array.
%   point       (d, n) or (d, m)  point array.
%   mode        char        'equal': find intersection of corresponding
%                                    columns in line and point.
%                           'full': find intersection of all combinations.
%
% Returns
%   dist        (1, n) or (n, m) distance array.
%   t           (1, n) or (n, m) parameter on line where projection of
%                                point occurs.
%   p_proj      (d, n) or (d, n, m) projection point on line.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin < 3
    mode = 'equal';
end
% Sanity check
[d2, n] = size(line);
[d, m] = size(point);
if ~is_close(d, d2 / 2)
    error(['point and line have non-matching dimensions! (' num2str(d) ', ' num2str(d2/2) ')'])
end
% Extract point-direction form parameters
p0 = line(1:d, :);               v0 = line(d+1:end, :);
% Consider different modes
if strcmp(mode, 'equal')
    if n ~= m
        error('Invalid dimensions! In `equal` mode point and line must have the same number of columns.')
    end
elseif strcmp(mode, 'full')
    % Since MATLAB R2014b does not support broadcasting we use reshape and
    % repmat functions.
    dim = [1 3 2];  % for permulation function below
    p0 = repmat(p0, [1, 1, m]);
    v0 = repmat(v0, [1, 1, m]);
    point = permute(repmat(point, [1, 1, n]), dim);
else
    error(['Invalid flag: ' mode, '!'])
end
d_p = point - p0;
tmp1 = dot(d_p, v0);
tmp2 = sum(v0.^2);
tmp3 = tmp1.^2 ./ tmp2;
dist = squeeze(sqrt(dot(d_p, d_p) - tmp3));
dist(isnan(dist)) = 0;
if nargout > 1
    t = squeeze(tmp1 ./ tmp2);
    if nargout > 2
        if strcmp(mode, 'equal')
            t_ = repmat(t, [d, 1]);
        elseif strcmp(mode, 'full')
            t_ = permute(repmat(t, [1, 1, d]), [3 1 2]);
        end
        p_proj = p0 + v0 .* t_;
    end
end
end