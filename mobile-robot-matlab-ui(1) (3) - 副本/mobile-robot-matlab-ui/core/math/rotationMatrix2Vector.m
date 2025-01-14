function w = rotationMatrix2Vector(R)
% -------------------------------------------------------------------------
% This function converts rotation from Lie group "SO(3)" to Lie algebra
% "so(3)".
%
% Input:
%   <R>     (3,3)   Rotation matrix in SO(3).
%
% Output:
%   <w>     (3,1)   Rotation vector in so(3). Angle-axis form.
%
% Implementation:   Mohamed Mustafa, July 2017
%
% References:
%   - https://en.wikipedia.org/wiki/Axis?angle_representation
%   - https://www.youtube.com/watch?v=khLM8VV8LuM&list=PLTBdjV_4f-EJn6udZ34tht9EVIW7lbeo4&index=3
%   - http://www2.ece.ohio-state.edu/~zhang/RoboticsClass/docs/LN3_RotationalMotion.pdf
% -------------------------------------------------------------------------

% Sanity check
if ~is_rotation_matrix(R)
    R = get_nearest_rotation_matrix(R);
end
% Make sure cos(theta) is EXACTLY in [-1, 1] to avoid any numerical issues
cos_theta = clip((trace(R) - 1) / 2, -1, 1);
% Consider different cases
if is_close(cos_theta, 1)
    % theta = 0
    w = [0 0 0]';
elseif is_close(cos_theta, -1)
    theta = pi;
    tmp = R(:, 3);
    tmp(3) = tmp(3) + 1;
    w_hat = tmp / sqrt(2 * tmp(3));     % unit axis of rotation
    w = theta * w_hat;
else
    % Compute theta (angle of rotation)
    theta = acos(cos_theta);
    w_hat = skewSymMat2vec((R - R') / (2 * sin(theta)));
    w = theta * w_hat;
end

% % >>>> Another Implementation <<<<<
% w = real(skewSymMat2vec(logm(R)));      % real is added becuase it returned complex numbers with zero imaginary
return