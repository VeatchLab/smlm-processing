function data = fitpsf_gpuscmos(psfstack, bgstack, specs, vars)
% DATA = FITPSF_GPUSCMOS(PSFSTACK, BGSTACK, SPECS, VARS)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>

% Notes:
% specs has information about what to do with the bgstack it also has notes
% about the variance/gain/dark of the camera.
% By analogy with earlier code, the best option is likely to calibrate() the
% dataset before this step, by subtracting the offset and dividing by the gain,
% and then only pass the effective variance (= variance/gain^2) to the fitting
% routine.

% We can accomodate the usual option for dealing with bg by adding the bg to
% the variance and subtracting it from the psfstack.  This is because the added
% variance is modeled by shifting the poisson distribution to compensate for
% the extra variance, and because background adds variance equal to its mean.

psf = specs.PSFwidth;
dL = round(specs.r_centroid);
iters = specs.mle_iters;

n = size(psfstack, 3);

if ~(size(psfstack) == size(bgstack))
    error('fitpsf_gpuscmos: size of psfstack and bgstack must be equal!');
end
if ~specs.fitsigma
    error('fixed PSF sigma not supported at this time for scmos fitting');
end


bgmeans = repmat(mean(mean(bgstack,1),2),2*dL + 1, 2*dL + 1);

% Do fits
stk = single(psfstack);
switch specs.bg_method
    case {'standard', 'unif'}
        if strcmp(specs.bg_method, 'standard')
            stk = stk - single(bgstack) + single(bgmeans);
        end
        % TODO: actual fitting call
        [P, CRLB, LL, last] = scmos_sigma(stk, psf, vars, iters);

    case {'true'}
        % TODO: roughly, this would involve adding bgstack to the variance stack, and then
        % subtracting it from the psfstack. See notes at top of this function.
        error('bg_method = true not implemented yet. It is not difficult to implement, though.')
    otherwise
        error(['no such bg_method: ', specs.bg_method]);
end

% Extract data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data.xroi = P(:,2)' - dL; data.yroi = P(:,1)' - dL; % positions wrt center of fitting region
data.I = P(:,3)'; % Fitted intensity
if specs.fitsigma,
    data.widthxx = P(:,5)';
    data.widthyy = data.widthxx;
    data.d = data.widthxx;
    data.errorsigma = sqrt(CRLB(:,5)');
%    else
%        data.widthxx = psf*ones(1,n); %P(:,5);
%        data.widthyy = data.widthxx; % widths are same
%        data.d = data.widthxx;
end
data.errorx = sqrt(CRLB(:,2)'); data.errory = sqrt(CRLB(:,1)'); % estimated fit errors
data.bg = P(:,4)';
data.errorI = sqrt(CRLB(:,3)');
data.errorbg = sqrt(CRLB(:,4)');
data.LL = LL';
