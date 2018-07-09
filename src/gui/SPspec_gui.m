function varargout = SPspec_gui(varargin)
% SPSPEC_GUI MATLAB code for SPspec_gui.fig
%      SPSPEC_GUI, by itself, creates a new SPSPEC_GUI or raises the existing
%      singleton*.
%
%      H = SPSPEC_GUI returns the handle to a new SPSPEC_GUI or the handle to
%      the existing singleton*.
%
%      SPSPEC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPSPEC_GUI.M with the given input arguments.
%
%      SPSPEC_GUI('Property','Value',...) creates a new SPSPEC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SPspec_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SPspec_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SPspec_gui

% Last Modified by GUIDE v2.5 08-May-2018 12:37:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SPspec_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SPspec_gui_OutputFcn, ...
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


% --- Executes just before SPspec_gui is made visible.
function SPspec_gui_OpeningFcn(hObject, ~, handles, varargin)
% Get arguments
handles.specs = default_specs_dualview();
if numel(varargin) > 0
    handles.specs = varargin{1};
end

handles.nchan = numel(handles.specs);
handles.channel = 1;

chan_strs = arrayfun(@(n) ['Channel ' num2str(n)], 1:handles.nchan,...
    'UniformOutput', false);
set(handles.channel_menu, 'String', chan_strs);
set(handles.channel_menu, 'Value', handles.channel);

handles.cameras = {'emccd', 'scmos'};
set(handles.cam_type_menu, 'String', handles.cameras);

handles = init_filenames(handles);

update_fields_from_specs(handles, handles.channel);

handles.output = handles.specs;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SPspec_gui_OutputFcn(hObject, ~, handles)
handles.to_return = nargout;
guidata(hObject, handles);
if nargout > 0
    uiwait(handles.figure1);
    handles = guidata(hObject);
    
    varargout{1} = handles.output;

    delete(handles.figure1);
end

%%%%%%%%%%%%%%%%%%%%%%%% My functions
function update_fields_from_specs(handles, channel)
specs = handles.specs;
setup_table(handles);
handles.selectedrows = [];

s = specs(handles.channel);
set(handles.cdim1_edit, 'String', num2str(s.channel_dims(1)));
set(handles.cdim2_edit, 'String', num2str(s.channel_dims(2)));
set(handles.cdim3_edit, 'String', num2str(s.channel_dims(3)));
set(handles.cdim4_edit, 'String', num2str(s.channel_dims(4)));

set(handles.thresh_edit, 'String', num2str(s.thresh));
bg_types = {'median', 'mean', 'selective', 'none'};
bg_methods = {'standard', 'true', 'unif'};
set(handles.bg_type_menu, 'String', bg_types);
set(handles.bg_type_menu, 'Value', find(strcmp(bg_types, s.bg_type)));
set(handles.bg_method_menu, 'String', bg_methods);
set(handles.bg_method_menu, 'Value', find(strcmp(bg_methods, s.bg_method)));

set(handles.cam_name_edit, 'String', s.camera_specs.name);
vals = get(handles.cam_type_menu, 'String');
val = find(strcmp(vals, s.camera_specs.type));
set(handles.cam_type_menu, 'Value', val);
set(handles.mag_edit, 'String', num2str(s.camera_specs.magnification));
set(handles.psize_edit, 'String', num2str(s.camera_specs.pixel_size));

cspec_eq = true;
cspec = specs(handles.channel).camera_specs;
for i = 1:handles.nchan
    cspec_eq = cspec_eq && isequal(specs(i).camera_specs, cspec);
end

if cspec_eq
    set(handles.lock_cameras_checkbox, 'Value', 1);
else
    set(handles.lock_cameras_checkbox, 'Value', 0);
end

set(handles.PSFwidth_edit, 'String', num2str(s.PSFwidth));
set(handles.r_centroid_edit, 'String', num2str(s.r_centroid));
set(handles.r_neighbor_edit, 'String', num2str(s.r_neighbor));

