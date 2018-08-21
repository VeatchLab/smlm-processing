function varargout = driftspecs_gui(varargin)
% DRIFTSPECS_GUI MATLAB code for driftspecs_gui.fig
%      DRIFTSPECS_GUI, by itself, creates a new DRIFTSPECS_GUI or raises the existing
%      singleton*.
%
%      H = DRIFTSPECS_GUI returns the handle to a new DRIFTSPECS_GUI or the handle to
%      the existing singleton*.
%
%      DRIFTSPECS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRIFTSPECS_GUI.M with the given input arguments.
%
%      DRIFTSPECS_GUI('Property','Value',...) creates a new DRIFTSPECS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before driftspecs_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to driftspecs_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help driftspecs_gui

% Last Modified by GUIDE v2.5 21-Aug-2018 09:57:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @driftspecs_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @driftspecs_gui_OutputFcn, ...
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


% --- Executes just before driftspecs_gui is made visible.
function driftspecs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.to_return = nargout;
if numel(varargin) > 0
    handles.specs = varargin{1};
else
    handles.specs = drift_default('nm', 'gaussianPSF');
end

% Fill in missing values from default
d = drift_default(handles.specs.units, 'gaussianPSF');
f = fieldnames(d);
for i = 1:numel(f)
    if ~isfield(handles.specs, f{i})
        handles.specs.(f{i}) = d.(f{i});
    end
end

update_fields_from_specs(handles);
handles.output = handles.specs;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = driftspecs_gui_OutputFcn(hObject, ~, handles)
handles.to_return = nargout;
guidata(hObject, handles);

if nargout > 0
    uiwait(handles.figure1);'gaussianPSF'
    handles = guidata(hObject);
    
    varargout{1} = handles.output;
    delete(handles.figure1);
end


function update_fields_from_specs(handles)
s = handles.specs;

set(handles.drift_channel_edit, 'String', num2str(s.channel));

set(handles.npoints_for_alignment_edit, 'String', num2str(s.npoints_for_alignment));
set(handles.nframes_per_alignment_edit, 'String', num2str(s.nframes_per_alignment));
set(handles.psize_for_alignment_edit, 'String', num2str(s.psize_for_alignment));
set(handles.rmax_shift_edit, 'String', num2str(s.rmax_shift));
set(handles.rmax_edit, 'String', num2str(s.rmax));
set(handles.sigma_startpt_edit, 'String', num2str(s.sigma_startpt));

set(handles.update_reference_flag_checkbox, 'value', s.update_reference_flag)
set(handles.include_diagnostics_checkbox, 'value', s.include_diagnostics)
%set(handles.show_diagnostics_flag_checkbox, 'value', s.show_diagnostics)
set(handles.correctz_checkbox, 'value', s.correctz)

interp_methods = {'linear', 'cubic'};
set(handles.interp_method_menu, 'String', interp_methods);
set(handles.interp_method_menu, 'Value', find(strcmp(interp_methods, s.interp_method)));

units_options = {'nm', 'px'};
set(handles.units_menu, 'String', units_options);
set(handles.units_menu, 'Value', find(strcmp(units_options, s.units)));

function specs = update_specs_from_fields(handles)

s.channel = round(str2double(get(handles.drift_channel_edit)));

s.npoints_for_alignment = round(str2double(get(handles.npoints_for_alignment_edit, 'String')));
s.nframes_per_alignment = round(str2double(get(handles.nframes_per_alignment_edit, 'String')));
s.psize_for_alignment = (str2double(get(handles.psize_for_alignment_edit, 'String')));
s.rmax_shift = (str2double(get(handles.rmax_shift_edit, 'String')));
s.rmax = (str2double(get(handles.rmax_edit, 'String')));
s.sigma_startpt = (str2double(get(handles.sigma_startpt_edit, 'String')));

s.update_reference_flag = get(handles.update_reference_flag_checkbox, 'value');
s.include_diagnostics = get(handles.include_diagnostics_checkbox, 'value');
%s.show_diagnostics = get(handles.show_diagnostics_checkbox, 'value');
s.correctz = get(handles.correctz_checkbox, 'value');

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



function psize_for_alignment_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psize_for_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psize_for_alignment_edit as text
%        str2double(get(hObject,'String')) returns contents of psize_for_alignment_edit as a double


% --- Executes during object creation, after setting all properties.
function psize_for_alignment_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psize_for_alignment_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rmax_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rmax_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmax_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of rmax_shift_edit as a double


% --- Executes during object creation, after setting all properties.
function rmax_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmax_shift_edit (see GCBO)
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



function sigma_startpt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_startpt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_startpt_edit as text
%        str2double(get(hObject,'String')) returns contents of sigma_startpt_edit as a double


% --- Executes during object creation, after setting all properties.
function sigma_startpt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_startpt_edit (see GCBO)
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


% --- Executes on button press in update_reference_flag_checkbox.
function update_reference_flag_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to update_reference_flag_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of update_reference_flag_checkbox


% --- Executes on button press in include_diagnostics_checkbox.
function include_diagnostics_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to include_diagnostics_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of include_diagnostics_checkbox


% --- Executes on button press in correctz_checkbox.
function correctz_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to correctz_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctz_checkbox


% --- Executes on button press in display_diagnostics_checkbox.
function display_diagnostics_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to display_diagnostics_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_diagnostics_checkbox


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
