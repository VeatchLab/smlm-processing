function varargout = coriolis_gui(varargin) %#ok<*NASGU>
% CORIOLIS_GUI MATLAB code for coriolis_gui.fig
%      CORIOLIS_GUI, by itself, creates a new CORIOLIS_GUI or raises the existing
%      singleton*.
%
%      H = CORIOLIS_GUI returns the handle to a new CORIOLIS_GUI or the handle to
%      the existing singleton*.
%
%      CORIOLIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CORIOLIS_GUI.M with the given input arguments.
%
%      CORIOLIS_GUI('Property','Value',...) creates a new CORIOLIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coriolis_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coriolis_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coriolis_gui

% Last Modified by GUIDE v2.5 13-Jun-2018 18:54:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coriolis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @coriolis_gui_OutputFcn, ...
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

function coriolis_gui_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% Deal with files and stuff
handles.here = cd;
if exist('./record.mat', 'file')
    handles.record_fname = 'record.mat';
    handles = load_all(handles);
    guidata(hObject, handles);
else
    % ask whether to load another file or make a new one
    question = 'record.mat not found: make new record or open record with other name?';
    answer = questdlg(question, 'record...', 'New record', 'Open record', 'Cancel',...
                        'New record');
    switch answer
        case 'Cancel'
            % exit immediately
            close(handles.figure1);
            return;
        case 'New record'
            % Ask: single or dual, and a filename
            new_button_Callback(handles.new_button, [], handles)
        case 'Open record'
            % like pressing 'choose'
            choose_button_Callback(handles.choose_button, [], handles)
    end

end

function varargout = coriolis_gui_OutputFcn(hObject, ~, handles)
if ~isempty(handles)
    varargout{1} = handles.output;
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if data_since_last_save(handles)
    answer = questdlg({'At least one dataset has been modified since last save.',...
        'Close without saving?'});

    switch answer
        case {'No', 'Cancel'}
            return;
    end
end
delete(hObject);

%% My functions
function set_fname_fields(handles)
record = handles.record;

set(handles.fname_text, 'String', handles.record_fname);

% set edit fields to show real filenames
set(handles.fits_fname_edit, 'String', record.fits_fname);
set(handles.transformed_fname_edit, 'String', record.transformed_fname);
set(handles.dilated_fname_edit, 'String', record.dilated_fname);
set(handles.culled_fname_edit, 'String', record.culled_fname);
set(handles.final_fname_edit, 'String', record.final_fname);

% enable/disable transform stuff depending on record.tform_channel
function tform_uielements_enable_disable(handles)
tform_channel = handles.record.tform_channel;

if isempty(tform_channel)
    set(handles.choose_transform_button, 'Enable', 'off');
    set(handles.transformed_fname_edit, 'Enable', 'off');
    set(handles.tform_checkbox, 'Value', false);
else
    set(handles.choose_transform_button, 'Enable', 'on');
    set(handles.transformed_fname_edit, 'Enable', 'on');
    set(handles.tform_checkbox, 'Value', true);
end

function handles = load_all(handles)
% record: load if it exists, make a new one if not
% CHANGE this when record struct is updated
record_version = 0.1;

if exist(handles.record_fname, 'file')
    record = validate_record(load(handles.record_fname), record_version);
    handles.nchannels = numel(record.SPspecs);
else
    % This is here because load_all is called after a new record_fname is chosen
    record = SP_record_default(handles.nchannels);
    record = validate_record(record, record_version);
end

handles.record = record;

set_fname_fields(handles);

cd(handles.here);

% enable/disable buttons/fields depending on nchannels
if handles.nchannels == 1
    set(handles.cullspec2_button, 'Enable', 'off');
elseif handles.nchannels == 2
    set(handles.cullspec2_button, 'Enable', 'on');
else
    warning('I don''t know how to handle that number of channels, proceed at own risk');
end

% see if you can apply_shifts
if isfield(record, 'drift_info') && ~isempty(record.drift_info)
    set(handles.apply_drift_button, 'Enable', 'on');
