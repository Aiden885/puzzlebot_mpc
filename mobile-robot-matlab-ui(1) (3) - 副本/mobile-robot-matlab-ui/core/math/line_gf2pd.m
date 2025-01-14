function line_pd = line_gf2pd(line_gf)
% -------------------------------------------------------------------------
% LINE_GF2PD    Convert line from general form to point-direction form.
% Lines are defined in 2D only. 
% General form: ax + by + c = 0.
% Point-direction form:  p(t) = p0 + t*v.
%   p0 is the point of shortest distance between line and origin,
%   v is unit vector.
%
% Usage
%   line_pd = LINE_GF2PD(line_gf);
%
% Parameters
%   line_gf     (3, n) set of 2D lines in general form.
%
% Returns
%   line_pd     (4, n) set of 2D lines in point-direction form. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity check
if size(line_gf, 1) ~= 3
    error('Invalid input! General form lines are not in 2D.')
end

line_hnf = line_gf2hnf(line_gf);    % hessian normal form
p0 = -line_hnf(1:2, :) .* repmat(line_hnf(3, :), 2, 1);
R90cw = [0 1;-1 0];     % -90 degrees rotation matrix
v = R90cw * line_hnf(1:2, :);
line_pd = [p0; v];      % unit vectors
end