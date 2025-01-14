
% -------------------------------------------------------------------------
% PLOT_ERROR_ELLIPSE    plot covariance error ellipse in 2D.
%
% Usage
%   h = PLOT_ERROR_ELLIPSE(cov, mu, conf, col, np);
%
% Parameters
%   cov     (2, 2)  Covariance matrix in 2D.
%   mu      (2, 1)  Mean in 2D.
%   conf    (1, 1)  Confidence percentage, e.g. 95%
%   col     (1, 1)  Color of the plot
%   np      (1, 1)  Number of points to use in plotting.
%
% Returns
%   h       (1, 1)  plot handle.
%
% Reference
%   https://www.visiondummy.com/2014/04/draw-error-ellipse-representing-covariance-matrix/
%
% Implementation
%   Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

