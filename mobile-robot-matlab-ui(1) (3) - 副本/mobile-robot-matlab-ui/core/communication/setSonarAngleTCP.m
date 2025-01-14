
% -------------------------------------------------------------------------
% This function returns a column vector that has the DaNI linear and angular velocity read by the encoders.
%
% Inputs:
%
%   <vw>         (2,1)          Vector with the linear and agular velocities fo the robot.
%  <des_V>                      ROS publisher to be used for the linear speed
%  <des_W>                      ROS Publishers to be used for the angular speed
%  <V,W>                        Definition of the type of messages to be sent by ROS for the
%                                linear velocity, angular velocity, scanner and position of the robot
%
% Outputs:
%   <done>    (1,1)             Boolean flag that is set to 1 when the velocities are sent to the robot, 0 otherwise
%
% -------------------------------------------------------------------------



