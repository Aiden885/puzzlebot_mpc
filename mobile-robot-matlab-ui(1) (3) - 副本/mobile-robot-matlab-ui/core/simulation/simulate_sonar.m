function depth = simulate_sonar(sensor, world, T_sensor_world)
% -------------------------------------------------------------------------
% SIMULATE_SONAR    find depth value when sonar interacts with the world.
%
% Simulation is done in 2D or 3D depending on the dimension of the world.
%
% Usage
%   depth = SIMULATE_SONAR(sensor, world, T_sensor_world);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object with type `sonar`
%   world           (1, 1)  WorldClass object
%   T_sensor_world  (4, 4)  Transformation from sensor to world (optional)
%                           If this parameter is not present it's replaced
%                           by sensor.transformation
%
% Returns
%   depth           (1, 1)  depth of the nearest object to the sensor
%                           within its conic region
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

