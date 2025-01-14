
% -------------------------------------------------------------------------
% PLOT_SHAPE    plot a shape on figure either in 2D or 3D.
%
% Usage
%   h = PLOT_SHAPE(shape, varargin);
%
% Parameters
%   shape       (1, 1)  Struct with the `type` mandatory field.
%                       `color` field is optional for all types.
%                       Optional fields depend on the shape. Look below for
%                       more detail.
%   varargin    sequence of char and arrays with following options:
%                       'transformation' --> (4, 4) rigid transformation,
%                       'alpha' --> color transparency parameter.
%
% Returns
%   h           (1, 1)  plot handle.
%
% TODO
%   Think about efficient ploting when having an array of similar type.
%
% Implementation
%   Mohamed Mustafa, July 2020
% -------------------------------------------------------------------------
