function varargout = inspect_STORMdata(varargin)
% INSPECT_STORMDATA MATLAB code for inspect_STORMdata.fig
%      INSPECT_STORMDATA, by itself, creates a new INSPECT_STORMDATA or raises the existing
%      singleton*.
%
%      H = INSPECT_STORMDATA returns the handle to a new INSPECT_STORMDATA or the handle to
%      the existing singleton*.
%
%      INSPECT_STORMDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPECT_STORMDATA.M with the given input arguments.
%
%      INSPECT_STORMDATA('Property','Value',...) creates a new INSPECT_STORMDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inspect_STORMdata_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inspect_STORMdata_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inspect_STORMdata

% Last Modified by GUIDE v2.5 25-Apr-2018 20:12:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inspect_STORMdata_OpeningFcn, ...
                   'gui_OutputFcn',  @inspect_STORMdata_OutputFcn, ...
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


function inspect_STORMdata_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;

% Get data
handles.datastruct = varargin{1};
if isempty(handles.datastruct) || ~isfield(handles.datastruct, 'data')
    error('No data provided, or format doesn''t check out');
end

handles.data = handles.datastruct.data;
handles.nchannel = numel(handles.data);

s = size(handles.data{1});
handles.maxmov = s(1);
handles.maxframe = s(2);

set(handles.firstframe_edit, 'String' , '1');
set(handles.lastframe_edit, 'String', num2str(handles.maxframe));
set(handles.firstmovie_edit, 'String', '1');
set(handles.lastmovie_edit, 'String', num2str(handles.maxmov));

fields = fieldnames(handles.data{1});
fields = {'solid', fields{:}};
set(handles.color_by_menu, 'String', fields);

