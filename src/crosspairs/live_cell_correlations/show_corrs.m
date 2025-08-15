function show_corrs(savedata)

% visualize cross-correlation function
figure;
plot_corr_function(savedata.XCor, savedata.XCor_tauavg, savedata.options.rmax_XCor, savedata.options.rbinsize_XCor, savedata.options.maxtau_XCor)
ylabel('Cross-Correlation')

% visualize auto-correlation of first channel
figure;
plot_corr_function(savedata.ACor11, savedata.ACor11_tauavg, savedata.options.rmax_ACor11, savedata.options.rbinsize_ACor11, savedata.options.maxtau_ACor11)
ylabel('Auto-Correlation of First Channel')
set(gca, 'Yscale', 'log')

% visualize auto-correlation of second channel
figure;
plot_corr_function(savedata.ACor22, savedata.ACor22_tauavg, savedata.options.rmax_ACor22, savedata.options.rbinsize_ACor22, savedata.options.maxtau_ACor22)
ylabel('Auto-Correlation of Second Channel')
% set(gca, 'Yscale', 'log')
