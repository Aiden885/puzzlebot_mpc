function my_alg = pathMPC(my_alg, robot)
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    %% =========================Initialization=====================
    % =====================Initial the variables here======================
    my_alg('path')=load('trajectory_circle.txt');% reference path (s shape)
    path=my_alg('path');              
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    my_alg('right motor')   = 0;    % angular velocity set point for the right motor speed
    my_alg('left motor')    = 0;    % angular velocity set point for the left motor speed
    my_alg('t_loop')        = tic;  % operationg time for one loop
    my_alg('xr')=path(:,1); % reference path in x
    my_alg('yr')=path(:,2); % reference path in y
    my_alg('thetar')=path(:,3); % reference path in theta
    my_alg('vr')=path(:,4); % reference path in x
    my_alg('wr')=path(:,5); % reference path in y
    my_alg('path_x')=[]; % simulated robot path in x
    my_alg('path_y')=[]; % simulated robot in y
    my_alg('theta')=[];  % simulated robot in theta
    my_alg('K')=1;
    my_alg('wR_all') = [];
    my_alg('wL_all') = [];
    my_alg('xe_all') = [];
    my_alg('ye_all') = [];
    my_alg('thetae_all') = [];
    my_alg('wr_all') = [];
    my_alg('vr_all') = [];
    my_alg('vd_all') = [];
    my_alg('x_all') = [];
    my_alg('y_all') = [];
    my_alg('w_desired') = [];
    my_alg('v_desired') = [];
    my_alg('F')=1;
    
    %% =======================Localizer============================
    my_alg('localizer') = LocalizationClass(...
        'method', 'wv',...
        'robot', robot,...
        'pose', [0 0 0],... % should always be the same as the initial 2D pose in mobile robot simulator GUI
        ...
        ...
        'ext_sensor_label', 'range');
    % =====================================================================
end

% Localization update
omegas_map = containers.Map({'right wheel', 'left wheel'},...
    [my_alg('right encoder'), my_alg('left encoder')]);
    my_alg('localizer') = Deadreckoning(my_alg('localizer'),omegas_map);
% Plotting section
my_alg = add_plot(my_alg, 'plot(my_alg(''localizer''))');     % plot pose estimation in the main figure
my_alg = add_plot(my_alg, 'plot(my_alg(''path_x''),my_alg(''path_y''),''k--'')');% plot robot passed path
my_alg('ref') = add_plot(my_alg, 'plot(my_alg(''xr''),my_alg(''yr''),''r'')');%plot premade reference path

%% Variables (add your own variables if needed) 
t_sampling          = 0.15;            % time period between two reference points (select a suitable time)
S                   = my_alg('localizer').pose; % current robot pose
w_r                 = my_alg('right motor');    % omega set point for right motor
w_l                 = my_alg('left motor');     % omega set point for left motor
L                   = 2*robot.components_tree.get('left motor').transformation(2,end);% length between wheels
r                   = robot.components_tree.get('left wheel').shape.diameter/2;% wheels radiu
x_r                 = my_alg('xr');
y_r                 = my_alg('yr');
theta_r             = my_alg('thetar');
v_ref                 = my_alg('vr'); % reference path in x
w_ref                 = my_alg('wr'); % reference path in y             
my_alg('is_done')   = false;
path                = my_alg('path');  
F                   = my_alg('F');

%======================================================================
%======================================================================
%% build your system model and MPC controller in a control loop here
% =====================================================================
%% Core part of the control loop
% Check if the last path point has been reached
if (my_alg('K')==164)
    my_alg('is_done')=true;
end

% Define the dimensions of states, inputs, and outputs
n_out=3;    % Number of outputs
n_states=3; % Number of states
n_in=2;     % Number of inputs

% Control weight matrices
s=50*diag([0.05,0.32]);
q=diag([1,1,1]);
N=300;
% s=50*diag([0.04778,1.2]);% Control input weights (v,w)
% q=diag([1,1,1]);% State weights (x,y,theta)
% N=300; % Prediction horizon

% Extract the current target point from the path data
xR=x_r(my_alg('K'));
yR=y_r(my_alg('K'));
thetaR=theta_r(my_alg('K'));
vR=v_ref(my_alg('K'));
wR=w_ref(my_alg('K'));

% Calculate current errors
ex=xR-S(1);
ey=yR-S(2);
etheta=atan2(ey,ex)-S(3);
v=(w_r+w_l)*r/2;
w=(w_r-w_l)*r/L;
u=[v w]';
ev=vR-v;
ew=wR-w;

% Normalize angular error to within -pi to pi range
while (abs(etheta)>5)
    if etheta<0
        etheta=etheta+2*pi;
    else 
        etheta=etheta-2*pi;
    end
end

% Calculate Euclidean distance of position error
ed=sqrt(ex^2+ey^2);

% If the error is below threshold, move to the next target point
if (ed<0.07)
    my_alg('K')=my_alg('K')+1;
end

% Build matrices for the optimization problem
Q = sparse(kron(eye(N),q));
SS = sparse(kron(eye(N),s));

Lambda = zeros((N)*n_out,n_states);
Phi = zeros((N)*n_out,(N)*n_in);
PP=eye(n_states);

