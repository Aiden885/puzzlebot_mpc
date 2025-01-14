function angle = angle_two_vectors(V1, V2)
% -------------------------------------------------------------------------
% ANGLE_TWO_VECTORS    find angle between two vectors in radian.
%
% Usage
%   angle = ANGLE_TWO_VECTORS(V1, V2);
%
% Parameters
%   V1          (d, m, n, ...)      first vector array in d-dimensions.
%   V2          (d, m, n, ...)      second vector array in d-dimensions.
%
% Returns
%   angle      	(m, n, ...)         angle array in radian. 
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity checks
s1 = size(V1);
s2 = size(V2);
if length(s1) ~= length(s2)
    error('V1 and V2 have non-matching dimensions!')
end
if ~all(s1 == s2)
    error('V1 and V2 have non-matching dimensions!')
end

V1 = unit_vector(V1);
V2 = unit_vector(V2);
angle = squeeze(real(acos(dot(V1, V2))));
end