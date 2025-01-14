function M = vec2skewSymMat(v)
% -------------------------------------------------------------------------
% Convert a 3D vector to skew symmetric matrix that represents the cross
% product.
%
% Inputs:
%   <v>         (3,n)       3D vector.
%
% Outputs:
%   <M>         (3,3,n)     Skew symmetric matrix (rank 2).
%
% Implementation:   Mohamed Mustafa, July 2017
%
% References:
%   - https://en.wikipedia.org/wiki/Cross_product#Conversion_to_matrix_multiplication
%   - Multiple View Geometry
% -------------------------------------------------------------------------

[d, n] = size(v);
% Take transpose if necessary
if d ~= 3 && n == 3
    v = v';
    n = d;
end
% Generate output
M = zeros(3, 3, n);     % initialize output
M(1, 2, :) = -v(3, :);      M(2, 1, :) = v(3, :);
M(1, 3, :) = v(2, :);       M(3, 1, :) = -v(2, :);
M(2, 3, :) = -v(1, :);      M(3, 2, :) = v(1, :);
return