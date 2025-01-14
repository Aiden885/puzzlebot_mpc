function conic = circle_to_conic(circle)
% -------------------------------------------------------------------------
% CIRCLE_TO_CONIC    convert circle to conic section general form.
% Circles are defined as center (x0, y0) and radius r.
%
% Usage
%   conic = CIRCLE_TO_CONIC(circle);
%
% Parameters
%   circle      (3, n)  circles (x0, y0, r)
%
% Returns
%   conic       (6, n)  conic general form
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

nc = size(circle, 2);
conic = [ones(1, nc);
         zeros(1, nc);
         ones(1, nc);
         -2 * circle(1, :);
         -2 * circle(2, :);
         circle(1, :).^2 + circle(2, :).^2 - circle(3, :).^2];
end