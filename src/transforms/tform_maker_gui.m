function varargout = tform_maker_gui(varargin)
% TFORM_MAKER_GUI MATLAB code for tform_maker_gui.fig
%      TFORM_MAKER_GUI, by itself, creates a new TFORM_MAKER_GUI or raises the existing
%      singleton*.
%
%      H = TFORM_MAKER_GUI returns the handle to a new TFORM_MAKER_GUI or the handle to
%      the existing singleton*.
%
%      TFORM_MAKER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TFORM_MAKER_GUI.M with the given input arguments.
%
%      TFORM_MAKER_GUI('Property','Value',...) creates a new TFORM_MAKER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tform_maker_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tform_maker_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 2023 Matt Stone, Thomas Shaw and Sarah Veatch
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
% Edit the above text to modify the response to help tform_maker_gui

% Last Modified by GUIDE v2.5 17-Oct-2019 16:16:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tform_maker_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @tform_maker_gui_OutputFcn, ...
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

function tform_maker_gui_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;

% look into current directory for transformdata
AA = dir();
c = {AA.name};
c_log = strcmp('transformdata.mat',c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CASE transformdata.mat exists
if sum(c_log) == 1 
    
    load transformdata 
    handles.data = handles_pass.data;
    handles.cullparams = handles_pass.cullparams;
    handles.transform_data_name = handles_pass.names;
    handles.culldata = handles_pass.culldata;
    handles.used_ch1_pts = handles_pass.used_ch1_pts;
    handles.used_ch2_pts = handles_pass.used_ch2_pts;
    handles.names = handles_pass.names;
    
    handles.T_2_1 = handles_pass.T_2_1;
    handles.p_remaining = handles_pass.p_remaining;
  
    set(handles.percent_remaining,'string',num2str(handles.p_remaining));
            
    set(handles.listbox1,'string',handles_pass.names);
    c = struct2cell(handles_pass.cullparams);
    set(handles.Cull_specs_table,'UserData',c)
    
    set(handles.FRE_error_disp,'string',handles_pass.FRE)
    set(handles.TRE_error_disp,'string',handles_pass.TRE)
    
    
    set(handles.figure1, 'CurrentAxes', handles.FRE_error_map); 
        FRE_err_plot = handles_pass.FRE_err_plot;
        scatter(FRE_err_plot.ydata,FRE_err_plot.xdata,[],FRE_err_plot.errs,'filled');
        set(gca,'ytick', [],'xtick', [])
        axis equal off
        axis([0 256 0 512]);
        caxis(FRE_err_plot.v);
        
    set(handles.figure1, 'CurrentAxes', handles.TRE_error_map); 
        TRE_err_plot = handles_pass.TRE_err_plot;   
        scat_plot = TRE_err_plot.scat_plot;
        
        scatter(scat_plot.fit2_2,scat_plot.fit2_1,[],scat_plot.TRE_err,'filled');
        set(gca,'ytick', [],'xtick', [])
        axis equal off
        axis([0 256 0 512]);
        caxis(TRE_err_plot.v);

    set(handles.figure1, 'CurrentAxes', handles.error_map_colorbar); 
        Color_err_plot = handles_pass.Color_err_plot;
        img = imagesc(Color_err_plot.Y');
        set(gca,'ytick', Color_err_plot.color_vec2)
        set(img,'XData',Color_err_plot.color_vec2)
        axis off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CASE transform.mat does not exist
elseif sum(c_log) == 0
    handles.data = [];

    cullparams.xyErrorMax = 0.35;
    cullparams.I_min = 600;
    cullparams.I_max = 25000;
    cullparams.width_max = 1.8;
    cullparams.width_min = 1.0;
    cullparams.LL_min = -100;
        
    c = struct2cell(cullparams);
    set(handles.Cull_specs_table,'UserData',c)

    handles.cullparams = cullparams;
    
%CASE degenerate files
elseif sum(c_log) > 1
    disp('Please remove degenerate transformdata.mat files from current directory')
end
    
guidata(hObject, handles);

function varargout = tform_maker_gui_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

function add_fiducial_file_Callback(hObject, ~, handles) %#ok<*DEFNU>
homer = cd;
[fiducial_file, pathname] = uigetfile('*.mat');

if fiducial_file
    H_listbox = handles.listbox1;

    contents = get(H_listbox,'String');
    if isempty(contents)
        new_ind = 1;
    else
        new_ind = numel(cellstr(contents))+1;
    end
    handles.names{new_ind}=pathname; % handles storing pathnames to fiducial data
    handles.filenames{new_ind}=fiducial_file; % handles storing filenames to fiducial data
    data = handles.data; %get the current data structure

    cd(pathname); 
    fits = load(fiducial_file); %LOAD IN THE DATA TO BE ADDED
    %store the data
    data(new_ind).all_data1 = fits.all_data1; %ADD NEW DATA TO NEW INDEX
    data(new_ind).all_data2 = fits.all_data2; %DATA ADDED TO SAME INDEX AS NAMES
    %this is where I would want to deal with version/channel_dims
    if isfield(fits, 'Version')
        data(new_ind).Version = fits.Version;
        data(new_ind).dims1 = fits.dims1;
        data(new_ind).dims2 = fits.dims2;
        if new_ind > 1 && ~all(fits.dims1 == data(1).dims1 & fits.dims2 == data(1).dims2)
            % in this case, don't add the file
            % (note that even though handles was changed, there hasn't been a call to
            % guidata(hObject, handles), so state should be preserved)
            cd(homer)
            error('dims of new file don''t match dims of other files');
        end
    end

    handles.data = data; %set the new data structure

    set(H_listbox,'String',handles.names) 
    guidata(hObject, handles);
    cd(homer)
end

function remove_file_Callback(hObject, ~, handles)
H_listbox = handles.listbox1;

contents = cellstr(get(H_listbox,'String'));

selected = contents{get(H_listbox,'Value')};

Remo = strcmp(selected,handles.names);
handles.names = handles.names(~Remo);
handles.filenames = handles.filenames(~Remo);
handles.data = handles.data(~Remo);
     
set(H_listbox,'String',handles.names) 
set(H_listbox,'Value',1)
set(handles.success,'string','');

set(handles.percent_remaining,'String',' ')
set(handles.FRE_error_disp,'String',' ')
set(handles.TRE_error_disp,'String',' ')
set(handles.figure1, 'CurrentAxes', handles.error_map_colorbar);
cla(handles.error_map_colorbar)
cla(handles.FRE_error_map)
cla(handles.TRE_error_map)
guidata(hObject, handles);

function make_transform_Callback(hObject, ~, handles)
data1 = [handles.culldata.data1];%updated by SAS 10.21.16 - transform was being calculated from unculled points. 
data2 = [handles.culldata.data2];
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fit1=[];
fit1(:,2)=[data1.x]; % transpose data to accomodate for STORM_analyzer_daulview
fit1(:,1)=[data1.y];

fit2=[];
fit2(:,2)=[data2.x];
fit2(:,1)=[data2.y];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

npt = round(str2double(handles.npt_lwm_edit.String));

[T_1_2] = cp2tform(fit1,fit2,'lwm', npt); %not really used, should update 
%SAD to remove

[T_2_1,used_ch2_pts,used_ch1_pts] = cp2tform(fit2,fit1,'lwm', npt);

if ~isempty(T_2_1)
    set(handles.success,'string','SUCCESS X0 ');
end

showtform(T_2_1);

handles.T_2_1 = T_2_1;
handles.T_1_2 = T_1_2;
handles.used_ch2_pts = used_ch2_pts;
handles.used_ch1_pts = used_ch1_pts;
guidata(hObject, handles);

function cull_fiducials_Callback(hObject, ~, handles)
cullparams = handles.cullparams;
data1 = [handles.data.all_data1];
data2 = [handles.data.all_data2];

ch1_fitting_errs = sqrt(([data1.error_x].^2)+([data1.error_y].^2));
ch2_fitting_errs = sqrt(([data2.error_x].^2)+([data2.error_y].^2));

ch1_widths = sqrt(([data1.wx].^2)+([data1.wy].^2));
ch2_widths = sqrt(([data2.wx].^2)+([data2.wy].^2));

AA = ch1_fitting_errs < cullparams.xyErrorMax;
BB = ch2_fitting_errs < cullparams.xyErrorMax;
passed_cull_error = AA & BB;

CC = [data1.tI] > cullparams.I_min;
DD = [data2.tI] > cullparams.I_min;
passed_cull_tI_min = CC & DD;

Ca = [data1.tI] < cullparams.I_max;
Da = [data2.tI] < cullparams.I_max;
passed_cull_tI_max = Ca & Da;

Cb = ch1_widths > cullparams.width_min;
Db = ch2_widths > cullparams.width_min;
passed_cull_width_min = Cb & Db;

Cc = ch1_widths < cullparams.width_max;
Dc = ch2_widths < cullparams.width_max;
passed_cull_width_max = Cc & Dc;

passed_LL_1 = [data1.LL] > cullparams.LL_min;
passed_LL_2 = [data2.LL] > cullparams.LL_min;
passed_LL = passed_LL_1 & passed_LL_2;

passed_all_cull = passed_cull_tI_min & passed_cull_error & passed_cull_tI_max & ...
    passed_cull_width_min & passed_cull_width_max & passed_LL;

percent_remaining = sum(passed_all_cull)/numel(data1);
pct_remaining_str = [num2str(sum(passed_all_cull)) ' of ' num2str(numel(data1)) ' = ' num2str(percent_remaining*100) '%'];

set(handles.percent_remaining, 'string', pct_remaining_str);
handles.p_remaining = percent_remaining;
culled_data1 = data1(passed_all_cull);
culled_data2 = data2(passed_all_cull);
  
  % CAN BE USED LATER TO FINISH DRAWING CULL VISUAL ON SUBPLOTS
%   if handles.parameter_window
%       h1 = handles.parameter_window;
%       figure(h1)
%       
%   subplot(4,1,1)
%       
%          hold on 
%          plot([cullparams.xyErrorMax cullparams.xyErrorMax],[min(N_Er1) max(N_Er1)],'k-')
%         hold on       
%       
%       subplot(4,1,2)
%          plot(X1,N_Er1,'r-')
%          hold on 
%          plot(X1,N_Er2,'b-')
%         
%         ylabel('Error xy')
%                   
% 
%       subplot(4,1,3)
%          plot(r_w1,N_w1,'r-')
%          hold on 
%          plot(r_w1,N_w2,'b-')
%          ylabel('Widths xy')
%          
%          subplot(4,1,4)
%          plot(r_we1,N_we1,'r')
%          hold on 
%          plot(r_we1,N_we2,'b')
%          ylabel('Error Wxy')
%   end

culldata.data1 = culled_data1;
culldata.data2 = culled_data2;

handles.culldata = culldata;
guidata(hObject, handles);

function Cull_specs_table_CellEditCallback(hObject, eventdata, handles)
cullparams = handles.cullparams;

table_index = eventdata.Indices(1);

switch table_index
    case 1
        cullparams.xyErrorMax = double(eventdata.NewData);
    case 2
        cullparams.I_min = double(eventdata.NewData);
    case 3
        cullparams.I_max = double(eventdata.NewData);
    case 4
        cullparams.width_max = double(eventdata.NewData);
    case 5
        cullparams.width_min = double(eventdata.NewData);
    case 6
        cullparams.LL_min = double(eventdata.NewData);
end

handles.cullparams = cullparams;
guidata(hObject, handles);

function Cull_specs_table_CellSelectionCallback(hObject, eventdata, handles)
function show_fit_statistics_Callback(hObject, ~, handles)
cullparams = handles.cullparams;
W_max = cullparams.width_max;
W_min = cullparams.width_min;
I_min = cullparams.I_min;
I_max = cullparams.I_max;
xyE_Max = cullparams.xyErrorMax;

if ~isempty(handles.data)

    data1 = [handles.data.all_data1];
    data2 = [handles.data.all_data2];

    ch1_fitting_errs = sqrt(([data1.error_x].^2)+([data1.error_y].^2));
    ch2_fitting_errs = sqrt(([data2.error_x].^2)+([data2.error_y].^2));

    ch1_widths = sqrt(([data1.wx].^2)+([data1.wy].^2));
    ch2_widths = sqrt(([data2.wx].^2)+([data2.wy].^2));

    ch1_widths_error = sqrt(([data1.error_wx].^2)+([data1.error_wy].^2));
    ch2_widths_error = sqrt(([data2.error_wx].^2)+([data2.error_wy].^2));

    [N_tI1, r_tI1] = hist([data1.tI],0:5e1:1e4);
    [N_tI2] = hist([data2.tI],r_tI1);

    [N_w1, r_w1] = hist(ch1_widths,0:.02:3);
    [N_w2] = hist(ch2_widths,r_w1);

    [N_we1, r_we1] = hist(ch1_widths_error,0:.02:2);
    [N_we2 ] = hist(ch2_widths_error,r_we1);


    [N_Er1, X1] = hist(ch1_fitting_errs,0:.02:2);
    [N_Er2] = hist(ch2_fitting_errs,X1);

    % mm = max([N_tI1 N_tI2]);

    h1= figure;
    set(h1, 'Position', get(h1, 'Position').*[1,1,1.5, 1]);
    subplot(2,3,2)
        plot(r_tI1,N_tI1,'r-')
        hold on 
        plot([I_min I_min],[0 max([N_tI1 N_tI2])],'k--')
        hold on 
        plot([I_max I_max],[0 max([N_tI1 N_tI2])],'k--')
        hold on 
        plot(r_tI1,N_tI2,'b-')
        hold on 
        ylabel('Intensity')

    subplot(2,3,1)
        plot(X1,N_Er1,'r-')
        hold on 
        plot(X1,N_Er2,'b-')
        hold on 
        plot([xyE_Max xyE_Max],[0 max([N_Er2 N_Er1])],'k--')
        hold on 
        ylabel('Error xy')

    subplot(2,3,4)
        plot(r_w1,N_w1,'r-')
        hold on 
        plot(r_w1,N_w2,'b-')
        hold on 
        plot([W_min W_min],[0 max([N_w2 N_w1])],'k--')
        hold on 
        plot([W_max W_max],[0 max([N_w2 N_w1])],'k--')
        hold on 
        ylabel('Widths xy')
             
    subplot(2,3,5)
        plot(r_we1,N_we1,'r')
        hold on 
        plot(r_we1,N_we2,'b')
        ylabel('Error Wxy')
        
    subplot(2,3,3)
        dims = handles.data(1).dims1;
        Icoverage = histcounts2([data1.x], [data1.y], 0:1:dims(2), 0:1:dims(4))';
        imagesc(filter2(fspecial('gaussian', 8, 3), Icoverage));
        caxis([0,.2]); colorbar; axis equal off;

    % Make sure culldata is there
    if isfield(handles, 'culldata') && isfield(handles.culldata, 'data1')
        subplot(2,3,6)
            cdata = handles.culldata.data1;
            Icoverage = histcounts2([cdata.x], [cdata.y], 0:1:dims(2), 0:1:dims(4))';
            imagesc(filter2(fspecial('gaussian', 8, 3), Icoverage));
            caxis([0,.2]); colorbar; axis equal off;
    end

    handles.parameter_window = h1;
    guidata(hObject, handles);
         
end

function points_removed_for_TRE_Callback(hObject, ~, handles)
handles.num_TRE_points =  str2double(get(hObject,'String'));
guidata(hObject, handles);

function calc_registration_errors_Callback(hObject, ~, handles)
T_2_1 = handles.T_2_1;
fit2 = handles.used_ch2_pts;
fit1 = handles.used_ch1_pts;

% %%%%%%%%%%%
%TRE target registration error
% 
number_cp=str2double(get(handles.points_removed_for_TRE,'string'));

points_to_remove = randi(size(fit2,1),number_cp,1);

set(handles.figure1, 'CurrentAxes', handles.TRE_error_map); 
cla

npt = round(str2double(handles.npt_lwm_edit.String));

sum_TRE =0;
for i=1:number_cp
    %take out control point
    p = points_to_remove(i);
    remain_cp=[1:p-1 p+1:number_cp];

    %calculate the transformation without the ith point
    tform_lwm_1_2=cp2tform(fit1(remain_cp,:),fit2(remain_cp,:),'lwm', npt);
    
    %transform the left out control point with the above transform
    trans_cp_channel2_TRE(i,:)=tforminv(fit2(p,:),tform_lwm_1_2);
    
    xy_TRE_error = fit1(p,:)-trans_cp_channel2_TRE(i,:);
    r_TRE_error = sqrt((xy_TRE_error(:,1).^2 + xy_TRE_error(:,2).^2));
    scatter(fit1(p,2),fit1(p,1),[],r_TRE_error,'filled');  
    scat_plot.fit2_2(i) = fit2(p,2);
    scat_plot.fit2_1(i) = fit2(p,1);
    scat_plot.TRE_err(i) = r_TRE_error;
    
    axis equal
    axis([0 256 0 512]);
    hold on 
    sum_TRE = sum_TRE + r_TRE_error;
end
% TRE=sqrt(sum(sum((fit1(points_to_remove,:)-trans_cp_channel2_TRE).^2))/(length(fit2)));
TRE = sum_TRE/number_cp;
set(gca,'ytick', [],'xtick', [])
v = caxis;
TRE_error_plot.scat_plot = scat_plot;
TRE_error_plot.v = v;
set(handles.TRE_error_disp,'string',num2str(TRE));
handles.TRE_error_plot = TRE_error_plot;
handles.TRE = TRE;
%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%
%FRE error calc
trans_cp_channel1=tforminv(fit1,T_2_1);
FRE=sqrt(sum(sum((fit2-trans_cp_channel1).^2))/length(fit2));
handles.FRE = FRE;
set(handles.FRE_error_disp,'string',num2str(FRE));
%%%%%%%%%%%%%%%%
%% making heat map of errors
errsxy = ((fit2-trans_cp_channel1).^2);
errs = sqrt(errsxy(:,1).^2 + errsxy(:,2).^2);
xdata = fit2(:,1);
ydata = fit2(:,2);

[X,Y] = meshgrid(floor(min(xdata)):ceil(max(xdata)),floor(min(ydata)):ceil(max(ydata)));

Z = griddata(xdata,ydata,errs,X,Y);

handles.griddata = [xdata, ydata, errs];


cla(handles.FRE_error_map)
set(handles.figure1, 'CurrentAxes', handles.FRE_error_map); 
% scatter(ydata,xdata,[],errs,'filled');

% pcolor(Y,X,Z,'edgecolor','off')
imagesc(rot90(Z))

set(gca,'ytick', [],'xtick', [])
axis equal tight
% axis([0 256 0 512]);
caxis(v);

FRE_err_plot.ydata = ydata;
FRE_err_plot.xdata = xdata;
FRE_err_plot.errs = errs;
FRE_err_plot.v = v;
handles.FRE_err_plot = FRE_err_plot;

%%%%%%%%%%%%%% 
%colorbar
set(handles.figure1, 'CurrentAxes', handles.error_map_colorbar);
cla(handles.error_map_colorbar)
% v(1)
% v(2)
color_vec = v(1):0.001:v(2);

numel(color_vec)
color_index = round(linspace(1,length(color_vec),4));
c_num_text = color_vec(color_index);
[~, Y] = meshgrid(0, color_vec);
imagesc(Y')
set(handles.error_map_colorbar,'xtick', color_index,'ytick',[])
% n=[10^-4 10^-2 10^0];
set(handles.error_map_colorbar,'xticklabel',num2str(c_num_text',2),'FontSize',11)

Color_err_plot.Y = Y;
Color_err_plot.color_vec = color_vec;
Color_err_plot.color_vec2 = color_index;
handles.Color_err_plot = Color_err_plot;

guidata(hObject, handles);

function make_file_Callback(hObject, eventdata, handles)
homer = cd;
%Note MBS: make this a batch process when have time 
[~, fiducial_location] = uigetfile('*.tif');
cd(fiducial_location);
tform_translate = [];
tform_translate = fiducial_finder_DV(tform_translate, 1, 1);

cd(homer);

function save_transform_Callback(~, ~, handles)
tform_data_name = get(handles.fname_edit, 'String');

if isempty(tform_data_name)
    tform_data_name = 'transformdata.mat';
elseif isempty(regexp(tform_data_name, '\.mat$', 'Once'))
    tform_data_name = [tform_data_name, '.mat'];
end
    
data = handles.data;

T_1_2 = handles.T_1_2; T_2_1 = handles.T_2_1;

FRE_2_1_all = handles.FRE_error;

% only take important stuff from handles
handles_pass.data = handles.data;
handles_pass.cullparams = handles.cullparams;
handles_pass.transform_data_name = handles.names;
handles_pass.culldata = handles.culldata;
handles_pass.used_ch1_pts = handles.used_ch1_pts;
handles_pass.used_ch2_pts = handles.used_ch2_pts;
handles_pass.names = handles.names;
handles_pass.FRE = handles.FRE;
handles_pass.TRE = handles.TRE;

handles_pass.T_2_1 = handles.T_2_1;
handles_pass.p_remaining = handles.p_remaining;

handles_pass.FRE_err_plot = handles.FRE_err_plot;
handles_pass.TRE_err_plot = handles.TRE_error_plot;   
handles_pass.Color_err_plot = handles.Color_err_plot;

grid_data = handles.griddata; 

if isfield(data(1), 'Version')
    Version = data(1).Version;
    dims1 = data(1).dims1;
    dims2 = data(1).dims2;
    save(tform_data_name, 'T_1_2', 'T_2_1', 'handles_pass', 'FRE_2_1_all',...
        'grid_data','Version', 'dims1', 'dims2');
else
    save(tform_data_name, 'T_1_2', 'T_2_1', 'handles_pass', 'FRE_2_1_all',...
        'grid_data');
end

function Cull_specs_table_CreateFcn(hObject, ~, handles)
%redefining cullparameters here bc handles not passed to opening function
%to determine number of culumns and rows (since matlab has glitch in 1
%column tables in guis...
cullparams.xyErrorMax = 0.35;
cullparams.I_min = 100;
cullparams.I_max = 25000;
cullparams.width_max = 1.8;
cullparams.width_min = 1.0;
cullparams.LL_min = -100;
handles.default_cull_params = cullparams;
handles.cullparams = cullparams;
guidata(hObject, handles);
        
c = struct2cell(cullparams);
set(hObject,'ColumnName','Cutoff Value','Data',c);

function npt_lwm_edit_Callback(hObject, eventdata, handles)
