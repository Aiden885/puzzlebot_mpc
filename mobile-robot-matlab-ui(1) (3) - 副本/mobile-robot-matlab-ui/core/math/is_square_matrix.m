function out = is_square_matrix(A)
% -------------------------------------------------------------------------
% IS_SQUARE_MATRIX    checks whether an array is a square matrix.
%
% Usage
%   out = IS_SQUARE_MATRIX(A);
%
% Parameters
%   A       (m, n, ...)     multidimensional array.
%
% Returns
%   out     (1, 1)          true if matrix is square, false otherwise.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------
s = size(A);
if length(s) > 2 || isempty(A)
    out = false;
else
    out = ~logical(diff(s));
end
end