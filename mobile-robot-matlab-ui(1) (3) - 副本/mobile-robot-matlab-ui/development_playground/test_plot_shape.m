clc
clear all
figure(1), clf

shape.type = 'cylinder';
shape.color = 'green';
shape.z_limits = [-1 1];
shape.diameter = 1;
subplot(2, 3, 1)
plot_shape(shape);      title(shape.type);      axis equal

shape.type = 'circle';
shape.color = 'red';
shape.center = [-1 1];
shape.diameter = 1;
subplot(2, 3, 2)
plot_shape(shape);      title(shape.type);      axis equal

shape.type = 'point';
shape.color = 'black';
shape.coordinates = [-2 4]';
subplot(2, 3, 3)
plot_shape(shape);      title(shape.type);      axis equal

shape.type = 'polygon';
shape.color = 'yellow';
shape.vertices = [1 2; 4 0; 3 5; 2 6]';
subplot(2, 3, 4)
plot_shape(shape);      title(shape.type);      axis equal

shape.type = 'box';
shape.color = 'black';
shape.x_limits = [-1 1];
shape.y_limits = 2 * [-1 1];
shape.z_limits = 3 * [-1 1];
subplot(2, 3, 5)
plot_shape(shape);      title(shape.type);      axis equal