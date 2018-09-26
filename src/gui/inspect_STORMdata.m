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

% Last Modified by GUIDE v2.5 26-Sep-2018 13:22:35

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

if numel(varargin) > 1
    handles.cullinds = varargin{2};
    handles.culling_enabled = true;
else
    handles.cullinds = [];
    handles.culling_enabled = false;
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
fields = vertcat({'time'}, fields(:));
fields = vertcat({'solid'}, fields(:));
set(handles.color_by_menu, 'String', fields);

% get preliminary imagestruct and reconstruction
handles.istruct = imagestruct_default(handles.datastruct);
set(handles.units_text, 'String', ['Units: ', handles.istruct.units]);

[handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
handles.Itoshow = handles.Merge;

set(handles.psize_edit, 'String', num2str(handles.istruct.psize));

set(handles.cmax1_edit, 'String', num2str(handles.istruct.cmax(1)));

set(handles.color1_edit, 'String', handles.istruct.color(1));

set(handles.psf1_edit, 'String', num2str(handles.istruct.sigmablur(1)));


% set up axes for reconstruction
r_axes = axes('Parent', handles.image_panel, 'Units', 'Normalized',...
                'Position', [0.02, 0.02, .96, .96]);
handles.r_axes = r_axes;
handles.im = imshow(handles.Itoshow, handles.istruct.imageref, ...
                'Parent', r_axes, 'Border', 'tight');
h = zoom(r_axes);
h.Enable = 'on';
h.ActionPreCallback = @(obj, evd) pre_zoom_callback(evd.Axes);
h.ActionPostCallback = @(obj, evd) post_zoom_callback(evd.Axes, handles.istruct.units);
axis(r_axes, 'equal','off');
handles.pts = [];
handles.cbar = [];

% axes for npoints histograms
handles.npts1_axes = axes('Parent', handles.nperframe_panel, 'Units', 'Normalized',...
                'OuterPosition', [0, 0, 1, .5]);
npts1 = arrayfun(@(s) numel(s.x), handles.data{1});
histogram(handles.npts1_axes, npts1(:));

% axes for vals histogram
handles.vals_axes = axes('Parent', handles.vals_panel, 'Units', 'Normalized', ...
                'OuterPosition', [0 0 1 1]);
handles.vals_hist = [];

if handles.nchannel > 1
    set(handles.psf2_edit, 'String', num2str(handles.istruct.sigmablur(2)));
    set(handles.cmax2_edit, 'String', num2str(handles.istruct.cmax(2)));
    set(handles.color2_edit, 'String', handles.istruct.color(2));
    handles.npts2_axes = axes('Parent', handles.nperframe_panel, 'Units', 'Normalized',...
                    'OuterPosition', [0, 0.5, 1, .5]);
    npts2 = arrayfun(@(s) numel(s.x), handles.data{2});
    histogram(handles.npts2_axes, npts2(:));
else
    set(handles.reconstruct_ch2_checkbox, 'Value', false);
    disable_uielements = {'psf2_edit', 'cmax2_edit', 'color2_edit',...
        'reconstruct_ch2_checkbox', 'overlay_ch2_checkbox'};
    for i = 1:numel(disable_uielements)
        set(handles.(disable_uielements{i}), 'Enable', 'off');
    end
end

handles.auto_color = get(handles.pts_autocolor_checkbox, 'Value');

guidata(hObject, handles);

% put initial scale bar
% this has to be done after handles are set
post_zoom_callback(r_axes, handles.istruct.units);

function varargout = inspect_STORMdata_OutputFcn(~, ~, handles)
varargout{1} = handles.output;


% My functions
% Callback to delete old scalebar before a zoom event
function pre_zoom_callback(ax) % takes the axes of the zoom
c = ax.Children;
for i = 1:numel(c)
    switch class(c(i))
        case {'matlab.graphics.primitive.Patch', 'matlab.graphics.primitive.Text'}
            delete(c(i));
    end
end

% Callback to draw new scalebar after zoom event
function post_zoom_callback(ax, units)
newxlim = ax.XLim;
newylim = ax.YLim;
newlim = max(diff(newxlim), diff(newylim));
newscalebarlen = round(newlim/10, 1, 'significant');
newscalebarmag = 10.^(floor(log10(newscalebarlen)));
if (newscalebarlen/newscalebarmag > 6)
    newscalebarmag = 10*newscalebarmag;
    newscalebarlen = newscalebarmag;
elseif (newscalebarlen/newscalebarmag > 2)
    newscalebarlen = newscalebarmag*5;
end

if strcmp(units, 'nm') && newscalebarmag > 500 % go to um
    labeltext = [num2str(newscalebarlen / 1000), ' {\mu}m'];
else
    labeltext = [num2str(newscalebarlen), ' ', units];
end

left = newxlim(1) + newlim/50;
right = left + newscalebarlen;
top = newylim(1) + newlim/50;
bottom = top + newlim/50;

patch(ax, [left, right, right, left], [bottom, bottom, top, top], 'w');
text(ax, left, (bottom + top)/2, labeltext, 'Interpreter', 'tex');

handles = guidata(ax);
if ~isempty(handles.vals_hist) && get(handles.update_hist_box, 'Value')
    inds = handles.x > newxlim(1) & handles.x < newxlim(2) & ...
            handles.y > newylim(1) & handles.y < newylim(2);
    handles.vals_hist = histogram(handles.vals_axes, handles.c(inds));
end

function [firstmov, lastmov, firstframe, lastframe] = check_datarange(handles)
firstmov = round(str2double(get(handles.firstmovie_edit, 'String')));
lastmov =  round(str2double(get(handles.lastmovie_edit, 'String')));
firstframe = round(str2double(get(handles.firstframe_edit, 'String')));
lastframe = round(str2double(get(handles.lastframe_edit, 'String')));

if firstmov < 1
    firstmov = 1;
elseif firstmov > handles.maxmov
    firstmov = handles.maxmov;
end

if lastmov < 1
    lastmov = 1;
elseif lastmov > handles.maxmov
    lastmov = handles.maxmov;
end

if firstframe < 1
    firstframe = 1;
elseif firstframe > handles.maxframe
    firstframe = handles.maxframe;
end

if lastframe < 1
    lastframe = 1;
elseif lastframe > handles.maxframe
    lastframe = handles.maxframe;
end

if firstmov > lastmov
    lastmov = firstmov;
end

if firstframe > lastframe
    lastframe = firstframe;
end

set(handles.firstmovie_edit, 'String', firstmov)
set(handles.lastmovie_edit, 'String', lastmov)
set(handles.firstframe_edit, 'String', firstframe)
set(handles.lastframe_edit, 'String', lastframe)

function update_caxis(handles)
ax = handles.r_axes;

if handles.auto_color
    caxis(ax, 'auto');
    [cx] = caxis(ax);
    set(handles.pts_cmin_edit, 'String', num2str(cx(1)));
    set(handles.pts_cmax_edit, 'String', num2str(cx(2)));
else
    cmin = str2double(get(handles.pts_cmin_edit, 'String'));
    cmax = str2double(get(handles.pts_cmax_edit, 'String'));
    cmax = max(cmax, cmin + 1); 
    set(handles.pts_cmax_edit, 'String', num2str(cmax));

    caxis(ax, [cmin, cmax]);
end


% This is awful. Rewrite from scratch? Making all the uielements
% call the same callback was a mistake.
function reconstruct_Callback(hObject, ~, handles) %#ok<*DEFNU>
newdatarange = false;
newptsdata = false;
redrawpoints = false;
newptscolors = false;
switch hObject.Tag
    case {'firstmovie_edit', 'lastmovie_edit',...
            'firstframe_edit', 'lastframe_edit'}
        newdatarange = true;
        newptsdata = true;
        redrawpoints = true;
    case {'overlay_ch1_checkbox', 'overlay_ch2_checkbox', 'color_by_menu'}
        newptsdata = true;
        redrawpoints = true;
end

% newptsdata should only be true if at least one of the checkboxes is true
if newptsdata
    newptsdata = get(handles.overlay_ch1_checkbox, 'Value') ||...
        get(handles.overlay_ch2_checkbox, 'Value');
end
if redrawpoints
    redrawpoints = get(handles.overlay_ch1_checkbox, 'Value') ||...
        get(handles.overlay_ch2_checkbox, 'Value');
    if ~redrawpoints % clear points
        delete(handles.pts);
        if ~isempty(handles.vals_hist)
            delete(handles.vals_hist)
            handles.vals_hist = [];
        end
        handles.pts = [];
    end
end

if newdatarange % update image
    [firstmov, lastmov, firstframe, lastframe] = check_datarange(handles);
    for i = 1:handles.nchannel
        if firstmov == lastmov
            handles.data{i} = handles.datastruct.data{i}(firstmov, firstframe:lastframe);
        else
            firstchunk = handles.datastruct.data{i}(firstmov, firstframe:end);
            lastchunk = handles.datastruct.data{i}(lastmov, 1:lastframe);
            otherstuff = handles.datastruct.data{i}((firstmov+1):(lastmov -1),:);
            handles.data{i} = [firstchunk(:)', otherstuff(:)', lastchunk(:)'];
        end
    end
    
    handles.istruct.data.data = handles.data;

    npts1 = arrayfun(@(s) numel(s.x), handles.data{1});
    histogram(handles.npts1_axes, npts1(:));
    if handles.nchannel > 1
        npts2 = arrayfun(@(s) numel(s.x), handles.data{2});
        histogram(handles.npts2_axes, npts2(:));
    end
end

if newptsdata % update which points are here
    handles.x = [];
    handles.y = [];
    c_ind = get(handles.color_by_menu, 'Value');
    color_by = get(handles.color_by_menu, 'String');
    color_by = color_by{c_ind};
    switch color_by
        case 'solid'
            handles.c = [1 0 0];
            set(handles.pts_cmin_edit, 'Enable', 'off');
            set(handles.pts_cmax_edit, 'Enable', 'off');
            if ~isempty(handles.vals_hist)
                delete(handles.vals_hist);
                handles.vals_hist = [];
            end
            c_field = false;
            c_time = false;
        case 'time'
            c_time = true;
            c_field = false;
            set(handles.pts_cmin_edit, 'Enable', 'on');
            set(handles.pts_cmax_edit, 'Enable', 'on');
        otherwise
            c_field = true;
            c_time = false;
            set(handles.pts_cmin_edit, 'Enable', 'on');
            set(handles.pts_cmax_edit, 'Enable', 'on');
    end
    if get(handles.overlay_ch1_checkbox, 'Value')
        d = handles.data{1}'; % transpose puts frames in right order for single-index
        set(handles.overlay_ch2_checkbox, 'Value', 0);
    elseif get(handles.overlay_ch2_checkbox, 'Value')
        d = handles.data{2}'; % transpose puts frames in right order for single-index
        set(handles.overlay_ch1_checkbox, 'Value', 0);
    else
        d = struct('x', -1, 'y', -1, color_by, 0);
    end
    handles.x = [d(:).x];
    handles.y = [d(:).y];
    if c_field
        handles.c = [d(:).(color_by)];
    elseif c_time
        handles.c = zeros(size(handles.x));
        ndone = 0;
        for i = 1:numel(d)
            nnew = numel(d(i).x);
            handles.c(ndone + (1:nnew)) = i;
            ndone = ndone + nnew;
        end
    end
end

if newdatarange
    [handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
    redraw_image(handles);
end

if redrawpoints
    handles.m = '.';
    
    if isempty(handles.pts)
        hold(handles.r_axes, 'on');
        handles.pts = scatter(handles.r_axes, handles.x, handles.y, 9, ...
            handles.c, 'Marker', handles.m);
    elseif ~isempty(handles.x)
        set(handles.pts, 'Xdata', handles.x, 'Ydata', handles.y,...
            'CData', handles.c, 'Marker', handles.m);
    else
        delete(handles.pts);
        handles.pts = [];
    end

    if ~isempty(handles.x) && numel(handles.c) == numel(handles.x)
        if get(handles.update_hist_box, 'Value')
            xlim = handles.r_axes.XLim;
            ylim = handles.r_axes.YLim;
            inds = handles.x > xlim(1) & handles.x < xlim(2) & ...
                handles.y > ylim(1) & handles.y < ylim(2);
            handles.vals_hist = histogram(handles.vals_axes, handles.c(inds));
        else
            handles.vals_hist = histogram(handles.vals_axes, handles.c);
        end
    elseif ~isempty(handles.vals_hist)
        delete(handles.vals_hist)
        handles.vals_hist = [];
    end

    
    if size(handles.c) == size(handles.x)
        handles.cbar = colorbar('peer', handles.r_axes);
    elseif ~isempty(handles.cbar)
        colorbar(handles.cbar, 'off');
        handles.cbar = [];
    end
end

update_caxis(handles);

guidata(hObject, handles);

function redraw_image(handles)
% Figure out which image
usechan = zeros(1,handles.nchannel);
usechan(1) = get(handles.reconstruct_ch1_checkbox, 'Value');
usechan(2) = get(handles.reconstruct_ch2_checkbox, 'Value');
if all(usechan)
    Itoshow = handles.Merge;
elseif ~any(usechan)
    Itoshow = zeros([handles.istruct.imageref.ImageSize, 3]);
else
    ind = find(usechan);
    Itoshow = handles.I{ind(1)};
end

% do the drawing
if isempty(handles.im)
    handles.im = imshow(Itoshow, handles.istruct.imageref, ...
                'Parent', handles.r_axes, 'Border', 'tight');
else
    set(handles.im, 'CData', Itoshow, 'XData', handles.istruct.imageref.XWorldLimits,...
        'YData', handles.istruct.imageref.YWorldLimits);
end

handles.Itoshow = Itoshow;
guidata(handles.figure1, handles);

function save_button_Callback(~, ~, handles)
imwrite(handles.Itoshow, 'img.tif');


function new_istruct_field_num(hObject, handles, fieldname, chan)
newval = str2double(get(hObject, 'String'));
handles.istruct.(fieldname)(chan) = newval;

% change the pixel size necessitates changing the imageref, too
if strcmp(fieldname, 'psize')
    handles.istruct.imageref = default_iref(handles.data{1}, newval);
end

[handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
guidata(hObject, handles);
redraw_image(handles);

function new_istruct_field_str(hObject, handles, fieldname, chan)
newval = get(hObject, 'String');
handles.istruct.(fieldname)(chan) = newval;

[handles.Merge, handles.I] = imerge_from_imagestruct(handles.istruct);
guidata(hObject, handles);
redraw_image(handles);

function cmax1_edit_Callback(hObject, ~, handles)
new_istruct_field_num(hObject,handles,'cmax', 1);

function cmax2_edit_Callback(hObject, ~, handles)
new_istruct_field_num(hObject,handles,'cmax', 2);

function psf1_edit_Callback(hObject, ~, handles)
new_istruct_field_num(hObject, handles, 'sigmablur', 1);

function psf2_edit_Callback(hObject, ~, handles)
new_istruct_field_num(hObject, handles, 'sigmablur', 2);

function psize_edit_Callback(hObject, ~, handles)
new_istruct_field_num(hObject, handles, 'psize', 1);

function color1_edit_Callback(hObject, ~, handles)
new_istruct_field_str(hObject,handles,'color', 1);

function color2_edit_Callback(hObject, ~, handles)
new_istruct_field_str(hObject,handles,'color', 2);

function reconstruct_checkbox_Callback(~, ~, handles)
redraw_image(handles);

function pts_autocolor_checkbox_Callback(hObject, ~, handles)
handles.auto_color = get(hObject, 'Value');
guidata(hObject, handles);
update_caxis(handles);

function pts_cmin_edit_Callback(hObject, ~, handles)
set(handles.pts_autocolor_checkbox, 'Value', 0);
handles.auto_color = 0;
guidata(hObject, handles);
update_caxis(handles);

function pts_cmax_edit_Callback(hObject, ~, handles)
set(handles.pts_autocolor_checkbox, 'Value', 0);
handles.auto_color = 0;
guidata(hObject, handles);
update_caxis(handles);

function update_hist_box_Callback(hObject, ~, handles)
if ~isempty(handles.vals_hist)
    if get(hObject, 'Value')
        xlim = handles.r_axes.XLim;
        ylim = handles.r_axes.YLim;
        inds = handles.x > xlim(1) & handles.x < xlim(2) & ...
            handles.y > ylim(1) & handles.y < ylim(2);
        handles.vals_hist = histogram(handles.vals_axes, handles.c(inds));
    else
        handles.vals_hist = histogram(handles.vals_axes, handles.c);
    end
end