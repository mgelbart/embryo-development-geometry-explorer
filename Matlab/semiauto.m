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


% The main file for the semiauto GUI. The other part of the interface is
% EDGE.m.

function varargout = semiauto(varargin)
    % SEMIAUTO M-file for semiauto.fig
    %      SEMIAUTO, by itself, creates a new SEMIAUTO or raises the existing
    %      singleton*.
    %
    %      H = SEMIAUTO returns the handle to a new SEMIAUTO or the handle
    %      to
    %      the existing singleton*.
    %
    %      SEMIAUTO('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in SEMIAUTO.M with the given input arguments.
    %
    %      SEMIAUTO('Property','Value',...) creates a new SEMIAUTO or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before semiauto_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to semiauto_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help semiauto

    % Last Modified by GUIDE v2.5 15-Jan-2011 21:13:49

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @semiauto_OpeningFcn, ...
                       'gui_OutputFcn',  @semiauto_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT


% --- Executes just before semiauto is made visible.
function semiauto_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to semiauto (see VARARGIN)
    clc;
    handles.file_ext = 'tif';
    
    % info from EDGE, if you got here by switching
    if ~isempty(varargin) && length(varargin) > 1
        passinfo = varargin{2};
%         axesinfo = varargin{3};
    else
        passinfo = [];
    end
    
    
    % use an absolute path for source so you can change directories while running the gui
    main_dir = mfilename('fullpath');
    this_filename = mfilename;
    main_dir = main_dir(1:end-length(this_filename));
    cd(main_dir);
    
    %%% read the names of the Data Sets!!!!
    datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
    
    if ~isempty(datanames)    
        set(handles.dropdown_datasets, 'String', datanames);
        %%%

        % default data set
        if ~isempty(passinfo)
            default_data_set = passinfo.data_set;
            % set the dropdown to be at the right thing
            val = find(strcmp(datanames, passinfo.data_set));
            set(handles.dropdown_datasets, 'Value', val);    
            % make sure we're in the right directory
            cd(main_dir);
        else
            default_data_set_number = 1;
            default_data_set = datanames{default_data_set_number};  % just take the first one
            set(handles.dropdown_datasets, 'Value', default_data_set_number);
        end


        handles = clear_data_set_semiauto(handles, default_data_set);

        % if there are arguments passed in (i.e., if we switched from EDGE)
        % then set them here
        if ~isempty(passinfo)
            set(handles.t_slider, 'Value', passinfo.t_slider);
            t_slider_Callback(hObject, [], handles);
            set(handles.z_slider, 'Value', passinfo.z_slider);
            z_slider_Callback(hObject, [], handles);
        end
    else   % if it's the first data set
        % no point putting a msgbox here because the gui loads on
        % top of it and you can't see it anyway
        handles = handles_set_program_dir(handles);
    end
       
    
    % initialize the image (after the data box is checked!)
    set(hObject,'toolbar','figure');

    % if you press a key, run keyFunction (defined by me)
    have_KeyPressFcn = findobj('KeyPressFcn', '');
    for i = 1:length(have_KeyPressFcn)
        set(have_KeyPressFcn(i), 'KeyPressFcn', @keyFunction);
    end
    
    set(handles.figure1,'CloseRequestFcn',@closeGUI)  
    set(handles.figure1,'WindowButtonUpFcn',@mouseFunction);
%     set(handles.axes1, 'ButtonDownFcn', @mouseFunction);

    set(handles.panel_vec_cell_vert,'SelectionChangeFcn', @vec_select_cv_change);
    set(handles.panel_vec_manual_auto,'SelectionChangeFcn', @vec_select_auto_change);
    
    % the below lines mess up proportional resizing
%     set(handles.axes1, 'Units', 'pixels');
%     set(handles.figure1, 'Units', 'pixels');
%     set(handles.main_panel, 'Units', 'pixels');
   
    % Choose default command line output for semiauto2
    handles.output = hObject;

    set(hObject,'toolbar','figure');
    % Update handles structure

    guidata(hObject, handles);
     
    % UIWAIT makes semiauto wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

function closeGUI(hObject, eventdata) %#ok<*INUSD>
    handles = guidata(hObject);
   
    % for debugging purposes, make sure you're in the current directory at
    % this time
    cd(fullfile(handles.program_dir, 'Matlab'));
    
    if isfield(handles, 'data_set') % if you've never imported anything, don't do a check
        try  % want to let it close even if there's an error!!
            handles = exit_data_set_semiauto(handles);
        end
    end
    
    % close the GUI
    delete(handles.figure1);

    
    
function keyFunction(hObject, eventdata)
    %keyPressFcn automatically takes in two inputs
    %src is the object that was active when the keypress occurred
    %evnt stores the data for the key pressed

    %brings in the handles structure in to the function
    handles = guidata(hObject);

    k = eventdata.Key; %k is the key that is pressed

%     disp(k)

    switch k
        case 'semicolon'  % time slider to the left by 1
           
            hObject = handles.t_slider; 

            sliderValue = get(handles.t_slider,'Value');
            if sliderValue-1 >= get(handles.t_slider, 'Min')
                set(handles.t_slider, 'Value', sliderValue-1);

                %call the add pushbutton callback.  
                %the middle argument is not used for this callback
                t_slider_Callback(hObject, [], handles);
            end
        case 'quote'  % time slider to the right by 1
            hObject = handles.t_slider;

            sliderValue = get(handles.t_slider,'Value');
            if sliderValue+1 <= get(handles.t_slider, 'Max')
                set(handles.t_slider, 'Value', sliderValue+1);
                t_slider_Callback(hObject, [], handles);
            end
        case 'leftbracket'   % z  slider to the left by 1
            hObject = handles.z_slider;

            sliderValue = get(handles.z_slider,'Value');
            if sliderValue-1 >= get(handles.z_slider, 'Min')        
                set(handles.z_slider, 'Value', sliderValue-1);
                z_slider_Callback(hObject, [], handles);
            end
        case 'rightbracket'  % z slider to the right by 1
            hObject = handles.z_slider;

            sliderValue = get(handles.z_slider,'Value');

            if sliderValue+1 <= get(handles.z_slider, 'Max')        
                set(handles.z_slider, 'Value', sliderValue+1);
                z_slider_Callback(hObject, [], handles);
            end
        case 'q'  %'escape'  % quit the gui
            closeGUI = handles.figure1;
            close(closeGUI);
        case 'c'  % switch to selecting cells
            set(handles.radiobutton_adjust_cells, 'Value', 1);
            vec_select_cv_change(hObject, eventdata);
        case 'v'  % switch to selecting vertices
            set(handles.radiobutton_adjust_vertices, 'Value', 1);
            vec_select_cv_change(hObject, eventdata);
        case {'1', 'hyphen'}
            % it is smart and realizes what you want based on what's
            % selected
            if get(handles.radiobutton_adjust_cells, 'Value') && ...
                    ~isempty(handles.activeCell)
                vec_remove_cell_Callback(hObject, eventdata, handles);
            elseif get(handles.radiobutton_adjust_vertices, 'Value') && ...
                    length(handles.activeVertex) == 2
                vec_remove_edge_Callback(hObject, eventdata, handles);
            elseif get(handles.radiobutton_adjust_vertices, 'Value') && ...
                    (length(handles.activeVertex) == 1 || ...
                     length(handles.activeVertex) > 2)
                 vec_remove_vertex_Callback(hObject, eventdata, handles);
            end        
        case 'equal'  % for +
            if get(handles.radiobutton_adjust_vertices, 'Value') && ...
                    length(handles.activeVertex) == 2
                vec_add_edge_Callback(hObject, eventdata, handles);
%             elseif get(handles.radiobutton_adjust_vertices, 'Value')
%                 vec_add_vertex_Callback(hObject, eventdata, handles);
            end
        case 'm'
            if get(handles.radiobutton_adjust_vertices, 'Value') && ...
                    length(handles.activeVertex) == 1
                vec_move_vertex_Callback(hObject, eventdata, handles);
            end
        case 'f'
            if get(handles.radiobutton_adjust_vertices, 'Value') && ...
                    length(handles.activeVertex) == 2
                vec_split_edge_Callback(hObject, eventdata, handles);
            end
        case 'a'
            if get(handles.radiobutton_adjust_cells, 'Value') && ...
                    ~isempty(handles.activeCell)
                vec_activate_cell_Callback(hObject, eventdata, handles);
            end
        case 's'
            vec_select_all_Callback(hObject, eventdata, handles);
        case 'u'
            vec_unselect_all_Callback(hObject, eventdata, handles);
        case 'return'
            if ~isempty(handles.activeAdjustment)
                button_vec_cancel_Callback(hObject, eventdata, handles);
            end
        otherwise
          % nothing
    end
    
function mouseFunction(hObject,evnt)
    handles = guidata(hObject);
    [T Z] = getTZ(handles);

    % only select a cell if the polygon mode is on
    if ~get(handles.cbox_poly, 'Value');
        return
    end
    if isempty(handles.embryo.getCellGraph(T, Z))
        return
    end
    
    
    Ys = handles.info.Ys; Xs = handles.info.Xs;
    [location whichbutton] = get_mouse_location_zoom(handles);
    
    % make sure we're in the figure
    if location(1) > Ys || location(1) < 1 || location(2) > Xs || location(2) < 1
        return
    end
    
    if strcmp(handles.activeAdjustment, 'split_edge')
        % we know there are exactly 2 active Vertices if this button is
        % pressed
        vert1 = handles.activeVertex{1};
        vert2 = handles.activeVertex{2};

        newVert = handles.embryo.getCellGraph(T, Z).splitEdge(vert1, vert2, location);
        
%         save_embryo(handles);
        
%         handles.activeVertex{3} = newVert;
        handles.activeVertex = [];

        handles.activeAdjustment = [];
        vec_adjustments_visible(handles, 'on');
        
        handles = slider_callbacks_draw_image_slice(handles);
        
    elseif strcmp(handles.activeAdjustment, 'move_vertex')
        vert = handles.activeVertex{1};
%         vert.move(location);
        handles.embryo.getCellGraph(T, Z).moveVertex(vert, location);

        handles.activeVertex = [];

%         save_embryo(handles);
%         tempcg = handles.tempcg;
%         [T Z] = getTZ(handles);
%         filename = handles.info.image_file(T, Z, handles.tempsrc.poly); 
%         save(chgext(filename, 'none'), 'tempcg');

        handles.activeAdjustment = [];
        vec_adjustments_visible(handles, 'on');
        
        handles = slider_callbacks_draw_image_slice(handles);
        
% the regular case of selecting a cell
    elseif get(handles.radiobutton_adjust_cells, 'Value')
        newCell = handles.embryo.getCellGraph(T, Z).cellAtPoint(location);
        if isempty(newCell) % clicked outside the polygons
            return;
        end
        
        addCell = 1;
        % if you click on the same cell it unselects
        if ~isempty(handles.activeCell)
            for i = 1:length(handles.activeCell)
              if handles.activeCell(i) == newCell.index
                  handles.activeCell(i) = [];
                  addCell = 0;
                  break;
              end
            end
        end
        if addCell
            handles.activeCell(length(handles.activeCell)+1) = newCell.index;
        end
        
        handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
% the regular case of selecting a vertex
    elseif get(handles.radiobutton_adjust_vertices, 'Value')
        VERTEX_CLICK_DIST_THRESH = Inf; % just take the closest one
        newVertex = handles.embryo.getCellGraph(T, Z).vertexAtPoint(location, VERTEX_CLICK_DIST_THRESH);
        if isempty(newVertex) 
            return
        end
        addVertex = 1;
        % if you click on the same Vertex it unselects
        for i = 1:length(handles.activeVertex)
            if handles.activeVertex{i} == newVertex
                handles.activeVertex(i) = [];
                addVertex = 0;
                break;
            end
        end

        if addVertex
            handles.activeVertex{length(handles.activeVertex)+1} = newVertex;
        end
        
        handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
    end
    
    % if you selected any vertices or cells, you probably want manual
    % adjustments
    if ~isempty(handles.activeCell) || ~isempty(handles.activeVertex)
        set(handles.radiobutton_vec_manual, 'Value', 1);
        semiauto_set_vec_enabling(handles);
    end
        
    
    
    % do the cell text thing
    if length(handles.activeCell) == 1
        set(handles.cell_text, 'String', num2str(handles.activeCell(1))); 
    else
        set(handles.cell_text, 'String', '-'); 
    end
    
    guidata(hObject, handles);
 
    
% --- Outputs from this function are returned to the command line.
function varargout = semiauto_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_applythis.
function button_applythis_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
    handles.activeCell = [];    
    [T Z] = getTZ(handles);

    readyproc(handles, 'proc');
    
    [bord tempcg] = semiauto_preprocess(handles, T, Z);
    
    filename_bord = handles.info.image_file(T, Z, handles.tempsrc.bord);
    imwrite(bord, filename_bord, handles.file_ext);
    
    if tempcg.numCells == 0
        msgbox('There are no cells in this image. This may cause tracking errors; please try other image processing parameters.', ...
            'No cells in image');
        uiwait;
    end
    
    readyproc(handles, 'tracking');
    handles.embryo.addCellGraph(tempcg, T, Z);
    readyproc(handles, 'ready');
%     save_embryo(handles);

    handles = semiauto_change_image_callbacks(handles);
    
    % redraw the new image
    handles = slider_callbacks_draw_image_slice(handles);    
    
    readyproc(handles, 'ready');
    guidata(hObject, handles);

    
    

function button_applysome_Callback(hObject, eventdata, handles)
    q = query_for_image_subset(); 

    % if some images are already processed, then ask about overwriting
    if ~handles.embryo.isEmpty
            res = questdlg(['Some images are already processed. Overwrite or keep these? ' ...
                'Note: if yes, all overwritten CellGraphs will be deleted immediately.'], ...
                          'Overwrite processed images?', 'Overwrite', 'Keep', 'Cancel', 'Overwrite');
        switch res
            case 'Cancel'
                return;
            case 'Overwrite'
                overwrite_ok = 1;
            case 'Keep'
                overwrite_ok = 0;
        end
    else
        overwrite_ok = 0;
    end
    
    % remove the cell graphs that you are going to overwrite
    % that way it won't do tracking each time
    if overwrite_ok
        for time_i = q.t_do_range(1):q.t_do_range(2)
        % in case they specify to skip anything
            if time_i >= q.t_skip_range(1) && time_i <= q.t_skip_range(2)
                continue;
            end

            for layer_i = q.z_do_range(1):q.z_do_range(2)
                % in case they specify to skip anything
                if layer_i >= q.z_skip_range(1) && layer_i <= q.z_skip_range(2)
                    continue;
                end            

                % skip those that are already processed if the user
                % specified this
                if ~overwrite_ok && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
    %                 if time_i == handles.info.master_time && layer_i == handles.info.master_layer && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
                    continue;
                end
                
                handles.embryo.removeCellGraph(time_i, layer_i);
            end
        end
  
    end
    

    handles.activeCell = [];
    readyproc(handles, 'proc_all');  
    badimages = '';
    for time_i = q.t_do_range(1):q.t_do_range(2)
        % in case they specify to skip anything
        if time_i >= q.t_skip_range(1) && time_i <= q.t_skip_range(2)
            continue;
        end
        
        for layer_i = q.z_do_range(1):q.z_do_range(2)
            % in case they specify to skip anything
            if layer_i >= q.z_skip_range(1) && layer_i <= q.z_skip_range(2)
                continue;
            end            

            % skip those that are already processed if the user
            % specified this
            if ~overwrite_ok && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
%                 if time_i == handles.info.master_time && layer_i == handles.info.master_layer && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
                continue;
            end
            
            

            set(handles.text_processing_time,  'String', num2str(time_i));
            set(handles.text_processing_layer, 'String', num2str(layer_i));
            drawnow;

            if get(handles.radiobutton_stop, 'Value')
                set(handles.radiobutton_stop, 'Value', 0);
                readyproc(handles, 'ready');
                guidata(hObject, handles);
                return;
            end

            [bord tempcg] = semiauto_preprocess(handles, time_i, layer_i);
            filename_bord = handles.info.image_file(time_i, layer_i, handles.tempsrc.bord);
            imwrite(bord, filename_bord, handles.file_ext);

            % readproc tracking?
            handles.embryo.addCellGraph(tempcg, time_i, layer_i);
%                 filename_poly = handles.info.image_file(time_i, layer_i,
%                 handles.tempsrc.poly);
%                 save(chgext(filename_poly, 'none'), 'tempcg'); % remove
%                 the extension

            if tempcg.numCells == 0
                badimages = strcat(badimages, '(t = ', num2str(time_i), ', z = ', num2str(layer_i), '); ');
            end
        end
        
        % must save here, because as soon as you move on to the next
        % embryo, all the work on the current embryo is lost!!
        save_embryo(handles);
               
    end
    set(handles.text_readyproc_details, 'Visible', 'off');

    if ~isempty(badimages)
        msgbox(strcat('The following images have no cells: ', badimages, ...
            'Please fix these images and try again.'), ...
            'Tracking aborted', 'error');
        uiwait;
%         return;
    end
        
    handles = semiauto_change_image_callbacks(handles);
    
    % redraw the new image
    handles = slider_callbacks_draw_image_slice(handles);
    
    readyproc(handles, 'ready');
    guidata(hObject, handles);
    
        
        

function button_applyall_Callback(hObject, eventdata, handles)
   
    % allows you to applyall for multiple data sets at once
    datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
    default_val = find(strcmp(datanames, handles.data_set));
    if length(datanames) > 1
        [selection ok] = listdlg('ListString', datanames, 'Name', 'Select data sets for processing', ...
            'ListSize', [300 300], 'InitialValue', default_val);
        if ~ok
            return;
        end
        
    else
        selection = default_val;
    end
    data_set = handles.data_set;
    
    if length(selection) == 1
    % if some images are already processed, then ask about overwriting
        if ~handles.embryo.isEmpty
            res = questdlg(['Some images are already processed. Overwrite or keep these? ' ...
                'Note: if yes, all overwritten CellGraphs will be deleted immediately.'], ...
                          'Overwrite processed images?', 'Overwrite', 'Keep', 'Cancel', 'Overwrite');
            switch res
                case 'Cancel'
                    return;
                case 'Overwrite'
                    overwrite_ok = 1;
                case 'Keep'
                    overwrite_ok = 0;
            end
        else
            overwrite_ok = 0;
        end
    else
        % if some images are already processed, then ask about overwriting
        if ~handles.embryo.isEmpty
            res = questdlg('Some images in some of these data sets may already be processed. Overwrite or keep these?', ...
                          'Overwrite processed images?', 'Overwrite', 'Keep', 'Cancel', 'Overwrite');
            switch res
                case 'Cancel'
                    return;
                case 'Overwrite'
                    overwrite_ok = 1;
                case 'Keep'
                    overwrite_ok = 0;
            end
        end
    end
    
   
    
    % do it for all data sets~~~
    for i = 1:length(selection)
        if ~strcmp(data_set, datanames{selection(i)})
            handles = clear_data_set_semiauto(handles, datanames{selection(i)});
        end
        set(handles.text_readyproc_details, 'String', datanames{selection(i)});
        set(handles.text_readyproc_details, 'Visible', 'on');
             
        
        % if the user selected to overwrite images that are already processed,
        % then first delete all the CellGraphs that are already processed. 
        % the reason is that if you don't delete them, then every time you
        % overwrite a single CellGraph, the Embryo4D is "full" and so
        % re-tracks the entire data set at each step. But there is no point
        % re-tracking until the entire Embryo is processed, namely when it
        % gets full at the last CellGraph
        if overwrite_ok
            handles.embryo.removeAllCellGraphs; 
        end
        
        
        handles.activeCell = [];

        readyproc(handles, 'proc_all');  

        badimages = '';
        for time_i = handles.info.start_time:handles.info.end_time
            
            for layer_i = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                
                % skip those that are already processed if the user
                % specified this
                if ~overwrite_ok && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
%                 if time_i == handles.info.master_time && layer_i == handles.info.master_layer && ~isempty(handles.embryo.getCellGraph(time_i, layer_i))
                    continue;
                end
                
                set(handles.text_processing_time,  'String', num2str(time_i));
                set(handles.text_processing_layer, 'String', num2str(layer_i));
                drawnow;

                if get(handles.radiobutton_stop, 'Value')
                    set(handles.radiobutton_stop, 'Value', 0);
                    readyproc(handles, 'ready');
                    guidata(hObject, handles);
                    return;
                end

                [bord tempcg] = semiauto_preprocess(handles, time_i, layer_i);
                filename_bord = handles.info.image_file(time_i, layer_i, handles.tempsrc.bord);
                imwrite(bord, filename_bord, handles.file_ext);
                
                % readproc tracking?
                handles.embryo.addCellGraph(tempcg, time_i, layer_i);
%                 filename_poly = handles.info.image_file(time_i, layer_i,
%                 handles.tempsrc.poly);
%                 save(chgext(filename_poly, 'none'), 'tempcg'); % remove
%                 the extension
                
                if tempcg.numCells == 0
                    badimages = strcat(badimages, '(t = ', num2str(time_i), ', z = ', num2str(layer_i), '); ');
                end
            end
        end
        % must save here, because as soon as you move on to the next
        % embryo, all the work on the current embryo is lost!!
        save_embryo(handles);
               
    end
    set(handles.text_readyproc_details, 'Visible', 'off');
    if ~strcmp(handles.data_set, data_set)
        % go back to the original data set
        handles = clear_data_set_semiauto(handles, data_set);
    end
    if ~isempty(badimages)
        msgbox(strcat('The following images have no cells: ', badimages, ...
            'Please fix these images and try again.'), ...
            'Tracking aborted', 'error');
%         return;
    end
        
    handles = semiauto_change_image_callbacks(handles);
    
    % redraw the new image
    handles = slider_callbacks_draw_image_slice(handles);
    
    readyproc(handles, 'ready');
    guidata(hObject, handles);
    


% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
    sliderValue = get(handles.z_slider,'Value');
    sliderValue = round(sliderValue);
    set(handles.z_slider, 'Value', sliderValue);
    
    %puts the slider value into the edit text component
    
    showValue = handles.info.bottom_layer - sliderValue * ...
        sign(handles.info.bottom_layer - handles.info.top_layer);

    set(handles.z_text,'String', num2str(showValue));

    handles = semiauto_change_image_callbacks(handles);
    
    handles = slider_callbacks_draw_image_slice(handles);
    
%     set(hObject,'toolbar','figure');
    % Update handles structure
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


% --- Executes on slider movement.
function t_slider_Callback(hObject, eventdata, handles)
    sliderValue = get(handles.t_slider,'Value');
    sliderValue = round(sliderValue);
    set(handles.t_slider, 'Value', sliderValue);

    %puts the slider value into the edit text component
    showValue = handles.info.start_time + sliderValue * ...
        sign(handles.info.end_time - handles.info.start_time);
    
    set(handles.t_text,'String', num2str(showValue));

    handles = semiauto_change_image_callbacks(handles);
    
    handles = slider_callbacks_draw_image_slice(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function t_slider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


% --- Executes on selection change in dropdown_datasets.
function dropdown_datasets_Callback(hObject, eventdata, handles)
    all_datasets = get(handles.dropdown_datasets, 'String');
    new_dataset_number = get(handles.dropdown_datasets, 'Value');
    new_dataset = all_datasets{new_dataset_number};

    if strcmp(new_dataset, handles.data_set)
        return;  % if you selected the same one, do nothing
    end
    
    handles = exit_data_set_semiauto(handles);

    handles = clear_data_set_semiauto(handles, new_dataset);
    
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

    

% --- Executes during object creation, after setting all properties.
function dropdown_datasets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdown_datasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbox_raw.
function cbox_raw_Callback(hObject, eventdata, handles)
    val1 = get(handles.cbox_raw, 'Value');
    val2 = get(handles.cbox_bord,'Value');
    val3 = get(handles.cbox_poly,'Value');
    val4 = get(handles.cbox_inactive,'Value');
    val5 = get(handles.cbox_other,'Value');
    
    if ~(val1 || val2 || val3 || val4 || val5)
        set(handles.cbox_raw, 'Value', 1);
    else
        handles = slider_callbacks_draw_image_slice(handles);
    end

% --- Executes on button press in cbox_poly.
function cbox_poly_Callback(hObject, eventdata, handles)
    val1 = get(handles.cbox_raw, 'Value');
    val2 = get(handles.cbox_bord,'Value');
    val3 = get(handles.cbox_poly,'Value');
    val4 = get(handles.cbox_inactive,'Value');
    val5 = get(handles.cbox_other,'Value');
    
    if ~(val1 || val2 || val3 || val4 || val5)
        set(handles.cbox_poly, 'Value', 1);
    else
        % if turning off, get rid of active Cells in handles.activeCells
        if ~val3 && ~isempty(handles.activeCell)
%             [T Z] = getTZ(handles);
%             activecells = javaArray('Cell', length(handles.activeCell));
%             for i = 1:length(handles.activeCell)
%                 activecells(i) = cg.getCell(handles.activeCell(i));
% %                 activecells(i) = handles.activeCell{i};
%             end
%             handles.activeCell = Cell.index(handles.embryo.getCellGraph(T, Z).inactiveCells(activecells));
            handles.activeCell = [];
        end
        handles = slider_callbacks_draw_image_slice(handles);
    end
    guidata(hObject, handles);
        

% --- Executes on button press in cbox_bord.
function cbox_bord_Callback(hObject, eventdata, handles)
    val1 = get(handles.cbox_raw, 'Value');
    val2 = get(handles.cbox_bord,'Value');
    val3 = get(handles.cbox_poly,'Value');
    val4 = get(handles.cbox_inactive,'Value');
    val5 = get(handles.cbox_other,'Value');
    
    if ~(val1 || val2 || val3 || val4 || val5)
        set(handles.cbox_bord, 'Value', 1);
    else
        handles = slider_callbacks_draw_image_slice(handles);
    end
    
    
function cbox_inactive_Callback(hObject, eventdata, handles)
    if isempty(handles.embryo)
        set(handles.cbox_inactive, 'Value', 0);
        msgbox('You must export the data first.', 'Cannot show inactive cells');
        return;
    end
    
    val1 = get(handles.cbox_raw, 'Value');
    val2 = get(handles.cbox_bord,'Value');
    val3 = get(handles.cbox_poly,'Value');
    val4 = get(handles.cbox_inactive,'Value');
    val5 = get(handles.cbox_other,'Value');
    
    if ~(val1 || val2 || val3 || val4 || val5)
        set(handles.cbox_inactive, 'Value', 1);
    else
        if ~val4 && ~isempty(handles.activeCell)
%             [T Z] = getTZ(handles);
%             activecells = javaArray('Cell', length(handles.activeCell));
%             for i = 1:length(handles.activeCell)
%                 activecells(i) = handles.embryo.getCell(handles.activeCell(i), T, Z);
%             end
%             handles.activeCell = Cell.index(handles.embryo.getCellGraph(T, Z).activeCells(activecells)); 
            handles.activeCell = [];  % simpler...
        end 
        handles = slider_callbacks_draw_image_slice(handles);
    end
    guidata(hObject, handles);
    
    
    
    
function cbox_other_Callback(hObject, eventdata, handles)
    val1 = get(handles.cbox_raw,  'Value');
    val2 = get(handles.cbox_bord, 'Value');
    val3 = get(handles.cbox_poly, 'Value');
    val4 = get(handles.cbox_inactive,  'Value');
    val5 = get(handles.cbox_other,'Value');
    
    % you should not be able to click this if isempty(handles.channelnames)
    % but this seems to be happening  sometimes
    
    if ~(val1 || val2 || val3 || val4 || val5)
        set(handles.cbox_other, 'Value', 1);
        return;
    end
    
    % if you're turning it on
    if val5
        % if there's only one to choose from, automatically select that
        if length(handles.channelnames) == 1
            handles.activeChannels = 1;
        else
            % choose the set of channels
            [selection ok] = listdlg('ListString', handles.channelnames, 'Name', 'Select channel(s)');
            if ~ok
                return
            end
            handles.activeChannels = selection;
        end
    else % if you're turning it off
        handles.activeChannels = [];
    end

    handles = slider_callbacks_draw_image_slice(handles);
    
    guidata(hObject, handles);




function info_text_number_of_erosions_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);

function info_text_number_of_erosions_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function info_text_preprocessing_threshold_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
    
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);

