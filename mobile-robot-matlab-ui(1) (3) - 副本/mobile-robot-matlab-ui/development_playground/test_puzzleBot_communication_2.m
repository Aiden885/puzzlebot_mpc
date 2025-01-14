clc, clear all, close all

% Create World
W = WorldClass('fname', 'world_0002.json');

% Create Robot
R1 = RobotClass('json_fname', 'puzzle_bot_0001.json');
R1.components_tree.tostring

% Try to connect to physical robot
R1.connect('192.168.1.1')


% Plot all
figure(1)
tic
h_w = W.plot();
toc

d_t = 1e-1;     % time step

% set pose
th = deg2rad(0);
T = R1.transformation;
T(1:3, 1:3) = rotationVector2Matrix(th * [0 0 1]);
R1.set_transformation(T)

for i=1:100
    tic
    % Update motors
    R1.update_component('right motor', 'omega_setpoint', 5, 'delta_time', d_t)
    R1.update_component('left motor', 'omega_setpoint', 4.5, 'delta_time', d_t)
    
    % Update sensors
    R1.update_requests();
    R1.update_component('right encoder')
    R1.update_component('left encoder')
    %[R1.components_tree.get('right encoder').omega, R1.components_tree.get('left encoder').omega]
        
    if R1.connected
        % Do localization...
        
    else
        % Update pose
        R1.update_pose('kinematics', d_t)
    end
    
    if i>1
        delete([h_r])
    end
    h_r = R1.plot('simple');
    
    
    pause(0.01)
    toc
end
hold off

% Stop motors and disconnect
R1.disconnect()

