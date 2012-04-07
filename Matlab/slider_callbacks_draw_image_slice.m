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


function handles = slider_callbacks_draw_image_slice(handles)
    % if handles.is_maingui
    %     set(handles.text_readyproc, 'String', 'Drawing');
    %     set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
    %     drawnow;
    % end

    [T Z] = getTZ(handles);

    axes(handles.axes1);
    cla
    hold on

    if get(handles.cbox_raw,  'Value') || get(handles.cbox_bord,  'Value') || ...
        ~isempty(handles.activeChannels)
        img = zeros(handles.info.Ys, handles.info.Xs, 3);
    else
        img = [];
    end

    % plot the raw image
    if get(handles.cbox_raw,  'Value')
        out = imread(handles.info.image_file(T, Z, handles.src.raw));
        out = double(out);
%         out = handles.info.image_file.raw(T, Z);
        out = out / max(out(:));

        img = repmat(out, [1 1 3]);  % all 3 channels
    end


    % plot the borders
    if get(handles.cbox_bord, 'Value')
        if handles.is_semiauto
            tempfilename = handles.info.image_file(T, Z, handles.tempsrc.bord);
            if exist(tempfilename, 'file')
                out = imread(tempfilename);
            else
%                 % draw a stripe
%                 out = imagestripe(handles.info.Ys, handles.info.Xs);
            end
        else  % for EDGE
            permfilename = handles.info.image_file(T, Z, handles.src.bord);
            out = imread(permfilename); 
        end
        img(:,:,2) = img(:,:,2) + double(out);
    end


    % plot the other channels
    if ~isempty(handles.activeChannels)
        for i = 1:length(handles.activeChannels)
            image_file = handles.info.channel_image_file{handles.activeChannels(i)};
            out = imread(image_file(T, Z, handles.src.channelsrc{handles.activeChannels(i)}));
            out = double(out);

            % this is the index of the channel out of the list of *all*
            % channels that have ever been imported. the idea here is that
            % there is some consistency when you're plotting in one session---
            % for example, myosin will always have some color even if you plot
            % it in a data set with only myosin in one case and a data set with
            % many channels in another case.
            existing_channel_names_nomemb = handles.all_channelnames;
            existing_channel_names_nomemb(strcmp(existing_channel_names_nomemb, 'Membranes')) = [];        
            ch_ind = find(strcmp(existing_channel_names_nomemb, handles.channelnames{handles.activeChannels(i)}));        
            cols = my_colors(ch_ind);
            % this may not actually be what i want. the other option is
            % commented below
    %         cols = my_colors(i);
            R = cols(1);
            G = cols(2);
            B = cols(3);
            img(:,:,1) = img(:,:,1) + R * out / max(out(:));
            img(:,:,2) = img(:,:,2) + G * out / max(out(:));
            img(:,:,3) = img(:,:,3) + B * out / max(out(:));
        end
    end





    % draw
    if ~isempty(img)
        handles.image_handle = imshow(img, 'InitialMagnification', 'fit');
    end


    if handles.is_semiauto
        handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
    else
    %     handles = slider_callbacks_draw_image_slice_dots_maingui(handles);

        cg = handles.embryo.getCellGraph(T, Z);


        % draw centroids of active Cells
        if ~isempty(handles.activeCell)

            % make a javaarray
            activecells = javaArray('Cell', length(handles.activeCell));
            if get(handles.button_manually_select_cells, 'Value')
                for i = 1:length(handles.activeCell)
                    activecells(i) = cg.getCell(handles.activeCell(i));
                end
                cents = Cell.centroidStack(activecells);
                        xplot = [cents(:, 2) NaN(size(cents, 1), 1)].';
                yplot = [cents(:, 1) NaN(size(cents, 1), 1)].';
                plot(xplot, yplot, '.');

            else
                the_cell = cg.getCell(handles.activeCell);
                if ~isempty(the_cell)
                
                    cents = the_cell.centroidInt;
                    cents = cents(:).';  % make it a row vector
                    plot(cents(:,2), cents(:,1), '.r');

                    % neighbors
                    if ~isempty(handles.activeCellNeighbors)
                        for i = 1:length(handles.activeCellNeighbors)
                            % this is already a java array, very conveniently. so I can
                            % immediately pass it to Cell.centroidStack(Cell[] )
                            activeneighbors = cg.getCell(handles.activeCellNeighbors{i});

                            if ~isempty(activeneighbors)
                                cents = round(Cell.centroidStack(activeneighbors));
                                plot(cents(:, 2), cents(:, 1), '.', 'Color', my_colors(i+1));  % +1 to skip red because the center is already red
                            end

                        end
                    end
                end
            end
        end

    end
    
    
    
    
    % plot the polygons
    % uses gplot, the function for plotting graphs
    % this method works much faster than any other i have tried (several)
    if handles.is_semiauto
        if ~isempty(handles.embryo.getCellGraph(T, Z))
            