function info_text_preprocessing_threshold_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function info_text_minimum_cell_size_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles); 

function info_text_minimum_cell_size_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function info_text_refine_max_angle_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
    
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles); 

function info_text_refine_max_angle_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function info_text_refine_min_angle_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles); 
    
function info_text_refine_min_angle_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_refine_min_edge_length_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles); 

function info_text_refine_min_edge_length_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function info_text_bandpass_high_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);


function info_text_bandpass_low_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
       
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);



function radiobutton_stop_Callback(hObject, eventdata, handles)
% nothing here --it's all done in the button_applyall_Callback



function button_export_Callback(hObject, eventdata, handles)
    % select which data sets to export
    datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
    default_val = find(strcmp(datanames, handles.data_set));
    if length(datanames) > 1
        [selection ok] = listdlg('ListString', datanames, 'Name', 'Select data sets for export', ...
            'ListSize', [300 300], 'InitialValue', default_val);
        if ~ok
            return;
        end
    else
        selection = default_val;
    end
    data_set = handles.data_set;
    
    % select which measurements to export (only for SINGLE export)
    if length(selection) == 1
        % change datasets immediately so that it gives the correct list of
        % measurements
        if ~strcmp(data_set, datanames{selection})
            handles = clear_data_set_semiauto(handles, datanames{selection});
        end
        [measurementchannelsall measurementnamesall] = get_measurement_file_names(handles);
        [selection_meas ok] = listdlg('ListString', strcat(measurementchannelsall, '--', measurementnamesall), ...
            'Name', 'Select measurements sets for export', 'ListSize', [300 300]);%, 'CancelString', 'None');
        if ~ok
            return;
