function [p1, p2] = intersect_line_conic(line_pd, conic, mode)
% -------------------------------------------------------------------------
% INTERSECT_LINE_CONIC    find the point of intersection of line and conic
% section.
% Lines are defined in 2D in point-direction form: p(t) = p0 + t*v, t in R.
% Conic section are also defined in 2D: Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
%
% Usage
%   [p1, p2] = INTERSECT_LINE_CONIC(line_pd, conic, mode);
%
% Parameters
%   line_pd     (4, n)  lines in point-direction form.
%   conic       (6, n) or (6, m)  conic sections.
%   mode        char    'equal': find intersection of corresponding columns
%                                in L and C.
%                       'full': find intersection of all combinations.
%
% Returns
%   p1          (2, n) or (2, n, m) first intersection points. 
%   p2          (2, n) or (2, n, m) second intersection points. 
%
% Reference
%   http://csharphelper.com/blog/2014/11/see-where-a-line-intersects-a-conic-section-in-c/
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin < 3
    mode = 'equal';
end
% Sanity check
[d1, n] = size(line_pd);
[d2, m] = size(conic);
if d1 ~= 4
    error('Lines are not in point-direction form in 2D!')
end
if d2 ~= 6
    error('Invalid conic sections!')
end
% Consider different modes
if strcmp(mode, 'equal')
    if n ~= m
        error('Invalid dimensions! In `equal` mode line_pd and conic must have the number of columns.')
    end
    % Extract data
    px = line_pd(1, :);     py = line_pd(2, :);
    vx = line_pd(3, :);     vy = line_pd(4, :);
    
    A = conic(1, :);        B = conic(2, :);        C = conic(3, :);
    D = conic(4, :);        E = conic(5, :);        F = conic(6, :);
    % Find the coefficients of quadratic equation in t of the line
    a_t = A .* vx.^2 + B .* vx .* vy + C .* vy.^2;
    b_t = 2 * A .* px .* vx + B .* (px .* vy + py .* vx) + 2 * C .* py .* vy + D .* vx + E .* vy;
    c_t = A .* px.^2 + B .* px .* py + C .* py.^2 + D .* px + E .* py + F;
    % Compute the determinant and location of intersection wrt lines
    detr = b_t.^2 - 4 * a_t .* c_t;
    sqrt_det = sqrt(detr);
    t1 = (-b_t + sqrt_det) ./ (2 * a_t);
    t2 = (-b_t - sqrt_det) ./ (2 * a_t);
    % Find intersection points
    p1 = line_pd(1:2, :) + bsxfun(@times, line_pd(3:4, :), t1);
    p2 = line_pd(1:2, :) + bsxfun(@times, line_pd(3:4, :), t2);
    % Consider cases of no intersection --> inf
    ind = detr < 0;
    p1(:, ind) = inf;
    p2(:, ind) = inf;
elseif strcmp(mode, 'full')
    % Since MATLAB R2014b does not support broadcasting we use reshape and
    % repmat functions.
    dim = [1 3 2];  % for permulation function below
    line_pd_ = reshape(permute(repmat(line_pd, [1, 1, m]), dim), 4, []);
    conic_ = repmat(conic, 1, n);
    % Recursive call
    [p1_, p2_] = intersect_line_conic(line_pd_, conic_, 'equal');
    p1 = permute(reshape(p1_, [2, m, n]), dim);
    p2 = permute(reshape(p2_, [2, m, n]), dim);
else
    error(['Invalid flag: ' mode, '!'])
end
end