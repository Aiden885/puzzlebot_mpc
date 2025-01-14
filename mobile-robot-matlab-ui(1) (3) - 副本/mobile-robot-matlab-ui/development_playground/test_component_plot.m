clc
% (1) Using filename
M1 = ComponentClass('json_fname', 'motor_0001.json');
S1 = ComponentClass('json_fname', 'encoder_0001.json');
W1 = ComponentClass('json_fname', 'wheel_0001.json');
S2 = ComponentClass('json_fname', 'reflectance_0001.json');

% (2) Plot each component
figure(1), clf
T = [rotationVector2Matrix([1 0 0]*-pi/2) [0 0.075 0]';0 0 0 1];
M1.plot(T)
T = [rotationVector2Matrix([1 0 0]*-pi/2) [0 0.075 0]';0 0 0 1];
hold on
S1.plot(T)
hold off
axis equal
xlabel('x')
ylabel('y')
zlabel('z')

figure(2), clf
for c={M1, S1, W1}
    c
    c{1}.plot()
    hold on
    %c.plot()
end

figure(3), clf
S2.plot()
axis equal
xlabel('x')
ylabel('y')
zlabel('z')