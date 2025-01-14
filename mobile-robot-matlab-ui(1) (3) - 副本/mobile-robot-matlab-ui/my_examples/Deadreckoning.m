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
    Sig             = obj.cov ; %Ignore for CW1
    % The time step
    dt              = toc(obj.timestamp);               % Compute Change in time
    set_property(obj, 'timestamp' , tic);               % reset stopwatch
    
    % ====================================================================
    %% ==== Coursework 1 - Task 2 - Dead Reckoning Localization ===========
    % ===== Start Here ====================================================
    % Compute the individual wheel displacements
    %% Dead Reckoning Localization - Update Step
   V=r*((w_r+w_l)/2);%
   omiga =r*((w_r-w_l)/l);%Angle speed
   theta =S(3);
   Vx =V*cos(theta);
   Vy =V*sin(theta);
   vtheta = omiga;
   delta_Sx=Vx* dt ;
   delta_Sy = Vy *dt;
  delta_Somiga = vtheta * dt;
  %calculate the estimated position of the robot
  S(1)=S(1)+ delta_Sx;
  S(2)=S(2)+ delta_Sy;
  S(3)=S(3)+ delta_Somiga;
  %Calculate the linearized model to be used in the uncertainty propagation
  H1=[1 0 -dt*V*sin(theta);
    0 1 dt*V*cos(theta);
    0  0             1];
inv_delta=1/2*r*dt*[cos(theta) cos(theta);
                    sin(theta) sin(theta);
                        2/l       -2/l];
sigma_delta=[kr*abs(w_r)    0;
                0          kl*abs(w_l)];
%calculate the covariance matrix Qk
Q=inv_delta*sigma_delta*inv_delta';
Sig=H1*Sig*H1'+Q;

           % theta update, ensure it's within [-pi, pi]
    % ===== Finish Here ===================================================
    % ===== Coursework 1 -  Task 2 - Dead Reckoning Localization ===========
    % =====================================================================
%% Save Robot pose and covariance
    set_property(obj, 'pose' , S);
    set_property(obj, 'cov' , Sig);
end

% d_sr = w_r * r * dt; % Distance right wheel has traveled in dt
% d_sl = w_l * r * dt; % Distance left wheel has traveled in dt
% 
% % Compute the average forward displacement
% d_s = (d_sr + d_sl) / 2;
% 
% % Compute the change in orientation
% d_theta = (d_sr - d_sl) / l;
% 
% % Update the robot's pose mean (x, y, theta)
% S(1) = S(1) + d_s * cos(S(3) + d_theta / 2); % x update
% S(2) = S(2) + d_s * sin(S(3) + d_theta / 2); % y update
% S(3) = wrapToPi(S(3) + d_theta);  
% 
