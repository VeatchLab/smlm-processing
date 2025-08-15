function  Cor_norm = find_Cor_norm_livecell(data1, data2, calib, mask, rmax, rbinsize)

%calib = final_image_specs.calib;
res = 25/calib;%final_image_specs.resolution/calib;
s = 1;%25/calib;%final_image_specs.psf/final_image_specs.resolution;
dims = [256 512]; 
%mask = res_specs.mask;

g_filt = fspecial('gaussian',300, 32);
 
[scrap, Ctot_raw1]=generate_STORM_image_MBS(data1, res, s, dims);
I1 = Ctot_raw1;

[scrap, Ctot_raw2]=generate_STORM_image_MBS(data2, res, s, dims);
I2 = Ctot_raw2;

% I1_f= (imfilter(mask.*I1, g_filt));
% I2_f= (imfilter(mask.*I2, g_filt));

I1_f= mask.*(imfilter(mask.*I1, g_filt))./imfilter(double(mask), g_filt);
I1_f(isnan(I1_f(:))) = 0;
I1_fudgefact = mean(I1_f(logical(mask(:))))/mean(I1(logical(mask(:))));
I1_densfact = mean(I1_f(logical(mask(:))));%/res^2; % camera pixel units

I2_f= mask.*(imfilter(mask.*I2, g_filt))./imfilter(double(mask), g_filt);
I2_f(isnan(I2_f(:))) = 0;
I2_fudgefact = mean(I2_f(logical(mask(:))))/mean(I2(logical(mask(:))));
I2_densfact = mean(I2_f(logical(mask(:))));%/res^2; % camera pixel units;

L1 = size(I1_f, 1);
L2 = size(I1_f, 2);

N4 = (1/I2_densfact)*(1/I1_densfact)*fftshift(ifft2(fft2(I1_f, 2*L1+1, 2*L2+1).*conj(fft2(I2_f, 2*L1+1, 2*L2+1))))*I1_fudgefact.*I2_fudgefact;

normalize = sum(sum(mask));%/res^2;

NP_norm = N4/normalize;

[~, rad_ave_NP_edge]  = radial_average_EM_int(NP_norm,ceil(rmax/res),(rbinsize/res),0);
Cor_norm = rad_ave_NP_edge(1:end-1);

