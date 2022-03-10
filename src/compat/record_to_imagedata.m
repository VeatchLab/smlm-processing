function record_to_imagedata(record_fname, group)

if nargin < 2
    group = false;
end

record = load(record_fname);
finaldata = load(record.final_fname);
fits = load(record.fits_fname);

nchan = numel(record.SPspecs);


id = repmat(struct('raw_data_filenames',[],'TIR_image_filename',[], ...
        'image_process_specs',[],'cull_specs',[],'final_image_specs',[], ...
        'zoom_specs',[],'align_specs',[],'alignment_data',[], ...
        'resolution_data',[],'culldata',[],'Itot',[],'res_specs',[], ...
        'corfunc_specs',[],'TIR_cropdim',[],'transformed_data',[], ...
        'DV_transform_specs',[],'XC_data',[],'Itot_RGB',[], ...
        'processed_image_data',[],'Ctot',[],'Iave',[],'timing_data',[], ...
        'Ctot_raw', []),...
        1,nchan);
    
if nchan == 1 && exist('./imagedata.mat', 'file')
    id = load('imagedata.mat');
elseif nchan == 2 && exist('./imagedata1.mat', 'file')
    id(1) = load('imagedata2.mat'); id(2) = load('imagedata1.mat');
end

for ichan = 1:nchan
    SPspecs = record.SPspecs(ichan);
    
    %filenames
    id(ichan).raw_data_filenames = char(SPspecs.movie_fnames);
    
    %skip TIR_image_filename
    %specs
    oldspecs = [];
    oldspecs.index_range = 1:500;
    oldspecs.smallfiltsigma = .75;
    oldspecs.largefiltsigma = 10;
    oldspecs.threshold = SPspecs.thresh;
    oldspecs.rmax_neighbor = SPspecs.r_neighbor;
    oldspecs.r_centroid = SPspecs.r_centroid;
    oldspecs.PSFwidth = SPspecs.PSFwidth;
    oldspecs.display_flag = 1;
    switch SPspecs.bg_type
        case 'mean'
            oldspecs.subtract_Iave_flag = 1;
            oldspecs.subtract_Imed_flag = 0;
        case {'median', 'selective'}
            oldspecs.subtract_Iave_flag = 0;
            oldspecs.subtract_Imed_flag = 1;
        otherwise % including 'none'
            oldspecs.subtract_Iave_flag = 0;
            oldspecs.subtract_Imed_flag = 0;
    end
    oldspecs.fit_tol = 1e-3;
    oldspecs.wavelet_flag = 1;
    
    ts_fname = replace( deblank(id(ichan).raw_data_filenames(1,:)), ...
                                    '.tif','_timestamp.mat');
    sample_timestamp = load(ts_fname);
    cd = sample_timestamp.cropdims;
    
    if nchan == 2
        oldspecs.cropdim = [1 1 255 cd(4) - cd(3)];
        if ichan == 2 % goes in imagedata1
            oldspecs.cropdim(1) = 256;
        end
    elseif nchan == 1
        oldspecs.cropdim = [1 1 cd(2) - cd(1) cd(4) - cd(3)];
    end
    
    id(ichan).image_process_specs = oldspecs;
    
    id(ichan).processed_image_data = new_to_old(fits.data{ichan});
    for imov = 1:numel(id(ichan).processed_image_data)
        id(ichan).processed_image_data(imov).raw_filename = SPspecs.movie_fnames{imov};
    end
    
    % skip cull_specs
    % final_image_specs
    fac = SPspecs.camera_specs.magnification/(1e3*SPspecs.camera_specs.pixel_size);
    fispecs.calib = 1/fac; % final points are scaled to nm
    fispecs.resolution = 16;
    fispecs.psf = 20;
    fispecs.contrast_fact = 4;
    fispecs.colormap = 'gray';
    if nchan == 2
        if ichan == 1
            fispecs.colormap = 'green';
        elseif ichan == 2
            fispecs.colormap = 'red';
        end
    end
    fispecs.scalebarlength = 5;
    
    id(ichan).final_image_specs = fispecs;
    
    % skip zoom_specs and align_specs
    d = dilatepts(finaldata.data{ichan}, fac);
    adata.alldata_track = new_to_old(d,'rawdata', true, false);
    
    [d.tmp] = d.y;
    [d.y] = d.x;
    [d.x] = d.tmp;
    d = rmfield(d, 'tmp');
    adata.alldata_raw = mergeacross(d);
    
    if group
        fprintf('Starting grouping on channel %d\n', ichan);
        tic;
        grouped = groupSTORM(d, .5);
        disp(toc);
        adata.alldata = mergeacross(grouped);
    else
        adata.alldata = adata.alldata_raw;
    end
        
    if ~isempty(record.drift_info)
        adata.xshifts = record.drift_info.xshift;
        adata.yshifts = record.drift_info.yshift;
    end
    
    id(ichan).alignment_data = adata;
   
    
    id(ichan).generated_by = 'record_to_imagedata'
    
end

%%

if nchan == 1
    imagedata = id(1);
    
    save imagedata.mat -struct imagedata
elseif nchan == 2
    % Note swapped channel order
    imagedata2 = id(1);
    imagedata1 = id(2);
    
    save imagedata1.mat -struct imagedata1
    save imagedata2.mat -struct imagedata2
end
