function [data names units] = basic_2d(embryo, getMembranes, t, z, c, dx, dz, dt, other)
% computes the ellipse properties at (t, z) for Cell i given the Embryo4D,
% the membranes, and the relevant resolutions

% the names
names{1} = 'Area';
names{2} = 'Perimeter';
names{3} = 'Centroid-x';
names{4} = 'Centroid-y';

% the units
units{1} = 'microns^2';
units{2} = 'microns';
units{3} = 'microns';
units{4} = 'microns';

% the data
cell = embryo.getCell(c, t, z);
centroid = cell.centroid;

data{1} = cell.area * dx^2;
data{2} = cell.perimeter * dx;
data{3} = centroid(2) * dx;
data{4} = centroid(1) * dx;



