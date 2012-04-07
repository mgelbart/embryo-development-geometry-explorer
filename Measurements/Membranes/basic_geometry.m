function [data names units] = basic_geometry(embryo, getMemb, t, z, c, dx, dz, dt, other)
% computes the basic geometrical properties at (t, z) for Cell c given the
% Embryo4D and the relevant resolutions

names{1} = 'Cell length';
names{2} = 'Cell volume';
names{3} = 'Cell length extrap';
names{4} = 'Cell volume extrap';

units{1} = 'microns';
units{2} = 'microns^3';
units{3} = 'microns';
units{4} = 'microns^3';

% if c ~= 502;%209 %353
% % if (c <= 358 || c>369)
%      data = num2cell(NaN(8, 1));
%      return;
%  end

% % just do this for one layer to save time, since these properties are a
% % function of the whole cell stack, not an individual layer
if z ~= embryo.masterLayer
     data{1} = NaN;
     data{2} = NaN;
     data{3} = NaN;
     data{4} = NaN;
     return;
 end

if ~embryo.anyTracked(c, t)
    data{1} = NaN;
    data{2} = NaN;
    data{3} = NaN;
    data{4} = NaN;
    return;
end


%% calculate intensity profile for all layers
%% extra and interpolate for cells for which there is no tracked cell

%c

% get layers that were tracked; all others are NaN in x_values 
centroids = Cell.centroidStack(embryo.getCellStack(c, t)) * dx;
x_values = centroids(:, 2);
tracked = ~isnan(x_values);
ind_tracked = find(tracked);
ntracked = sum(tracked);

if (ntracked <7);
    data{1} = NaN;
    data{2} = NaN;
    data{3} = NaN;
    data{4} = NaN;
    return;
end



% get indicis of master, highest tracked, and highest layer
indml = embryo.translateZ(embryo.masterLayer)+1; % master layer
indht = embryo.translateZ(embryo.highestTracked(c,t))+1; % highest tracked
indlt = embryo.translateZ(embryo.lowestTracked(c,t))+1; % highest tracked
indhl = length(x_values);                           % highest layer
indll = 1;

% get zs of several relevant layers
zht = embryo.highestTracked(c, t); % highest tracked


% get tilt at all layers

% extract coordinates of centroids
y_values = centroids(:, 1);
x_values = centroids(:, 2);
z_values = (1:length(x_values)) * dz;
z_values = z_values(:);

% coordinats to be estimated
x_est = x_values;
y_est = y_values;
z_est = z_values;

% max number of z layers chosen to calculate tilt
dz_tilt = 3; % length (in micron) over which tilt is estimated
n_sel = min([round(dz_tilt/dz) ntracked]);

profile = zeros(indhl,1);
areas = zeros(indhl,1);
for i=1: indhl
    if (tracked(i))
        z_i = embryo.unTranslateZ(i-1);
        [roic, R] = drawCellSmall(embryo, t, z_i, c);  % roic is cell_img
        % (R(1) is offset in vertical, R(2) in horizontal direction)
    else

        [q,ind_close] = sort(abs(i-ind_tracked));
        ind_an = ind_tracked(ind_close(1:n_sel));
        
        % select coordinates of 'n_sel' closest layers to zht that are not NaN
        x_sel = x_values(ind_an);
        y_sel = y_values(ind_an);
        z_sel = z_values(ind_an);
        
        % compute tilt via principle components
        X = [x_sel,y_sel,z_sel];
        [coeff,score,roots] = princomp(X);
        
        % first component, vector pointing towards largest variation of centroids
        v = coeff(:,1);
        if (v(3)<0)   % and towards the top of the cell
            v=-v;
        end        
                
        ang_tot = atan(sqrt(v(1)^2+v(2)^2)/abs(v(3)));
        ang_dir = atan2(v(2),v(1));

        nnext = 1;
        z_i = embryo.unTranslateZ(ind_an(nnext)-1);
        [roic, R] = drawCellSmall(embryo, t, z_i, c);  % roic is cell_img
        % (R(1) is offset in vertical, R(2) in horizontal direction)
        z_offset = z_values(i)-z_values(ind_an(nnext));  % offset in microns
        xsh=z_offset*v(1)/v(3);
        ysh=z_offset*v(2)/v(3);
        x_est(i) = x_values(ind_an(nnext))+xsh;
        y_est(i) = y_values(ind_an(nnext))+ysh;
        R=R+round([ysh xsh]/dx);
    end
    npad = 0;
    roic = padarray(roic,[npad npad]); % increase region around cell
    roic = bwmorph(roic,'thicken',npad);
    R = R-[npad npad];
    yxs = size(roic);
        
    % extract intensity inside cell
    zi = embryo.unTranslateZ(i-1);
    intens = getMemb(t, zi);  % global myosin at layer z_i
    siz = size(intens);
    Rc = [min([R(1) siz(1)-yxs(1)+1]) min([R(2) siz(2)-yxs(2)+1])];
    Rc = [max([Rc(1) 1]) max([Rc(2) 1])]; 
    intensc = double(intens(Rc(1):Rc(1)+yxs(1)-1,Rc(2):Rc(2)+yxs(2)-1));
    
    %keyboard
    intensc = intensc.*roic;
    intensc_raw = intensc;
    %myosinc = myosinc/mean(mean(myosinc(roic))); % normalize
    
    profile(i) = sum(sum(intensc)); 
    
    areas(i) = embryo.getCell(c, t, z_i).area * dx^2;

    %keyboard