%             measurementnames = cell(0);
%             measurementchannels = cell(0);
        else
            % the measurements array is the list of measurements that the user
            % selected
            measurementnames = cell(length(selection_meas), 1);
            measurementchannels = cell(length(selection_meas), 1);
            for i = 1:length(selection_meas)
                measurementnames{i} = measurementnamesall{selection_meas(i)};
                measurementchannels{i} = measurementchannelsall{selection_meas(i)};
            end
        end
    else    
    % get ALL measurements (even if none of these data sets can use them
        msgbox('When exporting multiple data sets at once, only applicable measurements will be computed for each data set.', 'Only applicable measurements computed'); 
        uiwait;
        [measurementchannelsall measurementnamesall] = get_measurement_file_names_specific_ch(...
            fullfile(handles.program_dir, 'Measurements'), ...
            handles.all_channelnames);
        % let the user slect
        [selection_meas ok] = listdlg('ListString', strcat(measurementchannelsall, '::', measurementnamesall), ...
            'Name', 'Select measurements sets for export', 'ListSize', [300 300], 'CancelString', 'None');
        if ~ok
            measurementnames_multi = cell(0);
            measurementchannels_multi = cell(0);
        else
            % the measurements array is the list of measurements that the user
            % selected
            measurementnames_multi = cell(length(selection_meas), 1);
            measurementchannels_multi = cell(length(selection_meas), 1);
            for i = 1:length(selection_meas)
                measurementnames_multi{i} = measurementnamesall{selection_meas(i)};
                measurementchannels_multi{i} = measurementchannelsall{selection_meas(i)};
            end
        end
%         msgbox('When exporting multiple data sets at once, all available measurements will be computed', 'All measurements computed'); 
    end
    %%%%
    
    
    for i = 1:length(selection)
        % if it's already at this data set, don't need to clear_data_set
        if ~strcmp(handles.data_set, datanames{selection(i)})
            handles = clear_data_set_semiauto(handles, datanames{selection(i)});
        end
             
        % make sure this data set is tracked!!
        % it would be better to only list those data sets in the list at
        % the top, but that is too much work, so i do this
        if ~handles.embryo.isTracked
            msgbox('This data set is not tracked and thus cannot be exported. Skipping export.', ...
                'Skipping data set', 'error');
            uiwait;
            continue
        end
        
        % create the measurements folder
        [a, b, c] = mkdir(handles.src.measurements);

        % choose the list of measurements
        if length(selection) > 1
            % only for the case of multiple data sets
            % first, find all measurements available for this data set
            [measurementchannels_thisdata measurementnames_thisdata] = get_measurement_file_names(handles); 
            % now, find all the measurements that are common to 
            % measurementnames_thisdata AND measurementnames_multi
            % the former is a list of all measurements for this data set,
            % and the latter is the selection of all choices
            intersection_inds = CStrAinBP(measurementnames_thisdata, measurementnames_multi);
            measurementnames = measurementnames_thisdata(intersection_inds);
            measurementchannels = measurementchannels_thisdata(intersection_inds);
        end
%         readyproc(handles, 'tracking');
%         handles.embryo.trackAllCells;
% 

        % ** output all the measurements into the mat file **
        % the format of stored properties is a struct with field names
        % equals to the channel names. each one contains a struct with
        % field names equal to the measurement names. each field contains a
        % t x z x numCells cell array. could have made it a numCells x t x z
        % x datasize array, but... i don't know how to put stuff into to
        % without knowing the number of dimensions...
        stored_properties = struct;
        
%         % set the built-in names
%         stored_properties.builtin.builtin.names = {'Area'; 'Perimeter'; 'Centroid-x'; 'Centroid-y'};
%         stored_properties.builtin.builtin.units = {'micron^2'; 'microns'; 'microns'; 'microns'};
      
        
        measure_path = fullfile(handles.program_dir, 'Measurements');
        for j = 1:length(measurementnames)  % for all measurements
            readyproc(handles, 'calculating');
            
            set(handles.text_readyproc_details, 'String', measurementnames{j});
            set(handles.text_readyproc_details, 'Visible', 'on');
            cd(fullfile(measure_path, measurementchannels{j}));  % go in that directory
            
            
            % the channel name might have spaces or other problematic
            % characters and then cannot be used as a field name in the
            % structure. this function returns the closet name.
            good_measurementchannels_j = genvarname(measurementchannels{j});
            
            
            % find out how many properties are given by this measurement,
            % so that if a cell is missing we can put in the appropriate
            % number of NaNs
            % to check this, do a cell with the master image and cell 1
            % load the image file for this channel at this (t, z)
            % (these few lines of code are repeated again a few lines later
            % for the general call, but here we just do it once)
            % ** also get the names & units!~~~~~
            if strcmp(measurementchannels{j}, 'Membranes')
%                 IMG_fun = [];
                IMG_fun = @(t, z) double(imread(handles.info.image_file(t, z, handles.src.raw)));
%                         IMG = imread(handles.info.image_file(time_i, layer_i, handles.src.bord));
            else
                channelnum = find(strcmp(good_measurementchannels_j, genvarname(handles.channelnames)));
%                 IMG = imread(handles.info.channel_image_file{channelnum}(handles.info.master_time, handles.info.master_layer, handles.src.channelsrc{channelnum}));
                IMG_fun = @(t, z) double(imread(handles.info.channel_image_file{channelnum}(t, z, handles.src.channelsrc{channelnum})));
            end                
            % also pass structure that allows you to read from all
            % channels (some special cases, but this is the final piece
            % of information available to them)
            for all_chan = 1:length(handles.channelnames)
                CHAN_fun.(genvarname(handles.channelnames{all_chan})) = ...
                    @(t, z) double(imread(handles.info.channel_image_file{all_chan}(t, z, handles.src.channelsrc{all_chan})));
            end
            % also give access to processed borders
            CHAN_fun.Processed = @(t, z) double(imread(handles.info.image_file(t, z, handles.src.bord)));
            
            try
                %preliminary call to get things like the size of data
                [data names units] = feval(measurementnames{j}, handles.embryo, ...
                    IMG_fun, handles.info.master_time, handles.info.master_layer, 1,  handles.info.microns_per_pixel, ...
                    handles.info.microns_per_z_step, handles.info.seconds_per_frame, CHAN_fun); 
            catch ME
                disp(getReport(ME));
                msgbox(strcat('Error in: ', measurementnames{j}, '. Export aborted'), ...
                    'Export failed', 'error');
                readyproc(handles, 'ready');
                cd(fullfile(handles.program_dir, 'Matlab'));
                return;
            end
%             if isvector(data)
%                 data_size = length(data);
%             else
%                 data_size = size(data);
%             end
            data_size = size(data);
            % here we set the names and units
            stored_properties.(good_measurementchannels_j).(measurementnames{j}).names  = names;
            stored_properties.(good_measurementchannels_j).(measurementnames{j}).units  = units;
            

            % create the stored_properties data field for this measurement
            stored_properties.(good_measurementchannels_j).(measurementnames{j}).data = ...
                cell([...
                abs(handles.info.end_time-handles.info.start_time)+1 ...
                abs(handles.info.bottom_layer - handles.info.top_layer)+1 ...
                handles.embryo.numCells]);
            % used to have data_size here
            
            
            % loop through all T, Z
            indTime = 0;
            for time_i = handles.info.start_time:handles.info.end_time
                set(handles.text_processing_time,  'String', num2str(time_i));
                drawnow;
                indTime = indTime + 1;
                indLayer = 0;
                for layer_i = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                    set(handles.text_processing_layer,  'String', num2str(layer_i));
                    drawnow;
                    indLayer = indLayer + 1;
                    if get(handles.radiobutton_stop, 'Value')
                        set(handles.radiobutton_stop, 'Value', 0);
                        readyproc(handles, 'ready');
                        cd(fullfile(handles.program_dir, 'Matlab'));
                        guidata(hObject, handles);
                        return;
                    end
                    
                    % load the image file for this channel at this (t, z)
                    if strcmp(measurementchannels{j}, 'Membranes')
                        % get a function handle to draw all the cells
%                         IMG_fun = @(t, z) double(handles.embryo.getCellGraph(t, z).draw);
                        IMG_fun = @(t, z) double(imread(handles.info.image_file(t, z, handles.src.raw)));
%                         IMG = imread(handles.info.image_file(time_i, layer_i, handles.src.bord));
                    else
                        channelnum = find(strcmp(good_measurementchannels_j, genvarname(handles.channelnames)));
%                         IMG = imread(handles.info.channel_image_file{channelnum}(time_i, layer_i, handles.src.channelsrc{channelnum}));
                        IMG_fun = @(t, z) double(imread(handles.info.channel_image_file{channelnum}(t, z, handles.src.channelsrc{channelnum})));
                    end
                    % also pass structure that allows you to read from all
                    % channels (some special cases, but this is the final piece
                    % of information available to them)
                    for all_chan = 1:length(handles.channelnames)
                        CHAN_fun.(genvarname(handles.channelnames{all_chan})) = ...
                            @(t, z) double(imread(handles.info.channel_image_file{all_chan}(t, z, handles.src.channelsrc{all_chan})));
                    end
                    CHAN_fun.Processed = @(t, z) double(imread(handles.info.image_file(t, z, handles.src.bord)));
                    
                    % loop through all the cells
                    for cell_i = 1:handles.embryo.numCells()
                        
                        if isempty(handles.embryo.getCellGraph(time_i, layer_i).getCell(cell_i))
                            % if this cell doesn't exist, we need to fill
                            % this with NaN everywhere
                            
                            
                            stored_properties.(good_measurementchannels_j).(measurementnames{j}).data{indTime, indLayer, cell_i}  = num2cell(NaN(data_size));
%                             stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).data  = NaN(data_size);
%                             stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).names = cell(data_size);
%                             stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).units = cell(data_size);
                        else
                        
                            try
                                data = feval(measurementnames{j}, handles.embryo, ...
                                    IMG_fun, time_i, layer_i, cell_i,  handles.info.microns_per_pixel, ...
                                    handles.info.microns_per_z_step, handles.info.seconds_per_frame, CHAN_fun);

                                stored_properties.(good_measurementchannels_j).(measurementnames{j}).data{indTime, indLayer, cell_i} = data;