set(handles.nmax_edit, 'String', num2str(s.nmax/1000));
set(handles.mle_iters_edit, 'String', num2str(s.mle_iters));

function setup_table(handles)

data = [handles.all_fnames(:), num2cell(handles.whichchannels)];

set(handles.fnames_table, 'Data', data);

function handles = update_fnames_from_table(handles)
tdata = get(handles.fnames_table, 'Data');
handles.all_fnames = tdata(:,1)';
handles.whichchannels = cell2mat(tdata(:,2:end));
if ~isempty(handles.whichchannels)
    for i = 1:handles.nchan
        handles.specs(i).movie_fnames = ...
            handles.all_fnames(handles.whichchannels(:,i));
    end
else
    [handles.specs.movie_fnames] = deal({});
end

function add_files(handles, files)
files = setdiff(files, handles.all_fnames, 'stable');
newdata = [files(:), repmat({true}, numel(files), handles.nchan)];
newdata = vertcat(get(handles.fnames_table, 'Data'), newdata);
set(handles.fnames_table, 'Data', newdata);

function handles = init_filenames(handles)
all_fnames = unique([handles.specs.movie_fnames],'stable');
handles.all_fnames = all_fnames;

nmov = numel(all_fnames);
nchan = handles.nchan;

% whichchannels(imov, ichan) is True iff imov has data for ichan
whichchannels = false(nmov, nchan);
imovchan = ones(1,handles.nchan);
nmovchan = arrayfun(@(s) numel(s.movie_fnames), handles.specs);
for imov = 1:numel(all_fnames)
    f = all_fnames{imov};
    for ichan = find(imovchan <= nmovchan)
        fchan = handles.specs(ichan).movie_fnames{imovchan(ichan)};
        if strcmp(f,fchan) % channel ichan has this movie
            imovchan(ichan) = imovchan(ichan) + 1;
            whichchannels(imov,ichan) = true;
        end
    end 
end

handles.whichchannels = whichchannels;


%%%%%%%%%%%%%%%%%%%%%%%%% Callbacks
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(~, ~, handles) %#ok<*DEFNU>
uiresume(handles.figure1);

if ~handles.to_return
    delete(handles.figure1)
end

function return_button_Callback(hObject, ~, handles)
handles.output = handles.specs;
guidata(hObject, handles);
uiresume(handles.figure1);

if ~handles.to_return
    delete(handles.figure1)
end

function channel_menu_Callback(hObject, ~, handles)
handles.channel = get(hObject, 'Value');
update_fields_from_specs(handles, handles.channel);
guidata(hObject, handles);


function fnames_table_CellEditCallback(hObject, ~, handles)
guidata(hObject, update_fnames_from_table(handles));

function add_files_button_Callback(hObject, ~, handles)
[newfiles, newpaths] = uigetfile('*.tif;*.Tif;*.tiff',...
    'Select multiple movies...', 'MultiSelect', 'on');
if ~isempty(newfiles)
    if ~iscell(newfiles)
        newfiles = {newfiles};
    end
    for i = 1:numel(newfiles)
        if ~strcmp(cd, newpaths(1:(end-1)))
            newfiles{i} = [newpaths, newfiles{i}];
        end
    end
end
add_files(handles, newfiles);
guidata(hObject, update_fnames_from_table(handles));

function add_re_button_Callback(hObject, ~, handles)
newre = inputdlg({'Give an expression to glob for'}, 'add files by glob',...
    1, {'mov*.tif'});
if ~isempty(newre)
    newfiles = glob_fnames(newre{1});
    add_files(handles,newfiles);
    guidata(hObject, update_fnames_from_table(handles));
end

function remove_button_Callback(hObject, ~, handles)
d = get(handles.fnames_table, 'Data');
inds = setdiff(1:size(d,1), handles.selectedrows);
set(handles.fnames_table, 'Data', d(inds, :));
handles.selectedrows = [];
guidata(hObject, update_fnames_from_table(handles));

function thresh_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
set(hObject, 'String', num2str(val));
handles.specs(handles.channel).thresh = val;
guidata(hObject, handles);

