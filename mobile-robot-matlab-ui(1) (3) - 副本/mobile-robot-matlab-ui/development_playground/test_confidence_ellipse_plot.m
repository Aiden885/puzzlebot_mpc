% Test confidence ellipse plot
% https://carstenschelp.github.io/2018/09/14/Plot_Confidence_Ellipse_001.html
% https://matplotlib.org/devdocs/gallery/statistics/confidence_ellipse.html
% https://www.visiondummy.com/2014/04/draw-error-ellipse-representing-covariance-matrix/
% https://commons.wikimedia.org/wiki/File:MultivariateNormal.png
clc, clear all

mu = [0 0];
cov = [1 3/5;3/5 2];
np = 50;

figure(1), clf
tic
plot_error_ellipse(cov, mu, 0.9, 'r', np);
hold on
plot_error_ellipse(cov, mu, 0.95, 'y', np);
plot_error_ellipse(cov, mu, 0.99, 'g', np);
toc
axis equal

figure(2), clf
tic
plot_k_sigma_ellipse(cov, mu, 1, 'r', np);
hold on
plot_k_sigma_ellipse(cov, mu, 2, 'y', np);
plot_k_sigma_ellipse(cov, mu, 3, 'g', np);
toc
axis equal