else
    set(handles.apply_drift_button, 'Enable', 'off');
end
% enable/disable transform stuff depending on record.transform_channel
tform_uielements_enable_disable(handles);

% datasets
fnames = {record.fits_fname, record.transformed_fname, ...
    record.dilated_fname, record.culled_fname, record.final_fname};
snames = {'fits', 'transformed', 'dilated', 'culled', 'final'};

ask_if_older = true;

% for each dataset
for i = 1:numel(fnames)
    if isfield(handles, snames{i})
        s = handles.(snames{i});
    else
        s = [];
    end
    
    % decide whether to load, depending on dates and user input
    if exist(fnames{i}, 'file')
        ss = load(fnames{i}, 'date');
        
        if ~isfield(handles, snames{i}) || isempty(handles.(snames{i}))
            timediff = Inf;
        else
            timediff = ss.date - handles.(snames{i}).date;
        end
        
        if timediff == 0
            % loaded file and saved file are the same
            loadthis = false;
        elseif timediff < 0 && ask_if_older
            % file is older, ask what to do
            msg = {sprintf(...
                'File for %s is older than the struct in memory',...
                snames{i}), 'What should I do?'};
            answer = questdlg(msg, 'Overwrite struct?', ...
                'Load', 'Skip', 'Load all',...
                'Load');
            switch answer
                case 'Skip'
                    loadthis = false;
                case 'Load all'
                    loadthis = true;
                    ask_if_older = false;
                case 'Load'
                    loadthis = true;
            end
        else
            loadthis = true;
        end
    else
        loadthis = false;
    end
    
    stat_field = [snames{i} '_stat'];        
    if loadthis
        s.date = ss.date;
        s.data = [];
        s.fname = fnames{i};
        status_str = {'loaded from file', char(s.date)};
        if isfield(handles, stat_field)
            set(handles.(stat_field), 'String', status_str);
        end
    end

    handles.(snames{i}) = s;
        
end

handles.last_save_date = datetime;
guidata(handles.figure1, handles);

% Save everything that should be saved
function save_all(handles)
tic;
record = handles.record;

here_now = cd;
cd(handles.here);

% save record
fprintf('Saving record as %s\n', handles.record_fname);
save(handles.record_fname, '-struct', 'record');

% save datasets
datanames = {'fits', 'transformed', 'dilated', 'culled', 'final'};
cellfun(@(name) savedataset(handles, name), datanames);

fprintf('Done with save_all: %f s\n', toc);
handles.last_save_date = datetime;
guidata(handles.figure1, handles);
cd(here_now);

function tf = data_since_last_save(handles)
t_data = [];
datanames = {'fits', 'transformed', 'dilated', 'culled', 'final'};
for i = 1:numel(datanames)
    if isfield(handles, datanames{i}) && isfield(handles.(datanames{i}), 'date')
        d = handles.(datanames{i}).date;
        if isempty(t_data) || (d - t_data) > 0
            t_data = d;
        end
    end
end

tf = ((t_data - handles.last_save_date) > 0);

% Get filename for new record
function fname = ask_for_record_fname(titlestr)
answer = inputdlg({'Input name for new record file:'}, titlestr, 1, {'record.mat'});

if isempty(answer) % user pressed cancel
    fname = '';
else
    fname = mat_ify(answer{1});
end

% add .mat if appropriate
function fname = mat_ify(fname)
if isempty(fname)
    return;
elseif length(fname) < 4 || ~strcmp(fname((end-3):end), '.mat')
    fname = [fname '.mat'];
end

function specs = getspecs(handles)
r = handles.record;
if isfield(r, 'SPspecs') && check_STORMprocess_specs(r.SPspecs)
    specs = r.SPspecs;
else
    error('record didn''t have a valid specs yet');
end

function d = getdataset(handles, name)
if isempty(handles.(name))
    d = [];
    return;
end

if ~isempty(handles.(name).data) % data is in memory
    d = handles.(name);
