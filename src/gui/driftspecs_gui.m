function varargout = driftspecs_gui(varargin)
%DRIFTSPECS_GUI MATLAB code file for driftspecs_gui.fig
%      DRIFTSPECS_GUI, by itself, creates a new DRIFTSPECS_GUI or raises the existing
%      singleton*.
%
%      H = DRIFTSPECS_GUI returns the handle to a new DRIFTSPECS_GUI or the handle to
%      the existing singleton*.
%
%      DRIFTSPECS_GUI('Property','Value',...) creates a new DRIFTSPECS_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to driftspecs_gui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DRIFTSPECS_GUI('CALLBACK') and DRIFTSPECS_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DRIFTSPECS_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help driftspecs_gui

% Last Modified by GUIDE v2.5 16-Aug-2021 15:18:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @driftspecs_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @driftspecs_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before driftspecs_gui is made visible.
function driftspecs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.to_return = nargout;

if numel(varargin) < 2
    error('Not enough arguments for driftspecs_gui. 2 required')
end

handles.specs = varargin{1};
culled = varargin{2};

specs_version = 0.1;
% Fill in missing values from default
handles.specs = validate_driftspecs(handles.specs, specs_version, culled);
try
    handles.totalnframes = numel(culled.data{1});
catch ME
    handles.totalnframes = 0; %to be fixed later once debug is less severe
end

% Create new UI elements if they don't exist
handles = create_new_ui_elements(handles);

update_fields_from_specs(handles);
handles.output = handles.specs;

% Update handles structure
guidata(hObject, handles);
set(hObject, 'Resize', 'on');


% --- Outputs from this function are returned to the command line.
function varargout = driftspecs_gui_OutputFcn(hObject, eventdata, handles)
handles.to_return = nargout;
guidata(hObject, handles);

if nargout > 0
    uiwait(handles.figure1);
    handles = guidata(hObject);
    
    varargout{1} = handles.output;
    delete(handles.figure1);
end

function update_fields_from_specs(handles)
s = handles.specs;

set(handles.drift_channel_edit, 'String', num2str(s.channel));

set(handles.npoints_for_alignment_edit, 'String', num2str(s.npoints_for_alignment));
set(handles.nframes_per_alignment_edit, 'String', num2str(s.nframes_per_alignment));
if s.fix_nframes_per_alignment
    set(handles.nframes_per_alignment_edit, 'String', num2str(floor(handles.totalnframes/s.npoints_for_alignment)));
else
    set(handles.nframes_per_alignment_edit, 'String', num2str(s.nframes_per_alignment));
end
 
set(handles.rmax_edit, 'String', num2str(s.rmax));
set(handles.outlier_error_edit, 'String', num2str(s.outlier_error));
set(handles.delta_broad_edit, 'String', num2str(s.delta_broad));
set(handles.delta_narrow_ratio_edit, 'String', num2str(s.delta_narrow_ratio));

set(handles.calc_error_checkbox, 'value', s.calc_error)
set(handles.correctz_checkbox, 'value', s.correctz)
set(handles.broadsweep_checkbox, 'value', s.broadsweep)
set(handles.fix_nframes_per_alignment_checkbox, 'value', s.fix_nframes_per_alignment)
set(handles.skip_correction_checkbox, 'value', s.skip_correction)

% new drift spec options
if isfield(s, 'downsample_flag')
    set(handles.downsample_flag_checkbox, 'value', s.downsample_flag)
else
    set(handles.downsample_flag_checkbox, 'value', 0)
end

if isfield(s, 'points_per_frame')
    set(handles.points_per_frame_edit, 'String', num2str(s.points_per_frame))
else
    set(handles.points_per_frame_edit, 'String', '100')
end

if isfield(s, 'local_tbins_flag')
    set(handles.local_tbins_flag_checkbox, 'value', s.local_tbins_flag)
else
    set(handles.local_tbins_flag_checkbox, 'value', 1)
end

if isfield(s, 'local_tbin_width')
    set(handles.local_tbin_width_edit, 'String', num2str(s.local_tbin_width))
else
    set(handles.local_tbin_width_edit, 'String', '20')
end

interp_methods = {'linear', 'cubic'};
set(handles.interp_method_menu, 'String', interp_methods);
set(handles.interp_method_menu, 'Value', find(strcmp(interp_methods, s.interp_method)));

