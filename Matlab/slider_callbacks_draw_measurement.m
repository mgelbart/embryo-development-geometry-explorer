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


function slider_callbacks_draw_measurement(handles)

axes(handles.axes3);
cla; hold on;


if isempty(handles.activeCell)
    return;
end


% set(handles.text_readyproc, 'String', 'Drawing');
% set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
% drawnow;

[T Z] = getTZ(handles);

% plots the data
totaldata = [];  % can define size of this later



% get the measure name from the dropdown menu
dropdown_val = get(handles.dropdown_measurements, 'Value');
    
    
if handles.fixed
    x_vals = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer;
    x_vals = x_vals * handles.info.microns_per_z_step;
    x_vals = x_vals(:);
    
    if get(handles.button_manually_select_cells, 'Value')  % multiple cells selected
        
        totaldata = zeros(abs(handles.info.top_layer-handles.info.bottom_layer)+1, length(handles.activeCell));
        for i = 1:length(handles.activeCell)
            [data name units] = get_measurement_data_TZ(...
                handles, dropdown_val, handles.activeCell(i));%, handles.info.start_time, handles.info.end_time, ...
%                 handles.info.bottom_layer, handles.info.top_layer);           
%             plot(x_vals, data, 'r'); % data should be 1-dimensional
            data = convert_cell_data_to_numerical(data);
            totaldata(:, i) = data(:);
        end
        
        if get(handles.radiobutton_neighbors_averages, 'Value') % if we need to average
            plot(x_vals, my_mean(totaldata), 'k');
        else
            plot(x_vals, totaldata);
        end
    else  % single cell selected
        [data name units] = get_measurement_data_TZ(...
            handles, dropdown_val, handles.activeCell);%, handles.info.start_time, handles.info.end_time, ...
%             handles.info.bottom_layer, handles.info.top_layer);   
        data = convert_cell_data_to_numerical(data);
        plot(x_vals, data, 'r'); % data should be 1-dimensional
        
        % plot the measurements for the neighbors as well
        if ~isempty(handles.activeCellNeighbors)    
            for i = 1:length(handles.activeCellNeighbors)
                totaldata = zeros(abs(handles.info.top_layer-handles.info.bottom_layer)+1, length(handles.activeCellNeighbors{i}));
                for j = 1:length(handles.activeCellNeighbors{i})
                    [data name units] = get_measurement_data_TZ(...
                        handles, dropdown_val, handles.activeCellNeighbors{i}(j));%, handles.info.start_time, handles.info.end_time, ...
%                         handles.info.bottom_layer, handles.info.top_layer);           
                    data = convert_cell_data_to_numerical(data);
                    totaldata(:, j) = data(:);
                end
                if get(handles.radiobutton_neighbors_averages, 'Value') % if we need to average
                    plot(x_vals, my_mean(totaldata), 'Color', my_colors(i+1));
                else
                    plot(x_vals, totaldata, 'Color', my_colors(i+1));
                end
            end
        end
        
    end

    title(strcat(name, ' vs. depth'));    
    % plot a dashed black line to indicate the current x_vals
    axisvals = axis;
    dz = handles.info.microns_per_z_step;
    plot(Z*[dz dz], [axisvals(3) axisvals(4)], '--k');  
    xlabel 'height (microns)';
        
else  % time series
    
    x_vals = handles.info.start_time:handles.info.end_time;
    x_vals = x_vals * handles.info.seconds_per_frame / 60;
    x_vals = x_vals(:);
    
    if get(handles.button_manually_select_cells, 'Value')  % for multiple cells
    
        totaldata = zeros(abs(handles.info.end_time-handles.info.start_time)+1, length(handles.activeCell));
        for i = 1:length(handles.activeCell)

            [data name units] = get_measurement_data_TZ(...
                handles, dropdown_val, handles.activeCell(i));%, handles.info.start_time, handles.info.end_time, ...
