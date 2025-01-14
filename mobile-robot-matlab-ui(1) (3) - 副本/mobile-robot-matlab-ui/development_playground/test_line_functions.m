clc
clear all

% All points
P = [1 3 5 3; 2 1 2 4];
np = size(P, 2);

% All possible valid lines from two distinct points
inds = combnk(1:np, 2);
nl = size(inds, 1);
line_tp = [P(:, inds(:, 1)); P(:, inds(:, 2))];     % in 2-points form
line_gf = line_tp2gf(line_tp);                      % in general form

% Construct 2 different sets of lines
ind1 = randsample(nl, 3)';
ind2 = setdiff(1:nl, ind1);
L1 = line_gf(:, ind1);
L2 = line_gf(:, ind2);
P_ = intersect_two_lines(L1, L2, 'full');

% Plot all
figure(1), clf
plot(P(1, :), P(2, :), 'ko', 'MarkerSize', 10)
hold on
for i=ind1
    t1 = inds(i, :);
    plot(P(1, t1), P(2, t1), 'r-')
end
for i=ind2
    t1 = inds(i, :);
    plot(P(1, t1), P(2, t1), 'b-')
end
% plot intersection points
plot(P_(1,:), P_(2,:), '*g', 'MarkerSize', 10)
hold off


% Test degenerate cases (parallel or coincident lines)
P_ = intersect_two_lines(L1, L1, 'full')    % coincident lines

L1 = [1 2 3; 1 0 3; 0 2 3]';
L2 = [1 2 4; 1 0 4; 0 2 4]';
P_ = intersect_two_lines(L1, L2)    % parallel lines

