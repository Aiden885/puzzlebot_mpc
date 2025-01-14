function P = homog2cart(P)
% -------------------------------------------------------------------------
% HOMOG2CART    converts coordinates from homogeneous to cartesian in
% d-dimensional space.
%
% Usage
% 	P = HOMOG2CART(P);
%
% Parameters
%   P   (d+1, n)    homogeneous points
%
% Returns
%   P	(d, n)      cartesian point in d-dimensions.
%
% Implementation
%   Mohamed Mustafa, July 2010
% -------------------------------------------------------------------------

d = size(P,1);                  % dimension of the points
P = bsxfun(@rdivide, P(1:d-1, :), P(end, :));
end
