function depth = simulate_lidar2d(sensor, world, T_sensor_world)
% -------------------------------------------------------------------------
% SIMULATE_LIDAR2D    find array of depth values when 2D lidar interacts
% with the world.
%
% Simulation is done in 2D or 3D depending on the dimension of the world.
%
% Usage
%   depth = SIMULATE_LIDAR2D(sensor, world, T_sensor_world);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object with type `lidar-2d`
%   world           (1, 1)  WorldClass object
%   T_sensor_world  (4, 4)  Transformation from sensor to world (optional)
%                           If this parameter is not present it's replaced
%                           by sensor.transformation
%
% Returns
%   depth           (1, n)  depth of each angle CCW where n is the number
%                           of angles recorded by the sensor
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

