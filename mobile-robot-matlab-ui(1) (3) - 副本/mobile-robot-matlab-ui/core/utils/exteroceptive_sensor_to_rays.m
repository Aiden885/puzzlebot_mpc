
% -------------------------------------------------------------------------
% EXTEROCEPTIVE_SENSOR_TO_RAYS    constructs a set of rays from sensor
% origin to its field of view based on sensor's properties.
%
% Usage
%   [p, v, angle_diff] = EXTEROCEPTIVE_SENSOR_TO_RAYS(sensor, T_sensor_world, dimension);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object
%   T_sensor_world  (4, 4)  Transformation from sensor to world (optional).
%                           If this parameter is not present it's replaced
%                           by sensor.transformation
%   dimension       (1, 1)  Rays dimension (optional). Possible values: {2, 3}
%   n_angles        (1, 1)  Number of points to generate for Sonar case
%                           only.
%
% Returns
%   p               (d, 1)  Rays starting point where d = dimesnion
%   v               (d, n)  Rays direction unit vectors
%   angle_diff      (1, 1)  Difference between consecutive generated
%                           angles. This output is needed for point
%                           primitive in ray_cast function.
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

