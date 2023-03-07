[all_data1 all_data2 rough_tform, dims1, dims2] = fidfind([], 'channel_dims', {[1 1024 1 2048], [1025 2048 1 2048]});

Version = 1;

save fiducial_fits.mat all_data1 all_data2 rough_tform dims1 dims2 Version
