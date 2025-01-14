function line_hnf = line_gf2hnf(line_gf)
% Line in 2D function:
% General Form --> Hessian Normal Form:  n.x + d = 0,  d >= 0
% 
% Inputs:
%       <line_gf>   (3XM) Line parameters in General Form (A,B,C)
%
% Output:
%       <line_hnf>  (3XM) Line parameters in Hessian Normal Form (n,d)

% Extract general form parameters
A = line_gf(1,:);       B = line_gf(2,:);       C = line_gf(3,:);

den = sqrt(A.^2 + B.^2);    % denominator
n = [A./den;B./den];        % unit normal vector
d = C./den;                 % signed distance to origin

% Make sure that <d> is always positive
ind = d<0;
d(ind) = -d(ind);
n(:,ind) = -n(:,ind);

% Form the line
line_hnf = [n;d];
return