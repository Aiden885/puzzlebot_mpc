
% -------------------------------------------------------------------------
% TRANSFORMATION3D_TO_POSE2D    converts 3D transformation matrix to pose
% in 2D.
%
% 2D pose is a 3D vector with (x, y, theta). Basically this function
% projects 3D transfromation matrix onto xy-plane.
%
% Usage
%   pose2d = TRANSFORMATION3D_TO_POSE2D(transformation3d);
%
% Parameters
%   transformation3d    (4, 4)  Transformation matrix of robot 3D pose.
%
% Returns
%   pose2d              (3, 1)  2D pose in xy-plane.
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

