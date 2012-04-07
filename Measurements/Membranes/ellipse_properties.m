function [data names units] = ellipse_properties(embryo, getMembranes, t, z, c, dx, dz, dt, other)
% computes the ellipse properties at (t, z) for Cell i given the Embryo4D,
% the membranes, and the relevant resolutions

% the names
names{1} = 'Major axis';
names{2} = 'Minor axis';
names{3} = 'Orientation';
names{4} = 'Anisotropy';
names{5} = 'Length-x';
names{6} = 'Length-y';
names{7} = 'Anisotropy-xy';

% the units
units{1} = 'microns';
units{2} = 'microns';
units{3} = 'degrees';
units{4} = '';
units{5} = 'microns';
units{6} = 'microns';
units{7} = '';

cell_img = drawCellSmall(embryo, t, z, c);

props = regionprops(cell_img, 'MajorAxisLength', 'MinorAxisLength', 'Orientation');

% gets all the properties 
major = [props.MajorAxisLength];
minor = [props.MinorAxisLength];
orient = [props.Orientation];
major = major(1);
minor = minor(1);
orient = orient(1);

% computes the remaining properties
anisotropy = major ./ minor;
length_x = major .* minor ./ sqrt(major.^2.*sind(orient).^2 + minor.^2.*cosd(orient).^2);
length_y = major .* minor ./ sqrt(major.^2.*cosd(orient).^2 + minor.^2.*sind(orient).^2);
anisotropy_xy = length_x ./ length_y;

% places the data in a cell array
data{1} = major * dx;
data{2} = minor * dx;
data{3} = orient;
data{4} = anisotropy;
data{5} = length_x * dx;
data{6} = length_y * dx;
data{7} = anisotropy_xy;




