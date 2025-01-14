function angle = simulate_servo_motor(sensor, angle)
% -------------------------------------------------------------------------
% SIMULATE_SERVO_MOTOR    find the new angle of a servo motor based on
% input angle signal.
%
% Usage
%   angle = SIMULATE_SERVO_MOTOR(sensor, angle);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object with type `lidar-2d`
%   angle           (1, 1)  Input angle in radian.
%
% Returns
%   angle           (1, 1)  Output angle.
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

