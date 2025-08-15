function savedata = calc_all_corrs(data1, data2, timings, options, startt, endt)

calib = options.calib;
mask = options.mask;
frame_time = options.frame_time; 

goodframes = find((startt<=timings) & (timings<=endt));
data1 = data1(goodframes);
data2 = data2(goodframes);
timings = timings(goodframes);

locper1 = sqrt(2)*mean([data1.errory])*calib;
locper2 = sqrt(2)*mean([data2.errory])*calib;

rmax_XCor = options.rmax_XCor/calib; % camera pixel units
rmax_ACor11 = options.rmax_ACor11/calib;
rmax_ACor22 = options.rmax_ACor22/calib;
rbinsize_XCor = options.rbinsize_XCor/calib;
rbinsize_ACor11 = options.rbinsize_ACor11/calib;
rbinsize_ACor22 = options.rbinsize_ACor22/calib;

mintau_XCor = options.mintau_XCor*frame_time;
maxtau_XCor = options.maxtau_XCor*frame_time;
mintau_ACor11 = options.mintau_ACor11*frame_time;
maxtau_ACor11 = options.maxtau_ACor11*frame_time;
mintau_ACor22 = options.mintau_ACor22*frame_time;
maxtau_ACor22 = options.maxtau_ACor22*frame_time;

% find normalizations
XCor_norm = find_Cor_norm_livecell(data1, data2, calib, mask, rmax_XCor, rbinsize_XCor);
ACor_norm11 = find_Cor_norm_livecell(data1, data1, calib, mask, rmax_ACor11, rbinsize_ACor11);
ACor_norm22 = find_Cor_norm_livecell(data2, data2, calib, mask, rmax_ACor22, rbinsize_ACor22);

% calculate cross-correlations and auto-correlations
[XCor, XCor_tauavg, r_XC] = find_Cor_livecell(data1, data2, mask, rmax_XCor, rbinsize_XCor, XCor_norm, mintau_XCor, maxtau_XCor, timings, frame_time);
[ACor11, ACor11_tauavg, r_11] = find_Cor_livecell(data1, data1, mask, rmax_ACor11, rbinsize_ACor11, ACor_norm11, mintau_ACor11, maxtau_ACor11, timings, frame_time);
[ACor22, ACor22_tauavg, r_22] = find_Cor_livecell(data2, data2, mask, rmax_ACor22, rbinsize_ACor22, ACor_norm22, mintau_ACor22, maxtau_ACor22, timings, frame_time);

% find taus
taubins_XCor = (mintau_XCor+.5*frame_time):frame_time:(maxtau_XCor+.5*frame_time);
taus_XCor = taubins_XCor(2:end)-.5*frame_time;

taubins_ACor11 = (mintau_ACor11+.5*frame_time):frame_time:(maxtau_ACor11+.5*frame_time);
taus_ACor11 = taubins_ACor11(2:end)-.5*frame_time;

taubins_ACor22 = (mintau_ACor22+.5*frame_time):frame_time:(maxtau_ACor22+.5*frame_time);
taus_ACor22 = taubins_ACor22(2:end)-.5*frame_time;

% for output
savedata.XCor = XCor;
savedata.XCor_tauavg = XCor_tauavg;
savedata.XCor_norm = XCor_norm;
savedata.ACor11 = ACor11;
savedata.ACor11_tauavg = ACor11_tauavg;
savedata.ACor_norm11 = ACor_norm11;
savedata.ACor22 = ACor22;
savedata.ACor22_tauavg = ACor22_tauavg;
savedata.ACor_norm22 = ACor_norm22;

savedata.taus11 = taus_ACor11*60; %in sec
savedata.taus22 = taus_ACor22*60;
savedata.taus12 = taus_XCor*60;

savedata.r11 = r_11*calib; % in nm
savedata.r22 = r_22*calib;
savedata.r12 = r_XC*calib;

savedata.locper1 = locper1;
savedata.locper2 = locper2;

savedata.options = options;



