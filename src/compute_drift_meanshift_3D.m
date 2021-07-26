function [shifteddata, drift_info] = compute_drift_meanshift_3D(data, specs, record, activenotif)
olddata = data;
% Put the data in the right shape
if size(data,2) ~= numel(data)
    data = reshape(data', 1, numel(data));
end
if nargin >= 3
    mdata = record.metadata;
end

% Get parameters
nframes = numel(data);
nTimeBin = round(specs.npoints_for_alignment);
binwidth = round(specs.nframes_per_alignment);
if specs.fix_nframes_per_alignment
    binwidth = floor(nframes/nTimeBin);
end

rmax = specs.rmax;
delta_broad = specs.delta_broad;
calc_error = specs.calc_error;
broadsweep = specs.broadsweep;
interp_method = specs.interp_method;
outlier_error = specs.outlier_error;
maxiter = 1000;

roi_width = max([data.x]) - min([data.x]);
roi_height = max([data.y]) - min([data.y]);
area = roi_width * roi_height;

% Compute which frames belong to which time bins
binspacing = (nframes - binwidth)/(nTimeBin-1);
firstframe = round(1 + (0:nTimeBin-1)*binspacing);
lastframe = min(nframes, firstframe + binwidth - 1);

if ~exist('activenotif', 'var')
    activenotif = [];
    segments = cell(1);
    segments{1} = [1 nframes];
else
    if isempty(activenotif)
        segments = cell(1);
        segments{1} = [1 nframes];
    else
        if isfield(activenotif, 'TPCNotif')
            segments = frame_segments(olddata, mdata, activenotif.TPCNotif);
        elseif isfield(activenotif, 'activenotif')
            segments = frame_segments(olddata, mdata, activenotif.activenotif);
        else
            segments = frame_segments(olddata, mdata, activenotif);
        end
    end
end
[nTimeBin, firstframe_cell, lastframe_cell, firstframe, lastframe, firstTimeBin, lastTimeBin, nTimeBin_cut] = find_zframes(nTimeBin, binwidth, nframes, segments);

xshift = zeros(nTimeBin, nTimeBin);
yshift = zeros(nTimeBin, nTimeBin);
zshift = zeros(nTimeBin, nTimeBin);

dxshift = zeros(nTimeBin, nTimeBin);
dyshift = zeros(nTimeBin, nTimeBin);
dzshift = zeros(nTimeBin, nTimeBin);

ntruepairs = zeros(nTimeBin, nTimeBin);
nfalsepairs = zeros(nTimeBin, nTimeBin);
ntruepairs_z = zeros(nTimeBin, nTimeBin);
nfalsepairs_z = zeros(nTimeBin, nTimeBin);
loc_error = zeros(nTimeBin, nTimeBin);
loc_error_z = zeros(nTimeBin, nTimeBin);
iter_toconverge = zeros(nTimeBin, nTimeBin);

npoints = zeros(1,nTimeBin);

% helper function for getting data
getnthdata = @(n) data(firstframe(n):lastframe(n));
refdata = getnthdata(1);
tref = get_ts(refdata);

% autocorrelate reference data to get a sense for how long the molecules
% stay on, as well as for the appropriate noutmax
x1 = [refdata(:).x]; y1 = [refdata(:).y]; z1 = [refdata(:).z];
x2 = x1; y2 = y1; z2 = z1;
taumax = max(tref); 
noutmax = 1e8;

[dx, dy, dz] = crosspairs_3D(x1, y1, z1, tref, x2, y2, z2, tref, rmax, 1, taumax, noutmax);
noutmax = 2*length(dx); % We'll use this later. This is an upper bound for the number of pairs.

xstart = 0; ystart = 0; zstart = 0;
[xshift_broadsweep, yshift_broadsweep, zshift_broadsweep] = meanshift_3D(dx, dy, dz, xstart, ystart, zstart, delta_broad, maxiter);
rho = length(x1)^2 / area;
[~, ~, ~, ntruepairs_broad, ~, ~, ~, loc_error_auto, loc_error_auto_z] = meanshift_3D_error(dx, dy, dz, xshift_broadsweep(end), yshift_broadsweep(end), zshift_broadsweep(end), delta_broad, rmax, rho, numel(x1), numel(x2));
loc_prec = loc_error_auto/sqrt(2);
loc_prec_z = loc_error_auto_z/sqrt(2);
delta_narrow = loc_prec*specs.delta_narrow_ratio;
mean_nframeson = (ntruepairs_broad/2)/length(x1) + 1; % relevant to the error calculation, too
corr_time = min(20*mean_nframeson, binwidth/2);

parfor i = 1:nTimeBin - 1
    refdata  = getnthdata(i);
    
    npoints(i) = numel([refdata.x]);
    
    xshift_temp = zeros(nTimeBin, 1); 
    yshift_temp = zeros(nTimeBin, 1);
    zshift_temp = zeros(nTimeBin, 1);
    dxshift_temp = zeros(nTimeBin, 1); 
    dyshift_temp = zeros(nTimeBin, 1);
    dzshift_temp = zeros(nTimeBin, 1);
    
    ntruepairs_temp = zeros(nTimeBin, 1); nfalsepairs_temp = zeros(nTimeBin, 1);
    ntruepairs_z_temp = zeros(nTimeBin, 1); nfalsepairs_z_temp = zeros(nTimeBin, 1);
    loc_error_temp = zeros(nTimeBin, 1); loc_error_z_temp = zeros(nTimeBin, 1);
    iter_toconverge_temp = zeros(nTimeBin, 1);
    for j = i+1:nTimeBin
        xoffset = -xshift_temp(j-1);
        yoffset = -yshift_temp(j-1);
        zoffset = -zshift_temp(j-1);
        
        thisdata = getnthdata(j);
        thisdata = translatepts(thisdata, xoffset, yoffset, zoffset);
        
        x1 = [refdata(:).x]; y1 = [refdata(:).y]; z1 = [refdata(:).z];
        x2 = [thisdata(:).x]; y2 = [thisdata(:).y]; z2 = [thisdata(:).z];
        
        tref = get_ts(refdata) + firstframe(i); tthis = get_ts(thisdata) + firstframe(j);
        taumin = min(min(tref) - max(tthis), min(tthis) - max(tref)); taumax = -taumin;
        
        [dx, dy, dz, dt] = crosspairs_3D(x1, y1, z1, tref, x2, y2, z2, tthis, rmax, taumin, taumax, noutmax);

        % remove all pairs with abs(dt) < corr_time
%         if min(abs(dt)) <= corr_time
%             tokeep = abs(dt) > corr_time;
%             dx = dx(tokeep); dy = dy(tokeep); dz = dz(tokeep); dt = dt(tokeep);
%         end
        
        xstart = 0; ystart = 0; zstart = 0;
        if broadsweep % necessary if you expect large shifts between consecutive bins
            [xshift_broadsweep, yshift_broadsweep, zshift_broadsweep] = meanshift_3D(dx, dy, dz, xstart, ystart, zstart, delta_broad, maxiter);
            xstart = xshift_broadsweep(end); ystart = yshift_broadsweep(end); zstart = zshift_broadsweep(end);
            if isnan(xstart)
                xstart = 0; ystart = 0; zstart = 0;
            end
        end
        
        [xshift_narrow, yshift_narrow, zshift_narrow] = meanshift_3D(dx, dy, dz, xstart, ystart, zstart, delta_narrow, maxiter);
        iter_toconverge_temp(j) = length(xshift_narrow) - 1;
        xshift_temp(j) = xshift_narrow(end) - xoffset;
        yshift_temp(j) = yshift_narrow(end) - yoffset;
        zshift_temp(j) = zshift_narrow(end) - zoffset;
        
        if isnan(xshift_temp(j))
            xshift_temp(j) = xoffset;
            yshift_temp(j) = yoffset;
            zshift_temp(j) = zoffset;
        end
        
        if calc_error
            rho = length(x1) * length(x2) / area;
            [dxshift_temp(j), dyshift_temp(j), dzshift_temp(j), ntruepairs_temp(j), nfalsepairs_temp(j), ntruepairs_z_temp(j), nfalsepairs_z_temp(j), loc_error_temp(j), loc_error_z_temp(j)] = meanshift_3D_error(dx, dy, dz, ...
                xshift_narrow(end), yshift_narrow(end), zshift_narrow(end), delta_narrow, rmax, rho, numel(x1), numel(x2), mean_nframeson, loc_prec, loc_prec_z);
            if isnan(dxshift_temp(j))
                dxshift_temp(j) = rmax;
                dyshift_temp(j) = rmax;
                dzshift_temp(j) = rmax;
            end
        end
    end
     % updating the matrices with the temporary rows
    xshift(i, :) = xshift_temp; yshift(i, :) = yshift_temp; zshift(i, :) = zshift_temp;
    dxshift(i, :) = dxshift_temp; dyshift(i, :) = dyshift_temp; dzshift(i, :) = dzshift_temp;
    ntruepairs(i, :) = ntruepairs_temp; nfalsepairs(i, :) = nfalsepairs_temp;
    ntruepairs_z(i, :) = ntruepairs_z_temp; nfalsepairs_z(i, :) = nfalsepairs_z_temp;
    loc_error(i, :) = loc_error_temp; loc_error_z(i, :) = loc_error_z_temp;
    iter_toconverge(i, :) = iter_toconverge_temp;   
%     fprintf('Finished with timebin %i\n', i)
end

% check if median predicted error is > loc_prec/2. If so, we've chosen too
% few frames for alignment.

med_error = sqrt(2)*median(dxshift(dxshift > 0));
if med_error > loc_prec/4
    warning('Errors between alignments are large: consider decreasing the number of time bins.')
end


% redundant calculation is adapted from code in "Wang et al."

% total number of iterations is nTimeBin*(nTimeBin-1)/2
nelements = (nTimeBin^2-nTimeBin)/2;
A = zeros(nelements, 2);
R = zeros(nelements, 3);
w = zeros(nelements, 1);
count = 1;
for i=1:nTimeBin-1
    for j=i+1:nTimeBin
        A(count, i) = -1;
        A(count, j) = 1;
        R(count, 1) = xshift(i,j);
        R(count, 2) = yshift(i,j);
        R(count, 3) = zshift(i,j);
        if calc_error
            w(count, 1) = 1/dxshift(i,j)^2;
        else
            w(count, 1) = 1;
        end
        count = count+1;
    end
end

A = A(:, 2:end);

[D, stderr, mse] = lscov(A, R, w);
err=A*D-R;
b=R;
rowerr = zeros(size(A,1),3);
for i=1:size(A,1)
    rowerr(i,1) = sqrt(err(i,1)^2+err(i,2)^2+err(i,3)^2);
end
rowerr(:,2)=1:size(A,1);
rowerr=flipud(sortrows(rowerr,1));

index=rowerr(find(rowerr(:,1)>outlier_error),2);
noutliers = numel(index);
fraction_outliers = noutliers/size(A,1);

% remove outliers while preventing rank deficiency of A
for i=1:size(index,1)
    flag = index(i);
    tmp=A;
    tmp(flag,:)=[];
    if rank(tmp,1)==(nTimeBin-1)
        A(flag,:)=[];
        b(flag,:)=[];
        w(flag,:)=[];
        sindex=find(index>flag);
        index(sindex)=index(sindex)-1;
    else
        tmp=A;
    end
end

% A(index,:)=[];
% b(index,:)=[];
% w(index,:)=[];

[D, stderr, mse] = lscov(A, b, w);

if nargin >= 3
    % Convert times to s from start of experiment.
    mdata = record.metadata;
    [movienum, Nframes] = size(olddata);
    totalNframes = movienum * Nframes;
    timings = zeros(totalNframes, 1);
    moviei_start_time = zeros(movienum, 1);
    for i = 1:movienum
        moviei_start_time(i) = 60 * 60 * 24 * rem(mdata(i).start_time, 1);
        timings((1:Nframes) + (i - 1) * Nframes) = mdata(i).timestamp + ...
            (moviei_start_time(i) - moviei_start_time(1));
    end
else
    timings = 1:nframes;
end
timings_frames = 1:nframes;

midtiming = zeros(nTimeBin, 1);
midtiming_frames = zeros(nTimeBin, 1);
for i = 1:nTimeBin
    midtiming(i) = mean(timings(firstframe(i):lastframe(i)));
    midtiming_frames(i) = mean(firstframe(i):lastframe(i));
end

D_all = vertcat([0,0,0], D);
xfit = interp1(midtiming, D_all(:,1), timings, interp_method, 'extrap');
yfit = interp1(midtiming, D_all(:,2), timings, interp_method, 'extrap');
% zfit = interp1(midtiming, D_all(:,3), timings, interp_method, 'extrap');

zfit = NaN(nframes, 1);
% interpolate only within each cut
ncut = length(segments);
for i = 1:ncut
    if nTimeBin_cut(i) < 2 % can't interpolate without at least 2 pts
        continue
    else
        framesincut = firstframe_cell{i}(1):lastframe_cell{i}(end);
        zfit(framesincut) = interp1(midtiming(firstTimeBin(i):lastTimeBin(i)), D_all(firstTimeBin(i):lastTimeBin(i),3), timings(framesincut), interp_method, 'extrap');
    end
end
    
figure; errorbar(midtiming, D_all(:,3), [0; stderr(:,3)], 'bo')
hold on;
plot(timings, zfit, 'b-')
hold on;

%     Plot vertical lines at cuts
y = ylim; %current y-axis limits
for i = 2:length(segments)
    plot([timings(segments{i}(1)) timings(segments{i}(1))], [y(1) y(2)], '--m');
    hold on;
end
xlabel('Timing');
ylabel('Z-Drift (nm)');


stderr = vertcat([0 0 0], stderr);
figure; errorbar(D_all(:,1), D_all(:,2), stderr(:,2), stderr(:,2), stderr(:,1), stderr(:,1), 'b-o')
xlabel('X-Drift (nm)')
ylabel('Y-Drift (nm)')
axis equal

% info and diagnostics
drift_info.xshift = xshift;
drift_info.yshift = yshift;
drift_info.zshift = zshift;
drift_info.dxshift = dxshift;
drift_info.dyshift = dyshift;
drift_info.dzshift = dzshift;

drift_info.xfit = xfit;
drift_info.yfit = yfit;
drift_info.zfit = zfit;
drift_info.timings = timings;
drift_info.timings_frames = timings_frames;
drift_info.midtiming = midtiming;
drift_info.midtiming_frames = midtiming_frames;
drift_info.firstframe = firstframe;
drift_info.lastframe = lastframe;
drift_info.npoints = npoints;
drift_info.nTimeBin = nTimeBin;
drift_info.binwidth = binwidth;

drift_info.delta_broad = delta_broad;
drift_info.delta_narrow = delta_narrow;

drift_info.err = err;
drift_info.rowerr = rowerr;
drift_info.drift = D_all;
drift_info.stderr = stderr;
drift_info.mse = mse;

drift_info.ntruepairs = ntruepairs;
drift_info.nfalsepairs = nfalsepairs;
drift_info.ntruepairs_z = ntruepairs_z;
drift_info.nfalsepairs_z = nfalsepairs_z;
drift_info.loc_error = loc_error;
drift_info.loc_error_z = loc_error_z;
drift_info.iter_toconverge = iter_toconverge;

drift_info.loc_prec = loc_prec;
drift_info.loc_prec_z = loc_prec_z;
drift_info.med_error = med_error;
drift_info.calc_error = calc_error;

drift_info.noutliers = noutliers;
drift_info.fraction_outliers = fraction_outliers;
drift_info.index = index;

drift_info.segments = segments;
drift_info.activenotif = activenotif;

shifteddata = olddata;

movienum = size(olddata, 1);
Nframes = size(olddata, 2);
for i = 1:movienum
    for j = 1:Nframes
        if isnan(zfit(Nframes * (i - 1) + j))
            f = fields(shifteddata(i, j));
            for k = 1:numel(f)
                shifteddata(i, j).(f{k})=[];
            end
        end
    end
end


shifteddata = apply_shifts(shifteddata, drift_info);
end

function ts = get_ts(d)

ns = arrayfun(@(ff) numel(ff.x), d);

ts = zeros(1, numel([d.x]));
last = 0;
for i = 1:numel(d)
    ts(last + (1:ns(i))) = i;
    last = last + ns(i);
end
end


