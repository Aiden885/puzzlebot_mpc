
% -------------------------------------------------------------------------
% PLOT_K_SIGMA_ELLIPSE    plot covariance error ellipse in 2D.
%
% Usage
%   h = PLOT_K_SIGMA_ELLIPSE(cov, mu, conf, col, np);
%
% Parameters
%   cov     (2, 2)  Covariance matrix in 2D.
%   mu      (2, 1)  Mean in 2D.
%   k       (1, 1)  Number of sigmas to include, e.g. 3
%   col     (1, 1)  Color of the plot
%   np      (1, 1)  Number of points to use in plotting.
%
% Returns
%   h       (1, 1)  plot handle.
%
% Reference
%   https://commons.wikimedia.org/wiki/File:MultivariateNormal.png
%
% Implementation
%   Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

