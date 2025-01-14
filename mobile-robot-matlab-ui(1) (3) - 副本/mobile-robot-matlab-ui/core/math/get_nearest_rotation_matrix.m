function R_hat = get_nearest_rotation_matrix(R)
% -------------------------------------------------------------------------
% GET_NEAREST_ROTATION_MATRIX    estimate the nearest orthonormal matrix in
% SO(d).
% d > 0 is the dimension of the space.
%
% Usage
%   R_hat = GET_NEAREST_ROTATION_MATRIX(R);
%
% Parameters
%   R       (d, d)      square matrix.
%
% Returns
%   R_hat   (d, d)      orthonomal matrix in SO(d).
%
% Reference
%   http://graphics.stanford.edu/~smr/ICP/comparison/eggert_comparison_mva97.pdf
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Sanity check
if ~is_square_matrix(R)
    error('`R` is not a square matrix!')
end

[U, ~, V] = svd(R);
s_hat = ones(1, size(R, 1));
s_hat(end) = det(U*V');
R_hat = U * diag(s_hat) * V';
end