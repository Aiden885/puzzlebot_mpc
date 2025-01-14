function R = rotationVector2Matrix(w)
% -------------------------------------------------------------------------
% This function converts rotation from Lie algebra "so(3)" (Euler vector)
% to Lie group "SO(3)" (orthognal matrix with det = 1).
%
% Input:
%   <w>     (3,1)   Rotation vector in so(3). Angle-axis form.
%
% Output:
%   <R>     (3,3)   Rotation matrix in SO(3).
%
% Implementation:   Mohamed Mustafa, July 2017
%
% References:
%   - https://en.wikipedia.org/wiki/Axis?angle_representation
%   - https://www.youtube.com/watch?v=khLM8VV8LuM&list=PLTBdjV_4f-EJn6udZ34tht9EVIW7lbeo4&index=3
%   - Multiple View Geometry (pages: 583-585).
% -------------------------------------------------------------------------

% (1) Extract rotation angle and axis from <w>
theta = sqrt(sum(w.^2));                % angle is the length of <w>
if is_close(theta,0)
    w_hat = [1 0 0];                    % any nonzero unit vector is sufficient
else
    w_hat = w/theta;                    % axis of rotation as unit vector
end
w_hat_cross = vec2skewSymMat(w_hat);    % skewed symmetric matrix

% (2) Apply Rodrigues' rotation formula
R = eye(3) + sin(theta)*w_hat_cross + (1-cos(theta))*w_hat_cross^2;

% % >>>> Another Implementation <<<<<
% R = expm(theta*w_hat_cross);
return