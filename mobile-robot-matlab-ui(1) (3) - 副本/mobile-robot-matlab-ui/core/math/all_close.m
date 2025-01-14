function out = all_close(X,Y,eps)
% -------------------------------------------------------------------------
% ALL_CLOSE    checks whether all elements in two arrays are numerically 
% close up to some threshold.
%
% Usage
%   out = ALL_CLOSE(X,Y,eps);
%
% Parameters
%   X       (m, n, ...)     first array.
%   Y       (m, n, ...)     second array.
%   eps     (1, 1)          threshold to accept any smaller distance.
%
% Returns
%   out     (1, 1)          true if all elements in arrays X and Y are 
%                           close by distance less than eps, and false
%                           otherwise.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default values
if nargin<3
    eps = 1e-12;
end

temp = is_close(X,Y,eps);
out = all(temp(:));
end
