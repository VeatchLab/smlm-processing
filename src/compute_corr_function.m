function [g, xc, yc, goodbins, tedge, tedge_sec] = compute_corr_function(dx, dy, dt, data, x, y, Npts, rmax, binsize, timevec, frame_time)
% can be used in 2D or for 3D cross sections
% no masking
% included "x" and "y" as inputs, though these could actually be any of x,
% y, and z in the 3D case. Similarly, dy could be dz.

width = max(x) - min(x);
height = max(y) - min(y);
FOV_area = width*height;  
nframes = numel(data);

bins = -rmax:binsize:rmax;

% find bins entirely within disk of radius rmax
xc = bins(2:end)-binsize/2;
yc = xc;
bins = -rmax:binsize:rmax;

goodbins = zeros(numel(xc)); % bins entirely within rmax of the origin
for k = 1:numel(xc)
    for l = 1:numel(xc)
        xmax = max(abs(xc(l)+binsize/2), abs(xc(l)-binsize/2));
        ymax = max(abs(yc(k)+binsize/2), abs(yc(k)-binsize/2));
        rmax_bin = sqrt(xmax^2+ymax^2);
        if rmax_bin <= rmax
            goodbins(k,l) = 1;
        end
    end
end

areas = binsize^2.*goodbins;

molinframe = zeros(numel(data), 1);
for k = 1:numel(data)
    molinframe(k) = length(data(k).x);
end

tedge = floor(logspace(0, log10(numel(timevec)), Npts));

tedge = unique(tedge); % should keep as integer?
tedge_sec = tedge*frame_time;

A = [dy' dx' dt'];
N = histcn(A, bins, bins, tedge_sec);

% Need to find how many pairs of molecules are in each time bin
timediffs = zeros(nframes*(nframes-1)/2, 1);
weights = zeros(nframes*(nframes-1)/2, 1);
count = 1;
for i = 1:nframes-1
    for j = i+1:nframes
        timediffs(count) = timevec(j) - timevec(i);
        weights(count) = molinframe(i)*molinframe(j);
        count = count + 1;
    end
end

[taucounted, ~, bin] = histcounts(timediffs, tedge_sec);
exptauperbin = accumarray(bin(bin > 0), weights(bin > 0)');

taufactor = exptauperbin / (numel(x)*(numel(x)-1)/2);

rho = length(x)^2/FOV_area;

N_exp = zeros(size(areas, 1), size(areas, 2), numel(taufactor));
for i = 1:size(areas, 1)
    for j = 1:size(areas, 2)
        for k = 1:numel(taufactor)
            N_exp(i,j,k) = rho*areas(i,j) * taufactor(k);
            if N_exp(i,j,k) == 0
                N(i,j,k) = 0;
            end
        end
    end
end

g = N./N_exp;
