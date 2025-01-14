function [my_alg] = ObstacleAvoidanceRange(my_alg, robot,distance)
%% Initialise all variables and settings
    if my_alg('is_first_time') 

    % =========================================================================
    %% ======== Coursework 2 - Task 3 - Obstacle Avoidance ====================
    % ========= Initialise variables Here =====================================


%% Call required state variables and system constants

        my_alg('ExtraW')        = 0;
        % Set the initial rate of change of the servo motor angle
        my_alg('dTh')           = 0.01;
        % Set the initial angle of the servo motor to 0% (PWM signal -1 - 1
        % representing -60 - 60 degree)
        my_alg('servo motor')   = 0;
        % Define Maximum positive and negative bearings of servo
        my_alg('max_b')         = 0.9;
        % minimum recorded range at bearing
        my_alg('min_z')         = [inf;0];
        % direction set point
        my_alg('Th_s')          = 0;
        % falg to indicate the application of obstacle avoidance
        my_alg('F')             = false;

    % ========= Finish initialisation Here ====================================
    % ========= Coursework 2 - Task 3 - Obstacle Avoidance ====================
    % =========================================================================
    end
    

    %% Call required state variables and system constants
    % Varaibles that can be used for Coursework 1 - Task 5
    % Robot pose estimation [(m) (m) (rad)]'
    S                   = my_alg('localizer').pose;
    % From the selected robot model call the distance between the two wheels(m)
    L                   = 2*robot.components_tree.get('left motor').transformation(2,end);
    % From the selected robot model call the radius of the wheel (m)
    r                   = robot.components_tree.get('left wheel').shape.diameter/2;
    % maximum angular velocity of the motor (rad/s)
    w_sat               = 12.7;
    % right wheel angular velocity (rad/s)
    w_r                 = my_alg('right motor');
    % Left wheel angular velocity (rad/s)
    w_l                 = my_alg('left motor');
    % falg to indicate the application of obstacle avoidance
    F                   = my_alg('F');
    % Range of servo motor
    Sev_r               = [-pi/3;pi/3];
    if my_alg('Sensor') == 1
    % Reading form sonar (m)
        range_dist      = my_alg('sonar');
    elseif my_alg('Sensor') == 3
    % Reading form laser (m)
        range_dist      = my_alg('laser');
    end
    % bearing of the sonar (the signal is PWM -1 - 1, representing -60
    % - 60 degrees)
    servo_motor         = my_alg('servo motor');
    % Rate of change of the servo motor angle
    dTh                 = my_alg('dTh');
    % Maximum positive and negative bearings of servo
    max_b               = my_alg('max_b');
    % minimum recorded range at bearing
    min_z               = my_alg('min_z');
    % direction set point
    Th_s                = my_alg('Th_s');

    % =========================================================================
    %% ======== Coursework 2 - Task 3 - Obstacle Avoidance - laser/sonar ======
    % ========= Start Here ====================================================
%  v = my_alg('v');
%     l = my_alg('l');
%     r = my_alg('r');
%     distance = my_alg('distance');
% alpha = my_alg('alpha');
% 
% 
%    RotateGain = 300; % Rotation gain
% TargetGap = 1; % Target gap between the obstacle
% ExtraOmega = 0; % Extra omega
% 
%     if F == false && range_dist < TargetGap
%         F = true;
%         my_alg('OperationTime') = 0;
%         ExtraOmega = 150;
%     end
% 
%     if F == true && my_alg('OperationTime') >= 10
%         servo_motor = -1;
%         这是一个基于距离差的动态角速度调整。如果机器人离障碍物越近，这个值会变得越大，
%         导致更快的转向速度以避开障碍。
%         ExtraOmega = -RotateGain * (range_dist - TargetGap);
%         if range_dist > TargetGap + 1
%             F = false;
%             servo_motor = 0;
%             ExtraOmega = 0;
%         end
% 
%         if abs(alpha) < 0.1  
%             F = false;
%             servo_motor = 0;
%         end
%     end
% 
% 
% Velocity calculation
% omega = my_alg('omega');
% omega = omega + ExtraOmega;
% 
% w_r = v/r + omega*l/(2*r);
% w_l = v/r - omega*l/(2*r);
% 
% 
% Compute the maximum absolute value among wheel speeds
% max_speed = max(abs([w_r, w_l]));
% 
% If maximum speed exceeds the saturation limit w_sat, adjust w_r and w_l to not exceed w_sat
% if max_speed > w_sat
%     scaling_factor = w_sat / max_speed;
%     w_r = w_r * scaling_factor;
%     w_l = w_l * scaling_factor;
% end
% my_alg('OperationTime') = my_alg('OperationTime')+1;
% 
% If distance is below a threshold, stop the robot and end the simulation
% if distance < 0.01
%     w_r = 0;
%     w_l = 0;
%     my_alg('is_done') = true;