%                                 stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).data  = data;
%                                 stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).names = names;
%                                 stored_properties{indTime, indLayer, cell_i}.(good_measurementchannels_j).(measurementnames{j}).units = units;
                            catch ME
                                disp(getReport(ME));
                                msgbox(strcat('Error in: ', measurementnames{j}, '. Export aborted'), ...
                                    'Export failed', 'error');
                                readyproc(handles, 'ready');
                                cd(fullfile(handles.program_dir, 'Matlab'));
                                return;
                            end
                            
                        end
                        
                    end
                    
                    
                    
                end   % for all layers
            end  % for all times
            
            
            set(handles.text_processing_time, 'Visible', 'off')
            set(handles.text_processing_time_label, 'Visible', 'off')
            set(handles.text_processing_layer, 'Visible', 'off')
            set(handles.text_processing_layer_label, 'Visible', 'off')
            set(handles.text_readyproc, 'String', 'Saving');
            drawnow;
            
            % save everything for that measurement
            names = stored_properties.(good_measurementchannels_j).(measurementnames{j}).names;
            units = stored_properties.(good_measurementchannels_j).(measurementnames{j}).units;
            for indiv_meas = 1:length(names)
                
                savename = [good_measurementchannels_j '--' measurementnames{j} '--' names{indiv_meas}];
                filename = fullfile(handles.src.measurements, savename);
                data = cell(size(stored_properties.(good_measurementchannels_j).(measurementnames{j}).data));
                for copyt = 1:size(data, 1)
                    for copyz = 1:size(data, 2)
                        for copyc = 1:size(data, 3)
                            data{copyt, copyz, copyc} = ...
                                stored_properties.(good_measurementchannels_j).(measurementnames{j}).data{copyt, copyz, copyc}{indiv_meas};                           
                        end
                    end
                end         
                name = names{indiv_meas};
                unit = units{indiv_meas};
                save(filename, 'data', 'name', 'unit');
            end
            
            
            
        end  % for all measurements
        cd(fullfile(handles.program_dir, 'Matlab'));
    
        readyproc(handles, 'saving');
        
        %%%% save stored properties
        % now there is a new version in which we no longer save everything
        % just in one .mat file, but rather split them up into subfiles as
        % we did with the exporting from EDGE        
