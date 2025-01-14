function D = distance_two_points(P1, P2)
% -------------------------------------------------------------------------
% DISTANCE_TWO_POINTS    find Euclidean distance between two sets of
% points.
%
% Usage
%   D = DISTANCE_TWO_POINTS(P1, P2);
%
% Parameters
%   P1          (d, m, n, ...)      first point array in d-dimensions.
%   P2          (d, m, n, ...)      second point array in d-dimensions.
%
% Returns
%   D         	(m, n, ...)         distance array. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity checks
s1 = size(P1);
s2 = size(P2);
if length(s1) ~= length(s2)
    error('P1 and P2 have non-matching dimensions!')
end
if ~all(s1 == s2)
    error('P1 and P2 have non-matching dimensions!')
end
D = squeeze(sqrt(sum((P1 - P2).^2, 1)));
end