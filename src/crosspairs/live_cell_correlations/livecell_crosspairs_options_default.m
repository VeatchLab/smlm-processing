function options = livecell_crosspairs_options_default()
% modify options by changing fields of the struct

options.startt = 0;
options.endt = 100;

options.show_corrs = 1;

options.rmax_XCor = 1000; %in nm
options.rmax_ACor11 = 1000;
options.rmax_ACor22 = 1000;

options.rbinsize_XCor = 50;
options.rbinsize_ACor11 = 25;
options.rbinsize_ACor22 = 25;

options.mintau_XCor = 0; 
options.maxtau_XCor = 100; %in frames
options.mintau_ACor11 = 0;
options.maxtau_ACor11 = 15;
options.mintau_ACor22 = 0;
options.maxtau_ACor22 = 15;

options.calib = 160; %nm per pixel
options.mask = [];
options.frame_time = 1; %time per frame
options.integration_time = .02; %in sec