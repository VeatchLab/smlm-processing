function [P,crlb,LL] = gpumle_fixpsf_floatbg(psfstack,psfsigma,niter)
% [P,CRLB,LL] = GPUMLE_FIXPSF_FLOATBG(PSFSTACK,PSFSIGMA,NITER)

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
npx = size(psfstack,1);
if npx ~= size(psfstack,2)
    error('gpu_fixpsf_floatbg: psfs must be square');
end
nroi = size(psfstack,3);

kern = parallel.gpu.CUDAKernel('GPUgaussMLEv2.ptx','GPUgaussMLEv2.cu','kernel_MLEFit');
P = zeros(nroi,4,'single','gpuArray');
crlb = zeros(nroi,4,'single','gpuArray');
LL = zeros(nroi,1,'single','gpuArray');
kern.ThreadBlockSize = [128 1 1];
kern.GridSize = [ceil(nroi/128) 1 1];
[P,crlb,LL] = feval(kern,psfstack,psfsigma,npx,niter,P,crlb,LL,nroi);
P = gather(P);
crlb = gather(crlb);
LL = gather(LL);