%         filename = fullfile(handles.src.parent, 'measurements.mat');
%         if exist(filename, 'file')
%             delete(filename);
%         end
%         if ~isempty(measurementnames)
%             save(filename, 'stored_properties');   
%         end


    %%%% save embryo4d in embryo_data.mat file
%         embryo4d = handles.embryo;
        src_filename = fullfile(handles.tempsrc.parent, 'embryo_data.mat');
        dest_filename = fullfile(handles.src.parent, 'embryo_data.mat');
%         save(filename, 'embryo4d');
% (could also do this using copyfile)
% using copyfile because saving is SLOW since it has to re-serialize and
% compress everything
        copyfile(src_filename, dest_filename);
        
        
        
        exported_text_controller(handles, 'exported');

        % let the embryo4d be stored in handles, just for drawing purposes
%         handles.embryo = embryo4d;

        readyproc(handles, 'copy_all');
        set(handles.text_readyproc_details, 'Visible', 'on');
        set(handles.text_readyproc_details, 'String', 'Processed Membranes'); drawnow;
    %%%% save Embryo4d in DATA_GUI folder and copy border files
        for time_i = handles.info.start_time:handles.info.end_time
            set(handles.text_processing_time,  'String', num2str(time_i));
            for layer_i = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                set(handles.text_processing_layer, 'String', num2str(layer_i));
                drawnow;

                if get(handles.radiobutton_stop, 'Value')
                    set(handles.radiobutton_stop, 'Value', 0);
                    readyproc(handles, 'ready');
                    guidata(hObject, handles);
                    return
                end

                src = handles.info.image_file(time_i, layer_i, handles.tempsrc.bord);
                dest = handles.src.bord;

                if ~exist(src, 'file')  
                    % this should never happen
                    msgbox(strcat('Temporary file ', src, ' does not exist. Save aborted.'), 'Save failed', 'error');
                    uiwait;
                    readyproc(handles, 'ready');
                    guidata(hObject, handles);
                    return;
                end

                copyfile(src, dest);

            end
        end
        
        
    end  % end of loop for data sets
    if ~strcmp(handles.data_set, data_set)
        handles = clear_data_set_semiauto(handles, data_set);
    end
    
    
    % there are some cases where it helps to re-draw like if the 
    % active cells change
%     handles = slider_callbacks_draw_image_slice(handles); 
    
    readyproc(handles, 'ready');
    
    guidata(hObject, handles);  



function info_text_microns_per_pixel_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);

function info_text_microns_per_pixel_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_microns_per_z_step_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
    
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);

function info_text_microns_per_z_step_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_seconds_per_frame_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    % take away focus
    uicontrol(handles.DUMMY);
    
    handles = semiauto_info_text_callback(handles, name);
    guidata(hObject, handles);

function info_text_seconds_per_frame_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_start_time_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % fix sliders
    handles = initialize_tz_sliders(handles);

    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);


function info_text_start_time_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_end_time_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % fix sliders
    handles = initialize_tz_sliders(handles);

    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);


function info_text_end_time_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_master_time_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_master_time_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_bottom_layer_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % fix sliders
    handles = initialize_tz_sliders(handles);

    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_bottom_layer_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_top_layer_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);

    % fix sliders
    handles = initialize_tz_sliders(handles);

    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_top_layer_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_master_layer_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles); 

function info_text_master_layer_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_tracking_area_change_Z_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);


function info_text_tracking_area_change_Z_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_tracking_layers_back_Z_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);


function info_text_tracking_layers_back_Z_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_tracking_centroid_distance_Z_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);


function info_text_tracking_centroid_distance_Z_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function info_text_tracking_area_change_T_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_tracking_area_change_T_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_tracking_layers_back_T_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_tracking_layers_back_T_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function info_text_tracking_centroid_distance_T_Callback(hObject, eventdata, handles)
    [ST, I] = dbstack;
    name = ST.name;
    % get rid of "info_text_" at the beginning and 
    % "_Callback" at the end
    name = name(11:end-9);
        
    handles = semiauto_info_text_callback(handles, name);
    
    % this will change the embryo file
    handles = update_embryo(handles);
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function info_text_tracking_centroid_distance_T_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function save_datainfo_Callback(hObject, eventdata, handles)
    changed = handles.embryo.changed;
    if changed
        readyproc(handles, 'saving');
        handles = save_embryo(handles);
    end
    fields = write_data_info(handles);
    if ~isempty(fields)
        othermsg = 'Successfully updated the following fields in DATA_INFO.csv:';
        msg = [othermsg fields];
        msgbox(msg, 'Save successful');  
    end
    if isempty(fields) && ~changed
        msgbox('No changes to be saved.');
    end
    readyproc(handles, 'ready');
    guidata(hObject, handles);



function button_import_Callback(hObject, eventdata, handles)
% get the source directory
    src = uigetdir(handles.program_dir, 'Select the data set location');
    if ~src
        return;
    end
    
% get the name of the data set
   	data_set = import_get_dataset_name(src);
    if isempty(data_set)
        return;
    end
    handles.data_set = data_set;
%     src = strcat(src, '/');


% set all the default parameters as specified in DATA_INFO.csv
    handles.info = read_data_info('__DEFAULT__');

% is the data set live of fixed?
    res = questdlg('Is this a live or fixed data set?', ...
                  'Select data set type', 'Live', 'Fixed', 'Cancel', 'Live');
    switch res
        case 'Cancel'
            return;
        case 'Live'
            fixed = 0;
        case 'Fixed'
            fixed = 1;
    end
    
% parse the filename for the membranes channel
    [name sample_file z_digits z_posn z_min z_max t_digits t_posn t_min t_max] = ...
        import_parse_filename(src, fixed);
    %%% need to handle the case where this fails (inside this function)   
    
    
    % if there is only one layer
    if z_min == z_max
        handles.info.top_layer    = z_max;
        handles.info.bottom_layer = z_max;
        
        res = questdlg(strcat('The program only found one layer, z = ', ...
            num2str(z_min), '. Is this correct?'), 'One layer only', ...
            'Ok', 'Cancel', 'Ok');
        if strcmp(res, 'Cancel')
            return;
        end
        
    else
    
    
        res = questdlg(strcat('The program found that the depths range from z = ', ...
            num2str(z_min), ' to z = ', num2str(z_max), '. Which of these depths', ...
            ' represents the TOP of the embryo?'), 'Select top image', ...
            num2str(z_min), num2str(z_max), 'Cancel', num2str(z_max));
        switch res
            case 'Cancel'
                return
            case num2str(z_max)
                handles.info.top_layer    = z_max;
                handles.info.bottom_layer = z_min;
            case num2str(z_min)
                handles.info.top_layer    = z_min;
                handles.info.bottom_layer = z_max;
        end
    end
    

    if ~fixed
        handles.info.start_time = t_min;
        handles.info.end_time   = t_max;
    else
        handles.info.start_time = 0;
        handles.info.end_time = 0;
    end
    
    
    
% get additional channels
	channels = cell(0);
    while 1
        res = questdlg('Are there more channels associated with this data set?', ...
            'Add channels', 'Add another', 'Continue import', 'Add another');
        if strcmp(res, 'Continue import')
            break;
        end
        
        % get the directory of this channel (open the dialog in the directory you
        % selected before, just for convenience)
        channel_info.src = uigetdir(src, 'Select the location for this channel');
        if ~channel_info.src
            continue;
        end
        
        % let you choose from a list of channels already imported. if none
        % are already imported, or if you select Other, then you enter it
        % in manually. at the end we store the name, src, and other info in
        % the channel_info structure, actually an array of structures, one
        % for each channel we add
        existing_channel_names = get_folder_names(fullfile('..', 'Measurements'));
        if length(existing_channel_names) > 1 % if not just Membranes
            existing_channel_names_nomemb = existing_channel_names;
            existing_channel_names_nomemb(strcmp(existing_channel_names_nomemb, 'Membranes')) = [];
            channel_choices = [existing_channel_names_nomemb(:); '*Other*'];
            [selection ok] = listdlg('ListString', channel_choices, 'Name', 'Select channel name', ...
                'ListSize', [300 300], 'SelectionMode', 'single');            
            if ~ok
                return;
            end
        end
        if length(existing_channel_names) <= 1 || selection == length(channel_choices)

            slash_loc = strfind(channel_info.src, filesep);
            slash_loc = slash_loc(end);
            ch_actual_dirname = channel_info.src(slash_loc+1:end);
            channel_info.channelname = inputdlg('Enter the name of this channel:', 'Channel name', 1, {ch_actual_dirname});
            if isempty(channel_info.channelname)
                return;
            elseif any(strcmp(existing_channel_names, channel_info.channelname))
                msgbox('This channel name already exists. Import failed.', 'Import failed', 'error');
                return;
            end
            channel_info.channelname = channel_info.channelname{1};
            % make a new directory for that Channel in Measurements
            [a b c] = mkdir(fullfile('..', 'Measurements', channel_info.channelname));
        else
            channel_info.channelname = channel_choices{selection};
        end
        
%         channel_info.src = strcat(channel_info.src, '/');
        
        [channel_info.name channel_info.sample_file ...
            channel_info.z_digits channel_info.z_posn channel_info.z_min channel_info.z_max ...
            channel_info.t_digits channel_info.t_posn channel_info.t_min channel_info.t_max] = ...
            import_parse_filename(channel_info.src, fixed);
        
        channels{length(channels)+1} = channel_info;
    end
    
