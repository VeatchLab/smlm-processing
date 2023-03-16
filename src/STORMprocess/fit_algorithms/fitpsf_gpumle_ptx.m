function [ data ] = fitpsf_gpumle_ptx(psfstack, bgstack, specs)
% [ DATA ] = FITPSF_GPUMLE_PTX(PSFSTACK, BGSTACK, SPECS)

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
    psf = specs.PSFwidth;
    dL = round(specs.r_centroid);
    iters = specs.mle_iters;
    
    if ~(size(psfstack) == size(bgstack))
        error('fitpsf_gpumle_ptx: size of psfstack and bgstack must be equal!');
    end

    bgmeans = repmat(mean(mean(bgstack,1),2),2*dL + 1,2*dL + 1);

    % Do fitting
    tic;
    n = size(psfstack,3);
    switch specs.bg_method
        case {'standard','unif'}
            stk = single(psfstack);
            if strcmp(specs.bg_method, 'standard')
                stk = stk-single(bgstack)+single(bgmeans);
            end

            if specs.fitsigma
                [P,CRLB,LL] = gpumle_floatpsf_floatbg(stk, psf, iters);
            else
                [P,CRLB,LL] = gpumle_fixpsf_floatbg(stk, psf, iters);
            end
        case 'true'
            stk = single(psfstack);
            if specs.fitsigma
                [P, CRLB, LL] = gpumle_floatpsf_fixbg(stk,psf,iters,single(bgstack));
            else
                [P, CRLB, LL] = gpumle_fixpsf_fixbg(stk,psf,iters,single(bgstack));
            end
        otherwise
            error(['no such bg_method: ', specs.bg_method]);
    end

    t=toc;
    fprintf('GPUgaussMLEv2 completed %d fits in %f s\n', n, t);

    % Extract data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data.xroi = P(:,2)' - dL; data.yroi = P(:,1)' - dL; % positions wrt center of fitting region
    data.I = P(:,3)'; % Fitted intensity
    if specs.fitsigma
        data.widthxx = P(:,5)';
        data.widthyy = data.widthxx;
        data.d = data.widthxx;
        data.errorsigma = sqrt(CRLB(:,5)');
    end
    data.errorx = sqrt(CRLB(:,2)'); data.errory = sqrt(CRLB(:,1)'); % estimated fit errors
    data.bg = P(:,4)';
    data.errorI = sqrt(CRLB(:,3)');
    data.errorbg = sqrt(CRLB(:,4)');
    data.LL = LL';
    
end
