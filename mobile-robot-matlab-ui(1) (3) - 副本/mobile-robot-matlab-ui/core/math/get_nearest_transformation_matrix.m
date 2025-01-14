function T_hat = get_nearest_transformation_matrix(T)
% -------------------------------------------------------------------------
% GET_NEAREST_TRANSFORMATION_MATRIX    estimate the nearest rigid
% transformation matrix in SE(d).
% d > 0 is the dimension of the space.
%
% Usage
%   T_hat = GET_NEAREST_TRANSFORMATION_MATRIX(T);
%
% Parameters
%   T       (d+1, d+1)	square matrix.
%
% Returns
%   T_hat   (d+1, d+1)  rigid transformation matrix in SE(d).
%
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

% Sanity check
if ~is_square_matrix(T)
    error('`T` is not a square matrix!')
end
% initialize
T_hat = eye(size(T));
% Get nearest rotation matrix
T_hat(1:3, 1:3) = get_nearest_rotation_matrix(T(1:3, 1:3));
T_hat(1:3, 4) = T(1:3, 4);
end