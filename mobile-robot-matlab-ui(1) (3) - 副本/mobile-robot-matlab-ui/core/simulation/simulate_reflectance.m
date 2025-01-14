function [E_normalized, unit_readings] = simulate_reflectance(sensor,...
    world, T_sensor_world)
% -------------------------------------------------------------------------
% SIMULATE_REFLECTANCE    find expected value of array of reflectance
% sensors in its local frame when the sensors interacts with the world.
%
% Simulation assumes objects in the world to be 2D with no height, and it
% only works with polygon shapes.
%
% Usage
%   [E_normalized, unit_readings] = ...
%       SIMULATE_REFLECTANCE(sensor, world, T_sensor_world);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object with type `reflectance`
%   world           (1, 1)  WorldClass object
%   T_sensor_world  (4, 4)  Transformation from sensor to world (optional)
%                           If this parameter is not present it's replaced
%                           by sensor.transformation
%
% Returns
%   E_normalized    (1, 1)  Expected value of the reflectance readings with
%                           respect to their position in the sensor local
%                           frame. This expectation is normalized such
%                           that range is [-1, 1].
%   unit_readings	(1, n)  Individual unit readings with n = num_units.
%                           The range is either [0, 1], or if available in
%                           the JSON-file [min_value, max_value].
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

