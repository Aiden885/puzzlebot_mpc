function [min_dist, point] = ray_cast(ray, target, varargin)
% -------------------------------------------------------------------------
% RAY_CAST    find the closest point of intersection between ray and
% target.
% Rays are defined in point-direction form:    p(s) = p0 + s*v0,   0 <= s
% Targets can be any geometric shape. Look below for supported shapes and
% dimensions (d).
%
% Usage
%   [min_dist, point] = RAY_CAST(ray, target, varargin);
%
% Parameters
%   ray         (2d, n) rays in point-direction form.
%   target      (1, 1)  Struct with the following supported fields:
%                       {'points', 'circles', 'line_segments'}
%   varargin    sequence of char and arrays with following options:
%                 'dimension'         (1, 1)  only supports 2D for now.
%                 'angle_threshold'   (1, 1)  this is for point-shape to be
%                       accepted as intersection when the angle between
%                       vector formed from ray starting point and
%                       point-shape and ray direction vector is less than
%                       this threshold.
%
% Returns
%   min_dist    (1, n)  minimum distance from ray starting point p0 to the
%                       closeset target.
%   point       (d, n)  Points of intersection at the closest target.
%
% TODO
%   Think about efficient ploting when having an array of similar type.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------

% Default value
dimension = 2;
angle_threshold = deg2rad(1);
var_ind = 1;
while var_ind <= length(varargin)
    switch varargin{var_ind}
        case 'dimension'
            % Read json-file
            dimension = varargin{var_ind + 1};
            var_ind = var_ind + 2;  % index to next variable
        case 'angle_threshold'
            angle_threshold = varargin{var_ind + 1};
            var_ind = var_ind + 2;  % index to next variable
        otherwise
            error(['Unexpected option: `' varargin{var_ind} '`!'])
    end
end
nr = size(ray, 2);          % number of rays
if isempty(target)
    min_dist = inf(1, nr);
    point = inf(dimension, nr);
    return
end
% Get primitive names
primitives = fieldnames(target);
% Consider each dimension
if dimension == 2
    p_intersection = [];    % initialize
    % Check each possible field
    for i = 1:length(primitives)
        if strcmp(primitives{i}, 'line_segments')
            p = intersect_ray_lineSeg(ray, target.line_segments, 'full');
            p_intersection = cat(3, p_intersection, p);
        elseif strcmp(primitives{i}, 'circles')
            conics = circle_to_conic(target.circles);
            [p1, p2] = intersect_ray_conic(ray, conics, 'full');
            p_intersection = cat(3, p_intersection, p1, p2);
        elseif strcmp(primitives{i}, 'points')
            [~, ~, p_proj] = distance_line_point(ray, target.points, 'full');
            np = size(target.points, 2);
            v0_ = repmat(ray(3:4, :), [1, 1, np]);
            p0_ = repmat(ray(1:2, :), [1, 1, np]);
            points_ = permute(repmat(target.points, [1, 1, nr]), [1, 3, 2]);
            v1 = points_ - p0_;
            angles = angle_two_vectors(v0_, v1);
            invalid_inds = permute(repmat(angles > angle_threshold, [1, 1, 2]), [3, 1, 2]);
            p_proj(invalid_inds) = inf;
            p_intersection = cat(3, p_intersection, p_proj);
        else
            error(['Invalid target field: ' primitives{i}])
        end
    end
    % TODO: Move all of this outside the dimesions if-statement when adding
    % support for 3D. Also review handling of higher dimensions below!
    % Distance from initial ray point to all points of intersection.
    p0_ = repmat(ray(1:dimension, :), [1, 1, size(p_intersection, 3)]);
    dist = distance_two_points(p_intersection, p0_);
    % Find min_dist to all objects
    [min_dist, k] = min(dist, [], 2);
    min_dist = min_dist';       % to match output format
    if nargout > 1
        % convert i,j,k subscripts to linear indices in p_intersection
        i = repmat(1:dimension, [1, nr]);
        jk = reshape(permute(repmat([1:nr; k'], [1, 1, dimension]), [1, 3, 2]), 2, []);
        ind = sub2ind(size(p_intersection), i, jk(1, :), jk(2, :));
        point = reshape(p_intersection(ind), dimension, []);
    end
else
    error(['Invalid dimension! ' num2str(dimension) '-D is not supported!'])
end
end