% get preliminary imagestruct and reconstruction
handles.istruct = imagestruct_default(handles.datastruct);
[handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
handles.Itoshow = handles.Merge;

set(handles.cmax1_edit, 'String', num2str(handles.istruct.cmax(1)));
set(handles.cmax2_edit, 'String', num2str(handles.istruct.cmax(2)));

% set up axes for reconstruction
r_axes = axes('Parent', handles.image_panel, 'Units', 'Normalized',...
                'Position', [0.1, 0.1, .8, .8]);
axis(r_axes, 'equal');
handles.r_axes = r_axes;
handles.im = imshow(handles.Itoshow, handles.istruct.imageref, ...
                'Parent', r_axes);
zoom(r_axes, 'on');
handles.pts = [];

handles.npts1_axes = axes('Parent', handles.nperframe_panel, 'Units', 'Normalized',...
                'Position', [0.2, 0.1, .75, .35]);
handles.npts2_axes = axes('Parent', handles.nperframe_panel, 'Units', 'Normalized',...
                'Position', [0.2, 0.55, .75, .35]);
npts1 = arrayfun(@(s) numel(s.x), handles.data{1});
npts2 = arrayfun(@(s) numel(s.x), handles.data{2});
histogram(handles.npts1_axes, npts1(:));
histogram(handles.npts2_axes, npts2(:));

% set up axes for 

guidata(hObject, handles);


function varargout = inspect_STORMdata_OutputFcn(~, ~, handles)
varargout{1} = handles.output;

% My functions
function reconstruct_Callback(hObject, ~, handles) %#ok<*DEFNU>
newdatarange = false;
newistruct = false;
newptsdata = false;
redrawimage = false;
redrawpoints = false;
switch hObject.Tag
    case {'reconstruct_ch1_checkbox', 'reconstruct_ch2_checkbox'}
        % only change image
        redrawimage = true;
    case {'firstmovie_edit', 'lastmovie_edit',...
            'firstframe_edit', 'lastframe_edit'}
        newdatarange = true;
        newptsdata = true;
        redrawimage = true;
        redrawpoints = true;
    case 'cmax1_edit'
        newistruct = true;
        redrawimage = true;
        newcmax = str2double(get(hObject, 'String'));
        handles.istruct.cmax(1) = newcmax;
    case 'cmax2_edit'
        newistruct = true;
        redrawimage = true;
        newcmax = str2double(get(hObject, 'String'));
        handles.istruct.cmax(2) = newcmax;
    case {'overlay_ch1_checkbox', 'overlay_ch2_checkbox', 'color_by_menu'}
        newptsdata = true;
        redrawpoints = true;
end

if newdatarange % update image
    firstmov = round(str2double(get(handles.firstmovie_edit, 'String')));
    firstframe = round(str2double(get(handles.firstframe_edit, 'String')));
    lastmov = round(str2double(get(handles.lastmovie_edit, 'String')));
    lastframe = round(str2double(get(handles.lastframe_edit, 'String')));
    %TODO: verify good ranges
    for i = 1:handles.nchannel
        firstchunk = handles.datastruct.data{i}(firstmov, firstframe:end);
        lastchunk = handles.datastruct.data{i}(lastmov, 1:lastframe);
        otherstuff = handles.datastruct.data{i}((firstmov+1):(lastmov -1),:);
        handles.data{i} = [firstchunk(:)', otherstuff(:)', lastchunk(:)'];
    end
    
    handles.istruct.data.data = handles.data;

end

if newptsdata % update which points are here
    handles.x = [];
    handles.y = [];
    c_ind = get(handles.color_by_menu, 'Value');
    color_by = get(handles.color_by_menu, 'String');
    color_by = color_by{c_ind};
    if strcmp(color_by, 'solid')
    	handles.c = 'red';
        c_field = false;
    else
        c_field = true;
    end
    if get(handles.overlay_ch1_checkbox, 'Value')
        handles.x = [handles.data{1}(:).x];
        handles.y = [handles.data{1}(:).y];
        if c_field
            handles.c = [handles.data{1}(:).(color_by)];
        end
        set(handles.overlay_ch2_checkbox, 'Value', 0);
    elseif get(handles.overlay_ch2_checkbox, 'Value')
        handles.x = [handles.data{2}(:).x];
        handles.y = [handles.data{2}(:).y];
        if c_field
            handles.c = [handles.data{2}(:).(color_by)];
        end
        set(handles.overlay_ch1_checkbox, 'Value', 0);
    end
end

if newdatarange || newistruct % || anything that means you need to reconstruct again
    [handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
    npts1 = arrayfun(@(s) numel(s.x), handles.data{1});
    npts2 = arrayfun(@(s) numel(s.x), handles.data{2});
    histogram(handles.npts1_axes, npts1(:));
    histogram(handles.npts2_axes, npts2(:));
end

if redrawimage
    usechan = zeros(1,handles.nchannel);
    usechan(1) = get(handles.reconstruct_ch1_checkbox, 'Value');
    usechan(2) = get(handles.reconstruct_ch2_checkbox, 'Value');
    if all(usechan)
        handles.Itoshow = handles.Merge;
    elseif ~any(usechan)
        handles.Itoshow = zeros(handles.istruct.imageref.ImageSize);
    else
        ind = find(usechan);
        handles.Itoshow = handles.I{ind(1)};
    end

    if isempty(handles.im)
        handles.im = imshow(handles.Itoshow, handles.istruct.imageref, ...
                    'Parent', r_axes);
    else
        set(handles.im, 'CData', handles.Itoshow)
    end
end

if redrawpoints
    handles.m = '.';
    
    if isempty(handles.pts)
        hold(handles.r_axes, 'on');
        handles.pts = plot(handles.r_axes, handles.x, handles.y, '.', ...
            'Marker', handles.m, 'Color', handles.c);
    else
        set(handles.pts, 'Xdata', handles.x, 'Ydata', handles.y,...
            'Color', handles.c, 'Marker', handles.m);
    end
        
end

guidata(hObject, handles);
