function  [Cor, Cor_tauavg, r] = find_Cor_livecell(data1, data2, mask, rmax, rbinsize, Cor_norm, mintau, maxtau, timings, frame_time)

maxpoints = 1e8;

x1 = zeros(maxpoints, 1); y1 = x1; t1 = x1;
x2 = x1; y2 = x1; t2 = x1;
ind1 = 1;
ind2 = 1;

mask = logical(mask); %load in mask from resolution stuff
mask = imresize(mask,[512 256]); %convert back to pixels
siz = size(mask);
k = [1 cumprod(siz(1:end-1))]; %initializing for sub2ind workaround to

% keep track of molperframe after unmasking
molinframe1 = zeros(numel(data1), 1);
molinframe2 = zeros(numel(data2), 1);
for i=1:numel(data1)
data1_xy = [data1(i).x data1(i).y];
data2_xy = [data2(i).x data2(i).y];
        
[m_data1, keep1] = unmask_data_TSC_1(data1_xy,mask,k);
[m_data2, keep2] = unmask_data_TSC_1(data2_xy,mask,k);

molinframe1(i) =  size(m_data1, 1);
molinframe2(i) =  size(m_data2, 1);

if ~isempty(m_data1)
    npts = size(m_data1, 1);
    x1(ind1:ind1+npts-1) = m_data1(:, 1);
    y1(ind1:ind1+npts-1) = m_data1(:, 2);
    t1(ind1:ind1+npts-1) = timings(i)*ones(size(m_data1(:, 2)));
    ind1 = ind1+npts;
end

if ~isempty(m_data2)
    npts = size(m_data2, 1);
    x2(ind2:ind2+npts-1) = m_data2(:, 1);
    y2(ind2:ind2+npts-1) = m_data2(:, 2);
    t2(ind2:ind2+npts-1) = timings(i)*ones(size(m_data2(:, 2)));
    ind2 = ind2+npts;
end

end

x1 = x1(1:ind1);
y1 = y1(1:ind1);
t1 = t1(1:ind1);
x2 = x2(1:ind2);
y2 = y2(1:ind2);
t2 = t2(1:ind2);

% [iout, jout, status, dx, dy, dr, dt] = crosspairs_indices_sortedt(x1, y1, t1, x2, y2, t2, rmax, mintau, maxtau);
[~, ~, ~, ~, ~, dr, dt] = crosspairs_indices_sortedt(x1, y1, t1, x2, y2, t2, rmax, mintau, maxtau);
rbins = 0:rbinsize:rmax;
taubins = (mintau+.5*frame_time):frame_time:(maxtau+.5*frame_time);
nframes = numel(data1);

% Need to find how many pairs of molecules are in each time bin
timediffs = zeros(nframes*(nframes-1)/2, 1);
weights = zeros(nframes*(nframes-1)/2, 1);
count = 1;
for i = 1:nframes-1
    for j = i+1:nframes
        timediffs(count) = timings(j) - timings(i);
        weights(count) = molinframe1(i)*molinframe2(j);
        count = count + 1;
    end
end

[taucounted, ~, bin] = histcounts(timediffs, taubins);
exptauperbin = accumarray(bin(bin > 0), weights(bin > 0)');

taufactor = exptauperbin / (numel(x1)*numel(x2));
taufactor = taufactor';

% taufactor_old = histcounts(timings - timings', taubins)/nframes^2;

inner_rads = rbins(1:end-1); % inner radius for each ring
outer_rads = rbins(2:end); % outer radius for each ring
areas = pi*(outer_rads.^2-inner_rads.^2); % area of each ring
areas_rep = repmat(areas', 1, length(taubins)-1);

r = rbins(2:end)-rbinsize/2;

N = histcounts2(dr, dt, rbins, taubins);
npossiblepairs = numel(x1)*numel(x2);
rho = npossiblepairs / sum(sum(mask));
N_exp = rho.*areas_rep.*taufactor;

Cor_norm_rep = repmat(Cor_norm', 1, size(N,2));
Cor = N./N_exp./Cor_norm_rep;

goodind = ((taubins(1) <= dt) & (dt <= taubins(end)));
N_tauavg = histcounts(dr(goodind), rbins);
N_exp_tauavg = rho.*areas*sum(taufactor);
Cor_tauavg = N_tauavg'./N_exp_tauavg'./Cor_norm';



