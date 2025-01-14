function out = is_rotation_matrix(R)
% -------------------------------------------------------------------------
% IS_ROTATION_MATRIX    checks whether a matrix is orthonormal in SO(d).
% d > 0 is the dimension of the space.
%
% Usage
%   out = IS_ROTATION_MATRIX(R);
%
% Parameters
%   R       (d, d)      square matrix.
%
% Returns
%   out     (1, 1)      true if R is orthonomal, and false otherwise.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity check
if ~is_square_matrix(R)
    error('`R` is not a square matrix!')
end

out = all_close(R'*R, eye(size(R, 1)));
end