function my_alg = drive_straight(my_alg, robot)
% This function drives the robot in a straight line for 10 seconds.
% Then, it stops.
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
end

time = toc(my_alg('tic'));      % Get time since start of session
if time < 10
    % Drive
    my_alg('right motor') = 5;
    my_alg('left motor') = 5;
else
    % Stop motors
    my_alg('right motor') = 0;
    my_alg('left motor') = 0;
    % Stop session
    my_alg('is_done') = true;
end

% display encoder readings
left_encoder_omega = my_alg('left encoder');
right_encoder_omega = my_alg('right encoder');
%['Encoders (left, right): (' num2str(left_encoder_omega) ', ' num2str(right_encoder_omega) ')  rad/sec.']

return