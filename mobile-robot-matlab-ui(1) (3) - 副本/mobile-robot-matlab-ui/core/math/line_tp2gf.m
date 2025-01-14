function line_gf = line_tp2gf(line_tp)
% -------------------------------------------------------------------------
% LINE_TP2GF    Convert line from 2-points form to general form.
% Lines are defined in 2D only. General form is: ax + by + c = 0.
%
% Usage
%   line_gf = LINE_TP2GF(line_tp);
%
% Parameters
%   line_tp     (4, n) set of 2D lines in 2-point form.
%
% Returns
%   line_gf     (3, n) set of 2D lines in geneal form. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity check
if size(line_tp, 1) ~= 4
    error('Invalid input! 2-points lines are not in 2D.')
end
% Use homogeneous coordinates to do conversion
line_gf = cross(cart2homog(line_tp(1:2, :)),...
                cart2homog(line_tp(3:4, :)));
end