% look for XML file with image properties
    readyproc(handles, 'xml');
    xml_success = 0;
    files = dir(src);
    for i = 1:length(files)
        if files(i).isdir
            continue;
        end
        xmlname = files(i).name;
        [dummy1, dummy2, xml_ext] = fileparts(xmlname); 
        if strcmp(xml_ext, '.xml')
            try
                tree = xml_read(fullfile(src, xmlname));
                xml_struct = leicaxmlextract(tree);
                dz = abs(xml_struct.zstep * 1e6); % convert to microns
                dz = round(dz*10)/10;  % round to the nearest 0.1 um
                dx = xml_struct.xdimreal / xml_struct.xpixels * 1e6;
                dx = round(dx*1000)/1000;  % round to the nearest 0.001 um
                if ~fixed
                    dt = diff(xml_struct.timeinmin);
                    dt = dt(~~dt);
                    dt = abs(mean(dt) * xml_struct.stacksize * 60);
                    dt = round(dt*2)/2;  % round to the nearest 0.5 seconds
                end
                xml_success = 1;
                break;
            catch 
                %%%
            end
        end
        
    end
    
    if xml_success
        queststr = strcat('Found info from file ', xmlname, ': dx = ', num2str(dx), ...
            ' microns/pixel, dz = ', num2str(dz), ' microns/image');
        if ~fixed
            queststr = strcat(queststr, ', dt = ', num2str(dt), ' sec/image. ');
        else
            queststr = strcat(queststr, '. ');
        end
        queststr = strcat(queststr, 'Do you want to use these parameters?');
        res = questdlg(queststr, 'Automatic parameter detection', 'Yes', 'No', 'Yes');
    end
    readyproc(handles, 'ready')
    if ~xml_success || strcmp(res, 'No')
        
        if fixed
            prompt = {'Enter XY spatial resolution ({\mu}m/pixel):', ...
                      'Enter Z spatial resolution ({\mu}m/image):'};
            dlg_title = 'Input image parameters';
            num_lines = 1;
            defaultanswer = {'',''};
        %     options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='tex';
            answer = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);

            if isempty(answer) || isempty(answer{1}) || isempty(answer{2})
                return;
            end

            handles.info.microns_per_pixel = str2double(answer{1});
            handles.info.microns_per_z_step = str2double(answer{2});
            handles.info.seconds_per_frame = NaN;
        elseif z_min == z_max
            prompt = {'Enter XY spatial resolution ({\mu}m/pixel):', ...
                      'Enter temporal resolution (sec/image):'};
            dlg_title = 'Input image parameters';
            num_lines = 1;
            defaultanswer = {'',''};
        %     options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='tex';
            answer = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);
            if isempty(answer) || isempty(answer{1}) || isempty(answer{2})
                return
            end

            handles.info.microns_per_pixel = str2double(answer{1});
            handles.info.microns_per_z_step = NaN;
            handles.info.seconds_per_frame = str2double(answer{2});
            
            
        else
            prompt = {'Enter XY spatial resolution ({\mu}m/pixel):', ...
                      'Enter Z spatial resolution ({\mu}m/image):' , ...
                      'Enter temporal resolution (sec/image):'};
            dlg_title = 'Input image parameters';
            num_lines = 1;
            defaultanswer = {'','',''};
        %     options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='tex';
            answer = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);
            if isempty(answer) || isempty(answer{1}) || isempty(answer{2}) || isempty(answer{3})
                return
            end


            handles.info.microns_per_pixel = str2double(answer{1});
            handles.info.microns_per_z_step = str2double(answer{2});
            handles.info.seconds_per_frame = str2double(answer{3});
        end
    else  % automatic detection (xml)
        handles.info.microns_per_pixel = dx;
        handles.info.microns_per_z_step = dz;
        if ~fixed
            handles.info.seconds_per_frame = dt;
        else
            handles.info.seconds_per_frame = NaN;
        end
    end
    % note for the above: 
    % it's okay that handles is being changed even if it fails,
    % and calls "return" because handles only gets really updated at the
    % end when I call "guidata(hObject, handles)"
    % and by then everything has worked.
    
    
    % we need to fill in the rest of the info with default values
    % finds Ys and Xs
    sample_image = imread(fullfile(src, sample_file));
    dims = size(sample_image);
    handles.info.Ys = dims(1);
    handles.info.Xs = dims(2);
    handles.info.master_time = handles.info.start_time;
    handles.info.master_layer = handles.info.bottom_layer;
    
    channelnames = cell(length(channels));
    for i = 1:length(channels)
        channelnames{i} = channels{i}.channelname;
    end
    handles.channelnames = channelnames;
    
    % run write_data_info
    fields = write_data_info(handles);
    
    % set the paths, handles.src and handles.tempsrc
    handles = handles_set_program_dir(handles);
    handles = handles_set_src_paths(handles);
    handles = handles_set_tempsrc_paths(handles);
    handles = handles_set_channelsrc_paths(handles);
    
    % make the directories in DATA_GUI
    [a b c] = mkdir(handles.src.parent);
    [a b c] = mkdir(handles.src.raw);
    [a b c] = mkdir(handles.src.bord);
    [a b c] = mkdir(handles.src.measurements);
    
    % make the directories in DATA_SEMIAUTO (remove old files)
    [a    ] = rmdir(handles.tempsrc.parent, 's');
    [a b c] = mkdir(handles.tempsrc.parent);
    [a b c] = mkdir(handles.tempsrc.bord);
%     [a b c] = mkdir(handles.tempsrc.poly);
     
    % make directories for the (possibly processed) data from the other channels
    for i = 1:length(handles.channelnames)
        [a b c] = mkdir(handles.src.channelsrc{i});
    end
    
    % make the image_filename files
    if isfield(handles.info, 'image_file')
        handles.info = rmfield(handles.info, 'image_file');  % just to avoid some weird errors
    end
    handles.info.image_file = write_image_filename_function(handles.src.membranes, ...
        name, z_posn, z_digits, t_posn, t_digits, fixed, handles.data_set);

    for i = 1:length(handles.channelnames)
        handles.info.channel_image_file{i} = write_image_filename_function(...
            handles.src.channelsrc{i}, ...
            channels{i}.name, channels{i}.z_posn, channels{i}.z_digits, ...
            channels{i}.t_posn, channels{i}.t_digits, fixed, handles.data_set);  
    end
    
    % reinitialize the Data Sets dropdown menu
    datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
    set(handles.dropdown_datasets, 'String', datanames);
    data_set_number = find(strcmp(datanames, handles.data_set), 1);
    set(handles.dropdown_datasets, 'Value', data_set_number);
    
    res = questdlg(strcat('EDGE will now copy the raw data into its own folder. ', ...
        'Would you like to delete the original files from the folder you specified?'), ...
          'Delete originals?', 'Delete originals', 'Keep originals', 'Keep originals');
    switch res
        case 'Delete originals'
            rm_files = 1;
            readyproc(handles, 'move_all');        
        case 'Keep originals'
            rm_files = 0;
            readyproc(handles, 'copy_all');        
    end
    
    % copy the files into the new directory - membranes
    copymove_src = @(t, z) handles.info.image_file(t, z, src);
    copymove_dest= handles.src.raw;
    set(handles.text_readyproc_details, 'Visible', 'on');
    set(handles.text_readyproc_details, 'String', 'Membranes'); drawnow;
    import_copymove_files(handles, copymove_src, copymove_dest, rm_files, sample_image);
    
    % copy the files into the new directory - other channels
    for i = 1:length(handles.channelnames)
        set(handles.text_readyproc_details, 'String', handles.channelnames{i}); drawnow;
        copymove_src = @(t, z) handles.info.channel_image_file{i}(t, z, channels{i}.src);
        copymove_dest = handles.src.channelsrc{i};
        sample_image = imread(fullfile(channels{i}.src, channels{i}.sample_file));
        import_copymove_files(handles, copymove_src, copymove_dest, rm_files, sample_image);
    end

    % create the embryo file
    handles.embryo = Embryo4D(...
        handles.info.start_time, handles.info.end_time, handles.info.master_time, ...
        handles.info.bottom_layer, handles.info.top_layer, handles.info.master_layer, ... 
        handles.info.tracking_area_change_Z, handles.info.tracking_layers_back_Z, ...
        handles.info.tracking_centroid_distance_Z / handles.info.microns_per_pixel, ...
        handles.info.tracking_area_change_T, handles.info.tracking_layers_back_T, ...
        handles.info.tracking_centroid_distance_T / handles.info.microns_per_pixel);

    handles = save_embryo(handles);
    
    handles = clear_data_set_semiauto(handles, handles.data_set);
    
    readyproc(handles, 'ready');
    
    msgbox(['Data set ', handles.data_set, ' has been imported succesfully.', ...
        'The information entered can be edited anytime using this program. ', ...
        ' Before processing, select a reference image and press the "Set reference image" button.']);    

    guidata(hObject, handles);
       
    
function button_set_master_image_Callback(hObject, eventdata, handles)
    [T Z] = getTZ(handles);

    if ~handles.fixed
        set(handles.info_text_master_time,  'String', num2str(T));
        handles.info.master_time = T;
    end
    set(handles.info_text_master_layer, 'String', num2str(Z));
    handles.info.master_layer = Z;

    handles = update_embryo(handles);
    handles = slider_callbacks_draw_image_slice(handles);
    
    guidata(hObject, handles);
    

function vec_puncture_cell_Callback(hObject, eventdata, handles)
    if isempty(handles.activeCell)
        msgbox('You must select at least one cell for puncturing.',...
            'Cell puncture failed', 'error');
        return;
    end    
    if length(handles.activeCell) > 1
        msgbox('You can only puncture one cell at a time.',...
            'Cell puncture failed', 'error');
        return;
    end    
    [T Z] = getTZ(handles);
    CellObj = handles.embryo.getCell(handles.activeCell, T, Z);
    
    % delete the cells
    handles.embryo.getCellGraph(T, Z).destroyCell(CellObj);
  
    % no longer active
    handles.activeCell = [];
    
    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);

function vec_remove_cell_Callback(hObject, eventdata, handles)
    if isempty(handles.activeCell)
        msgbox('You must select at least one cell for delete.',...
            'Cell deletion failed', 'error');
        return;
    end    

    [T Z] = getTZ(handles);
    % make a java array
%     cellArray = javaArray('Cell', length(handles.activeCell));
%     for i = 1:length(handles.activeCell)
%         cellArray(i) = handles.embryo.getCell(handles.activeCell(i), T, Z);
%     end
    cellArray = handles.embryo.getCells(handles.activeCell, T, Z);
    
    % delete the cells
    handles.embryo.getCellGraph(T, Z).removeCells(cellArray);
  
    % no longer active
    handles.activeCell = [];
    
    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);
    
 