% Linearized model matrices
A=[1 0 -t_sampling*vR*sin(thetaR);0 1 t_sampling*vR*cos(thetaR);0 0 1];
B=[t_sampling*cos(thetaR) 0;t_sampling*sin(thetaR) 0;0 t_sampling];
C=eye(3);
D=zeros(3,2);

% Build Phi and Lambda matrices for prediction model
for j = 1:N-1
    Phi(1+(j-1)*n_out:j*n_out,1+(j-1)*n_in:(j)*n_in) = D;
    Phi(1+j*n_out:(j+1)*n_out,1+(j-1)*n_in:(j)*n_in) = C*B;
    for i = 1:N-1-j
        PP=A*PP;
        Phi(1+(j+i)*n_out:(j+i+1)*n_out,1+(j-1)*n_in:(j)*n_in) = C*PP*B;
    end
end
Phi=sparse(Phi);
Lambda(1:n_out,:) = C;
P=eye(n_states);
for i = 2:N
    P=A*P;
    Lambda(1+(i-1)*n_out:i*n_out,:) = C*P;
end

% Build and solve the quadratic programming problem
H = full(Phi'*Q*Phi) + SS;
H=(H+H')/2;
d=t_sampling*u; % Linear and angular displacements
Xx=S+[d(1)*cos(S(3)) d(1)*sin(S(3)) d(2)]'-[xR yR thetaR]';% Observer output

% f vector for quadratic programming
f = double(2*Phi'*Q*Lambda*Xx);%

% Define constraints
% LL=[eye(N*n_in);-eye(N*n_in)];
% upper_bound=13.7; % Constraint upper limit
% Aeq=[1/r -L/r;1/r L/r];
% AEQ=kron(eye(N),Aeq);
% aaeq=[AEQ;-AEQ];
% b=0.5*ones(N*2*2,1);
% UB=0.21*ones(N*n_in,1);
% for i=1:N
%     UB(n_in*i)=0.3;
% end
% 
% UB=[];

% Solve the quadratic programming problem
uu=quadprog(H,f,[],[],[],[],[],[],[],optimset('display','off'));
MM=LL*uu;
while all(MM(:)>upper_bound)
    uu=quadprog(H,f,[],[],[],[],[-0.05,-0.1]',[0.05,0.1]',[],optimset('display','off'));
end

% Calculate and update control inputs for left and right wheels
Control_Inputs = uu(1:n_in);% First elements
w_l=(Control_Inputs(1)-L*Control_Inputs(2))/r+w_l;
w_r=(Control_Inputs(1)+L*Control_Inputs(2))/r+w_r;


my_alg('wR_all') = [my_alg('wR_all') w_r];
my_alg('wL_all') = [my_alg('wL_all') w_l];
my_alg('xe_all') = [my_alg('xe_all') ex];
my_alg('ye_all') = [my_alg('ye_all') ey];
my_alg('thetae_all') = [my_alg('thetae_all') etheta];
my_alg('vr_all') = [my_alg('vr_all') v];
my_alg('wr_all') = [my_alg('wr_all') w];
my_alg('vd_all') = [my_alg('vd_all') w*0.6673];
my_alg('x_all') = [my_alg('x_all') S(1)];
my_alg('y_all') = [my_alg('y_all') S(2)];
my_alg('w_desired') = [my_alg('w_desired') wR];
my_alg('v_desired') = [my_alg('v_desired') vR];
toc(my_alg('tic'))
% =====================================================================
if my_alg('is_done')
%% make your plots here
    figure(7);
    plot(my_alg('wR_all'), '-b', 'LineWidth', 2);
    hold on;
    plot(my_alg('wL_all'), '-r', 'LineWidth', 2);
    legend('Wheel Angular Velocities');
    figure(4);
    plot(my_alg('xe_all'), '-r', 'LineWidth', 2);
    hold on;
    plot(my_alg('ye_all'), '-b', 'LineWidth', 2);
    plot(my_alg('thetae_all'), '-g', 'LineWidth', 2);
    legend('x error', 'y error', 'theta error')
    figure(2);
    plot(my_alg('v_desired'),':r','LineWidth',2);
    hold on
    plot(my_alg('vr_all'), '-r', 'LineWidth', 2);
    legend('v desired', 'Vr')
    figure(3);
    plot(my_alg('w_desired'),':r','LineWidth',2);
    hold on
    plot(my_alg('wr_all'), '-r', 'LineWidth', 2);
    legend('w desired', 'wr')
    figure(1)
    plot(path(:,1),path(:,2),':r','LineWidth',2);
    hold on;
    axis equal;
    plot(my_alg('x_all'), my_alg('y_all'), '-b', 'LineWidth', 2);
    legend('XY desired', 'XY robot')


end


%% ====================update datas=========================================
my_alg('right motor')   = w_r;
my_alg('left motor')    = w_l;
my_alg('path_x')        = [my_alg('path_x') my_alg('localizer').pose(1)];
my_alg('path_y')        = [my_alg('path_y') my_alg('localizer').pose(2)];
my_alg('theta')         = [my_alg('theta')  my_alg('localizer').pose(3)];
return