end

nar_fit = 4; %number of areas for linear extrapolation
navg_intens = 2; % number of extreme layers over which intensity is averaged
intensfac = 0.5; % factor of intensity at which extrapolation terminates

areas_est = areas*0;   % corrected areas
areas_est(indlt:indht) = areas(indlt:indht);


% lower end
intens_end = mean(profile(ind_tracked(1:navg_intens))); %intensity at end
area_epol = polyfit(indlt:indlt+nar_fit-1,...
    areas(indlt:indlt+nar_fit-1)',1);    
i=1;  % extrapolate                
while (indlt-i>=1 && profile(indlt-i)>intensfac*intens_end)
    areas_est(indlt-i) = area_epol(2)+area_epol(1)*(indlt-i); 
    i=i+1;
end
nl_extrap = i-1;

% upper end
intens_end = mean(profile(ind_tracked(end-navg_intens+1:end))); %intensity at end
area_epol = polyfit(indht-nar_fit+1:indht,...
    areas(indht-nar_fit+1:indht)',1);
i=1;   % extrapolate                
while (indht+i<=indhl && profile(indht+i)>intensfac*intens_end)
    areas_est(indht+i) = area_epol(2)+area_epol(1)*(indht+i); 
    i=i+1;
end
nu_extrap = i-1;


% put volume together
areas_est(areas_est<0) = 0;
cell_volume_extrap = sum(areas_est)*dz;

% pult length together
coo_est = [x_est y_est z_est];
coo_est(indht+nu_extrap:end,:) = [];
coo_est(1:indlt-nl_extrap,:) = [];


cell_length_extrap = sum(sqrt(diff(coo_est(:,1)).^2 + ...
                           diff(coo_est(:,2)).^2 + ...
                           diff(coo_est(:,3)).^2));




% figure(1);
% plot(profile);
% hold on;
% plot(ind_tracked,profile(ind_tracked),'ko')
% hold off;
% 
% figure(2);
% plot(areas);
% hold on;
% plot(ind_tracked,areas(ind_tracked),'ko')
% hold off;
% 
% figure(3);
% plot(areas_est);
% hold on;
% plot(ind_tracked,areas_est(ind_tracked),'ko')
% hold off;

%keyboard

%% compute the cell length
centroids = Cell.centroidStack(embryo.getCellStack(c, t)) * dx;
y_values = centroids(:, 1);
x_values = centroids(:, 2);
z_values = (1:length(x_values)) * dz;
z_values = z_values(:);

% remove NaN values
for i = length(x_values):-1:1
    if isnan(x_values(i))
        x_values(i) = [];
        y_values(i) = [];
        z_values(i) = [];
    end
end
cell_length = sum(sqrt(diff(x_values).^2 + ...
                           diff(y_values).^2 + ...
                           diff(z_values).^2));

%% compute the cell volume 
% here we just compute each volume element as area * dz. we might
% be able to do a smarter estimation using the orthogonal area, but this is
% ok for now.

% add up the volume elements from each layer. if the current
% layer is not tracked (NaN), then use the last volume element that you
% found. move from the bottom to the top. do not include an element from
% the top, because there is nothing "above" it
cell_volume = 0;
dir = sign(embryo.highestTracked(c, t) - embryo.lowestTracked(c, t));
for i = embryo.lowestTracked(c, t) : dir : embryo.highestTracked(c, t) - dir
   if ~isempty(embryo.getCell(c, t, i));
       last_volume_element = (embryo.getCell(c, t, i).area * dx^2) * dz;
   end
   cell_volume = cell_volume + last_volume_element;
end


%keyboard
%% places the data in the cell array

data{1} = cell_length;
data{2} = cell_volume;
data{3} = cell_length_extrap;
data{4} = cell_volume_extrap;
