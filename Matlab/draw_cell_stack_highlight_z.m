%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2012, Michael Gelbart (michael.gelbart@gmail.com)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
% - Redistributions of source code must retain the above copyright notice,
%   this list of conditions and the following disclaimer.
% 
% - Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
% EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Draw the 3D rendering of a cell. Takes in an array of java Cell objects
% in CS. Also, highlights one of the slices in red (i.e., the one that the
% user is currently looking at in the image view).

function draw_cell_stack_highlight_z(CS, T, slice_highlight, handles, dx, dz)

z_points = (0:length(CS)-1) * dz;
z_points = z_points(:);

% XY = zeros(size(vert, 1), size(vert, 2));

% MEMBRANES
if get(handles.cbox_show_membs, 'Value')
    for i = 1:length(z_points)
        % highlight the special layer
        if i == slice_highlight
            col = 'r';
        else 
            col = 'k';
        end
        
        % vertices for this layer
        if isempty(CS(i))
            continue;
        end
        verts = CS(i).vertexCoords * dx;
        
        % put the beginning one at the end for wrap-around drawing
        verts(size(verts, 1)+1, :) = verts(1, :);      
       
        for j = 1:size(verts, 1)-1
            plot3(verts(j:j+1, 2), verts(j:j+1, 1), [z_points(i); z_points(i)], col)
        end
     end
end


% SURFACE
if get(handles.cbox_show_surface, 'Value')
%     keyboard
    
    csImage = Misc.drawCellStack(CS);
    Xpts = squeeze(csImage(1, :, :)) * dx;
    Ypts = squeeze(csImage(2, :, :)) * dx;
    Zpts = squeeze(csImage(3, :, :)) * dz;

    colormap(bone);  
%     colormap(copper)
    surf(Xpts, Ypts, Zpts); shading interp;
%     surf(Xpts, Ypts, Zpts, 'EdgeAlpha', 0); % transparent edges
end



% VERTICES
if get(handles.cbox_show_vertices, 'Value')
    vertstacks = Cell.allVertexStack(CS) * dx;
    %size: z x num verts x 2
    for zz = 1:size(vertstacks, 2)
        plot3(vertstacks(:, zz, 2), vertstacks(:, zz, 1), z_points, '.b');%, 'MarkerSize', 15);
        if ~isnan(slice_highlight)  % for making movies, we don't want to highlight any z
            plot3(vertstacks(slice_highlight, zz, 2), vertstacks(slice_highlight, zz, 1), z_points(slice_highlight), '*r');
        end
    end
end



cent = Cell.centroidStack(CS) * dx;

% CENTROID
if get(handles.cbox_show_centroids, 'Value')
    plot3(cent(:, 2), cent(:,1), z_points, '.b');
    if ~isnan(slice_highlight)
        plot3(cent(slice_highlight, 2), cent(slice_highlight,1), z_points(slice_highlight), '.r');
    end
    % centroid line
    linecent = cent;
    linezpts = z_points;
    for i = size(cent, 1):-1:1
        if isnan(linecent(i, 1))
            linecent(i, :) = [];
            linezpts(i) = [];
        end
    end
    line(linecent(:, 2), linecent(:, 1), linezpts, 'Color', 'g');
end


% OTHER CHANNELS (starting with nuclei for test)
if get(handles.cbox_show_other_channels, 'Value')
    X = [];
    for i = 1:length(z_points)
   
        if isempty(CS(i))
            continue;
        end
     
     
        c = handles.activeCell(1);

        image_file = handles.info.channel_image_file{handles.activeChannels3d};
        out = double(imread(image_file(T, handles.embryo.unTranslateZ(i-1), handles.src.channelsrc{handles.activeChannels3d})));
        wholenuc = drawCell(handles.embryo, T, handles.embryo.unTranslateZ(i-1), c);

        nuc = out;
        nuc(~wholenuc) = 0;
        x = nuc(nuc ~= 0);
        
        nuc(nuc < 60) = 0;  % pixels must have brightness of at least 60
        if sum(~~nuc(:)) < 15  % must be at least 15 px passing threshold
            continue;
        end
        [a b] = find(nuc);
        n = length(a);
        X = [X; zeros(n, 3)];
        X(end-n+1:end, 1) = b(:)*dx;
        X(end-n+1:end, 2) = a(:)*dx; 
        X(end-n+1:end, 3) = z_points(i)*ones(n,1); 
%         for j = 1:length(a)
%             plot3(b(j)*dx, a(j)*dx, z_points(i), '.g');
%         end
    end

   
    try  % this is buggy so I just try... (sloppy!)
        K = convhulln(X);
        trisurf(K,X(:,1),X(:,2),X(:,3), 'CData', ones(size(X(:,3))), 'EdgeAlpha', 0);
    end

end


% % CENTROID FIT
% if get(handles.cbox_show_centroid_fit, 'Value')
% 
%     fitObj = CS.centroidLineFit;
%     % slope must be adjusted by dz/dx
%     Mx = fitObj.mX * dz/dx;
%     Bx = fitObj.bX * dx;
%     My = fitObj.mY * dz/dx;
%     By = fitObj.bY * dx;
% 
%     line_z = linspace(min(z_points), max(z_points) + (max(z_points) - min(z_points))/2.5);
%     % line_z = linspace(min(z_points), max(z_points) + (max(z_points)-min(z_points))/max(length(z_points), 1));
%     xss = (line_z / Mx) + Bx;
%     yss = (line_z / My) + By;  
%     plot3(xss, yss, line_z, 'g');
% end



