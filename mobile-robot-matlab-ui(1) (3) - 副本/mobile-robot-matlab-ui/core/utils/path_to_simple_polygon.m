
% -------------------------------------------------------------------------
% PATH_TO_SIMPLE_POLYGON    generates a simple polygon around path with 
% some input width.
%
% This function works only in 2D.
%
% If the path is self-intersecting or path is close enough to 
% self-intersection then resulting polygon is not guaranteed to be simple,
% i.e. it may be self-intersecting. Some of these cases are detected in
% this function but not all of them.
%
% Usage
%   polygon = PATH_TO_SIMPLE_POLYGON(path, width);
%
% Parameters
%   path        (2, n)      Sequence of 2D points representing the path.
%   width       (1, 1)      Width of polygon perpendicular to the path.
%
% Returns
%   polygon     (2, 2n)     Vertices of polygon representing inflated path.
%
% TODO
%   Needs revision, testing and refactoring
%
% Implementation
%   Mohamed Mustafa, September 2020
% -------------------------------------------------------------------------

