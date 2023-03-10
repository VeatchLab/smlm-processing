function [P,crlb,LL] = gpumle_fixpsf_floatbg(psfstack,psfsigma,niter)
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