else
    now_here = cd;
    cd(handles.here);
    handles.(name) = load(handles.(name).fname);
    d = handles.(name);
    guidata(handles.figure1, handles);
    cd(now_here);
end

function savedataset(handles, name)
% check whether dataset should be saved and if dataset exists and is nonempty
if ~isempty(handles.record.([name, '_fname']))...
            && isfield(handles, name) && ~isempty(handles.(name))
    now_here = cd;
    cd(handles.here);

    fname_to_save = handles.record.([name, '_fname']);

    % don't save if the dataset is uncached data from the same file
    if ~(isempty(handles.(name).data) && strcmp(handles.(name).fname, fname_to_save))
        save_it = true;
        if exist(fname_to_save, 'file') % also check times
            ss = load(fname_to_save, 'date');
            if (handles.(name).date - ss.date) == 0
                save_it = false;
            end
        end
        
        if save_it
            fprintf('saving %s data to %s\n', name, fname_to_save);
            d = getdataset(handles, name);
            save(fname_to_save, '-struct', 'd')
        end
    end

    cd(now_here);
end

%% Callbacks
function choose_button_Callback(hObject, ~, handles) %#ok<*DEFNU>
[fname, fpath] = uigetfile('.mat','Choose a processing record...');
if fname == 0 % This means user pressed cancel
    return; % do nothing
end

handles.here = fpath;
cd(fpath);

handles.record_fname = fname;

handles = load_all(handles);

guidata(hObject, handles);

function new_button_Callback(hObject, ~, handles)
% Ask: single or dual
answer = questdlg('Single or dualview?', 'channels', 'Single', 'Dual', 'Dual');
switch answer
    case 'Single'
        handles.nchannels = 1;
    case 'Dual'
        handles.nchannels = 2;
end

record_fname = ask_for_record_fname('New record...');

if isempty(record_fname)
    error('new record: aborted by user');
end

handles.record_fname = record_fname;

handles = load_all(handles);
guidata(hObject, handles);

function runall_button_Callback(hObject, ~, handles)
dofits_button_Callback(hObject, [], handles);
geo_button_Callback(hObject, [], guidata(hObject));
cull_button_Callback(hObject, [], guidata(hObject));
compute_drift_button_Callback(hObject, [], guidata(hObject));

function edit_fitspecs_button_Callback(hObject, ~, handles)
handles.record.SPspecs = SPspec_gui(handles.record.SPspecs);
guidata(hObject,handles);

function dofits_button_Callback(hObject, ~, handles)
% Handle prereqs
specs = getspecs(handles);

% Do fitting
set(handles.fits_stat, 'String', 'Fitting ...');
drawnow;

[data, ~, metadata] = STORMprocess(specs);

fits.data = data;
fits.date = datetime;
fits.produced_by = 'STORMprocess';
fits.units = 'px';

handles.fits = fits;

handles.record.metadata = metadata;
guidata(hObject, handles);
set(handles.fits_stat, 'String', {'done', char(fits.date)});

function choose_transform_button_Callback(hObject, ~, handles)
[fname, fpath] = uigetfile('.mat','Choose a transform...');
if fname == 0 % This means user pressed cancel
    return; % do nothing
end

fname = [fpath, fname];

handles.record.dv_transform_fname = fname;

guidata(hObject, handles);

function geo_button_Callback(hObject, ~, handles)
% Prereqs
SPspecs = getspecs(handles);
cspecs = SPspecs.camera_specs;

fits = getdataset(handles, 'fits');
%fits = handles.fits;
if isempty(fits)
    error('geometry: No fits yet, aborting');
end

