% Generate World Edit PNGs

close all, clear all, clc
alpha = 0.9;
target_path = fullfile(pwd, 'core', 'gui', 'icons');


%% (1) Add polygon
fid = 1;
figure(fid);    fid = fid + 1;
shape.type = 'polygon';
shape.color = 'black';
shape.vertices = [0 2 1 0.5 -1;0 2 3 2 3];
plot_shape(shape, 'alpha', alpha);
% hold on
% plot([1.5 1.5], [0 1], 'g-', 'LineWidth', 30)
% plot([1 2], [0.5 0.5], 'g-', 'LineWidth', 30)
% hold off
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);

D = ones( size(cdata(:,:,1)) );
%D( all( cdata==255, 3 ) ) = 0; 

imwrite(cdata, fullfile(target_path, 'add_polygon.png'), 'alpha',D)


%% (2) Add Circle
figure(fid);    fid = fid + 1;
shape.type = 'circle';
shape.color = 'black';
shape.center = [0.5 1.5];
shape.diameter = 2.5;
plot_shape(shape, 'alpha', alpha);
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);
imwrite(cdata, fullfile(target_path, 'add_circle.png'), 'PNG')


%% (3) Add point
figure(fid);    fid = fid + 1;
plot(0.5,1.5,'rp','MarkerSize',200,'MarkerFaceColor','black');
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);
imwrite(cdata, fullfile(target_path, 'add_point.png'), 'PNG')


%% (4) Add path
figure(fid);    fid = fid + 1;
plot([-0.5 0.5 1.5 0.1 0 1.5], [2 2.5 1.5 1.15 0.5 0.1], 'k-', 'LineWidth', 40)
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);
imwrite(cdata, fullfile(target_path, 'add_path.png'), 'PNG')


%% (5) Delete shape
figure(fid);    fid = fid + 1;
plot([-0.5 1.5], [2.5 0.5], 'r-', 'LineWidth', 40)
hold on
plot([-0.5 1.5], [0.5 2.5], 'r-', 'LineWidth', 40)
hold off
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);
imwrite(cdata, fullfile(target_path, 'delete_shape.png'), 'PNG')

%% (6) Add ramp
figure(fid);    fid = fid + 1;
shape.type = 'polygon';
shape.color = 'black';
shape.vertices = [-0.9 1.9 1 0; 1 1 2 2];
plot_shape(shape, 'alpha', alpha);
axis equal
axis([-1 2 0 3])
set(gca,'Visible','off')

cdata = imresize(print('-RGBImage'), [30 40]);
cdata = cdata(:, 7:36, :);

D = ones( size(cdata(:,:,1)) );
%D( all( cdata==255, 3 ) ) = 0; 

imwrite(cdata, fullfile(target_path, 'add_ramp.png'), 'alpha',D)