units_options = {'nm', 'px'};
set(handles.units_menu, 'String', units_options);
set(handles.units_menu, 'Value', find(strcmp(units_options, s.units)));

function specs = update_specs_from_fields(handles)
s = handles.specs;
s.channel = round(str2double(get(handles.drift_channel_edit, 'String')));

s.npoints_for_alignment = round(str2double(get(handles.npoints_for_alignment_edit, 'String')));
if get(handles.fix_nframes_per_alignment_checkbox, 'value')
    s.nframes_per_alignment = floor(handles.totalnframes/str2double(get(handles.npoints_for_alignment_edit, 'String')));
else
    s.nframes_per_alignment = round(str2double(get(handles.nframes_per_alignment_edit, 'String')));
end
s.rmax = (str2double(get(handles.rmax_edit, 'String')));
s.outlier_error = (str2double(get(handles.outlier_error_edit, 'String')));
s.delta_broad = (str2double(get(handles.delta_broad_edit, 'String')));
s.delta_narrow_ratio = (str2double(get(handles.delta_narrow_ratio_edit, 'String')));

s.calc_error = get(handles.calc_error_checkbox, 'value');
s.correctz = get(handles.correctz_checkbox, 'value');
s.broadsweep = get(handles.broadsweep_checkbox, 'value');
s.fix_nframes_per_alignment = get(handles.fix_nframes_per_alignment_checkbox, 'value');
s.skip_correction = get(handles.skip_correction_checkbox, 'value');

% new drift spec options
s.downsample_flag = get(handles.downsample_flag_checkbox, 'value');
s.points_per_frame = round(str2double(get(handles.points_per_frame_edit, 'String')));
s.local_tbins_flag = get(handles.local_tbins_flag_checkbox, 'value');
s.local_tbin_width = round(str2double(get(handles.local_tbin_width_edit, 'String')));

interp_methods = get(handles.interp_method_menu, 'String');
s.interp_method = interp_methods{get(handles.interp_method_menu, 'value')};

units_options = get(handles.units_menu, 'String');
s.units = units_options{get(handles.units_menu, 'value')};

specs = s;

function handles = create_new_ui_elements(handles)
% CREATE_NEW_UI_ELEMENTS Create new UI elements for drift spec options
%   This function programmatically creates UI elements for the new drift spec
%   options that may not exist in the .fig file

% Get the figure handle
fig = handles.figure1;

% Check if the new elements already exist
if ~isfield(handles, 'downsample_flag_checkbox')
    % Create downsample flag checkbox
    handles.downsample_flag_checkbox = uicontrol('Parent', fig, ...
        'Style', 'checkbox', ...
        'String', 'Downsample data', ...
        'Units', 'pixels', ...
        'Position', [20, 50, 150, 25], ...
        'Value', 0, ...
        'Tag', 'downsample_flag_checkbox');
    
    % Create points per frame label and edit box
    handles.text8 = uicontrol('Parent', fig, ...
        'Style', 'text', ...
        'String', 'Points per frame:', ...
        'Units', 'pixels', ...
        'Position', [170, 50, 120, 25], ...
        'HorizontalAlignment', 'left', ...
        'Tag', 'text8');
    
    handles.points_per_frame_edit = uicontrol('Parent', fig, ...
        'Style', 'edit', ...
        'String', '100', ...
        'Units', 'pixels', ...
        'Position', [300, 50, 60, 25], ...
        'Tag', 'points_per_frame_edit');
    
    % Create local tbins flag checkbox
    handles.local_tbins_flag_checkbox = uicontrol('Parent', fig, ...
        'Style', 'checkbox', ...
        'String', 'Use local time bins', ...
        'Units', 'pixels', ...
        'Position', [20, 85, 150, 25], ...
        'Value', 1, ...
        'Tag', 'local_tbins_flag_checkbox');
    
    % Create local tbin width label and edit box
    handles.text9 = uicontrol('Parent', fig, ...
        'Style', 'text', ...
        'String', 'Local tbin width:', ...
        'Units', 'pixels', ...
        'Position', [170, 85, 120, 25], ...
        'HorizontalAlignment', 'left', ...
        'Tag', 'text9');
    
    handles.local_tbin_width_edit = uicontrol('Parent', fig, ...
        'Style', 'edit', ...
        'String', '20', ...
        'Units', 'pixels', ...
        'Position', [300, 85, 60, 25], ...
        'Tag', 'local_tbin_width_edit');