%                 Z, Z);
            data = data(:, handles.embryo.translateZ(Z)+1);
            data = convert_cell_data_to_numerical(data);
            totaldata(:, i) = data(:);
        end
        
        if get(handles.radiobutton_neighbors_averages, 'Value') % if we need to average
            plot(x_vals, my_mean(totaldata), 'k');
        else
            plot(x_vals, totaldata);
        end
        title(strcat(name, ' vs time for each selected cell at the current depth'));
    else  % just one cell selected
        
        % in this case, it's a bit tricky. if there are no neighbors, we do
        % something special and plot all layers, with red-->blue
        % representing top-->bottom. however, if there are neighbors we
        % skip this and just plot the middle cell at this current depth,
        % and the same goes for all the neighbors
        if isempty(handles.activeCellNeighbors)
            [data name units] = get_measurement_data_TZ(...
                handles, dropdown_val, handles.activeCell);%, handles.info.start_time, handles.info.end_time, ...
%                 handles.info.bottom_layer, handles.info.top_layer);
            data = convert_cell_data_to_numerical(data);
            
            % if we are on averages, we average over all layers!!
            if get(handles.radiobutton_neighbors_averages, 'Value')
                plot(x_vals, my_mean(data), 'k');
                title(strcat(name, ' vs. time averaged over all depths'));
            else
                if size(data, 2) == 1
                    plot(x_vals, data, 'r');
                else
                    for j = 1:size(data, 2)
                        col = [(j-1)/(size(data,2)-1), 0, 1-(j-1)/(size(data,2)-1)];
                        plot(x_vals, data(:, j), 'Color', col);
                    end
                end
                title(strcat(name, ' vs. time for each depth (red = top, blue = bottom)'));    
            end
        else
            % in the neighbors case, we first need to plot the active
            % (middle) cell in the non-special way (i.e., we just want this
            % layer, not all layers), and then we plot all the neighbors as
            % well.
            [data name units] = get_measurement_data_TZ(...
                handles, dropdown_val, handles.activeCell);%, handles.info.start_time, handles.info.end_time, ...
%                 Z, Z);   
            data = data(:, handles.embryo.translateZ(Z)+1);
            data = convert_cell_data_to_numerical(data);
            plot(x_vals, data, 'r'); % data should be 1-dimensional
            
            % now we plot for all the neighbors
            for i = 1:length(handles.activeCellNeighbors)
                totaldata = zeros(abs(handles.info.end_time-handles.info.start_time)+1, length(handles.activeCellNeighbors{i}));
                for j = 1:length(handles.activeCellNeighbors{i})
                    [data name units] = get_measurement_data_TZ(...
                        handles, dropdown_val, handles.activeCellNeighbors{i}(j));%, handles.info.start_time, handles.info.end_time, ...
%                         Z, Z);           
                    data = data(:, handles.embryo.translateZ(Z)+1);
                    data = convert_cell_data_to_numerical(data);
                    totaldata(:, j) = data(:);
                end
                if get(handles.radiobutton_neighbors_averages, 'Value') % if we need to average
                    plot(x_vals, my_mean(totaldata), 'Color', my_colors(i+1));
                else
                    plot(x_vals, totaldata, 'Color', my_colors(i+1));
                end
            end
        end
        
        
    end
    

    % plot a dashed black line to indicate the current time
    axisvals = axis;
    dt = handles.info.seconds_per_frame / 60;
    plot(T*[dt dt], [axisvals(3) axisvals(4)], '--k');
    xlabel 'time (min)';
end




% sets the y-axis label
ylab = strcat('Cell ', name, '(', units);
if get(handles.button_rate_of_change, 'Value')
    ylab = strcat(ylab, '/min');
end
ylab = strcat(ylab, ')');
ylabel(ylab);
legend('off');


% set the y-axis to user-specified values
yaxismin = str2double(get(handles.axis_min, 'String'));
yaxismax = str2double(get(handles.axis_max, 'String'));
if ~isnan(yaxismin) && ~isnan(yaxismax)
    axis([min(x_vals) max(x_vals) yaxismin yaxismax]);
elseif ~isnan(yaxismin)  % only fix the minimum
    cur = ylim;
    if yaxismin < cur(2)
        ylim([yaxismin cur(2)]);
    else
        ylim('auto');
    end
elseif ~isnan(yaxismax)  % only fix the maximum
    cur = ylim;
    if yaxismax > cur(1)
        ylim([cur(1) yaxismax]);
    else
        ylim('auto');
    end
else
    ylim('auto');
end
xlim([min(x_vals) max(x_vals)]);



hold off;


% set(handles.text_readyproc, 'String', 'Ready');
% set(handles.text_readyproc, 'ForegroundColor', [0 1 0]);

