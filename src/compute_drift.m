function [shifteddata, drift_info] = compute_drift(data, timings, specs)

olddata = data;
% Put the data in the right shape
if size(data,2) ~= numel(data)
    data = reshape(data', 1, numel(data));
end

% Get parameters
nTimeBin = round(specs.npoints_for_alignment);
binwidth = round(specs.nframes_per_alignment);
nframes = numel(data);

psize = specs.psize_for_alignment;
rmax1 = specs.rmax_shift;
rmaxpx1 = round(rmax1/psize);
rmax = specs.rmax;
sigma_startpt = specs.sigma_startpt/psize;
update = specs.update_reference_flag;
interp_method = specs.interp_method;
include_diagnostics = specs.include_diagnostics;

% Compute which frames belong to which time bins
binspacing = (nframes - binwidth)/(nTimeBin-1);
firstframe = round(1 + (0:nTimeBin-1)*binspacing);
lastframe = min(nframes, firstframe + binwidth);
 

% Initialize some stuff
xshift = zeros(nTimeBin,1);
yshift = zeros(nTimeBin,1);
zshift = zeros(nTimeBin,1);

dxshift = zeros(nTimeBin,1);
dyshift = zeros(nTimeBin,1);

amp = zeros(1, nTimeBin);
width = zeros(1, nTimeBin);

goodinitial = true(1,nTimeBin);
goodinds = true(1,nTimeBin);
npoints = zeros(1,nTimeBin);

if include_diagnostics
    finalfits = cell(1,nTimeBin);
    Csms = cell(1,nTimeBin);
end

% helper function for getting data
getnthdata = @(n) data(firstframe(n):lastframe(n));

% useful numbers for second fit
rmaxpx= ceil(rmax/psize);
npx = 2*rmaxpx + 1;
pxrange = (-rmaxpx):rmaxpx;
[x,y] = meshgrid(1:npx, 1:npx);

% make a fittype for the gaussian
fitgauss = fittype(...
    @(A,s,x0,y0,c,x,y) A*exp(-((x0-x).^2 + (y0-y).^2)/(2*s.^2)) + c,...
        'coefficients', {'A', 's', 'x0', 'y0','c'},...
        'indep', {'x', 'y'}, 'dep', 'z');

% Fit options for more refined fit, using Trust-Region algorithm
fgo = fitoptions(fitgauss);
fgo.Lower = [1,0,1,1,0];
fgo.Upper = [Inf,Inf,npx,npx,Inf];

% Compute xcors, and resulting offsets
refdata = getnthdata(1);
npoints(1) = numel([refdata.x]);
refbin = 1;
if specs.correctz
    refmeanz = mean([refdata.z]);  % for now, correct z drift with time average.
end
while npoints(refbin) == 0
    refbin = refbin + 1;
    if refbin > nTimeBin
        error('None of the timebins contain points!')
    end
    refdata = getnthdata(refbin);
    npoints(refbin) = numel([refdata.x]);
    if specs.correctz
        refmeanz = mean([refdata.z]);  % for now, correct z drift with time average.
    end
end


dx_last = 0;
dy_last = 0;
for i = (refbin + 1):nTimeBin
    thisdata  = getnthdata(i);

    npoints(i) = numel([thisdata.x]);
    if npoints(i) == 0
        goodinds(i) = false;
        continue;
    end
        
    C = xcor_dirty(refdata, thisdata, psize, rmax);

    centerx = round((size(C,2) + 1)/2);
    centery = round((size(C,1) + 1)/2);
    
    Cstd = std(C(:));
    Cmean = mean(C(:));
    Cmax = max(C(:));
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find a starting point. This is not trivial. I've tried various
    % strategies:
    % - two rounds of fitting. One starting at origin, the next starting at
    % the (fitted) peak of the first. This works reasonably well, until you
    % get near the edge of the first fitting region
    %
    % - just take the max of C. This can cause problems in undersampled
    % data, because there are sometimes outliers far from the origin
    %
    % - the closest local maximum above a threshold. I don't have a good
    % way to determine a good threshold, so only works for some datasets
    %
    % - linear extrapolation from previous two points. This is probably
    % good as long as there are a reasonably large number of points.
    %
    % - closest local maximum to this linear extrapolation. Same threshold
    % problem
    
    % 1st order prediction for next peak
    x_pred = centerx - (xshift(i-1) + dx_last)/psize;
    y_pred = centery - (yshift(i-1) + dy_last)/psize;

    % local maxima greater than Cmean + (Cmax - Cmean)/2
    [y_max, x_max, vals_max] = find(maskedRegionalMax(C, C > (Cmean + (Cmax - Cmean)*.75)));
    
    %how many are within rmaxpx1 of pred
    r2 = (x_max - x_pred).^2 + (y_max - y_pred).^2;
    in_disc = r2 < rmaxpx1^2;
    
    if sum(in_disc) == 1 % we're golden, take this as center
        x_start = x_max(in_disc);
        y_start = y_max(in_disc);
    elseif sum(in_disc) > 1
        fprintf('more than one local max for time bin %d\n',i);
        nid = sum(in_disc);
        id_inds = find(in_disc);
        ind = find(vals_max == max(vals_max(in_disc)));
        fprintf('\tx_max\tx_pred\ty_max\ty_pred\tval\n');
        for j =1:nid
            if vals_max(id_inds(j)) == max(vals_max(in_disc))
                fprintf('  *\t%d\t%d\t%d\t%d\t%.2e\n', x_max(id_inds(j)), round(x_pred),...
                    y_max(id_inds(j)), round(y_pred), vals_max(id_inds(j)));
            else
                fprintf('   \t%d\t%d\t%d\t%d\t%.2e\n', x_max(id_inds(j)), round(x_pred),...
                    y_max(id_inds(j)), round(y_pred), vals_max(id_inds(j)));
            end
        end
        %disp([x_max(in_disc), x_pred*ones(nid,1), y_max(in_disc), y_pred*ones(nid,1), vals_max(in_disc)])
        x_start = x_max(ind(1));
        y_start = y_max(ind(1));
    else % no luck
        
        fgo1 = fgo;
        pxrange1 = -rmaxpx1:rmaxpx1;
        smallinds1 = round(y_pred) + pxrange1;
        smallinds2 = round(x_pred) + pxrange1;
        
        npx1 = 2*rmaxpx1 + 1;
        [x1,y1] = meshgrid(1:npx1, 1:npx1);
        Csm = C(smallinds1, smallinds2);
        
        Cmin = min(Csm(:));
        fgo1.StartPoint = [Cmax - Cmin, sigma_startpt*10, ...
            rmaxpx1+1, rmaxpx1+1, Cmean];
        fgo1.Lower = [0,2,1,1,0];
        fgo1.Upper = [Inf,Inf,npx1,npx1,Inf];
        
        F1 = fit([x1(:), y1(:)], Csm(:), fitgauss, fgo1);
        
        x_start = round(F1.x0 - rmaxpx1 - 1 + round(x_pred));
        y_start = round(F1.y0 - rmaxpx1 - 1 + round(y_pred));
        warning('no local max, resorting to a pre-fit');
        fprintf('time bin %d\n', i);
        fprintf('\tx_start\tx_pred\ty_start\ty_pred\tval\tmax\n');
        fprintf('  *\t%d\t%d\t%d\t%d\t%.2e\t%.2e\n', x_start, round(x_pred),...
                   y_start, round(y_pred), C(y_start,x_start), Cmax);
    end
    x_shift_i = x_start - centerx;
    y_shift_i = y_start - centery;
        
    
%     (Cmax - Cmean)/Cstd      % 
%     
%     % use 50*Cstd + Cmean as starting pt
%     [y_max, x_max] = find(maskedRegionalMax(C, C > (Cmean + 20*Cstd)));
%     nmax = numel(x_max)
%     
%     r2 = (x_max - x_pred).^2 + (y_max - y_pred).^2;
%     
%     %how many are within rmaxpx1 of center
%     n_max_in_disc = sum(r2 < rmaxpx1^2);
%     
%     if n_max_in_disc == 1
%         ind = find(r2 == min(r2));
%         x_max = x_max(ind);
%         y_max = y_max(ind);
%     elseif n_max_in_disc > 1
%         warning('More than one reasonable local max: proceed with caution');
% %         keyboard
%         ind = find(r2 == min(r2));
%         x_max = x_max(ind(1));
%         y_max = y_max(ind(1));
%     else
%         warning('I couldn''t find a local max to fit to, using 1st order prediction');
%         x_max = round(x_pred);
%         y_max = round(y_pred);
%     end
%     
% %     [y_max,x_max] = find(C == Cmax);
%     
% %     y_max = y_max(1);
% %     x_max = x_max(1);
%     
%     x_shift_i = x_max - centerx;
%     y_shift_i = y_max - centery;
%     
%     outofframe = abs(x_shift_i) > rmaxpx1 || abs(y_shift_i) > rmaxpx1;
%     if outofframe
%         warning('I couldn''t find a local max to fit to, using 1st order prediction');
%         x_max = round(x_pred);
%         y_max = round(y_pred);
%         x_shift_i = x_max - centerx;
%         y_shift_i = y_max - centery;
%     end

    smallinds1 = y_start + pxrange;
    smallinds2 = x_start + pxrange;
    Csm = C(smallinds1, smallinds2);

    Cmin = min(Csm(:));
    fgo.StartPoint = [Cmax - Cmin, sigma_startpt, ...
        rmaxpx+1, rmaxpx+1, Cmean];

    F = fit([x(:), y(:)], Csm(:), fitgauss, fgo);

    % Shifts, in the correct units
    xshift(i) = -(F.x0 - rmaxpx - 1 + x_shift_i)*psize;
    yshift(i) = -(F.y0 - rmaxpx - 1 + y_shift_i)*psize;

    dx_last = xshift(i) - xshift(i-1);
    dy_last = yshift(i) - yshift(i-1);
    
    finalfit = F; %for extracting parameters for diag
    
    if specs.correctz
        zshift(i) = mean([thisdata.z])-refmeanz;
    end
    
    % extract parameters
    CI = confint(finalfit, .34);
    d = .5*(diff(CI, 1)); % standard errors
    dxshift(i) = d(3)*psize;
    dyshift(i) = d(4)*psize;
    
    amp(i) = finalfit.A;
    width(i) = finalfit.s*psize;

    if include_diagnostics
        finalfits{i} = finalfit;
        Csms{i} = Csm;
    end
    
    % Use this to debug large shifts
%     if max(xshift(i), yshift(i)) > 2
%         keyboard;
%     end
    
    % handle update_reference_image flag
    if update
        refdata = [refdata translatepts(thisdata,-xshift(i),-yshift(i))];
    end
end

% interpolate
if isempty(timings)
    timings = 1:nframes;
end

goodinds = find(goodinds);
midtiming = zeros(size(goodinds));
for i  = 1:numel(goodinds)
    ii = goodinds(i);
    midtiming(i) = mean(timings(firstframe(ii):lastframe(ii)));
end

xfit = interp1(midtiming, xshift(goodinds), timings, interp_method, 'extrap');
yfit = interp1(midtiming, yshift(goodinds), timings, interp_method, 'extrap');
if specs.correctz
    zfit = interp1(midtiming, zshift(goodinds), timings, interp_method, 'extrap');
end

% info and diagnostics
drift_info.xshift = xshift;
drift_info.yshift = yshift;
drift_info.dxshift = dxshift;
drift_info.dyshift = dyshift;
drift_info.amplitude = amp;
drift_info.fitwidth = width;
drift_info.xfit = xfit;
drift_info.yfit = yfit;
drift_info.timings = timings;
drift_info.midtiming = midtiming;
drift_info.goodinitial = goodinitial;
drift_info.npoints = npoints;
if include_diagnostics % optional because potentially large
    drift_info.finalfits = finalfits;
    drift_info.Csms = Csms;
end
if specs.correctz
    drift_info.zfit = zfit;
    drift_info.zshift = zshift;
end
shifteddata = apply_shifts(olddata, drift_info);
