clear all, clc, close all

% Build motor
motor = ComponentClass('json_fname', 'motor_0001.json');

% Input signal and time smaples
t = 0:0.001:0.2;
%v_u = sign(rand(1, length(t)) - 0.5);   %PRBS
v_u = ones(1, length(t));
omega_setpoint = 150;

% Closed form simulaton
tic
state = [0, 0, 0]';
for k = 2:length(t)
    dt = t(k) - t(k-1);
    state(:, k) = simulate_dc_motor(motor, state(:, k-1), dt, 'voltage_pwm', v_u(k));
    %state(:, k) = simulate_dc_motor(motor, state(:, k-1), dt, 'omega_setpoint', omega_setpoint);
end
toc

% plot
figure(1), clf
subplot(3, 1, 1), plot(t, state(1, :), 'r'), xlabel('time (sec)'), ylabel('angle (radian)'), hold on
subplot(3, 1, 2), plot(t, state(2, :), 'r'), xlabel('time (sec)'), ylabel('angular velocity (radian/sec)'), hold on
subplot(3, 1, 3), plot(t, state(3, :), 'r'), xlabel('time (sec)'), ylabel('current (amp)'), hold on

%{
% Use ODE solvers (very slow)
% Here we assume gearbox ratio is 1.
tic
v_u = 1;
A = [0 1 0
    0 -motor.b/motor.J motor.K/motor.J
    0 -motor.K/motor.L -motor.R/motor.L];
B = [0 ; 0 ; 1/motor.L];
u = motor.v_max * v_u;
[~, state_2] = ode45(@(t, state) A*state + B*u, t, [0; 0; 0]);
toc
state_2 = state_2';

% plot
subplot(3, 1, 1), plot(t, state_2(1, :), 'b.'), hold off
subplot(3, 1, 2), plot(t, state_2(2, :), 'b.'), hold off
subplot(3, 1, 3), plot(t, state_2(3, :), 'b.'), hold off
%}