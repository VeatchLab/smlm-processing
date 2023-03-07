function correct_dx_in_imagedatas(outfile, backupfilename)
% corrections to STORM_analyzer_dualview data
% with culldata shifted by the dx error induced by the 'bugfix' of July
% 2017 (cropdims(3) - 1 instead of 512 - cropdims(4)), and subsequent
% analysis redonego

if nargin < 1
    error('No filename pattern provided');
end

% filenames to put corrected data in
outf1 = [outfile '1.mat'];
outf2 = [outfile '2.mat'];

% copy old data if requested
if nargin == 2
    back1 = [backupfilename '1.mat'];
    back2 = [backupfilename '2.mat'];
    copyfile('imagedata1.mat', back1);
    copyfile('imagedata2.mat', back2);
else
    if strcmp(outfile, 'imagedata')
        fprintf('This would overwrite imagedata without backing up the old version\n');
        return;
    end
    if ~isempty(dir(outf1)) || ~isempty(dir(outf2))
        fprintf('Specified outfiles already exist, aborting\n');
        return;
    end
end

% find the timestamp
d = dir();
nm = {d.name};
ind = find(~cellfun(@isempty, regexp(nm, 'timestamp', 'match')));
if ~isempty(ind)
    ts_name = nm{ind(1)};
else
    d = dir('..');
    nm = {d.name};
    ind = find(~cellfun(@isempty, regexp(nm, 'timestamp', 'match')));
    if ~isempty(ind)
        ts_name = ['../' nm{ind(1)}];
    else
        d = dir('../..');
        nm = {d.name};
        ind = find(~cellfun(@isempty, regexp(nm, 'timestamp', 'match')));
        if ~isempty(ind)
            ts_name = ['../../' nm{ind(1)}];
        else
            d = dir('../../..');
            nm = {d.name};
            ind = find(~cellfun(@isempty, regexp(nm, 'timestamp', 'match')));
            if ~isempty(ind)
                ts_name = ['../../../' nm{ind(1)}];
            else
                error('No timestamp found');
            end
        end
    end
end

ts = load(ts_name);
right_dx = 512 - ts.cropdims(4);
    

% check if there's a difference
id1 = load('imagedata1', 'image_process_specs', 'processed_image_data');
mov_height = id1.image_process_specs.cropdim(4);
if isfield(id1.processed_image_data(1), 'dx')
    used_dx = id1.processed_image_data(1).dx
else
    used_dx = right_dx;
    disp('no dx in imagedata. assuming right dx')
end
%right_dx = 512 - (wrong_dx + mov_height + 1)

if used_dx == right_dx
    disp('dx is already correct, copying only');
    copyfile('imagedata1.mat', outf1);
    copyfile('imagedata2.mat', outf2);
    return;
end

h = STORM_analyzer_dualview();

%%

handles = guidata(h);

%%
% mov_height = handles.imagedata1.image_process_specs.cropdim(4); % height of cropped recorded movie
% wrong_dx = handles.imagedata1.processed_image_data(1).dx;
% right_dx = 512 - (wrong_dx + 1 + mov_height); % double checked with compare_dx script for one dataset

%% do the shifting of dxs
PID1 = handles.imagedata1.processed_image_data;
[PID1.dx] = deal(right_dx);
PID2 = handles.imagedata2.processed_image_data;
[PID2.dx] = deal(right_dx);

for i = 1:numel(PID1) % loop over movies
    d1 = PID1(i).data;
    d2 = PID2(i).data;
    
    for j = 1:numel(d1) % loop over frames
        d1(j).x = d1(j).x - used_dx + right_dx;
        d2(j).x = d2(j).x - used_dx + right_dx;
    end
    
    PID1(i).data = d1;
    PID2(i).data = d2;
end

handles.imagedata1.processed_image_data = PID1;
handles.imagedata2.processed_image_data = PID2;

guidata(h, handles);

%%

b = handles.run_cull_pushbutton1;
STORM_analyzer_dualview('run_cull_pushbutton1_Callback',b,[],guidata(b));

b = handles.run_cull_pushbutton2;
STORM_analyzer_dualview('run_cull_pushbutton2_Callback',b,[],guidata(b));

%%

b = handles.DV_transform_pushbutton;
STORM_analyzer_dualview('DV_transform_pushbutton_Callback', b, [], guidata(b));

%%

b = handles.run_alignment_pushbutton;
STORM_analyzer_dualview('run_alignment_pushbutton_Callback', b, [], guidata(b));

%%

b = handles.update_STORM_image_pushbutton;
STORM_analyzer_dualview('update_STORM_image_pushbutton_Callback', b, [], guidata(b));

%%

% need to correct the mask first
handles = guidata(h);
calib = handles.imagedata1.final_image_specs.calib;
resolution = handles.imagedata1.final_image_specs.resolution;
px_shift = round((right_dx - used_dx) * calib/resolution);
%px_shift = round((right_dx - wrong_dx) * calib/resolution);

M = handles.imagedata1.res_specs.mask;
if px_shift > 0
    M = vertcat(M((end - px_shift + 1):end,:), M(1:(end - px_shift),:));
elseif px_shift < 0
    M = vertcat( M((-px_shift + 1):end,:), M(1:(-px_shift),:));
end

handles.imagedata1.res_specs.mask = M;
handles.imagedata2.res_specs.mask = M;
guidata(h, handles);

b = handles.update_resolution_pushbutton;
STORM_analyzer_dualview('update_resolution_pushbutton_Callback', b, [], guidata(b));

%%

b = handles.update_xcorr_pushbutton;
STORM_analyzer_dualview('update_xcorr_pushbutton_Callback', b, [], guidata(b));


%%
handles = guidata(h);
imd1 = handles.imagedata1;
imd2 = handles.imagedata2;

save(outf1, '-struct', 'imd1');
save(outf2, '-struct', 'imd2');

%%

b = handles.Close_no_save;
STORM_analyzer_dualview('Close_no_save_Callback', b, [], guidata(b));
