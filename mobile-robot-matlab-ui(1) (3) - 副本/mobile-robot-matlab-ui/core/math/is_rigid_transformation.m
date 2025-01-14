function out = is_rigid_transformation(T, desired_d)
% -------------------------------------------------------------------------
% IS_RIGIT_TRANSFORMATION    Check whether a matrix is homogeneous rigid
% transformation in SE(d).
% d > 0 is the dimension of the space.
%
% Usage
%   out = IS_RIGIT_TRANSFORMATION(T);
%
% Parameters
%   T           (d+1, d+1)  square matrix.
%   desired_d   (1, 1)      desired dimension.
%
% Returns
%   out         (1, 1)      true if T is a homogeneous rigid
%                           transformation, and false otherwise. Desired
%                           dimension is also checked.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% default values
if nargin < 2
    desired_d = -1;     % any dimension is valid
end

% Sanity check
if ~is_square_matrix(T)
    error('`R` is not a square matrix!')
end

d = size(T,1) - 1;  % dimension
cond1 = all_close(T(end, :), [zeros(1, d) 1]);  % valid last row
cond2 = is_rotation_matrix(T(1:3, 1:3));        % valid rotation matrix
cond3 = desired_d < 0 || desired_d == d;        % matching desired dim
if cond1 && cond2 && cond3
    out = true;
else
    out = false;
end
end