function vec_remove_edge_Callback(hObject, eventdata, handles)
    [T Z] = getTZ(handles);
    if get(handles.radiobutton_vec_manual, 'Value')

        if length(handles.activeCell) ~= 2 && length(handles.activeVertex) ~= 2
            msgbox('You must select exactly two cells or exactly two vertices for edge removal.', ...
                'Edge removal failed', 'error');
            return;
        end

        if get(handles.radiobutton_adjust_cells, 'Value')  %cells
            cell1 = handles.embryo.getCell(handles.activeCell(1), T, Z);
            cell2 = handles.embryo.getCell(handles.activeCell(2), T, Z);

            if ~handles.embryo.getCellGraph(T, Z).edgeConnected(cell1, cell2)
                msgbox('Edge removal only works for cells that share an edge.', ...
                    'Edge removal failed', 'error');
                return;
            end


            handles.embryo.getCellGraph(T, Z).removeEdge(cell1, cell2);

            % no longer active
            handles.activeCell = [];


        elseif get(handles.radiobutton_adjust_vertices, 'Value')  % vertices
            vert1 = handles.activeVertex{1};
            vert2 = handles.activeVertex{2};

            if ~handles.embryo.getCellGraph(T, Z).connected(vert1, vert2)
                msgbox('Edge removal only works for vertices that are connected.', ...
                    'Edge removal failed', 'error');
                uiwait;
                return;
            end

            remove_out = handles.embryo.getCellGraph(T, Z).removeEdge(vert1, vert2); 
            if remove_out == 0
                msgbox(['Error: the two selected vertices must be shared by exactly two cells' ...
                    '. It is possible that one of the two cells does not actually exist. ' ...
                    'Try selecting all cells to see this.'], 'Edge removal failed', 'error');
                uiwait;
                return;
            end
            

            handles.activeVertex = [];
        end
    %     tempcg = handles.tempcg;
    %     [T Z] = getTZ(handles);
    %     filename = handles.info.image_file(T, Z, handles.tempsrc.poly); 
    %     save(chgext(filename, 'none'), 'tempcg');
    %     save_embryo(handles);
    elseif get(handles.radiobutton_vec_auto_thisimg, 'Value')
        readyproc(handles, 'proc');
        
        handles.embryo.autoRemoveEdges(T, Z);
        
        readyproc(handles, 'ready');
        
    elseif get(handles.radiobutton_vec_auto_allimg, 'Value') || get(handles.radiobutton_vec_auto_someimg, 'Value')
        readyproc(handles, 'proc_all');

        for time_i = handles.time_array;%handles.info.start_time:handles.info.end_time
            set(handles.text_processing_time,  'String', num2str(time_i));
            for layer_i = handles.layer_array;%handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer                
                if get(handles.radiobutton_vec_auto_someimg, 'Value')
                    if query_for_image_subset_skip(handles.some_auto_range, time_i, layer_i)
                        continue;
                    end
                end
                
                set(handles.text_processing_layer, 'String', num2str(layer_i));
                drawnow;
                
                % skip the refrerence image (!)
                if time_i == handles.info.master_time && layer_i == handles.info.master_layer
                    continue;
                end

                if get(handles.radiobutton_stop, 'Value')
                    set(handles.radiobutton_stop, 'Value', 0);
                    readyproc(handles, 'ready');
                    guidata(hObject, handles);
                    return;
                end
                
                handles.embryo.autoRemoveEdges(time_i, layer_i);
     
            end
        end

        readyproc(handles, 'ready');
    end    
    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);
    

function vec_add_cell_Callback(hObject, eventdata, handles)
    if length(handles.activeVertex) < 3
        msgbox('You must select at least three vertices to form a Cell.', ...
            'Add cell failed', 'error');
        return;
    end

    vertexArray = javaArray('Vertex', length(handles.activeVertex));
    for i = 1:length(handles.activeVertex)
        vertexArray(i) = handles.activeVertex{i};
    end
    
    [T Z] = getTZ(handles);
    success = handles.embryo.getCellGraph(T, Z).addCell(vertexArray);
    
    if ~success
        msgbox('This cell already exists in the CellGraph.', ...
            'Add Cell failed', 'error');
        return;
    end
    
    handles.activeVertex = [];
    
%     tempcg = handles.tempcg;
%     [T Z] = getTZ(handles);
%     filename = handles.info.image_file(T, Z, handles.tempsrc.poly); 
%     save(chgext(filename, 'none'), 'tempcg');
%     save_embryo(handles);
    
    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);

function vec_add_edge_Callback(hObject, eventdata, handles)
    [T Z] = getTZ(handles);
    
    if get(handles.radiobutton_vec_manual, 'Value')
        if length(handles.activeVertex) ~= 2 
            msgbox('You must select exactly two Vertices to add an edge.', ...
                'Add edge failed', 'error');
            return;
        end

        vert1 = handles.activeVertex{1};
        vert2 = handles.activeVertex{2};

        [T Z] = getTZ(handles);
        if handles.embryo.getCellGraph(T, Z).connected(vert1, vert2)
            msgbox('An edge between these two vertices already exists.', ...
                'Edge removal failed', 'error');
            return;
        end
        handles.embryo.getCellGraph(T, Z).addEdge(vert1, vert2);

        handles.activeVertex = [];

    
    elseif get(handles.radiobutton_vec_auto_thisimg, 'Value')
        readyproc(handles, 'proc');
                
        handles.embryo.autoAddEdges(T, Z);
        
        readyproc(handles, 'ready');

    elseif get(handles.radiobutton_vec_auto_someimg, 'Value') || get(handles.radiobutton_vec_auto_allimg, 'Value')
        readyproc(handles, 'proc_all');

        for time_i = handles.time_array;%handles.info.start_time:handles.info.end_time
            set(handles.text_processing_time,  'String', num2str(time_i));
            for layer_i = handles.layer_array;%handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                if get(handles.radiobutton_vec_auto_someimg, 'Value')
                    if query_for_image_subset_skip(handles.some_auto_range, time_i, layer_i)
                        continue;
                    end
                end
                
                set(handles.text_processing_layer, 'String', num2str(layer_i));
                drawnow;
                
                % skip the reference image (!)
                if time_i == handles.info.master_time && layer_i == handles.info.master_layer
                    continue;
                end

                if get(handles.radiobutton_stop, 'Value')
                    set(handles.radiobutton_stop, 'Value', 0);
                    readyproc(handles, 'ready');
                    guidata(hObject, handles);
                    return;
                end

                handles.embryo.autoAddEdges(time_i, layer_i);
     
            end
        end
        readyproc(handles, 'ready');
    end    
%     tempcg = handles.tempcg;
%     [T Z] = getTZ(handles);
%     filename = handles.info.image_file(T, Z, handles.tempsrc.poly); 
%     save(chgext(filename, 'none'), 'tempcg');
%     save_embryo(handles);
    
    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);
       

function vec_remove_vertex_Callback(hObject, eventdata, handles)    
    if length(handles.activeVertex) < 1
        msgbox('You must select at least one Vertex.', ...
            'Remove Vertex failed', 'error');
        return;
    end
    [T Z] = getTZ(handles);
    
    vertexArray = javaArray('Vertex', length(handles.activeVertex));
    for i = 1:length(handles.activeVertex)
        vertexArray(i) = handles.activeVertex{i};
    end
    
    handles.embryo.getCellGraph(T, Z).removeVertices(vertexArray);
    
    handles.activeVertex = [];
    
%     tempcg = handles.tempcg;
%     [T Z] = getTZ(handles);
%     filename = handles.info.image_file(T, Z, handles.tempsrc.poly); 
%     save(chgext(filename, 'none'), 'tempcg');
%     save_embryo(handles);

    handles = slider_callbacks_draw_image_slice(handles);
    guidata(hObject, handles);


function vec_select_all_Callback(hObject, eventdata, handles)
    [T Z] = getTZ(handles);
    if get(handles.radiobutton_adjust_cells, 'Value')  % cells
        if get(handles.cbox_poly, 'Value') && ~get(handles.cbox_inactive, 'Value')
            handles.activeCell = Cell.index(handles.embryo.getCellGraph(T, Z).activeCells);
        elseif ~get(handles.cbox_poly, 'Value') && get(handles.cbox_inactive, 'Value')
            handles.activeCell = Cell.index(handles.embryo.getCellGraph(T, Z).inactiveCells);
        else
            handles.activeCell = Cell.index(handles.embryo.getCellGraph(T, Z).cells);
        end
    elseif get(handles.radiobutton_adjust_vertices, 'Value')  % vertices
        if get(handles.cbox_poly, 'Value') && ~get(handles.cbox_inactive, 'Value')
            handles.activeVertex = cell(handles.embryo.getCellGraph(T, Z).activeVertices);
        elseif ~get(handles.cbox_poly, 'Value') && get(handles.cbox_inactive, 'Value')
            handles.activeVertex = cell(handles.embryo.getCellGraph(T, Z).inactiveVertices);
        else
            handles.activeVertex = cell(handles.embryo.getCellGraph(T, Z).vertices);
        end
                
    end
    set(handles.cell_text, 'String', '-'); 
    handles = slider_callbacks_draw_image_slice_dots_semiauto(handles); 
    guidata(hObject, handles);

    
function vec_unselect_all_Callback(hObject, eventdata, handles)
    handles.activeCell = [];
    handles.activeVertex = [];
    handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
    set(handles.cell_text, 'String', '-'); 
    guidata(hObject, handles);
    
 function vec_select_cv_change(hObject, eventdata)
    % unselect all when you change this
    handles = guidata(hObject);
    handles.activeCell = [];
    handles.activeVertex = [];
    handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
    set(handles.cell_text, 'String', '-'); 
    guidata(hObject, handles);

function vec_select_auto_change(hObject, eventdata)
    handles = guidata(hObject);
    
    if get(handles.radiobutton_vec_auto_someimg, 'Value')
        handles.some_auto_range = query_for_image_subset;
        if isempty(handles.some_auto_range)
            set(handles.radiobutton_vec_manual, 'Value', 1);
        end
    end
    
    semiauto_set_vec_enabling(handles);
    guidata(hObject, handles);

   
    
% function vec_add_vertex_Callback(hObject, eventdata, handles)
%     handles.activeAdjustment = 'add_vertex';
%     vec_adjustments_visible(handles, 'off');
%     set(handles.radiobutton_adjust_vertices, 'Value', 1);
%     guidata(hObject, handles);
    
function vec_move_vertex_Callback(hObject, eventdata, handles)
    if length(handles.activeVertex) ~= 1 
        msgbox('You must select exactly one Vertex to move it.', ...
            'Add edge failed', 'error');
        return;
    end
    
    handles.activeAdjustment = 'move_vertex';
    vec_adjustments_visible(handles, 'off');
    guidata(hObject, handles);
    