if handles.record.tform_channel % only transform if specified

    transf_fname = handles.record.dv_transform_fname;
    if exist(transf_fname, 'file')
        % the transform structures only have reverse transforms,
        % so we need T_1_2 to transform 2->1
        tf = load(transf_fname, 'T_1_2');
        tf = tf.T_1_2;
    else
        error('dualview transform file not specified or does not exist');
    end

    % transform
    set(handles.dilated_stat, 'String', 'Applying Transform ...');
    drawnow;

    [tfdata] = apply_transform(fits.data{handles.record.tform_channel}, tf);

    transformed.data = fits.data;
    transformed.data{handles.record.tform_channel} = tfdata;

    transformed.date = datetime;
    transformed.produced_by = 'apply_transform';
    transformed.units = 'px';

    handles.transformed = transformed;

end

% pixel size
set(handles.dilated_stat, 'String', 'Converting to nm ...');
drawnow;

dilatefac = cspecs.pixel_size / cspecs.magnification * 1e3; %to nm

% do to different datasets depending on number of channels
if isempty(handles.record.tform_channel)
    startdata = fits;
else
    startdata = transformed;
end

% apply the dilation to each channel
dilateddata = cellfun(@(d) dilatepts(d, dilatefac), startdata.data,...
                'UniformOutput', false);

dilated.data = dilateddata;
dilated.date = datetime;
dilated.units = 'nm';
dilated.produced_by = 'dilatepts';

handles.dilated = dilated;

guidata(hObject, handles);
set(handles.dilated_stat, 'String', {'done', char(dilated.date)});

function cullspec1_button_Callback(hObject, ~, handles)
dilated = getdataset(handles, 'dilated');
cs1 = handles.record.cullspecs{1};
cs1 = cullspec_gui(cs1, dilated.data{1});
handles.record.cullspecs{1} = cs1;
guidata(hObject, handles);

function cullspec2_button_Callback(hObject, ~, handles)
dilated = getdataset(handles, 'dilated');
handles.record.cullspecs{2} = cullspec_gui(handles.record.cullspecs{2}, ...
    dilated.data{2});
guidata(hObject, handles);

function cull_button_Callback(hObject, ~, handles)
% Prerequisites
if ~isfield(handles.record, 'cullspecs')
    nocs = 1;
else
    nocs = 0;
    cs = handles.record.cullspecs;
end

if nocs || isempty(cs) || any(cellfun(@isempty, cs))
    error('cull: no cull specs, aborting');
end

if isempty(handles.dilated)
    error('cull: no data from geometry step, aborting');
end

% do culling
set(handles.culled_stat, 'String', 'Culling ...');
drawnow;

dilated = getdataset(handles, 'dilated');

% this should work independent of number of channels
[culled.data, handles.record.cullinds] = ...
    cellfun(@cullSTORM, dilated.data, cs, 'UniformOutput', false);

culled.date = datetime;
culled.produced_by = 'cullSTORM';
culled.units = 'nm';

handles.culled = culled;
guidata(hObject, handles);
set(handles.culled_stat, 'String', {'done ' char(culled.date)});

function driftspec_button_Callback(hObject, ~, handles)
error('not implemented');

function compute_drift_button_Callback(hObject, ~, handles)
% check prereqs
if ~isfield(handles.record, 'driftspecs')
    nods = 1;
else
    nods = 0;
    driftspecs = handles.record.driftspecs;
end

if nods || isempty(driftspecs)
    error('drift correction: no drift specs, aborting');
end

if isempty(handles.culled)
    error('drift correction: no culled data, aborting');
end

% do drift correction
set(handles.final_stat, 'String', 'Correcting Drift ...');
drawnow;

culled = getdataset(handles, 'culled');

final.data = cell(1,handles.nchannels);

timing = zeros(1, numel(culled.data{1}));
nframes = size(culled.data{1},2);
mdata = handles.record.metadata;
for i = 1:size(culled.data{1},1)
    dvec = datevec(mdata(i).start_time);
    Tstart = 60*[0 0 60*24 60 1 1/60]*dvec';
    timing((1:nframes) + (i-1)*nframes) = Tstart + ...
                                                mdata(i).timestamp;
end

[final.data{1}, drift_info] = compute_drift(culled.data{1}, timing, driftspecs);
handles.record.drift_info = drift_info;