end

function npoints_for_alignment_edit_Callback(hObject, eventdata, handles)
% update nframes_per_alignment
if get(handles.fix_nframes_per_alignment_checkbox, 'value')
    set(handles.nframes_per_alignment_edit, 'String', num2str(floor(handles.totalnframes/str2double(get(handles.npoints_for_alignment_edit, 'String')))));
end


function nframes_per_alignment_edit_Callback(hObject, eventdata, handles)
% update nframes_per_alignment
if get(handles.fix_nframes_per_alignment_checkbox, 'value')
    set(handles.nframes_per_alignment_edit, 'String', num2str(floor(handles.totalnframes/str2double(get(handles.npoints_for_alignment_edit, 'String')))));
end

% --- Executes on button press in return_button.
function return_button_Callback(hObject, eventdata, handles)

handles.specs = update_specs_from_fields(handles);

handles.output = handles.specs;
guidata(hObject, handles);
uiresume(handles.figure1);

if ~handles.to_return
    delete(handles.figure1)
end

function figure1_CloseRequestFcn(~, ~, handles) %#ok<*DEFNU>
uiresume(handles.figure1);
if ~handles.to_return
    delete(handles.figure1)
end


% --- Executes on figure resize.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
if isempty(handles)
    return;
end

% Get the new figure size
fig_pos = get(hObject, 'Position');
width = fig_pos(3);
height = fig_pos(4);

% Set minimum dimensions to prevent overlapping
min_height = 500;
min_width = 600;
if height < min_height
    set(hObject, 'Position', [fig_pos(1), fig_pos(2), width, min_height]);
    height = min_height;
end
if width < min_width
    set(hObject, 'Position', [fig_pos(1), fig_pos(2), min_width, height]);
    width = min_width;
end

% Calculate spacing parameters
element_height = 50;
element_spacing = 25;
vertical_spacing = element_height + element_spacing;
button_height = 30;
button_margin = 20;
left_margin = 20;
right_margin = 20;

% Calculate total required height for all elements
% Count the number of UI element rows
num_elements = 0;
if isfield(handles, 'drift_channel_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'npoints_for_alignment_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'nframes_per_alignment_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'rmax_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'outlier_error_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'delta_broad_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'delta_narrow_ratio_edit'), num_elements = num_elements + 1; end
if isfield(handles, 'correctz_checkbox'), num_elements = num_elements + 1; end
if isfield(handles, 'downsample_flag_checkbox'), num_elements = num_elements + 1; end
if isfield(handles, 'local_tbins_flag_checkbox'), num_elements = num_elements + 1; end
if isfield(handles, 'interp_method_menu'), num_elements = num_elements + 1; end
if isfield(handles, 'units_menu'), num_elements = num_elements + 1; end

total_required_height = (num_elements * vertical_spacing) + button_height + (button_margin * 2);

% If height is insufficient, adjust it
if height < total_required_height
    set(hObject, 'Position', [fig_pos(1), fig_pos(2), width, total_required_height]);
    height = total_required_height;
end

% Start positioning from the top, leaving margin
current_y = height - button_margin - button_height;

% Position return button at bottom
if isfield(handles, 'return_button')
    set(handles.return_button, 'Position', [width - right_margin - 100, button_margin, 100, button_height]);
end

% Position UI elements from top to bottom
% Units menu
if isfield(handles, 'units_menu') && isfield(handles, 'text11')
    set(handles.text11, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.units_menu, 'Position', [left_margin + 110, current_y, 100, element_height]);
    current_y = current_y - vertical_spacing;
end

% Interpolation method menu
if isfield(handles, 'interp_method_menu') && isfield(handles, 'text10')
    set(handles.text10, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.interp_method_menu, 'Position', [left_margin + 110, current_y, 100, element_height]);
    current_y = current_y - vertical_spacing;
end

% Local tbins flag checkbox and width
if isfield(handles, 'local_tbins_flag_checkbox')
    set(handles.local_tbins_flag_checkbox, 'Position', [left_margin, current_y, 150, element_height]);
    if isfield(handles, 'local_tbin_width_edit')
        set(handles.local_tbin_width_edit, 'Position', [left_margin + 300, current_y, 60, element_height]);
        % Add label if it exists
        if isfield(handles, 'text9')
            set(handles.text9, 'Position', [left_margin + 170, current_y, 120, element_height]);
        end
    end
    current_y = current_y - vertical_spacing;