function fnames_table_CellSelectionCallback(hObject, eventdata, handles)
handles.selectedrows = eventdata.Indices(:,1);
guidata(hObject,handles);

function thresh_diag_button_Callback(~, ~, handles)
threshold_diagnostics(handles.all_fnames);

function cdim1_edit_Callback(hObject, ~, handles)
handles.specs(handles.channel).channel_dims(1) = ...
    round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
function cdim2_edit_Callback(hObject, ~, handles)
handles.specs(handles.channel).channel_dims(2) = ...
    round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
function cdim3_edit_Callback(hObject, ~, handles)
handles.specs(handles.channel).channel_dims(3) = ...
    round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
function cdim4_edit_Callback(hObject, ~, handles)
handles.specs(handles.channel).channel_dims(4) = ...
    round(str2double(get(hObject, 'String')));
guidata(hObject, handles);

function PSFwidth_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.specs(handles.channel).PSFwidth = val;
guidata(hObject, handles);
function r_centroid_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.specs(handles.channel).r_centroid = val;
guidata(hObject, handles);
function r_neighbor_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.specs(handles.channel).r_neighbor = val;
guidata(hObject, handles);

function lock_cameras_checkbox_Callback(hObject, ~, handles)
if get(hObject, 'Value')
    [handles.specs.camera_specs] = deal(handles.specs(handles.channel).camera_specs);
end

function cam_name_edit_Callback(hObject, ~, handles)
val = get(hObject, 'String');
if get(handles.lock_cameras_checkbox, 'Value')
    cs = handles.specs(handles.channel).camera_specs;
    cs.name = val;
    [handles.specs(:).camera_specs] = deal(cs);
else
    handles.specs(handles.channel).camera_specs.name = val;
end
guidata(hObject, handles);
function psize_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
if get(handles.lock_cameras_checkbox, 'Value')
    cs = handles.specs(handles.channel).camera_specs;
    cs.pixel_size = val;
    [handles.specs(:).camera_specs] = deal(cs);
else
    handles.specs(handles.channel).camera_specs.pixel_size = val;
end
guidata(hObject, handles);
function mag_edit_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
if get(handles.lock_cameras_checkbox, 'Value')
    cs = handles.specs(handles.channel).camera_specs;
    cs.magnification = val;
    [handles.specs(:).camera_specs] = deal(cs);
else
    handles.specs(handles.channel).camera_specs.magnification = val;
end
guidata(hObject, handles);
function cam_type_menu_Callback(hObject, ~, handles)
vals = get(hObject, 'String');
val = vals{get(hObject, 'Value')};
if get(handles.lock_cameras_checkbox, 'Value')
    cs = handles.specs(handles.channel).camera_specs;
    cs.type = val;
    [handles.specs(:).camera_specs] = deal(cs);
else
    handles.specs(handles.channel).camera_specs.type = val;
end

function bg_type_menu_Callback(hObject, ~, handles)
vals = get(hObject, 'String');
val = vals{get(hObject, 'Value')};
handles.specs(handles.channel).bg_type = val;
guidata(hObject, handles);
function bg_method_menu_Callback(hObject, ~, handles)
vals = get(hObject, 'String');
val = vals{get(hObject, 'Value')};
handles.specs(handles.channel).bg_method = val;
guidata(hObject, handles);

function fitsigma_checkbox_Callback(hObject, ~, handles)
val = get(hObject, 'Value');
handles.specs(handles.channel).fitsigma = val;
guidata(hObject, handles);

function mle_iters_edit_Callback(hObject, ~, handles)
val = round(str2double(get(hObject, 'String')));
set(hObject, 'String', num2str(val));
handles.specs(handles.channel).mle_iters = val;
guidata(hObject,handles);
function nmax_edit_Callback(hObject, ~, handles)
val = round(str2double(get(hObject, 'String'))*1000);
set(hObject, 'String', num2str(val/1000));
handles.specs(handles.channel).nmax = val;
guidata(hObject,handles);
