function varargout = show_fits(varargin)
% SHOW_FITS MATLAB code for show_fits.fig
%      SHOW_FITS, by itself, creates a new SHOW_FITS or raises the existing
%      singleton*.
%
%      H = SHOW_FITS returns the handle to a new SHOW_FITS or the handle to
%      the existing singleton*.
%
%      SHOW_FITS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOW_FITS.M with the given input arguments.
%
%      SHOW_FITS('Property','Value',...) creates a new SHOW_FITS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before show_fits_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to show_fits_OpeningFcn via varargin.
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
% Edit the above text to modify the response to help show_fits

% Last Modified by GUIDE v2.5 08-Aug-2017 15:29:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @show_fits_OpeningFcn, ...
                   'gui_OutputFcn',  @show_fits_OutputFcn, ...
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


% --- Executes just before show_fits is made visible.
function show_fits_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to show_fits (see VARARGIN)

% Choose default command line output for show_fits
handles.output = hObject;

n = numel(varargin);

if n < 1
    datafile = uigetfile('*.mat');
    fstruct = load(datafile);
    data = fstruct.data;
else
    data = varargin{1};
end
if n < 2
    specsfile = uigetfile('*.mat');
    fstruct = load(specsfile);
    specs = fstruct.specs;
else
    specs = varargin{2};
end

nchan = numel(specs);
chan_strs = cellfun(@num2str, num2cell(1:nchan),'UniformOutput', false);
set(handles.channel_popup,'String', chan_strs);
set(handles.channel_popup,'Value', 1);
handles.channel = 1;

nmov = numel(specs(1).movie_fnames);
mov_strs = cellfun(@num2str, num2cell(1:nmov),'UniformOutput', false);
set(handles.movie_popup,'String', mov_strs);
set(handles.movie_popup,'Value', 1);

handles.data = data;
handles.specs = specs;

handles.nframe = size(data{1},2);
set(handles.frame_slider,'SliderStep',[1,10]/(handles.nframe - 1));

iptsetpref('ImshowBorder','tight');

handles.image = imshow([],'Parent',handles.image_axes);
    hold(handles.image_axes,'on');
handles.pts = plot(1,1,'ro','Parent',handles.image_axes);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = show_fits_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
varargout{1} = handles.output;

% ------------------------------------------------------------------------
% User defined functions -------------------------------------------------
% ------------------------------------------------------------------------

function load_movie(hObject,handles,movie)

fname = handles.specs(handles.channel).movie_fnames{movie};
xrange = handles.specs(handles.channel).channel_dims([1 2]);
xinds = xrange(1):xrange(2);
handles.movie = readTiffFast(fname);
handles.movie = handles.movie(:,xinds,:);
handles.movie_num = movie;
set(handles.frame_edit, 'String', '1');
show_frame(handles,1);
guidata(hObject,handles);

function show_frame(handles,frame_num)
I = handles.movie(:,:,frame_num);
m = handles.movie_num;
pts = [handles.data{handles.channel}(m,frame_num).x',...
    handles.data{handles.channel}(m,frame_num).y'];
show_image(handles,I,pts);

function show_image(handles,frame,pts)

hold(handles.image_axes,'off');
set(handles.image,'CData', frame);
caxis(handles.image_axes, [min(frame(:)) max(frame(:))]);

if pts
    hold(handles.image_axes,'on');
    set(handles.pts,'XData',pts(:,1),'YData',pts(:,2));
end

function n = frame_from_slider(nframes, val)
n = round(val*(nframes - 1) + 1);

function val = slider_from_frame(nframes, n)
val = (n-1)/(nframes-1);


% --- Executes on selection change in channel_popup.
function channel_popup_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.channel = get(hObject,'Value');
load_movie(hObject,handles,handles.movie_num);


% --- Executes during object creation, after setting all properties.
function channel_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in movie_popup.
function movie_popup_Callback(hObject, eventdata, handles)

movie = get(hObject,'Value');
load_movie(hObject,handles,movie);


% --- Executes during object creation, after setting all properties.
function movie_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
n = frame_from_slider(handles.nframe, val);
set(handles.frame_edit, 'String', num2str(n));
show_frame(handles,n);


% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function frame_edit_Callback(hObject, eventdata, handles)
frame_num = round(str2num(get(hObject,'String')));

show_frame(handles,frame_num);
val = slider_from_frame(handles.nframe, frame_num);
set(handles.frame_slider,'Value', val);


% --- Executes during object creation, after setting all properties.
function frame_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
