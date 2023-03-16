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
clear all

%%
d = fspecial('gaussian', 7, 1);
imagesc(d)
N=2^14;
dd = repmat(d,1,1,N);
ddn = single(poissrnd(dd*100));


%%
% kern = parallel.gpu.CUDAKernel('GPUgaussMLEv2.ptx','GPUgaussMLEv2.cu','kernel_MLEFit');
% out = zeros(N,4,'single','gpuArray');
% crlb = zeros(N,4,'single','gpuArray');
% LL = zeros(N,1,'single','gpuArray');
% kern.ThreadBlockSize = [16 1 1];
% kern.GridSize = [ceil(N/16) 1 1];
% [out,crlb,LL] = feval(kern,ddn,1,7,15,out,crlb,LL,N);
% cout = gather(out);
% scatter(cout(:,1),cout(:,2));

[p,crlb,ll] = gpumle_floatpsf_floatbg(ddn,1,20);
