% Test matrix multiplication in higher dimensions
% https://uk.mathworks.com/matlabcentral/answers/10161-3d-matrix-multiplication
clear all, clc

% Generate data
k = 1000;
m = 50;  n = 30;  d = 40;
A = rand(m, d, k); B = rand(d, n, k);

numel(A), numel(B)

% For-loop approach
tic
out1 = zeros(size(A, 1), size(B, 2), k);
for i = 1:k
    out1(:, :, i) = A(:, :, i) * B(:, :, i);
end
toc

% Vectorized approach
% A : (a x c x Z)
% B : (c x b x Z)
tic
Ap = permute(A,[2,1,4,3]); % (c x a x 1 x Z)
Bp = permute(B,[1,4,2,3]); % (c x 1 x b x Z)
M = bsxfun(@times, Ap, Bp);% (c x a x b x Z)
M = sum(M,1);              % (1 x a x b x Z)
M = permute(M,[2,3,4,1]);  % (a x b x Z)
toc

all_close(M, out1)

