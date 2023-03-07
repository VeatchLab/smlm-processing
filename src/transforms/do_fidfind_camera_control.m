[all_data1, all_data2, rough_tform, dims1, dims2] = fidfind([], 'channel_dims', {[1, 512, 1 256], [1 512 257 512]});

Version = 1;

save fiducial_fits.mat all_data1 all_data2 rough_tform dims1 dims2 Version
