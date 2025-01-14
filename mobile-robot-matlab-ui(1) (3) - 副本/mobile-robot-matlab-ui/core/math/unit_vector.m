function [v_unit, v_len] = unit_vector(v)
% -------------------------------------------------------------------------
% UNIT_VECTOR    find the unit vector of input such that the output
% Euclidean length is 1.
%
% Usage
%   v_unit = UNIT_VECTOR(v);
%
% Parameters
%   v       (d, n, m, ...)	set of vectors in d-dimensions.
%
% Returns
%   v_unit  (d, n, m, ...)	set of unit vectors in d-dimensions.
%   v_len  (n, m, ...)   	length of each vector.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

v_len = sqrt(sum(v.^2, 1));
v_unit = bsxfun(@rdivide, v, v_len);
v_unit(~isfinite(v_unit)) = 0;      % for vectors of 0 euclidean length.
end