%{
% plot the vertex fits and the vertices themsevles
vertFitObjects = CS.verticesLineFit;
for all = 1:length(vertFitObjects)
    currentObj = vertFitObjects(all);
    Mx = currentObj.mX * dz/dx;
    Bx = currentObj.bX * dx;
    My = currentObj.mY * dz/dx;
    By = currentObj.bY * dx;
    xss = (line_z / Mx) + Bx;
    yss = (line_z / My) + By;
    plot3(xss, yss, line_z, 'b');
end
%}

% if strcmp(MEASURE, 'Area (orthogonal)') && ~isnan(slice_highlight)
% % draw the orthogonal plane
%     [area plane Vpts] = orthogonal_area(CS, z_points(slice_highlight), INFO);
%     n = plane(:, 1); % normal
%     nx = n(1); ny = n(2); nz = n(3);
%     c = plane(:, 2); % point
% 
%     % we want to pick 4 (x,y) points to draw the plane (4 corners)
%     plsz = 5; % size of the plane
%     planeX(2) = cent(1, 1) + plsz;
%     planeX(1) = cent(1, 1) - plsz;
%     planeY(2) = cent(1, 2) + plsz;
%     planeY(1) = cent(1, 2) - plsz;
% 
%     % find Z using the formula for a plane and solving for z
%     % the repmat is just to get Z as a matrix for surf
%     planeZ = (1/nz)*(n.'*c - nx*repmat(planeX, 2, 1) - ...
%         ny*repmat(planeY.', 1, 2));
% 
%     color = zeros(2, 2, 3);
%     % draw the actual shape used for orthogonal area, not just a 
%     % square plane. well, for this you'd need to use a bunch of triangles
%     % each connected with the center. otherwise it won't really work.
%     % wait, shouldn't it work? they all lie in a plane...
%     %{
%     planeX = Vpts(1, :);
%     planeY = Vpts(2, :);
%     planeZ = repmat(Vpts(3,:), length(planeX), 1);
%     color = zeros(length(planeX), length(planeX), 3);
%     %}
%     color(:,:,1) = 1;
%     surf(planeX, planeY, planeZ, ...
%         'FaceAlpha', 0.1, 'CData', color);
% 
%     % draw the points that are used for the orthogonal area
%     % orthoX = Vpts(1, :);
%     % orthoY = Vpts(2, :);
%     % orthoZ = Vpts(3, :);
%     % plot3(orthoX, orthoY, orthoZ, '+g');
% end
% 
% 
% ZP = Z;
% if get(handles.cbox_3d_myo, 'Value')
% 
%     [t z T Z] = getTZ(handles);
% 
%     rawmyo = double(imread(handles.info.myosin_file(T, Z, handles.src.myo)));
% 
%     rawmyo(rawmyo < mean(rawmyo(:)) + 2*std(rawmyo(:))) = 0;
% 
%     mnx=min(min(vertstacks(:,:,2)));
%     mxx=max(max(vertstacks(:,:,2)));
%     mny=min(min(vertstacks(:,:,1)));
%     mxy=max(max(vertstacks(:,:,1)));
%     mask=logical(rawmyo*0);
%     mask(round(mny/dx):round(mxy/dx),round(mnx/dx):round(mxx/dx),:)=1;
%     rawmyo(mask==0)=0;
% 
% 
% %     [qx,qy,vals] = find(rawmyo(:,:,i));
%     [qx,qy,vals] = find(rawmyo);
%     vals=vals/max(vals)*80;
%     nq=length(qx);
%     scatter3(qy*dx,qx*dx,max(z_points)+0*qy,vals,'sc','filled');
% %     scatter3(qy*dx,qx*dx,repmat(size(rawmyo,3)-i,nq,1)*dz,vals,'sc','filled');
%     
%     
% end
% 
% if get(handles.cbox_3d_stalk, 'Value')
%     [t z T Z] = getTZ(handles);
% 
% % hard-coded --- BAD!!!!!!!!!!!!!!!!!
%     for layer = 0:7
%     
%     
%         rawstalk = double(imread(handles.info.stalk_file(T, layer, handles.src.stalk)));
% 
%         rawstalk(rawstalk < mean(rawstalk(:)) + 3*std(rawstalk(:))) = 0;
% 
%         mnx=min(min(vertstacks(:,:,2)));
%         mxx=max(max(vertstacks(:,:,2)));
%         mny=min(min(vertstacks(:,:,1)));
%         mxy=max(max(vertstacks(:,:,1)));
%         mask=logical(rawstalk*0);
%         mask(round(mny/dx):round(mxy/dx),round(mnx/dx):round(mxx/dx),:)=1;
%         rawstalk(mask==0)=0;
% 
% 
%     %     [qx,qy,vals] = find(rawmyo(:,:,i));
%         [qx,qy,vals] = find(rawstalk);
%         vals=vals/max(vals)*80;
%         nq=length(qx);
%          scatter3(qy*dx,qx*dx, ZP(layer+1, 1)  +0*qy,vals,'sc','filled');
%     %     scatter3(qy*dx,qx*dx,repmat(size(rawmyo,3)-i,nq,1)*dz,vals,'sc','filled');
% 
%     end
%     
% end