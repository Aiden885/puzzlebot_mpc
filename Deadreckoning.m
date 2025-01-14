function [obj] = Deadreckoning(obj,omegas_map)
%Deadreckoning Summary of this function goes here
%   Detailed explanation goes here

%% Call required state variables and system constants
    % Variables that can be used for Coursework 1 - Task 2
    % From the selected robot model call the error associated with
    % computing the angular velocity for both wheels
    kr              = obj.robot.wheel_error_constant; %Ignore for CW1
    kl              = kr;
    % From the selected robot model call the radius of the wheel (m)
    r               = obj.robot.components_tree.get('left wheel').shape.diameter/2;
    % From the selected robot model call the distance between the two wheels(m)
    l               = 2*obj.robot.components_tree.get('left motor').transformation(2,end);
    % The encoder reading of the right wheel angular velocity (rad/s)
    w_r             = omegas_map('right wheel');
    % The encoder reading of the left wheel angular velocity (rad/s)
    w_l             = omegas_map('left wheel');
    % Robot pose mean
    S               = obj.pose;
    % Robot pose covariance
    Sig             = obj.cov; %Ignore for CW1
    % The time step
    dt              = toc(obj.timestamp);               % Compute Change in time
    set_property(obj, 'timestamp' , tic);               % reset stopwatch
    
    % ====================================================================
    %% ==== Coursework 1 - Task 2 - Dead Reckoning Localization ===========
    % ===== Start Here ====================================================
    % Compute the linear velocities of each wheel
V_r = w_r * r;
V_l = w_l * r;

%Compute the average linear velocity and angular velocity
V = (V_r + V_l) / 2;
omega = (V_r - V_l) / l;

theta = S(3);

%Update the orientation
theta_new = S(3) + omega * dt;
%Normalize theta to be within -pi to pi
theta_new = mod(theta_new + pi, 2 * pi) - pi;

%Update the position
x_new = S(1) + V * cos(theta_new) * dt;
y_new = S(2) + V * sin(theta_new) * dt;

%Update the state vector
S = [x_new; y_new; theta_new];


H1=[1 0 -dt*V*sin(theta);
0 1 dt*V*cos(theta);
0 0 1];

%控制输入对状态变化的影响矩阵，将控制输入噪声映射到位置和角度的变化
inv_delta=1/2*r*dt*[cos(theta) cos(theta);
sin(theta) sin(theta);
2/l -2/l];

%控制输入的误差协方差矩阵
sigma_delta=[kr*abs(w_r) 0;
0 kl*abs(w_l)];
Q=inv_delta*sigma_delta*inv_delta';
Sig=H1*Sig*H1'+Q

                
    % ===== Finish Here ===================================================
    % ===== Coursework 1 -  Task 2 - Dead Reckoning Localization ===========
    % =====================================================================
%% Save Robot pose and covariance
    set_property(obj, 'pose' , S);
    set_property(obj, 'cov' , Sig);
end

