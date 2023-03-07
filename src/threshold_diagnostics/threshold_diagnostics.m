function varargout = threshold_diagnostics(varargin)

% Edit the above text to modify the response to help threshold_diagnostics

% Last Modified by GUIDE v2.5 25-Jul-2018 15:22:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threshold_diagnostics_OpeningFcn, ...
                   'gui_OutputFcn',  @threshold_diagnostics_OutputFcn, ...
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


% --- Executes just before threshold_diagnostics is made visible.
function threshold_diagnostics_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;

% some setup that is easier to do here than in guide
crop_types = {'Left', 'Right', 'Top', 'Bottom', 'Full Frame'}; %,'From specs'};
set(handles.channel_popup, 'String', crop_types, 'Value', 2);

handles.spchandims = [];

% Handle the varargin
if numel(varargin) > 0
    v1 = varargin{1};
    if iscell(v1) % filenames or glob provided
        if numel(v1) == 1 && contains(v1{1}, '*')
            handles.fnames = glob_fnames(v1{1});
        else
            handles.fnames = v1;
        end
    elseif isstruct(v1) %SPspecs provided
        handles.fnames = v1.movie_fnames;
        set(handles.r_centroid_edit, 'String', num2str(v1.r_centroid));
        set(handles.r_neighbor_edit, 'String', num2str(v1.r_neighbor));
        bgtypeval = find(strcmp({'median', 'mean', 'selective', 'none'}, v1.bg_type));
        set(handles.bgtype_popup, 'Value', bgtypeval);
        handles.spchandims = v1.channel_dims;
        % hack to not have to deal with crops. Will only work with
        % half-frame channels on 512x512 camera
        cd = v1.channel_dims;
        if all(cd == [1 512 1 256])
            val = 3;
        elseif all(cd == [1 512 257 512])
            val = 4;
        elseif all(cd == [1 256 1 512])
            val = 1;
        elseif all(cd == [257 512 1 512])
            val = 2;
        elseif all(cd == [1 512 1 512])
            val = 5;
        else
            warning('couldn''t figure out which channel to use')
            val = 2;
        end
        set(handles.channel_popup, 'Value', val);
        %set(handles.channel_popup, 'Value', 6); % use provided channel dims
    else
        handles.fnames = glob_fnames(v1);
    end

else
    handles.fnames = uigetfile({'*.tif', '*.tiff', '*.Tif', '*.Tiff'}', ...
                                'MultiSelect', 'on');
    if ~iscell(handles.fnames)
        handles.fnames = {handles.fnames};
    end
    % assume all have same name format
    filenums = zeros(size(handles.fnames));
    for i = 1:numel(handles.fnames)
        [~,~,~,fnstr] = regexp(handles.fnames{i}, '\d+\.');
        fnnum = str2double(fnstr{1});
        if ~isempty(fnnum)
            filenums(i) = fnnum(1);
        end
    end

    [~, sortinds] = sort(filenums);

    handles.fnames = handles.fnames(sortinds);
end

handles.nfiles = numel(handles.fnames);
set(handles.fname_text, 'String', ['To Load: ' handles.fnames{1}]);

handles.im_disp_type = 'raw_rb';

set(handles.movie_total_text,'String',['of ', num2str(handles.nfiles)]);

% set default values
handles.threshs = 1:.2:3; % Thresholds to try
handles.thresh_ind_for_pts = 4; % Index in threshs to display points for

% Set up axes
% Axes for the image/points
im_axes = axes(handles.image_panel);
set(im_axes,'Units','Normalized', 'Position', [0,0,1,1]);
zoom(im_axes,'on');

handles.im_axes = im_axes;

% Axes for n vs threshold
nvsthresh_axes = axes(handles.nvsthresh_panel);
set(nvsthresh_axes,'Units', 'Normalized', 'Position', [0.05,0.15,.85,.9]);
zoom(nvsthresh_axes,'on');

handles.nvsthresh_axes = nvsthresh_axes;

