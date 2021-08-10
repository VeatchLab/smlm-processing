function varargout = res_specs_gui(varargin)
% RES_SPECS_GUI MATLAB code for res_specs_gui.fig
%      RES_SPECS_GUI, by itself, creates a new RES_SPECS_GUI or raises the existing
%      singleton*.
%
%      H = RES_SPECS_GUI returns the handle to a new RES_SPECS_GUI or the handle to
%      the existing singleton*.
%
%      RES_SPECS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RES_SPECS_GUI.M with the given input arguments.
%
%      RES_SPECS_GUI('Property','Value',...) creates a new RES_SPECS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before res_specs_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to res_specs_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help res_specs_gui

% Last Modified by GUIDE v2.5 10-Aug-2021 14:16:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @res_specs_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @res_specs_gui_OutputFcn, ...
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


% --- Executes just before res_specs_gui is made visible.
function res_specs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.to_return = nargout;
if numel(varargin) > 0
    handles.specs = varargin{1};
else
    handles.specs = resolution_default('nm');
end

% Fill in missing values from default
r = resolution_default(handles.specs.units);
f = fieldnames(r);
for i = 1:numel(f)
    if ~isfield(handles.specs, f{i})
        handles.specs.(f{i}) = r.(f{i});
    end
end

update_fields_from_specs(handles);
handles.output = handles.specs;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes res_specs_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = res_specs_gui_OutputFcn(hObject, eventdata, handles) 
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

set(handles.Npts_edit, 'String', num2str(s.Npts));
set(handles.rmax_edit, 'String', num2str(s.rmax));
set(handles.binsize_edit, 'String', num2str(s.binsize));

set(handles.show_diagnostics_checkbox, 'value', s.show_diagnostics)

units_options = {'nm', 'px'};
set(handles.units_menu, 'String', units_options);
set(handles.units_menu, 'Value', find(strcmp(units_options, s.units)));

function specs = update_specs_from_fields(handles)
s = handles.specs;
s.Npts = round(str2double(get(handles.Npts_edit, 'String')));
s.rmax = round(str2double(get(handles.rmax_edit, 'String')));
s.binsize = round(str2double(get(handles.binsize_edit, 'String')));

s.show_diagnostics = get(handles.show_diagnostics_checkbox, 'value');

units_options = get(handles.units_menu, 'String');
s.units = units_options{get(handles.units_menu, 'value')};

specs = s;



function Npts_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Npts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Npts_edit as text
%        str2double(get(hObject,'String')) returns contents of Npts_edit as a double


% --- Executes during object creation, after setting all properties.
function Npts_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Npts_edit (see GCBO)
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



function binsize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to binsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binsize_edit as text
%        str2double(get(hObject,'String')) returns contents of binsize_edit as a double


% --- Executes during object creation, after setting all properties.
function binsize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in return_button.
function return_button_Callback(hObject, eventdata, handles)
% hObject    handle to return_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.specs = update_specs_from_fields(handles);

handles.output = handles.specs;
guidata(hObject, handles);
uiresume(handles.figure1);

if ~handles.to_return
    delete(handles.figure1)
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


% --- Executes on button press in show_diagnostics_checkbox.
function show_diagnostics_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_diagnostics_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_diagnostics_checkbox
