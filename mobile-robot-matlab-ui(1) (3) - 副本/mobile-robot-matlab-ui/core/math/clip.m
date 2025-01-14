function y = clip(x, x_min, x_max)
% -------------------------------------------------------------------------
% CLIP    limit the values in array x to be between x_min and x_max.
%
% Empty x_min or x_max result in -inf or inf limits, respectively.
%
% Usage
%   y = CLIP(x, x_min, x_max);
%
% Parameters
%   x       (m, n, ...)     input array.
%   x_min   (1, 1)          minimum value.
%   x_max   (1, 1)          maximum value.
%
% Returns
%   y       (m, n, ...)     output array.
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

% Extreme values
if isempty(x_min)
    x_min = -inf;
end
if isempty(x_max)
    x_max = inf;
end
% Output
y = max(min(x, x_max), x_min);
end