%             % try plotting all the centroids
%             cents = Cell.centroidStack(handles.embryo.getCellGraph(T, Z).cells);
%             xplot = [cents(:, 2) NaN(size(cents, 1), 1)].';
%             yplot = [cents(:, 1) NaN(size(cents, 1), 1)].';
%             plot(xplot, yplot, '*r', 'MarkerSize', 3);
            
            
            if handles.embryo.isTracked  % if it's tracked
                
                if get(handles.cbox_poly, 'Value')
%                     img(:,:,3) = img(:,:,3) + handles.embryo.getCellGraph(T, Z).drawActive;
                    if handles.embryo.getCellGraph(T, Z).numActiveCells > 0
                        CMS = double(handles.embryo.getCellGraph(T, Z).connectivityMatrixVertexSparseActive);
                        numV = handles.embryo.getCellGraph(T, Z).numActiveVertices;
                        sparseCM = sparse(CMS(1, :), CMS(2, :), 1, numV, numV);
                        gplot2(sparseCM, fliplr(Vertex.coords(handles.embryo.getCellGraph(T, Z).activeVertices)), 'm'); % 'LineWidth', 2
                    end
                end
                if get(handles.cbox_inactive, 'Value')  % if you want to draw inactive cells
%                     img(:,:,1) = img(:,:,1) +
%                     (handles.embryo.getCellGraph(T, Z).draw - handles.embryo.getCellGraph(T, Z).drawActive);
%                     img(:,:,1) = img(:,:,1) +
%                     handles.embryo.getCellGraph(T, Z).drawInactive;
                    if handles.embryo.getCellGraph(T, Z).numInactiveCells > 0
                        CMS = double(handles.embryo.getCellGraph(T, Z).connectivityMatrixVertexSparseInactive);
                        numV = handles.embryo.getCellGraph(T, Z).numInactiveVertices;
                        sparseCM = sparse(CMS(1, :), CMS(2, :), 1, numV, numV);
                        gplot2(sparseCM, fliplr(Vertex.coords(handles.embryo.getCellGraph(T, Z).inactiveVertices)), '--y');
                    end
                    
                end
            elseif get(handles.cbox_poly, 'Value')
%                     img(:,:,3) = img(:,:,3) + handles.embryo.getCellGraph(T, Z).draw;
                if handles.embryo.getCellGraph(T, Z).numCells > 0
                    CMS = double(handles.embryo.getCellGraph(T, Z).connectivityMatrixVertexSparse);
                    numV = handles.embryo.getCellGraph(T, Z).numVertices;
                    sparseCM = sparse(CMS(1, :), CMS(2, :), 1, numV, numV);
                    gplot(sparseCM, fliplr(Vertex.coords(handles.embryo.getCellGraph(T, Z).vertices)), 'm');
                end
            end            
        else
%             img(:,:,3) = img(:,:,3) + imagestripe(handles.info.Ys, handles.info.Xs);
        end
    elseif get(handles.cbox_poly, 'Value')  % for EDGE browser
%         img(:,:,3) = img(:,:,3) + handles.embryo.getCellGraph(T, Z).drawActive;
        if handles.embryo.getCellGraph(T, Z).numActiveCells > 0
            CMS = double(handles.embryo.getCellGraph(T, Z).connectivityMatrixVertexSparseActive);
            numV = handles.embryo.getCellGraph(T, Z).numActiveVertices;
            sparseCM = sparse(CMS(1, :), CMS(2, :), 1, numV, numV);
            gplot2(sparseCM, fliplr(Vertex.coords(handles.embryo.getCellGraph(T, Z).activeVertices)), 'm');
        end
    end


