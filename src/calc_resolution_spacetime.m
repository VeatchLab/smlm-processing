function [res, info] = calc_resolution_spacetime()
% CALC_RESOLUTION_SPACETIME Compute spatiotemporal resolution for STORM data
%   [RES, INFO] = CALC_RESOLUTION_SPACETIME()
%   
%   Inputs:
%       final.mat - imagestruct containing fields x, y, t, spacewin, timewin
%   
%   Outputs:
%       RES - resolution value in nm
%       INFO - structure containing correlation data and parameters
%
%   TODO: Functionalize this code
&   Note: I tried to make this file fancy and functional, but it did not work.
%         Compare to last commit to see what I mean. 

is1 = imagestruct_default('final.mat');
data = unpack_imagestruct(is1);

%% Optionally draw a new spatial window / ROI. Skip this step to use the one from the paper.
% spacewin_gui is a helper gui for drawing spatial windows that may have
% holes or multiple disjoint segments. Press 'save and close' when
% you are done.

%data.spacewin = spacewin_gui(data, 'PixelSize', 10) % use 10nm pixels
data(1).spacewin = spacewin_gui(data(1), 'PixelSize', 10); % use 10nm pixels
data(2).spacewin = data(1).spacewin;

%% Run the resolution estimation routine
% Here we supply the data as a struct with fields x,y,t,spacewin,timewin.
% The function also accepts these arguments separately (in that order).
[corrdata, params] = spacetime_resolution(data(2), 'NTauBin', 10, 'Bootstrap', false);

%% Plot the correlation functions for each tau bin
figure;
plot(corrdata.r, corrdata.cWA)
tau = corrdata.taubincenters;
lh = legend(arrayfun(@num2str, tau, 'UniformOutput', false));
title(lh,'\tau (s)');
xlabel 'r (nm)'
ylabel 'g(r, \tau)'
set(gca, 'YScale', 'log');

%% Plot the normalized correlation function differences
figure;
plot(corrdata.r, corrdata.nDg);
lh = legend(arrayfun(@num2str, tau(1:end-1), 'UniformOutput', false));
title(lh,'\tau (s)');
xlabel 'r (nm)'
ylabel 'g(r, \tau)'

%% Plot the estimated resolution as a function of tau, and report average resolution
figure;
errorbar(tau(1:end-1),corrdata.s,corrdata.confint, 'o-');
title(sprintf('Average resolution is %.1f nm ', corrdata.S))
xlabel('\tau (s)', 'FontSize', 16)
ylabel('resolution estimate (nm)','FontSize',16)
%xlim([0,2.5])
%ylim([6,9])
%% Save Resolution Info
res_info.corrdata = corrdata;
res_info.params = params;
res_info.tau = tau;

save('res_info_channel2.mat','-struct','res_info');

