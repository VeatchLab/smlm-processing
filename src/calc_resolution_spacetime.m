function [res, info] = calc_resolution_spacetime(data, options)
% CALC_RESOLUTION_SPACETIME Compute spatiotemporal resolution for STORM data
%   [RES, INFO] = CALC_RESOLUTION_SPACETIME(DATA, OPTIONS)
%   
%   Inputs:
%       DATA - imagestruct containing fields x, y, t, spacewin, timewin
%              or struct array with these fields
%       OPTIONS - resolution options structure (optional, uses defaults if not provided)
%   
%   Outputs:
%       RES - resolution value in nm
%       INFO - structure containing correlation data and parameters
%
%   Loads 'final.mat' and uses default options

is1 = imagestruct_default('final.mat');
data = unpack_imagestruct(is1);
%data.spacewin = spacewin_gui(data, 'PixelSize', 10) % use 10nm pixels
data(1).spacewin = spacewin_gui(data(1), 'PixelSize', 10); % use 10nm pixels
data(2).spacewin = data(1).spacewin;

% Process each channel
res = cell(size(data));
info = cell(size(data));

    
%% Run the resolution estimation routine
% Here we supply the data as a struct with fields x,y,t,spacewin,timewin.
% The function also accepts these arguments separately (in that order).
    
% Extract parameters from options if available
nt_bin = 10; % default
bootstrap = false; % default

if isfield(options, 'NTauBin')
    nt_bin = options.NTauBin;
end
if isfield(options, 'Bootstrap')
    bootstrap = options.Bootstrap;
end
    
[corrdata, params] = spacetime_resolution(data, 'NTauBin', nt_bin, 'Bootstrap', bootstrap);
    
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