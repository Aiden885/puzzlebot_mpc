function [obj] = ParticleFilter(obj, omigas_map)

%% 调用所需的状态变量和系统常数
% 从所选的机器人模型中调用计算每个轮子角速度的误差常数
k               = obj.robot.wheel_error_constant;
% 从所选的机器人模型中调用两轮之间的距离（m）
L               = 2*obj.robot.components_tree.get('left motor').transformation(2,end);
% 从所选的机器人模型中调用轮子的半径（m）
r               = obj.robot.components_tree.get('left wheel').shape.diameter/2;
% 粒子数量
m               = obj.n_particles;
% 粒子的位置
Particles       = obj.particles;
% 右轮角速度的编码器读数（rad/s）
w_r             = omigas_map('right wheel');
% 左轮角速度的编码器读数（rad/s）
w_l             = omigas_map('left wheel');
% 时间步长
dt              = toc(obj.timestamp);               % 计算时间变化
set_property(obj, 'timestamp' , tic);               % 重置计时器

% 初始化权重向量
Weights = ones(1, m) / m; % 初始权重均等

% 获取实际测量值
z_actual = get_measurement(obj);

% 测量噪声标准差（根据您的传感器特性设置）
measurement_noise = obj.measurement_noise;

% 状态预测和测量更新
for i = 1:m

    % 计算速度和角速度
    v = r*((w_r+w_l)/2); % 线速度
    omiga = r*((w_r - w_l)/L); % 角速度
    
    % 噪声协方差矩阵
    sigma = [k^2 0 0; 0 k^2 0; 0 0 (k/L)^2];

    % 提取粒子状态
    x = Particles(1, i);
    y = Particles(2, i);
    theta = Particles(3, i);

    % 状态预测
    x_next = x + v * cos(theta) * dt;
    y_next = y + v * sin(theta) * dt;
    theta_next = theta + omiga * dt;
   
    % 添加运动噪声
    Gaussian_noise = mvnrnd([0 0 0], sigma);
    x_next = x_next + Gaussian_noise(1);
    y_next = y_next + Gaussian_noise(2);
    theta_next = theta_next + Gaussian_noise(3);

    % 更新粒子状态
    Particles(1, i) = x_next;
    Particles(2, i) = y_next;
    Particles(3, i) = theta_next;

    % 预测测量值
    z_predicted = predict_measurement(obj, Particles(:, i));

    % 计算测量概率（使用高斯概率密度函数）
    Weights(i) = exp(-0.5 * ((z_actual - z_predicted)/measurement_noise)^2);
end

% 归一化权重
Weights = Weights / sum(Weights);

% 重采样步骤
% 计算累积权重
cumulative_weights = cumsum(Weights);

% 初始化新的粒子集
new_Particles = zeros(size(Particles));

% 生成一个初始随机数
r_random = rand / m;

% 指示器
i = 1;

for j = 1:m
    U = r_random + (j - 1) / m;
    while U > cumulative_weights(i)
        i = i + 1;
    end
    new_Particles(:, j) = Particles(:, i);
end

% 更新粒子集
Particles = new_Particles;

% 保存新的粒子位置
set_property(obj, 'particles' , Particles);

% 更新机器人状态估计（可选）
x_estimated = mean(Particles(1, :));
y_estimated = mean(Particles(2, :));
theta_estimated = mean(Particles(3, :));
set_property(obj, 'state', [x_estimated; y_estimated; theta_estimated]);

end

%% 辅助函数：获取实际测量值
function z_actual = get_measurement(obj)
    % 获取传感器的实际测量值
    % 假设机器人有一个测距传感器，测量到固定路标的距离
    landmark_position = obj.landmark_position; % 路标位置 [x; y]
    robot_state = obj.true_state; % 机器人真实状态 [x; y; theta]
    measurement_noise = obj.measurement_noise; % 测量噪声标准差
    distance = sqrt((robot_state(1) - landmark_position(1))^2 + (robot_state(2) - landmark_position(2))^2);
    z_actual = distance + randn * measurement_noise; % 添加测量噪声
end

%% 辅助函数：预测测量值
function z_predicted = predict_measurement(obj, particle)
    % 根据粒子状态预测测量值
    landmark_position = obj.landmark_position; % 路标位置 [x; y]
    x = particle(1);
    y = particle(2);
    z_predicted = sqrt((x - landmark_position(1))^2 + (y - landmark_position(2))^2);
end
