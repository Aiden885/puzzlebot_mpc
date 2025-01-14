clc, clear all, close all

% Create World
W = WorldClass('fname', 'world_0002.json');

% Create Robot
R1 = RobotClass('json_fname', 'puzzle_bot_0001.json');
R1.components_tree.tostring

% Try to connect to physical robot
R1.connect('192.168.1.1')

tic
for i=1:20
    % To actuators
    %R1.set_request('left motor', 'voltage_pwm', 0.5);
    R1.set_request('right motor', 'omega_setpoint', -7);
    % From sensors
    R1.update_requests();
    [~, value] = R1.get_request('right encoder');
    
    pause(0.25)
    toc
end

% Stop motors and disconnect
R1.disconnect()



