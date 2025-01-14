function [ax,h] = worldPlot2(map,alpha)
% -------------------------------------------------------------------------
% This function plots a grid map.
%

% Default Values
if nargin<2
    error('Too few parameters for ploting world!')
end
if strcmp(map.type,'binary')
    map_hat = 1-map.OGrid;
end
if strcmp(map.type,'log_odds')
    map_hat = 1 ./ (1 + exp(map.OGrid));
end

x_lims = [map.ll_corner(1) map.ur_corner(1) - map.res];
y_lims = [map.ll_corner(2) map.ur_corner(2) - map.res];

h = imagesc(x_lims, y_lims, map_hat, [0 1]);
h.AlphaData = alpha;
colormap('gray')
set(gca, 'YDir', 'normal');
return
