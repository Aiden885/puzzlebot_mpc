
% -------------------------------------------------------------------------
% POSE2D_TO_TRANSFORMATION3D    converts pose in 2D to 3D transfromation
% matrix.
%
% 2D pose is a 3D vector with (x, y, theta). This function creates rotation
% about the z-axis and adds 0 to the extra z dimension.
%
% Usage
%   transformation3d = POSE2D_TO_TRANSFORMATION3D(pose2d);
%
% Parameters
%   pose2d              (3, 1)  2D pose in xy-plane.
%
% Returns
%   transformation3d    (4, 4)  Transformation matrix of robot 3D pose.
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

