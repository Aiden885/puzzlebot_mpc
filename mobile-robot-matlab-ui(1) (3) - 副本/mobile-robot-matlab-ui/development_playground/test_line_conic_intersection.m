clc
clear all

% Lines
l_tp = [0 1 1 2; 4 0 4 1;0 3 1 3]';
l_gf = line_tp2gf(l_tp);
l_pd = line_gf2pd(l_gf);

% Conics
circles = [2 4 3; 3 -1 1]';
conics = circle_to_conic(circles);

% Find intersection
[p1, p2] = intersect_line_conic(l_pd, conics, 'full');

% Plot all
figure(1), clf
nl = size(l_pd, 2);     % lines
for i = 1:nl
    x = [l_tp(1, i), l_tp(3, i)];
    y = [l_tp(2, i), l_tp(4, i)];
    plot(x, y, 'b-')
    if i == 1
        hold on
    end
end

nc = size(circles, 2);       % circles
th = linspace(0, 2*pi, 100);
for i = 1:nc
    x = circles(1, i) + circles(3, i) * cos(th);
    y = circles(2, i) + circles(3, i) * sin(th);
    plot(x, y, 'r-')
end

p = [reshape(p1, 2, []), reshape(p2, 2, [])];       % intersection points
np = size(p, 2);
for i = 1:np
    if isfinite(p(1, i))
        plot(p(1, i), p(2, i), 'g*', 'MarkerSize', 10)
    end
end

axis equal
hold off