end

% Downsample flag checkbox and points per frame
if isfield(handles, 'downsample_flag_checkbox')
    set(handles.downsample_flag_checkbox, 'Position', [left_margin, current_y, 150, element_height]);
    if isfield(handles, 'points_per_frame_edit')
        set(handles.points_per_frame_edit, 'Position', [left_margin + 300, current_y, 60, element_height]);
        % Add label if it exists
        if isfield(handles, 'text8')
            set(handles.text8, 'Position', [left_margin + 170, current_y, 120, element_height]);
        end
    end
    current_y = current_y - vertical_spacing;
end

% Checkboxes row
if isfield(handles, 'correctz_checkbox') || isfield(handles, 'broadsweep_checkbox') || isfield(handles, 'calc_error_checkbox') || isfield(handles, 'skip_correction_checkbox')
    checkbox_width = 150;
    checkbox_spacing = 20;
    checkbox_x = left_margin;
    
    if isfield(handles, 'correctz_checkbox')
        set(handles.correctz_checkbox, 'Position', [checkbox_x, current_y, checkbox_width, element_height]);
        checkbox_x = checkbox_x + checkbox_width + checkbox_spacing;
    end
    if isfield(handles, 'broadsweep_checkbox')
        set(handles.broadsweep_checkbox, 'Position', [checkbox_x, current_y, checkbox_width, element_height]);
        checkbox_x = checkbox_x + checkbox_width + checkbox_spacing;
    end
    if isfield(handles, 'calc_error_checkbox')
        set(handles.calc_error_checkbox, 'Position', [checkbox_x, current_y, checkbox_width, element_height]);
        checkbox_x = checkbox_x + checkbox_width + checkbox_spacing;
    end
    if isfield(handles, 'skip_correction_checkbox')
        set(handles.skip_correction_checkbox, 'Position', [checkbox_x, current_y, 150, element_height]);
    end
    current_y = current_y - vertical_spacing;
end

% Delta narrow ratio
if isfield(handles, 'delta_narrow_ratio_edit') && isfield(handles, 'text7')
    set(handles.text7, 'Position', [left_margin, current_y, 120, element_height]);
    set(handles.delta_narrow_ratio_edit, 'Position', [left_margin + 130, current_y, 60, element_height]);
    current_y = current_y - vertical_spacing;
end

% Delta broad
if isfield(handles, 'delta_broad_edit') && isfield(handles, 'text6')
    set(handles.text6, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.delta_broad_edit, 'Position', [left_margin + 110, current_y, 60, element_height]);
    current_y = current_y - vertical_spacing;
end

% Outlier error
if isfield(handles, 'outlier_error_edit') && isfield(handles, 'text5')
    set(handles.text5, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.outlier_error_edit, 'Position', [left_margin + 110, current_y, 60, element_height]);
    current_y = current_y - vertical_spacing;
end

% Rmax
if isfield(handles, 'rmax_edit') && isfield(handles, 'text4')
    set(handles.text4, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.rmax_edit, 'Position', [left_margin + 110, current_y, 60, element_height]);
    current_y = current_y - vertical_spacing;
end

% Nframes per alignment
if isfield(handles, 'nframes_per_alignment_edit') && isfield(handles, 'text3')
    set(handles.text3, 'Position', [left_margin, current_y, 150, element_height]);
    set(handles.nframes_per_alignment_edit, 'Position', [left_margin + 160, current_y, 60, element_height]);
    if isfield(handles, 'fix_nframes_per_alignment_checkbox')
        set(handles.fix_nframes_per_alignment_checkbox, 'Position', [left_margin + 230, current_y, 300, element_height]);
    end
    current_y = current_y - vertical_spacing;
end

% Npoints for alignment
if isfield(handles, 'npoints_for_alignment_edit') && isfield(handles, 'text2')
    set(handles.text2, 'Position', [left_margin, current_y, 150, element_height]);
    set(handles.npoints_for_alignment_edit, 'Position', [left_margin + 160, current_y, 60, element_height]);
    current_y = current_y - vertical_spacing;
end

% Drift channel
if isfield(handles, 'drift_channel_edit') && isfield(handles, 'text1')
    set(handles.text1, 'Position', [left_margin, current_y, 100, element_height]);
    set(handles.drift_channel_edit, 'Position', [left_margin + 110, current_y, 60, element_height]);
end