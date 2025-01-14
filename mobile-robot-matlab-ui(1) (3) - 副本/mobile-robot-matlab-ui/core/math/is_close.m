function out = is_close(X,Y,eps)
% -------------------------------------------------------------------------
% IS_CLOSE    checks whether two arrays are numerically close element-wise
% up to some threshold.
%
% Usage
%   out = IS_CLOSE(X,Y,eps);
%
% Parameters
%   X       (m, n, ...)     first array.
%   Y       (m, n, ...)     second array.
%   eps     (1, 1)          threshold to accept any smaller distance.
%
% Returns
%   out     (m, n, ...)     true if arrays X and Y are close by distance
%                           less than eps, and false otherwise.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin<3
    eps = 1e-12;
end

temp = X - Y;
out = abs(temp) < eps;
out(isnan(temp)) = 1;     % Exception for infinity equality (inf-inf)
end
