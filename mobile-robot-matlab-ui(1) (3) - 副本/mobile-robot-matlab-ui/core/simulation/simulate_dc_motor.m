
% -------------------------------------------------------------------------
% SIMULATE_DC_MOTOR    find the new state of a DC motor based on its linear
% dynamical model.
%
% State is defined as [theta,  omega,  i] where:
%   - theta: angle of the shaft (radian)
%   - omega: angular velocity of the shaft (radian per second)
%   - i: electrical current in the armature (ampere)
%
% Simulation assumes a step input during timestep d_t.
%
% There are two types of input signal: `voltage_pwm` or `omega_setpoint`
% that are specified by `varargin` parameter. When voltage is selected the
% motor dynamics is simulated, whereas when selecting angular velocity
% (omega_setpoint) as input signal then motor steady state is considered.
%
% The voltage input is pulse width modulation duty cycle with range of 
% [-1, 1]
%
% If `sensor` has `gear_ratio` property then both `theta` and `omega`
% represent the output of the gearbox attached to the DC motor. Moreover
% `omega_setpoint` is also with respect to the output of the gearbox.
%
% Usage
%   state = SIMULATE_DC_MOTOR(sensor, initial_state, d_t, 'voltage_pwm', v_n);
%   state = SIMULATE_DC_MOTOR(sensor, initial_state, d_t, 'omega_setpoint', omega);
%
% Parameters
%   sensor          (1, 1)  ComponentClass object with type `dc-motor`
%   initial_state   (3, 1)  Initial state.
%   d_t             (1, 1)  Time interval size where input signal is
%                           assumed constant (step response).
%   varargin        (x, 1)  Structure that contains either `voltage_pwm`
%                           or `omega_setpoint` followed by the value.
%
% Returns
%   state           (3, 1)  New state after d_t seconds with step input
%                           signal.
%
% References
%   http://web.mit.edu/2.14/www/Handouts/StateSpaceResponse.pdf
%   http://ctms.engin.umich.edu/CTMS/index.php?example=MotorPosition&section=ControlStateSpace
%
% Implementation
%   Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

