function out = getBresenhamLine(map,p1,p2)
% This function returns the index of cells in 2D occupancy grid inside
% <map> that form a line between two points in p1 and p2.
%
% Bresenham line algorithm.
%
% The output is ordered from p1 to p2.
% 
% <p1> <p2> are not necessary inside the world.
%
% Inputs:
%   <map>     Data structure, Only 'grid' type.
%   <p1> <p2>  (2,1)   start point and end point
%
% Output:
%   <out>       (2,N)   rows/cols in map.OGrid that constitute a line.
%
% https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
% Mohamed Mustafa, August, 2015

if nargin<3
    flag = 0;
    if nargin<2
        out = [];   return
    end
end

pts = [p1 p2];

% (2) find dx and dy
dx = pts(1,2)-pts(1,1);
dy = pts(2,2)-pts(2,1);

% (3) Choose which direction in row/col
if abs(dx)>abs(dy)
    start_with_columns = 1;
else
    start_with_columns = 0;     % start with rows
end

% (4) Convert the points to rows and columns
r = floor((pts(2,:) - map.ll_corner(2))./map.res)+1;
c = floor((pts(1,:) - map.ll_corner(1))./map.res)+1;
rc = [r;c];

cond1 = dx==0 && dy==0;
cond2 = abs(dx)<map.res && abs(dy)<map.res;

if (cond1 || cond2)
    rc_out = rc(:,1);
else
    % (6) Fix rows/columns that are outside the range
    rc(1,rc(1,:)<1) = 1;
    rc(1,rc(1,:)>size(map.OGrid,1)) = size(map.OGrid,1);
    rc(2,rc(2,:)<1) = 1;
    rc(2,rc(2,:)>size(map.OGrid,2)) = size(map.OGrid,2);
    
    % (4) All columns/rows between first and last
    rows_all = rc(1,1):sign(dy):rc(1,2);
    cols_all = rc(2,1):sign(dx):rc(2,2);
    %     in case sign(dx)==0 or sign(dy)==0, do the following:
    if isempty(rows_all),   rows_all = rc(1,1);     end
    if isempty(cols_all),   cols_all = rc(2,1);     end
    
    % (5) Find the xy values of all possible rows/cols
    x_all = (cols_all-1)*map.res + map.ll_corner(1);
    y_all = (rows_all-1)*map.res + map.ll_corner(2);
    
    % (6) Check which direction to start
    if start_with_columns
        % find the image of x_all using the line
        y_temp = dy/dx*(x_all - pts(1,1)) + pts(2,1);
        y_all = round(y_temp./map.res).*map.res;
    else
        % find the image of y_all using the line
        x_temp = dx/dy*(y_all - pts(2,1)) + pts(1,1);
        x_all = round(x_temp./map.res).*map.res;
    end
    
    % (7) Convert xy to row and columns
    xy_all = [x_all;y_all];     % >>this is correct<<
    
    % >>> Here, we might have some precision issues!!!!! 
    r = round((xy_all(2,:) - map.ll_corner(2))./map.res)+1;
    c = round((xy_all(1,:) - map.ll_corner(1))./map.res)+1;
    rc_out = [r;c];
    % % This is the same as (7) but it is slow beacuse <repmat>
    % t1 = (xy_all - repmat(World.corner,1,size(xy_all,2)))./World.res;
    % rc_out = flipud(floor(t1 + eps(t1))+1);       % in Java, take +1 away
end

% (8) Delete all row/col that are out of range
ind_r_del = rc_out(1,:)<1 | rc_out(1,:)>size(map.OGrid,1);
ind_c_del = rc_out(2,:)<1 | rc_out(2,:)>size(map.OGrid,2);
ind_all_del = ind_r_del | ind_c_del;
rc_out(:,ind_all_del) = [];

out = rc_out;
return