function Sensor = getSonarTCP(Sensor,com_data)
% -------------------------------------------------------------------------
% This function returns a column vector that has the DaNI linear and angular velocity read by the encoders.
%
% Inputs:
%   <Robot>         (1,1)       Structure with differet parameters:
%                               - <type>    (1,1) Character with sensor type
%                               - <wb>      (1,1) Wheel base
%                               - <K>       (2,2) sigma_d constant for robot/floor interaction
%                                                 (non-deterministic and found by trial and error)
%                               - <Epose>   [x y theta]' Estrimated pose
%                               - <cov>     (3,3) covariance
%                               - <Tpose>   [x y theta]' True pose (subject to noise in wheel velocities)
% <vel_wr,vel_wl>               ROS Topic subscribers
% Outputs:
%   <vw>            (2,1)             Column vector with the linear and angular velocities of the DaNI robot
%
% -------------------------------------------------------------------------


