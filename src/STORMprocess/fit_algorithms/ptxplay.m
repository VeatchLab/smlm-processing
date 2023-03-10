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