% Axes for n vs time
nvstime_axes = axes(handles.nvstime_panel);
set(nvstime_axes,'Units','Normalized','Position',[0.1,0.15,.85,.9]);
zoom(nvstime_axes,'on');

handles.nvstime_axes = nvstime_axes;

%handles = load_movie(handles,1);
axis(handles.legend_axes, 'off');

handles.ptscolor = 'cyan';
handles.ptsprecolor = [1 .4 .2];

guidata(hObject, handles);

function fnames = glob_fnames(glob)
% Get filenames matching the given glob (UNIX glob syntax: *,?,[], etc)
fs = dir(glob);
dates = [fs.datenum];
n = numel(dates);

if n == 0
    fnames = {};
    return;
end
% names = strcat({fs.folder},repmat({'/'},1,n),{fs.name});
names = strcat({fs.name});

% Sort by date ... should usually work
[~, sortinds] = sort(dates);
fnames = names(sortinds);

function varargout = threshold_diagnostics_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = load_movie(handles,movie_ind)
fname = handles.fnames{movie_ind};

set(handles.loaded_fname_text, 'String', ['Loading: ', fname]);
drawnow();

Iall = readTiffFast(fname);

% Crop to one channel
crop_type = get(handles.channel_popup, 'Value');
width = size(Iall, 2);
height = size(Iall, 1);
switch crop_type
    case 1
        chandims = [1 floor(width/2) 1 height];
    case 2
        chandims = [floor(width/2) + [1 floor(width/2)], 1 height];
    case 3
        chandims = [1 width 1 floor(height/2)];
    case 4
        chandims = [1 width, floor(height/2) + [1 floor(height/2)]];
    case 5
        chandims = [1 width 1 height];
    case 6
        chandims = handles.spchandims;
        if isempty(chandims)
            warning('No channel dimensions provided by specs, using full frame');
            chandims = [1 width 1 height];
        end
    otherwise
        warning('Channel popup option not implemented, using full frame');
        chandims = [1 width 1 height];
end

Iall = double(Iall(chandims(3):chandims(4),chandims(1):chandims(2), :));

handles.Iall = Iall;

nframe = size(Iall,3);

dL = round(str2double(handles.r_centroid_edit.String));
set(handles.r_centroid_edit, 'String', num2str(dL));

bg_type = get(handles.bgtype_popup,'Value');
switch bg_type
    case 1 % median
        Ibg = median(Iall,3);
    case 2 % mean
        Ibg = mean(Iall,3);
    case 3 % selective mean
        disp('First pass, for selective mean'); tic;
        thresh_for_Isel = 1.5;
        r_for_Isel = dL;
        bginfo = segment_for_Isel(Iall,thresh_for_Isel, r_for_Isel);
        t = toc;
        disp(['Done with first pass. time: ' num2str(t)]);
        Ibg = bginfo.Isel;
    case 4 % none
        Ibg = zeros(size(Iall(:,:,1)));
end
Idisc = zeros(size(Iall));
for i = 1:nframe
    Idisc(:,:,i) = filter_frame(Iall(:,:,i) - Ibg);
end

handles.nframe = nframe;
handles.Ibg = Ibg;
handles.Idisc = Idisc;

set(handles.frame_slider, 'Min', 1, 'Max', nframe, 'SliderStep', [1 10]/nframe);
set(handles.frame_slider, 'Value', 1);
set(handles.frame_edit, 'String', '1');

threshs = handles.threshs;

