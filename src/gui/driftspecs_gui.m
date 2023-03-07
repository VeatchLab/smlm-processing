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

% Last Modified by GUIDE v2.5 04-Mar-2023 04:17:04

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

handles.totalnframes = numel(culled.data{1});
update_fields_from_specs(handles);
handles.output = handles.specs;

% Update handles structure
guidata(hObject, handles);

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

interp_methods = get(handles.interp_method_menu, 'String');
s.interp_method = interp_methods{get(handles.interp_method_menu, 'value')};

units_options = get(handles.units_menu, 'String');
s.units = units_options{get(handles.units_menu, 'value')};

specs = s;

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
