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

% Last Modified by GUIDE v2.5 26-Jul-2021 14:19:11

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
if numel(varargin) > 0
    handles.specs = varargin{1};
end
if numel(varargin) > 1
   culled = varargin{2};
   % Fill in missing values from default
    if isfield(culled.data{1}(1), 'z')
        d = drift_default(culled, 'spline');
    else    
        d = drift_default(culled, 'gaussianPSF');
    end
else
    handles.specs = drift_default('nm', 'gaussianPSF');
    d = handles.specs;
end

% Fill in missing values from default
f = fieldnames(d);
for i = 1:numel(f)
    if ~isfield(handles.specs, f{i})
        handles.specs.(f{i}) = d.(f{i});
    end
end

handles.totalnframes = numel(culled.data{1});
update_fields_from_specs(handles);
handles.output = handles.specs;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes driftspecs_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
% hObject    handle to npoints_for_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of npoints_for_alignment_edit as text
%        str2double(get(hObject,'String')) returns contents of npoints_for_alignment_edit as a double

% update nframes_per_alignment
if get(handles.fix_nframes_per_alignment_checkbox, 'value')
    set(handles.nframes_per_alignment_edit, 'String', num2str(floor(handles.totalnframes/str2double(get(handles.npoints_for_alignment_edit, 'String')))));
end


% --- Executes during object creation, after setting all properties.
function npoints_for_alignment_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to npoints_for_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nframes_per_alignment_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nframes_per_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nframes_per_alignment_edit as text
%        str2double(get(hObject,'String')) returns contents of nframes_per_alignment_edit as a double

% update nframes_per_alignment
if get(handles.fix_nframes_per_alignment_checkbox, 'value')
    set(handles.nframes_per_alignment_edit, 'String', num2str(floor(handles.totalnframes/str2double(get(handles.npoints_for_alignment_edit, 'String')))));
end


% --- Executes during object creation, after setting all properties.
function nframes_per_alignment_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nframes_per_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delta_broad_edit_Callback(hObject, eventdata, handles)
% hObject    handle to delta_broad_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delta_broad_edit as text
%        str2double(get(hObject,'String')) returns contents of delta_broad_edit as a double


% --- Executes during object creation, after setting all properties.
function delta_broad_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delta_broad_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmax_edit as text
%        str2double(get(hObject,'String')) returns contents of rmax_edit as a double


% --- Executes during object creation, after setting all properties.
function rmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in units_menu.
function units_menu_Callback(hObject, eventdata, handles)
% hObject    handle to units_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns units_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from units_menu


% --- Executes during object creation, after setting all properties.
function units_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in interp_method_menu.
function interp_method_menu_Callback(hObject, eventdata, handles)
% hObject    handle to interp_method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns interp_method_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from interp_method_menu


% --- Executes during object creation, after setting all properties.
function interp_method_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interp_method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in broadsweep_checkbox.
function broadsweep_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to broadsweep_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of broadsweep_checkbox


% --- Executes on button press in correctz_checkbox.
function correctz_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to correctz_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctz_checkbox


% --- Executes on button press in calc_error_checkbox.
function calc_error_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to calc_error_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calc_error_checkbox


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



function drift_channel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to drift_channel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drift_channel_edit as text
%        str2double(get(hObject,'String')) returns contents of drift_channel_edit as a double


% --- Executes during object creation, after setting all properties.
function drift_channel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drift_channel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_error_edit_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_error_edit as text
%        str2double(get(hObject,'String')) returns contents of outlier_error_edit as a double


% --- Executes during object creation, after setting all properties.
function outlier_error_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlier_error_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delta_narrow_ratio_edit_Callback(hObject, eventdata, handles)
% hObject    handle to delta_narrow_ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delta_narrow_ratio_edit as text
%        str2double(get(hObject,'String')) returns contents of delta_narrow_ratio_edit as a double


% --- Executes during object creation, after setting all properties.
function delta_narrow_ratio_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delta_narrow_ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in skip_correction_checkbox.
function skip_correction_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to skip_correction_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skip_correction_checkbox


% --- Executes on button press in fix_nframes_per_alignment_checkbox.
function fix_nframes_per_alignment_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to fix_nframes_per_alignment_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fix_nframes_per_alignment_checkbox
