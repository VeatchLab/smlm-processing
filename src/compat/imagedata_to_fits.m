function imagedata_to_fits(imagedata_name)

%%% cd /lipid/group/data/Jenny/2021_11_18_Ramos-latA-phalloidin/0uM_latA %%%

rotate = true; 

if ~exist('imagedata_name')
    if exist('./imagedata.mat','file') && ~exist('./imagedata1.mat','file')
        imagedata_name{:,1} = 'imagedata.mat'
    elseif exist('./imagedata1.mat','file')
        imagedata_name{:,1} = 'imagedata2.mat'
        imagedata_name{:,2} = 'imagedata1.mat'
    else
        disp('no imagedata file found')
    end
end

for j=1:size(imagedata_name,2)
    id(j) = load(char(imagedata_name{:,j}));
end
nchan = size(imagedata_name,2);


%% initialize record file
record_fname = 'record.mat';
record.fits_fname = 'fits.mat';
record.culled_fname = '';
record.dilated_fname = 'transformed.mat';
record.final_fname = 'final.mat';
record.grouped_fname = '';
record.transformed_fname = '';
record.dv_transform_fname = '';
record.tform_to_channel = [];
temp.specs = load('/lipid/group/data/Jenny/default_STORMspecs.mat');
record.cullspecs = temp.specs.cullspecs;
record.driftspecs = temp.specs.driftspecs;


SPspecs = [];
for ichan = 1:nchan
    
    %% populate SPspecs - modify if needed
    SPspecs(ichan).movie_fnames = char(id(ichan).raw_data_filenames);
    SPspecs(ichan).thresh = id(ichan).image_process_specs.threshold;
    SPspecs(ichan).r_neighbor = id(ichan).image_process_specs.rmax_neighbor;
    SPspecs(ichan).r_centroid = id(ichan).image_process_specs.r_centroid;
    SPspecs(ichan).PSFwidth = 1.2; %id(ichan).image_process_specs.PSFwidth;
    SPspecs(ichan).nmax = 100000; %
    SPspecs(ichan).mle_iters = 10; %
    SPspecs(ichan).fitsigma = 1; %
    SPspecs(ichan).bg_method = 'standard'; %
    SPspecs(ichan).camera_specs.type = 'emccd'; %
    SPspecs(ichan).camera_specs.name = 'iXon 888'; %
    SPspecs(ichan).camera_specs.offset = 100; %
    SPspecs(ichan).camera_specs.pixel_size = 16; %
    SPspecs(ichan).camera_specs.magnification = 100; %
    
    if id(ichan).image_process_specs.subtract_Iave_flag == 1
        SPspecs(ichan).bg_type = 'mean';
    elseif id(ichan).image_process_specs.subtract_Imed_flag == 1
        SPspecs(ichan).bg_type = 'median';
    else
        SPspecs(ichan).bg_type = 'none';
    end
    
    %% load cropdims, reshape data, & rotate if indicated
    ts_fname = replace( deblank(SPspecs(ichan).movie_fnames(1,:)), ...
        '.tif','_timestamp.mat');
    record.sample_timestamp = load(ts_fname);
    
    if nchan == 2
        rect = record.sample_timestamp.cropdims;
        if ichan == 1
            SPspecs(ichan).channel_dims = [1 256 rect(1) rect(2)];
        elseif ichan == 2
            SPspecs(ichan).channel_dims = [257 512 rect(1) rect(2)];
        end
    else
        SPspecs(ichan).channel_dims = record.sample_timestamp.cropdims;
    end
    
    if rotate
        tmp_dims = SPspecs(ichan).channel_dims;
        SPspecs(ichan).channel_dims = [tmp_dims(3) tmp_dims(4) tmp_dims(1) tmp_dims(2)];
        fits.data{ichan} = old_to_new_flipxy(id(ichan).processed_image_data);
    else
        fits.data{ichan} = old_to_new(id(ichan).processed_image_data);
    end
    
    
end

%% save variables in new folder

ts_list = dir('movie*_timestamp.mat');
[~,index] = sortrows({ts_list.date}.');
ts_list = ts_list(index);

for a=1:size(ts_list,1)
    record.metadata(a) = load(ts_list(a).name);
end

record.SPspecs = SPspecs;
mkdir new_record
if exist('new_record/record.mat')
    promptMsg = sprintf('"record.mat" already exists. Overwrite?');
    button = questdlg(promptMsg,'Saving record','Yes','No (rename)','Cancel','Yes');
    switch button
        case 'Yes'
            save new_record/record.mat -struct record
        case 'No (rename)'
            savename = inputdlg('Rename file:','s')
            save(['new_record/' savename{:}],'-struct','record')
        case 'Cancel'
    end
else
    save new_record/record.mat -struct record
end

fits.date = datetime;
fits.produced_by = 'STORM_analyzer';
fits.units = 'px';

if exist('new_record/fits.mat')
    promptMsg = sprintf('"fits.mat" already exists. Overwrite?');
    button = questdlg(promptMsg,'Saving fits','Yes','No (rename)','Cancel','Yes');
    switch button
        case 'Yes'
            save new_record/fits.mat -struct fits
        case 'No (rename)'
            savename = inputdlg('Rename file:','s')
            save(['new_record/' savename{:}],'-struct','fits')
        case 'Cancel'
    end
else
    save new_record/fits.mat -struct fits
end

end
