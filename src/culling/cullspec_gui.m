function varargout = cullspec_gui(varargin)
% CULLSPEC_GUI MATLAB code for cullspec_gui.fig
%      CULLSPEC_GUI, by itself, creates a new CULLSPEC_GUI or raises the existing
%      singleton*.
%
%      H = CULLSPEC_GUI returns the handle to a new CULLSPEC_GUI or the handle to
%      the existing singleton*.
%
%      CULLSPEC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CULLSPEC_GUI.M with the given input arguments.
%
%      CULLSPEC_GUI('Property','Value',...) creates a new CULLSPEC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cullspec_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cullspec_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>
% Edit the above text to modify the response to help cullspec_gui

% Last Modified by GUIDE v2.5 10-Apr-2018 17:04:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cullspec_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @cullspec_gui_OutputFcn, ...
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


% --- Executes just before cullspec_gui is made visible.
function cullspec_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cullspec_gui (see VARARGIN)

% Get arguments
handles.hasdata = 0;
handles.cullspec = cull_defaults();
if numel(varargin) > 0
    handles.cullspec = varargin{1};
end
if numel(varargin) > 1
    handles.data = varargin{2};

    handles.alldata = mergeacross(handles.data);
    handles.alldata = arrayfun(@(x) structfun(@mean, x, 'UniformOutput', false), handles.alldata);

    nmov = size(handles.data,1);
    handles.movies = 1:nmov;
    set(handles.lastmovie_edit, 'String', num2str(nmov));
    handles.nmov = nmov;

    handles.hasdata = 1;
end

setup_table(handles);

ax = axes('Parent', handles.plotpanel, 'Units', 'Normalized', 'Position', [.125 .6 .85 .35]);
handles.histaxes = ax;
zoom(ax, 'xon');
ax = axes('Parent', handles.plotpanel, 'Units', 'Normalized', 'Position', [.125 .1 .85 .3]);
handles.f_of_movies_axes = ax;
% zoom(ax, 'yon');

handles.output = handles.cullspec;
handles.selectedrow = 0;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = cullspec_gui_OutputFcn(hObject, eventdata, handles)
if nargout > 0
    uiwait(handles.figure1);
    handles = guidata(hObject);
    
    varargout{1} = handles.output;

    delete(handles.figure1);
end

%%%%%%%%%%%%%%%%%%%%%%%% My functions
function setup_table(handles)
cs = handles.cullspec;
t = handles.table; %handle for this table
t.ColumnName = {'field', 'culltype', 'min', 'max'};

culltypes = {'none', 'absolute', 'sds', 'permoviesds', 'quantile', 'permoviequantile'};
t.ColumnFormat = {'char', culltypes, 'numeric', 'numeric'};

t.Data = [{cs(:).field}', {cs(:).culltype}', {cs(:).min}', {cs(:).max}'];
t.ColumnEditable = true(1,4);

function rowcolors = setuprowstripes(validrows)
% make valid rows alternate white and gray, and invalid ones light red
numrows = numel(validrows);
onerep = [1 1 1; .9 .9 .9];
rowcolors = repmat(onerep, ceil(numrows/2),1);
rowcolors = rowcolors(1:numrows,:);

%set the invalid ones to red
rowcolors(~validrows, :) = repmat([1 .5 .5], sum(~validrows), 1);

function valids = checkvalidedit(newcs) %mess
valids = true(1,4);

% check culltype
switch newcs.culltype
    case {'absolute', 'sds', 'permoviesds', 'none'}
        % min,max can be anything
    case { 'quantile', 'permoviequantile'}
        % min, max must be between 0 and 1
        if newcs.min < 0 || newcs.min > 1
            valids(3) = false;
        end
        if newcs.max < 0 || newcs.max > 1
            valids(4) = false;
        end
    otherwise
        valids(2) = false; % invalid culltype
end

% check that min <= max
if newcs.min > newcs.max
    valids(3) = false;
    valids(4) = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%% Callbacks
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure1);

function return_button_Callback(hObject, eventdata, handles)
handles.output = handles.cullspec;
guidata(hObject, handles);
uiresume(handles.figure1);