function vec_split_edge_Callback(hObject, eventdata, handles)
    if get(handles.radiobutton_vec_manual, 'Value')   
    
        if length(handles.activeVertex) ~= 2 
            msgbox('You must select exactly two Vertices to split an edge.', ...
                'Add edge failed', 'error');
            return;
        end

        vert1 = handles.activeVertex{1};
        vert2 = handles.activeVertex{2};

        [T Z] = getTZ(handles);
        if ~handles.embryo.getCellGraph(T, Z).connected(vert1, vert2)
            msgbox('You must select two connected vertices to split an edge.', ...
                'Edge removal failed', 'error');
            return;
        end

        handles.activeAdjustment = 'split_edge';
        vec_adjustments_visible(handles, 'off');
    elseif get(handles.radiobutton_vec_auto_thisimg, 'Value')
            readyproc(handles, 'proc');
            handles.activeVertex = [];


            % get the parameters
            [T Z]   = getTZ(handles);
            max_angle   = degtorad(str2double(get(handles.info_text_refine_max_angle, 'String')));
            min_angle   = degtorad(str2double(get(handles.info_text_refine_min_angle, 'String')));
            min_edge_len= str2double(get(handles.info_text_refine_min_edge_length, 'String')) ...
                            /handles.info.microns_per_pixel;
            bords       = imread(handles.info.image_file(T, Z, handles.tempsrc.bord));

            % refine the edges
            handles.embryo.autoSplitEdges(T, Z, bords, max_angle, min_angle, min_edge_len); 

            handles = slider_callbacks_draw_image_slice(handles);

            readyproc(handles, 'ready');

        
    elseif get(handles.radiobutton_vec_auto_someimg, 'Value') || get(handles.radiobutton_vec_auto_allimg, 'Value')
%        % allows you to applyall for multiple data sets at once
%         datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
%         default_val = find(strcmp(datanames, handles.data_set));
%         if length(datanames) > 1
%             [selection ok] = listdlg('ListString', datanames, 'Name', 'Select data sets for processing', ...
%                 'ListSize', [300 300], 'InitialValue', default_val);
%             if ~ok
%                 return;
%             end
%         else
%             selection = default_val;
%         end
%         data_set = handles.data_set;
% 
%         % do it for all data sets~~~
%         for i = 1:length(selection)
%             if ~strcmp(data_set, datanames{selection(i)})
%                 handles = clear_data_set_semiauto(handles, datanames{selection(i)});
%             end

            for time_i = handles.time_array;%handles.info.start_time:handles.info.end_time
                set(handles.text_processing_time,  'String', num2str(time_i));
                for layer_i = handles.layer_array;%handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                    set(handles.text_processing_layer, 'String', num2str(layer_i));
                    drawnow;

                    if get(handles.radiobutton_vec_auto_someimg, 'Value')
                        if query_for_image_subset_skip(handles.some_auto_range, time_i, layer_i)
                            continue;
                        end
                    end
                    
                    if get(handles.radiobutton_stop, 'Value')
                        set(handles.radiobutton_stop, 'Value', 0);
                        readyproc(handles, 'ready');
                        guidata(hObject, handles);
                        return;
                    end

                    max_angle   = degtorad(str2double(get(handles.info_text_refine_max_angle, 'String')));
                    min_angle   = degtorad(str2double(get(handles.info_text_refine_min_angle, 'String')));
                    min_edge_len= str2double(get(handles.info_text_refine_min_edge_length, 'String'));
                    bords       = imread(handles.info.image_file(time_i, layer_i, handles.tempsrc.bord));

                    % refine the edges
                    handles.embryo.autoSplitEdges(time_i, layer_i, bords, max_angle, min_angle, min_edge_len);
                end
            end
%         end
%         if ~strcmp(handles.data_set, data_set)
%             % go back to the original data set
%             handles = clear_data_set_semiauto(handles, data_set);
%         end

        handles = slider_callbacks_draw_image_slice(handles);

        readyproc(handles, 'ready');

    end
    guidata(hObject, handles);
    

function button_vec_cancel_Callback(hObject, eventdata, handles)
    handles.activeAdjustment = [];
    vec_adjustments_visible(handles, 'on');
    guidata(hObject, handles);    
    
    

function button_switch_to_explorer_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    passinfo.data_set = handles.data_set;
    passinfo.t_slider = get(handles.t_slider, 'Value');
    passinfo.z_slider = get(handles.z_slider, 'Value');
    
    closeGUI(hObject, eventdata);
    EDGE('dummy', passinfo);

    

% this button is for activating cells in the Manual mode,
% in automatic mode, it is
% used to do error correcton all in one step. in particular, it calls 
% remove edge, then split edge, then add edge
function vec_activate_cell_Callback(hObject, eventdata, handles)
    if get(handles.radiobutton_vec_manual, 'Value')   
        [T Z] = getTZ(handles);
        could_not_activate = '';
        for i = 1:length(handles.activeCell)
            if ~handles.embryo.isTrackingCandidate(handles.activeCell(i), T, Z);
                could_not_activate = [could_not_activate num2str(handles.activeCell(i)) ', '];
            else
                handles.activeCell(i) = handles.embryo.activateCell(handles.activeCell(i), T, Z);
            end
        end
        
        if ~isempty(could_not_activate)
            msgbox(['The following cells could not be activated either because they ' ...
                'are already active or because a corresponding cell could not be found: ', ...
                could_not_activate], ...
                'Some cells not activated', 'error');
            uiwait;
        end
        
        handles = slider_callbacks_draw_image_slice(handles);
        
    elseif get(handles.radiobutton_vec_auto_thisimg, 'Value')
        readyproc(handles, 'proc');
        handles.activeVertex = [];

        % get the parameters
        [T Z]   = getTZ(handles);
        max_angle   = degtorad(str2double(get(handles.info_text_refine_max_angle, 'String')));
        min_angle   = degtorad(str2double(get(handles.info_text_refine_min_angle, 'String')));
        min_edge_len= str2double(get(handles.info_text_refine_min_edge_length, 'String')) ...
                        /handles.info.microns_per_pixel;
        bords       = imread(handles.info.image_file(T, Z, handles.tempsrc.bord));

        % remove edges, split edges, add edges
        handles.embryo.autoRemoveEdges(T, Z);
        handles.embryo.autoSplitEdges(T, Z, bords, max_angle, min_angle, min_edge_len);
        handles.embryo.autoAddEdges(T, Z);


        handles = slider_callbacks_draw_image_slice(handles);

        readyproc(handles, 'ready');
    elseif get(handles.radiobutton_vec_auto_someimg, 'Value') || get(handles.radiobutton_vec_auto_allimg, 'Value')
%        % allows you to applyall for multiple data sets at once
%         datanames = get_folder_names(fullfile('..', 'DATA_GUI'));
%         default_val = find(strcmp(datanames, handles.data_set));
%         if length(datanames) > 1
%             [selection ok] = listdlg('ListString', datanames, 'Name', 'Select data sets for processing', ...
%                 'ListSize', [300 300], 'InitialValue', default_val);
%             if ~ok
%                 return;
%             end
%         else
%             selection = default_val;
%         end
%         data_set = handles.data_set;
% 
%         % do it for all data sets~~~
%         for i = 1:length(selection)
%             if ~strcmp(data_set, datanames{selection(i)})
%                 handles = clear_data_set_semiauto(handles, datanames{selection(i)});
%             end

            readyproc(handles, 'proc_all');
            for time_i = handles.time_array%handles.info.start_time:handles.info.end_time
                set(handles.text_processing_time,  'String', num2str(time_i));
                for layer_i = handles.layer_array%handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
                    set(handles.text_processing_layer, 'String', num2str(layer_i));
                    drawnow;
                         
                    % skip the reference image (!)
                    if time_i == handles.info.master_time && layer_i == handles.info.master_layer
                        continue;
                    end
                    
                    if get(handles.radiobutton_vec_auto_someimg, 'Value')
                        if query_for_image_subset_skip(handles.some_auto_range, time_i, layer_i)
                            continue;
                        end
                    end
                    

                    if get(handles.radiobutton_stop, 'Value')
                        set(handles.radiobutton_stop, 'Value', 0);
                        readyproc(handles, 'ready');
                        guidata(hObject, handles);
                        return;
                    end

                    max_angle   = degtorad(str2double(get(handles.info_text_refine_max_angle, 'String')));
                    min_angle   = degtorad(str2double(get(handles.info_text_refine_min_angle, 'String')));
                    min_edge_len= str2double(get(handles.info_text_refine_min_edge_length, 'String'));
                    bords       = imread(handles.info.image_file(time_i, layer_i, handles.tempsrc.bord));

                    % remove edges, refine edges, add edges
                    handles.embryo.autoRemoveEdges(time_i, layer_i);
                    handles.embryo.autoSplitEdges(time_i, layer_i, bords, max_angle, min_angle, min_edge_len);
                    handles.embryo.autoAddEdges(time_i, layer_i);
                end
            end
%         end
%         if ~strcmp(handles.data_set, data_set)
%             % go back to the original data set
%             handles = clear_data_set_semiauto(handles, data_set);
%         end

        handles = slider_callbacks_draw_image_slice(handles);

        readyproc(handles, 'ready');

    end
    guidata(hObject, handles);


function goto_master_image_Callback(hObject, eventdata, handles)
    [T Z] = getTZ(handles);
    if T == handles.info.master_time && Z == handles.info.master_layer
        return
    end
    handles = go_to_image(handles, handles.info.master_time, handles.info.master_layer);
    guidata(hObject, handles);    


function cell_text_Callback(hObject, eventdata, handles)
    ind = str2double(get(handles.cell_text, 'String'));
    [T Z] = getTZ(handles);
    if round(ind)~=ind || ind==0
        handles.activeCell = [];
        msgbox('Cell number must be a nonzero integer.', '', 'error');
    elseif ~handles.embryo.getCellGraph(T, Z).containsCell(ind)
        handles.activeCell = [];
        msgbox(['Cell number ' num2str(ind) ' does not exist at this (T, Z).'], '', 'error');
        uiwait;
    else
        handles.activeCell = ind;
        handles = slider_callbacks_draw_image_slice_dots_semiauto(handles);
        guidata(hObject, handles);
    end
    
    % take away focus
    uicontrol(handles.DUMMY);
    guidata(hObject, handles);

function cell_text_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function DUMMY_Callback(hObject, eventdata, handles)
% does nothing, just allows us to take focus away from things
% by giving focus to DUMMY

