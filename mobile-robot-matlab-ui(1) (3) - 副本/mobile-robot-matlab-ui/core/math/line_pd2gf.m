function line_gf = line_pd2gf(line_pd)
% -------------------------------------------------------------------------
% LINE_PD2GF    Convert line from point-direction form to general form.
% Lines are defined in 2D only. 
% General form: ax + by + c = 0.
% Point-direction form:  p(t) = p0 + t*v.
%
% Usage
%   line_gf = LINE_GF2PD(line_pd);
%
% Parameters
%   line_pd     (4, n) set of 2D lines in point-direction form. 
%
% Returns
%   line_gf     (3, n) set of 2D lines in general form.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity check
if size(line_pd, 1) ~= 4
    error('Invalid input! Lines are not in point-direction form in 2D.')
end

p0 = line_pd(1:2, :);
p1 = p0 + line_pd(3:4, :);
line_gf = line_tp2gf([p0; p1]);
end