set(handles.apply_drift_button, 'Enable', 'on');

if handles.nchannels > 1
    [final.data{2}] = apply_shifts(culled.data{2}, drift_info);
end

final.date = datetime;
final.produced_by = 'compute_drift';
final.units = 'nm';
final.drift_info = drift_info;

handles.final = final;

guidata(hObject, handles);
set(handles.final_stat, 'String', {'done', char(final.date)});

function apply_drift_button_Callback(hObject, eventdata, handles)
% check prereqs
if ~isfield(handles.record, 'drift_info')
    nods = 1;
else
    nods = 0;
    drift_info = handles.record.drift_info;
end

if nods || isempty(drift_info)
    error('drift correction: no preexisting drift correction, aborting');
end

if isempty(handles.culled)
    error('drift correction: no culled data, aborting');
end

set(handles.final_stat, 'String', 'Applying Drift Correction ...');
drawnow;

culled = getdataset(handles, 'culled');
final.data = cellfun(@(d) apply_shifts(d, drift_info), culled.data, 'UniformOutput', false);
final.date = datetime;
final.produced_by = 'compute_drift';
final.units = 'nm';
final.drift_info = drift_info;

handles.final = final;
guidata(hObject, handles);
set(handles.final_stat, 'String', {'done', char(final.date)});


function save_button_Callback(~, ~, handles)
save_all(handles);

function fname_edit_Callback(hObject, ~, handles)
fname_name = hObject.Tag(1:end-5);
fname = get(hObject, 'String');
if iscell(fname) % This happened once, never figured out why
    fname = fname{1};
end

fname = mat_ify(fname); % add .mat if appropriate
set(hObject, 'String', fname);

handles.record.(fname_name) = fname;

guidata(hObject, handles);

function fork_record_button_Callback(hObject, ~, handles)
% Get filename for new record
titlestr = 'Fork record...';
record_fname = ask_for_record_fname(titlestr);
if isempty(record_fname) % user pressed cancel
    return;
end

record = handles.record;
% Ask user where fork should happen
liststr = {'fits', 'transform', 'dilation', 'culling', 'drift correction'};
prompt = 'What processing step do you want to fork before?';

[selection, ok] = listdlg('PromptString', prompt, 'ListString', liststr,...
    'SelectionMode', 'single', 'Name', titlestr, 'ListSize', [250, 100]);

if ok == 0 % user pressed cancel
    return;
end

% Prefix to prepend to new filenames
answer = inputdlg('Choose a prefix for the new data file names:', titlestr);
if isempty(answer) % user pressed cancel
    return;
end

prefix = answer{1};

% put prefix on the filenames that will be different after the fork
if selection < 2 && ~isempty(record.fits_fname) % fits gets renamed
    record.fits_fname = [prefix, record.fits_fname];
end
if selection < 3 && ~isempty(record.transformed_fname) % tf gets renamed
    record.transformed_fname = [prefix, record.transformed_fname];
end
if selection < 4 && ~isempty(record.dilated_fname) % dilated gets renamed
    record.dilated_fname = [prefix, record.dilated_fname];
end
if selection < 5 && ~isempty(record.culled_fname) % dilated gets renamed
    record.culled_fname = [prefix, record.culled_fname];
end
if selection < 6 && ~isempty(record.final_fname) % final gets renamed
    record.final_fname = [prefix, record.final_fname];
end

handles.record = record;
handles.record_fname = record_fname;

set_fname_fields(handles);
guidata(hObject, handles);

function inspect_button_Callback(hObject, ~, handles)
tokens = regexp(hObject.Tag, '(\w+)_inspect_button','tokens');
if isempty(tokens)
    error('button tag not named right... check it out');
end
data_name = tokens{1}{1};
d = getdataset(handles, data_name);
inspect_STORMdata(d);

function tform_checkbox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles.record.tform_channel = handles.nchannels;
else
    handles.record.tform_channel = [];
end
tform_uielements_enable_disable(handles);
guidata(hObject, handles);