% add steps to remove neighbors and edge points
% IMPORTANT NOTE: the order of x and y is opposite here compared to
% STORMprocess. That is fine (they don't have to communicate), but could
% cause confusion in the future.
ptspre = thresh_diag(Idisc,threshs);

r_neighbor = str2double(get(handles.r_neighbor_edit, 'String'));
[pts, ptspre] = remove_neighbors(ptspre, r_neighbor); %TODO: make input for rmax_neighbors

pts = remove_edges(pts,width, height, dL);
ptspre = remove_edges(ptspre, width, height, dL);

handles.nseg = cellfun(@(x) size(x,1), pts);
handles.nsegpre = cellfun(@(x) size(x,1), ptspre) + handles.nseg; % total points before removing neighbors
handles.pts = pts;
handles.ptspre = ptspre;

sz = size(Ibg);
Iptspre = zeros([size(Ibg), numel(threshs)]);
Ipts = zeros([size(Ibg), numel(threshs)]);
for i=1:numel(threshs)
    Iptspre(:,:,i) = accumarray(vertcat(ptspre{:,i}),1,sz);
    Ipts(:,:,i) = accumarray(vertcat(pts{:,i}),1,sz);
end
handles.Iptspre = Iptspre;
handles.Ipts = Ipts;

handles.auto_contrast = get(handles.autoscale_checkbox, 'Value');

% Set up the image
im_axes = handles.im_axes;
handles.im_image = imshow(Iall(:,:,1),[],'Parent', im_axes, 'Border', 'Tight');
axis(im_axes, 'equal', 'off');
hold(im_axes,'on');
handles.im_points = scatter(im_axes,pts{1,4}(:,2),pts{1,4}(:,1),100,'MarkerEdgeColor', handles.ptscolor);
handles.im_pointspre = scatter(im_axes,ptspre{1,4}(:,2),ptspre{1,4}(:,1),100,'MarkerEdgeColor', handles.ptsprecolor);

update_image_frame(handles,1);

ptscolor = handles.ptscolor;
ptsprecolor = handles.ptsprecolor;

hold(handles.nvsthresh_axes,'off');
boxplot(handles.nvsthresh_axes, handles.nseg,threshs,'position',threshs);
hold(handles.nvsthresh_axes,'on');
ylim(handles.nvsthresh_axes,[0,inf]);
handles.nvsthresh_frame_plot = plot(handles.nvsthresh_axes,threshs,handles.nseg(1,:)','-o',...
    'Color', ptscolor);
handles.nprevsthresh_frame_plot = plot(handles.nvsthresh_axes,threshs,handles.nsegpre(1,:)','-o',...
    'Color', ptsprecolor);

lh = legend(handles.legend_axes, ...
    [handles.nvsthresh_frame_plot, handles.nprevsthresh_frame_plot], ...
    {'candidates', 'removed (nbrs)'}, ...
    'FontSize', 10, 'Location', 'SouthWest');

axis(handles.legend_axes, 'off');

update_nvstime_plot(handles);

set(handles.loaded_fname_text, 'String', ['Loaded: ', fname]);


function pts = remove_edges(pts,width,height,dL)
% Get coords that aren't at edge
for i =1:numel(pts)
    c = pts{i};
    if(numel(c))
        inds = ((c(:,2) > dL) & (c(:,2) < width - dL) & ...
            (c(:,1) > dL) & (c(:,1) < height - dL));
        pts{i} = c(inds,:);
    end
end

function [pts, ptspre] = remove_neighbors(pts, dr)
ptspre = cell(size(pts));
for i = 1:numel(pts)
    c = pts{i};
    if numel(c) > 0
        x = c(:,1); y = c(:,2);
        n = size(c,1);
        mask = true(1,n);
        for j = 1:(n-1)
            for k = (j+1):n
                if (((x(j) - x(k))^2 + (y(j) - y(k))^2) < dr^2)
                    mask(j) = false;
                    mask(k) = false;
                end
            end
        end
        pts{i} = c(mask,:);
        ptspre{i} = c(~mask,:);
    end
end

function update_caxis(handles)
ax = handles.im_axes;

if handles.auto_contrast
    % This should work but does not. Maybe because several images have been
    % plotted?
    %caxis(ax, 'auto');
    %[cx] = caxis(ax);
    I = get(handles.im_image, 'CData');
    cx = [min(I(:)), max(I(:))];
    caxis(ax, cx);
    set(handles.min_edit, 'String', num2str(cx(1)));
    set(handles.max_edit, 'String', num2str(cx(2)));
else
    cmin = str2double(get(handles.min_edit, 'String'));
    cmax = str2double(get(handles.max_edit, 'String'));
    cmax = max(cmax, cmin + 1);
    set(handles.max_edit, 'String', num2str(cmax));

    caxis(ax, [cmin, cmax]);
end

function update_image_frame(handles,frame_ind)
thresh = handles.thresh_ind_for_pts;
switch handles.im_disp_type
    case 'raw_rb'
        colordata = handles.Iall(:,:,frame_ind);
    case 'wavelet_rb'
        colordata = handles.Idisc(:,:,frame_ind);
    case 'bgsub_rb'
        colordata = handles.Iall(:,:,frame_ind) - handles.Ibg;
    case 'bg_rb'
        colordata = handles.Ibg;
    case 'pts_rb'
        colordata = handles.Ipts(:,:,thresh);
    case 'ptspre_rb'
        colordata = handles.Iptspre(:,:,thresh);
end
hold(handles.im_axes,'off');
%imshow(colordata,[],'Parent',handles.im_axes);
set(handles.im_image, 'CData', colordata);

% plot the identified points
pts = handles.pts{frame_ind,thresh};
ptspre = handles.ptspre{frame_ind,thresh};

if isempty(handles.im_points)
    hold(handles.im_axes,'on');
    handles.im_points = scatter(handles.im_axes,pts(:,2),pts(:,1),100,'MarkerEdgeColor', handles.ptscolor);
elseif isempty(pts)
    delete(handles.im_points);
    handles.im_points = [];
else
    set(handles.im_points, 'XData', pts(:,2), 'YData', pts(:,1));
end
% plot the identified but removed points
if isempty(handles.im_pointspre)
    hold(handles.im_axes,'on');
    handles.im_pointspre = scatter(handles.im_axes, ptspre(:,2),ptspre(:,1),100,'MarkerEdgeColor', handles.ptsprecolor);
elseif isempty(ptspre)
    delete(handles.im_pointspre)
    handles.im_pointspre = [];
else
    set(handles.im_pointspre, 'XData', ptspre(:,2), 'YData', ptspre(:,1));
end

update_caxis(handles);
guidata(handles.figure1, handles);

function update_plot_frame(handles,frame_index)
pl = handles.nvsthresh_frame_plot;
set(pl,'YData', handles.nseg(frame_index,:));

plpre = handles.nprevsthresh_frame_plot;
set(plpre, 'YData', handles.nsegpre(frame_index,:));

function update_nvstime_plot(handles)
ax = handles.nvstime_axes;
nvstime = handles.nseg(:,handles.thresh_ind_for_pts);
nvstimepre = handles.nsegpre(:,handles.thresh_ind_for_pts);
xs = 1:numel(nvstime);
plot(ax,xs,nvstime,'Color', handles.ptscolor);
hold(ax, 'on')
plot(ax,xs,nvstimepre,'Color', handles.ptsprecolor);
ylim(ax, [0 inf]);
hold(ax, 'off')

function threshs = get_threshs(handles)
low = str2double(get(handles.threshs_low_edit,'String'));
high = str2double(get(handles.threshs_high_edit,'String'));
n = str2double(get(handles.threshs_n_edit,'String'));
if any(isnan([low,high,n]))
    warning(['bad input for threshs. Using old values: ' num2str(handles.threshs)]);
    threshs = handles.threshs;
else
    threshs = linspace(low,high,n);
    handles.threshs = threshs;
    update_thresh(handles.thresh_edit, handles);
end

function frame_edit_Callback(~, ~, handles)
val = round(str2double(get(handles.frame_edit,'String')));
val = min(max(val,1),handles.nframe);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function frame_slider_Callback(~, ~, handles)
val = round(get(handles.frame_slider,'Value'));
val = min(max(val,1),handles.nframe);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function prev_button_Callback(~, ~, handles)
val = round(str2double(get(handles.frame_edit,'String')));
val = max(val - 1,1);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function next_button_Callback(~, ~, handles)
val = round(str2double(get(handles.frame_edit,'String')));
val = min(val + 1,handles.nframe);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function rewind_button_Callback(~, ~, handles)
val = round(str2double(get(handles.frame_edit,'String')));
val = max(val - 10,1);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function advance_button_Callback(~, ~, handles)
val = round(str2double(get(handles.frame_edit,'String')));
val = min(val + 10,handles.nframe);

update_image_frame(handles,val);
update_plot_frame(handles,val);

set(handles.frame_edit,'String',num2str(val));
set(handles.frame_slider, 'Value', val);

function thresh_edit_Callback(hObject, ~, handles)
update_thresh(hObject,handles);
handles = guidata(hObject);
update_image_frame(handles,str2double(get(handles.frame_edit,'String')));
update_nvstime_plot(handles);

function update_thresh(hObject, handles)
val = str2double(get(hObject,'String'));

threshs = handles.threshs;
new_ind = find(threshs <= val,1,'last');
new_thresh = threshs(new_ind);
set(hObject,'String', num2str(new_thresh));
handles.thresh_ind_for_pts = new_ind;

guidata(hObject,handles);

function thresh_less_Callback(hObject, ~, handles)
threshs = handles.threshs;
new_ind = max(handles.thresh_ind_for_pts - 1, 1);
new_thresh = threshs(new_ind);
set(handles.thresh_edit,'String', num2str(new_thresh));
handles.thresh_ind_for_pts = new_ind;

update_image_frame(handles,str2double(get(handles.frame_edit,'String')));
update_nvstime_plot(handles);

guidata(hObject,handles);

function thresh_more_Callback(hObject, ~, handles)
threshs = handles.threshs;
new_ind = min(handles.thresh_ind_for_pts + 1, numel(threshs));
new_thresh = threshs(new_ind);
set(handles.thresh_edit,'String', num2str(new_thresh));
handles.thresh_ind_for_pts = new_ind;

update_image_frame(handles,str2double(get(handles.frame_edit,'String')));
update_nvstime_plot(handles);

guidata(hObject,handles);


function load_movie_button_Callback(hObject, ~, handles)
nmov = round(str2double(get(handles.movie_edit,'String')));
handles.threshs = get_threshs(handles);
handles = load_movie(handles,nmov);
guidata(hObject,handles);

function movie_edit_Callback(~, ~, handles)
val = round(str2double(get(handles.movie_edit,'String')));
val = min(val,handles.nfiles);
val = max(val,1);
set(handles.movie_edit,'String', num2str(val));
set(handles.fname_text, 'String', ['To Load: ' handles.fnames{val}]);

function movie_prev_button_Callback(~, ~, handles)
val = round(str2double(get(handles.movie_edit,'String')));
val = val - 1;
val = min(val,handles.nfiles);
val = max(val,1);
set(handles.movie_edit,'String', num2str(val));
set(handles.fname_text, 'String', ['To Load: ' handles.fnames{val}]);

function movie_next_button_Callback(~, ~, handles)
val = round(str2double(get(handles.movie_edit,'String')));
val = val + 1;
val = min(val,handles.nfiles);
val = max(val,1);
set(handles.movie_edit,'String', num2str(val));
set(handles.fname_text, 'String', ['To Load: ' handles.fnames{val}]);

function im_type_bg_SelectionChangedFcn(hObject, eventdata, handles)
new_tag = eventdata.NewValue.Tag;
handles.im_disp_type = new_tag;
guidata(hObject,handles);
update_image_frame(handles,str2double(get(handles.frame_edit,'String')));

function autoscale_checkbox_Callback(hObject, ~, handles)
handles.auto_contrast = get(hObject, 'Value');
guidata(hObject, handles);
update_caxis(handles);

function min_edit_Callback(hObject, ~, handles)
set(handles.autoscale_checkbox, 'Value', 0);
handles.auto_contrast = 0;
guidata(hObject, handles);
update_caxis(handles);

function max_edit_Callback(hObject, ~, handles)
set(handles.autoscale_checkbox, 'Value', 0);
handles.auto_contrast = 0;
guidata(hObject, handles);
update_caxis(handles);
