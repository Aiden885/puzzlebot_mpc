function my_alg = driveToGoal(my_alg, robot)

% Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

%% Initialise all variables and settings
if my_alg('is_first_time')
    % =========================Initialization==============================
    % =====================Initial the variables here====================== 
    
    % change if necessary to 'volt
    % age_pwm'
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     
    % Initialise sequence to store estimated robot pose at each time step
    my_alg('path_x')=[];
    my_alg('path_y')=[];
    % initialise the right and left wheel angular velocity to 0
    my_alg('right motor')   = 0;
    my_alg('left motor')    = 0;
    
    %======================Set your goal here==============================
    my_alg('goal')=[8 0]';
    % my_alg('LastTheta')=0;
    % ===================================================================== 
    
    % =================== Set localisation alg ============================
    my_alg('Integration')=0;
    my_alg('wl_pre') = 0;
    my_alg('wr_pre') = 0;
    my_alg('RemainDistance') = 0;
    my_alg('TargetV') = 0;
    my_alg('TargetOV') = 0;
    my_alg('TargetOV_all') = [];
    my_alg('TargetTheta') = 0;
    my_alg('OperationTime') = 0;
    my_alg('ErrorOmiga') = 0;

    my_alg('AvailableAngleStart')=[];
    my_alg('AvailableAngleEnd')=[];
    % =====================================================================
    % Select 1 for Deadreckoning and 2 for Particle Filter
    my_alg('localiser_type') = 2;  
    % =====================================================================
    % =====================================================================
    
    % Based on the selected robot model define if the on-board sensor is
    % sonar/LiDAR/Laser
    if strfind(robot.description,'sonar')
        my_alg('Sensor')    = 1;
    elseif strfind(robot.description,'Lidar')
        my_alg('Sensor')    = 2;
    elseif strfind(robot.description,'laser')
        my_alg('Sensor')    = 3;
    end
    
    % Dead-reckoning
    if my_alg('localiser_type') == 1
        my_alg('localizer') = LocalizationClass(...
            'method', 'wv',...  % 'wv' is dead-reckoning localisation alg
            'robot', robot,...  % insert the robot object
            'pose', [0 0 0],... % Initial robot pose (must be the same as in GUI)
            ... % Not specified for dead-reckoning
            ... % Not specified for dead-reckoning
            'ext_sensor_label', 'range');   % specify sensor 'range' -> sonar/Laser
    elseif my_alg('localiser_type') == 2
    % Particle filter
        my_alg('localizer') = LocalizationClass(...
            'method', 'pf',... % 'pf' is particle filter localisation alg
            'robot', robot,... % insert the robot object
            'pose', [0 0 0],...% Initial robot pose (must be the same as in GUI)
            'n_particles', 30,...   % specify the number of particles
            'map', WorldClass('fname','world_0006.mat'),... % Specify the map
            'ext_sensor_label', 'lidar');   % specify sensor 'lidar' -> LiDAR
    end
end

%% Apply Dead reckoning or particle filter
% create an object that contains encoder reading for both right and left
% wheels
omegas_map = containers.Map({'right wheel', 'left wheel'},...
    [my_alg('right encoder'), my_alg('left encoder')]);
% Based on the localisation alg statement apply either dead-reckoning
% localisation or particle filter localisation
if strfind(my_alg('localizer').method,'wv')
    my_alg('localizer') = Deadreckoning(my_alg('localizer'),omegas_map);
elseif strfind(my_alg('localizer').method,'pf')
    my_alg('localizer') = ParticleFilter(my_alg('localizer'),omegas_map);
end

%% Call required state variables and system constants

% Varaibles that can be used for Coursework 1 - Task 3
% Robot pose estimation [(m) (m) (rad)]'
S                   = my_alg('localizer').pose;
% Goal point (m)
goal                = my_alg('goal');
% right wheel angular velocity (rad/s)
w_r                 = omegas_map('right wheel');
% Left wheel angular velocity (rad/s)
w_l                 = omegas_map('left wheel'); 
% From the selected robot model call the distance between the two wheels(m)
l                   = 2*robot.components_tree.get('left motor').transformation(2,end);
% From the selected robot model call the radius of the wheel (m)
r                   = robot.components_tree.get('left wheel').shape.diameter/2;
% maximum angular velocity of the motor (rad/s)
w_sat               = 13.7;
% Boolen varaiable that indicates the end of simulation (true/false)
% (finish simulation/continue simulation)
my_alg('is_done')   = false;

