function [data names units] = myosin_intensity(embryo, getMyosin, t, z, c, dx, dz, dt, other)

% the names
names{1} = 'Myosin intensity';

% the units
units{1} = 'intensity units';

% draw the Cell
[cell_img R] = drawCellSmall(embryo, t, z, c);

myosin = getMyosin(t, z);

myosin = myosin(R(1):R(1)+size(cell_img, 1)-1, R(2):R(2)+size(cell_img, 2)-1);

% compute the myosin intensity in each cell
data{1} = sum(sum(myosin(cell_img))); 