function table_CellEditCallback(hObject, eventdata, handles)
fieldno = eventdata.Indices(1);
line = hObject.Data(fieldno,:);

newcs = cell2struct(line, {'field', 'culltype', 'min', 'max'}, 2);

valids = checkvalidedit(newcs);

if isfield(handles,'validrows')
    validrows = handles.validrows;
else
    validrows = true(1,size(hObject.Data,1));
end

%update valid rows
validrows(fieldno) = all(valids);
handles.validrows = validrows;

if all(validrows)
    handles.cullspec(fieldno) =  newcs;
end

%update backgroud colors to reflect valid rows
hObject.BackgroundColor = setuprowstripes(validrows);

table_CellSelectionCallback(hObject, eventdata, handles);

guidata(hObject, handles);


function addrow_button_Callback(hObject, eventdata, handles)
if handles.hasdata
    fields = fieldnames(handles.data);
    newrow = fields{1};
    movies = handles.movies;
    drange = cellfun(@(f) f([handles.data(movies,:).(newrow)]), ...
                        {@min, @max});
else
    newrow = '';
    drange = [0 1];
end

newcs = struct('field', newrow, 'culltype', 'absolute', ...
                'min', drange(1), 'max', drange(2));
            
handles.cullspec(end + 1) = newcs;
guidata(hObject, handles);
setup_table(handles);

function removerow_button_Callback(hObject, eventdata, handles)
t = handles.table;

r = handles.selectedrow;
cs = handles.cullspec;

if r > 0
    handles.cullspec = cs((1:numel(cs)) ~= r);
    handles.selectedrow = 0;
end

guidata(hObject, handles);

setup_table(handles);


function table_CellSelectionCallback(hObject, eventdata, handles)
% update selection indices
if size(eventdata.Indices,1) == 0
    handles.selectedrow = 0;
    guidata(hObject, handles);
    return;
end
row = eventdata.Indices(1);
handles.selectedrow = row;
guidata(hObject, handles);

% Plot a histogram if there is data
if ~handles.hasdata
    return
end

cs = handles.cullspec(row);
fieldname = cs.field;

h = handles.histaxes;
ht = handles.f_of_movies_axes;
if isfield(handles.data, fieldname)
    hold(h, 'off');
    currentdata = [handles.data(handles.movies,:).(fieldname)];
    histogram(h, currentdata);
    showrange = true;
    switch cs.culltype
        case 'absolute'
            l = cs.min; u = cs.max;
        case {'quantile', 'permoviequantile'}
            drange = quantile(currentdata, [cs.min cs.max]);
            l = drange(1); u = drange(2);
        case {'sds', 'permoviesds'}
            m = mean(currentdata,'omitnan');
            sd = std(currentdata, 'omitnan');
            l = m + cs.min*sd;
            u = m + cs.max*sd;
        otherwise
            showrange = false;
    end
    if showrange
        hold(h, 'on');
        plot(h, [l l], ylim(h), 'b');
        plot(h, [u u], ylim(h), 'b');
    end
    xlabel(h, 'field value');

    % Show average values for each movie
    plot(ht, [handles.alldata(:).(fieldname)], 'Marker', '.', 'MarkerSize', 15);
    xlabel(ht, 'Movie Number');
    title(ht, 'Movie-averaged field value');
else % not a field of the data, clear the axes
    cla(h);
    cla(ht);
    text(h, .2, .5,...
        sprintf('%s is not a field in the data!', fieldname),...
        'Color', 'r');
    axis(h, 'off');
end

function movie_edit_Callback(hObject, eventdata, handles)
first = round(str2double(get(handles.firstmovie_edit, 'String')));
last = round(str2double(get(handles.lastmovie_edit, 'String')));
first = max(first, 1);
last = min(handles.nmov, last);
set(handles.firstmovie_edit, 'String', num2str(first));
set(handles.lastmovie_edit, 'String', num2str(last));

handles.movies = first:last;

guidata(hObject, handles);

table_CellSelectionCallback(handles.table, ...
                    struct('Indices', [handles.selectedrow, 1]),...
                    handles);