% =====================================================================
%% ==== Coursework 1 - Task 3 - Motion Control (Part 1) ===============
% ===== Start Here ====================================================
Kd = 3.1; %Linear volocity gain
Ki = 0;
Ko = 40; %Angular volocity gain

% Target position
TargetX = goal(1,1);
TargetY = goal(2,1);

% Current position
NowX = S(1);
NowY = S(2);

% Position error
ErrorX = TargetX - NowX;
ErrorY = TargetY - NowY;

% Angle error
NowOmiga = S(3);
TargetOmiga = atan2(ErrorY,ErrorX);
my_alg('TargetTheta') = TargetOmiga;
my_alg('ErrorOmiga') = TargetOmiga - NowOmiga;
% ErrorOmiga = atan2(sin(ErrorOmiga),cos(ErrorOmiga));

% Remaining distance
my_alg('RemainDistance') = sqrt(ErrorX^2+ErrorY^2);

% Target velocity
my_alg('Integration') = my_alg('Integration')+Ki*my_alg('RemainDistance');% Integration
my_alg('TargetV') = Kd * my_alg('RemainDistance') + my_alg('Integration');% Target linear volocity
my_alg('TargetOV') = Ko * my_alg('ErrorOmiga');% Target angular volocity

% % Velocity calculation
    % TotalW = my_alg('TargetOV');
    % trans_matrix = [r/2 r/2; r/l -r/l];
    % v_matrix = [my_alg('TargetV');TotalW];
    % w = inv(trans_matrix) * v_matrix;
    % w_r = w(1,1);
    % w_l = w(2,1);
    % 
    % % Relative constrain
    % if w_r>w_sat && w_l>w_sat
    %     if w_r>w_l
    %         w_l = w_sat*(w_l/w_r);
    %         w_r = w_sat;
    %     end
    % 
    %     if w_l>w_r
    %         w_r = w_sat*(w_r/w_l);
    %         w_l = w_sat;
    %     end
    % end 
    % 
    % if w_r<-w_sat && w_l<-w_sat
    %     if w_r<w_l
    %         w_l = -w_sat*(w_l/w_r);
    %         w_r = -w_sat;
    %     end
    % 
    %     if w_l<w_r
    %         w_r = -w_sat*(w_r/w_l);
    %         w_l = -w_sat;
    %     end
    % end
    % Compute wheel speeds before saturation
% w_r_unsat = v/r + omega*l/(2*r);
% w_l_unsat = v/r - omega*l/(2*r);

% % Scale the speeds if any of them exceeds the maximum speed
% max_speed = max(abs([w_r_unsat, w_l_unsat]));
% if max_speed > w_sat
%     scale =(w_sat) / max_speed;
%     w_r = scale * w_r_unsat;
%     w_l = scale * w_l_unsat;
% else
%     w_r = w_r_unsat;
%     w_l = w_l_unsat;
% end
    
% ===== Finish Here ===================================================
% ===== Coursework 1 - Task 3 - Motion Control (Part 1) ===============
% =====================================================================
%% Aquire robot input
my_alg('right motor')   = w_r;
my_alg('left motor')    = w_l;

%% Apply obstacle avoidance
if my_alg('Sensor') == 2
    my_alg = ObstacleAvoidanceLiDAR(my_alg, robot);
elseif my_alg('Sensor') == 1 || my_alg('Sensor') == 3
    my_alg = ObstacleAvoidanceRange(my_alg, robot);
end

%% Build the map
% BinaryMapping(my_alg, robot);

%% Display results in GUI
% update the path sequence
my_alg('path_x')=[my_alg('path_x') my_alg('localizer').pose(1)];
my_alg('path_y')=[my_alg('path_y') my_alg('localizer').pose(2)];
% plot actual pose estimation in the main figure
my_alg = add_plot(my_alg, 'plot(my_alg(''localizer''))');
% plot pose estimation in the main figure
my_alg = add_plot(my_alg, 'plot(my_alg(''path_x''),my_alg(''path_y''),''k--'')');
% plot Robot covariance circle
my_alg = add_plot(my_alg, 'plot(my_alg(''obj,cov''))');

return