% end

new_x = S(1);
new_y = S(2);
try
    % 尝试获取 my_alg('current_k')
    k0 = my_alg('current_k');
catch
    % 如果出现错误，设置 k0 为一个固定的默认值
    k0 = 0;  % 这里的2默认值0替换为你想要设置的实际数值
end

k = new_y / new_x;

% 使用 num2str 将所有数值转换为字符串
disp(['w_r  ', num2str(w_r), '  w_l   ', num2str(w_l), ...
    '  range_dist  ', num2str(range_dist), '  F  ', num2str(F) ...
    ' servo_motor ',num2str(servo_motor)]);
% 
 if F == 0 && range_dist < 0.8
    F = 1;
    servo_motor = 1;
    w_l = w_sat / 1.8;
    w_r = w_sat / 4;
elseif F == 1
    if range_dist > 0.8
        w_l = w_sat / 4;
        w_r = w_sat / 1.9;
    elseif range_dist >= 0.7
        w_l = w_sat / 1.2;
        w_r = w_sat / 1.2;
    elseif range_dist >= 0.4
        w_l = w_sat ;
        w_r = w_sat / 3;
    else
        w_l = w_sat;
        w_r = w_sat / 5;
    end
 end
if F == 1 && abs(k - k0) < 0.1 %|| F ==1 && range_dist > 2
    F = 0;
    servo_motor = 0;
end
x1 = 0;
y1 = 0;

% % 在适当的初始化部分定义并初始化变量
% if ~exist('firstObstacle', 'var')
%     firstObstacle = true;  % 标志第一次进入避障
%     timer = tic;           % 初始化计时器
% end
% 
% if F == 0 && range_dist < 0.6
%     % 如果是第一次避障或超过3秒，则进入避障模式
%     if firstObstacle || toc(timer) > 3
%         x1 = new_x;
%         y1 = new_y;
%         F = 1;
%         servo_motor = 1;
%         w_l = w_sat / 1;
%         w_r = w_sat / 4;
%         timer = tic;       % 重置计时器
%         firstObstacle = false;  % 更新标志，表示已不是第一次避障
%     end
% elseif F == 1
%     if range_dist > 0.7
%         w_l = w_sat / 5;
%         w_r = w_sat / 2;
%     elseif range_dist >= 0.5
%         w_l = w_sat / 1.2;
%         w_r = w_sat / 1.2;
%     elseif range_dist >= 0.45
%         w_l = w_sat;
%         w_r = w_sat / 4;
%     else
%         w_l = w_sat;
%         w_r = w_sat / 6;
%     end
% 
%     if F == 1 && abs(k - k0) < 0.1 && sqrt((x1-new_x)^2 + (y1-new_y)^2) > 1 %|| F ==1 && range_dist > 2
%         F = 0;
%         servo_motor = 0;
%         timer = tic;  % 重置计时器，记录退出避障的时刻
%     end
% end






  


    % ========= Finish Here ===================================================
    % ========= Coursework 2 - Task 3 - Obstacle Avoidance - laser/sonar ======
    % =========================================================================

%% update robot input
    % Acquire unpdated variables used For range sensors
    my_alg('dTh')           = dTh;
    my_alg('servo motor')   = servo_motor;
    % Acquire wheels velocity
    my_alg('right motor')   = w_r;
    my_alg('left motor')    = w_l;
    % Save other data
    my_alg('min_z')         = min_z;
    my_alg('F')             = F;
    my_alg('Th_s')          = Th_s;


end

