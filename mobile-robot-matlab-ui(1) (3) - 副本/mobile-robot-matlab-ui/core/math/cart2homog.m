function P = cart2homog(P)
% -------------------------------------------------------------------------
% CART2HOMOG    converts coordinates from cartesian to homogeneous in
% d-dimensional space.
%
% Usage
% 	P = CART2HOMOG(P);
%
% Parameters
%   P	(d, n)      cartesian point in d-dimensions.
%
% Returns
%   P   (d+1, n)    homogeneous points
%
% Implementation
%   Mohamed Mustafa, July 2010
% -------------------------------------------------------------------------

P = [P;ones(1,size(P,2))];
end
