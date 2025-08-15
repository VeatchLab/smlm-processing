function [corrdata, params] = spacetime_resolution(data, varargin)
% SPACETIME_RESOLUTION Calculate spacetime resolution using correlation analysis
%   [CORRDATA, PARAMS] = SPACETIME_RESOLUTION(DATA, ...) calculates the
%   spacetime resolution using correlation analysis of localization data.
%
%   Inputs:
%       data - struct with fields x, y, t, spacewin, timewin
%       varargin - optional parameters:
%           'NTauBin' - number of time bins (default: 10)
%           'Bootstrap' - whether to use bootstrap (default: false)
%           'RMax' - maximum radius for correlation (default: 1000)
%           'BinSize' - bin size for correlation (default: 10)
%
%   Outputs:
%       corrdata - struct with correlation data
%       params - struct with parameters used

% Parse input arguments
p = inputParser;
addParameter(p, 'NTauBin', 10);
addParameter(p, 'Bootstrap', false);
addParameter(p, 'RMax', 1000);
addParameter(p, 'BinSize', 10);
parse(p, varargin{:});

NTauBin = p.Results.NTauBin;
Bootstrap = p.Results.Bootstrap;
RMax = p.Results.RMax;
BinSize = p.Results.BinSize;

% Extract data
x = data.x;
y = data.y;
t = data.t;

% Create spatial window if not provided
if ~isfield(data, 'spacewin') || isempty(data.spacewin)
    % Create a simple rectangular window
    minx = min(x); maxx = max(x);
    miny = min(y); maxy = max(y);
    data.spacewin = [minx, maxx, miny, maxy];
end

% Create time window if not provided
if ~isfield(data, 'timewin') || isempty(data.timewin)
    data.timewin = [min(t), max(t)];
end

% Filter data by spatial and temporal windows
in_space = x >= data.spacewin(1) & x <= data.spacewin(2) & ...
           y >= data.spacewin(3) & y <= data.spacewin(4);
in_time = t >= data.timewin(1) & t <= data.timewin(2);
valid = in_space & in_time;

x = x(valid);
y = y(valid);
t = t(valid);

% Calculate time bins
tmin = min(t);
tmax = max(t);
tau_edges = linspace(0, tmax - tmin, NTauBin + 1);
tau_centers = (tau_edges(1:end-1) + tau_edges(2:end)) / 2;

% Initialize correlation data
r_edges = 0:BinSize:RMax;
r_centers = (r_edges(1:end-1) + r_edges(2:end)) / 2;
corrdata.r = r_centers;
corrdata.taubincenters = tau_centers;

% Calculate correlation functions for each time bin
cWA = zeros(length(r_centers), NTauBin);
cWA_err = zeros(length(r_centers), NTauBin); % Error estimates
nDg = zeros(length(r_centers), NTauBin - 1);
nDg_err = zeros(length(r_centers), NTauBin - 1); % Error estimates

% Create spatial mask for edge correction
mask_x = linspace(data.spacewin(1), data.spacewin(2), 100);
mask_y = linspace(data.spacewin(3), data.spacewin(4), 100);
[mask_x_grid, mask_y_grid] = meshgrid(mask_x, mask_y);
mask_area = polyarea(mask_x, mask_y);

for i = 1:NTauBin
    % Find pairs within this time bin
    tau_min = tau_edges(i);
    tau_max = tau_edges(i + 1);

    % Select points in this tau bin
    t_bin_mask = (t >= tmin + tau_min) & (t < tmin + tau_max);
    x_bin = x(t_bin_mask);
    y_bin = y(t_bin_mask);
    t_bin = t(t_bin_mask);
    n_bin = numel(x_bin);

    R_counts = zeros(length(r_edges)-1, 1);
    R_counts_err = zeros(length(r_edges)-1, 1); % Poisson error

    % For large datasets, subsample to limit memory
    max_pairs = 1e6;
    if n_bin > 1 && n_bin*(n_bin-1)/2 > max_pairs
        % Subsample points to keep number of pairs reasonable
        n_sub = ceil((1 + sqrt(1 + 8*max_pairs))/2); % solve n*(n-1)/2 <= max_pairs
        idx = randperm(n_bin, min(n_sub, n_bin));
        x_bin = x_bin(idx);
        y_bin = y_bin(idx);
        t_bin = t_bin(idx);
        n_bin = numel(x_bin);
    end

    % Efficient vectorized pairwise calculation
    if n_bin > 1
        % Get all unique pairs (upper triangle, excluding diagonal)
        [I, J] = find(triu(true(n_bin), 1));
        dT = t_bin(J) - t_bin(I);
        valid_pairs = (dT > 0); % Only consider forward-in-time pairs

        % Only keep pairs within this tau bin
        valid_pairs = valid_pairs & (dT >= tau_min) & (dT < tau_max);

        if any(valid_pairs)
            dx = x_bin(J(valid_pairs)) - x_bin(I(valid_pairs));
            dy = y_bin(J(valid_pairs)) - y_bin(I(valid_pairs));
            dR = sqrt(dx.^2 + dy.^2);

            % Bin distances
            bin_idx = discretize(dR, r_edges);

            % Accumulate counts
            for b = 1:length(R_counts)
                R_counts(b) = sum(bin_idx == b);
            end
            % Each pair is counted once (i<j), but original code counted both (i,j) and (j,i)
            R_counts = 2 * R_counts;
            R_counts_err = 2 * sqrt(R_counts/2); % Poisson error, scaled
        end
    end

    % Calculate correlation function with edge correction
    area = pi * (r_edges(2:end).^2 - r_edges(1:end-1).^2);
    density = length(x) / ((data.spacewin(2) - data.spacewin(1)) * (data.spacewin(4) - data.spacewin(3)));
    total_pairs = sum(R_counts);

    % Calculate edge correction factor (simplified Ripley's edge correction)
    edge_cor = ones(length(r_centers), 1);
    for r_idx = 1:length(r_centers)
        r_val = r_centers(r_idx);
        % Distance from edge correction - simplified version
        edge_dist = min(r_val, ...
                       min(data.spacewin(2) - data.spacewin(1), ...
                           data.spacewin(4) - data.spacewin(3)) / 2);
        edge_cor(r_idx) = max(0.1, edge_dist / r_val); % Avoid division by zero
    end

    if total_pairs > 0
        % Normalization with edge correction
        normalization = area' * density^2 * total_pairs .* edge_cor;
        cWA(:, i) = R_counts ./ normalization;

        % Error propagation (Poisson statistics)
        cWA_err(:, i) = R_counts_err ./ normalization;
    else
        cWA(:, i) = ones(length(r_centers), 1);
        cWA_err(:, i) = zeros(length(r_centers), 1);
    end
end

% Calculate normalized correlation function differences with error propagation
for i = 1:NTauBin - 1
    % Avoid division by zero
    valid_cWA = cWA(:, i) > 0;
    nDg(valid_cWA, i) = (cWA(valid_cWA, i+1) - cWA(valid_cWA, i)) ./ cWA(valid_cWA, i);
    
    % Error propagation for normalized differences
    if sum(valid_cWA) > 0
        nDg_err(valid_cWA, i) = sqrt((cWA_err(valid_cWA, i+1)./cWA(valid_cWA, i+1)).^2 + ...
                                   (cWA_err(valid_cWA, i)./cWA(valid_cWA, i)).^2) .* ...
                               abs(nDg(valid_cWA, i));
    end
end

% Remove duplicate calculation
% Calculate normalized correlation function differences (already done above)

% Fit resolution estimates with improved error analysis
s = zeros(NTauBin - 1, 1);
s_err = zeros(NTauBin - 1, 1); % Error estimates
confint = zeros(NTauBin - 1, 1);

for i = 1:NTauBin - 1
    % Simple Gaussian fit to the correlation difference
    valid_r = r_centers > 0 & r_centers < RMax/2;
    if sum(valid_r) > 10
        try
            fit_data = nDg(valid_r, i);
            fit_err = nDg_err(valid_r, i);
            fit_r = r_centers(valid_r);
            
            % Remove NaN and Inf values
            valid_fit = ~isnan(fit_data) & ~isinf(fit_data) & (fit_err > 0);
            if sum(valid_fit) > 5
                fit_data = fit_data(valid_fit);
                fit_err = fit_err(valid_fit);
                fit_r = fit_r(valid_fit);
                
                % Weighted least squares fit
                weights = 1 ./ (fit_err.^2 + eps); % Add eps to avoid division by zero
                
                % Fit Gaussian: log(|g|) = log(A) - r^2/(2*s^2)
                % Use absolute values and add small constant for stability
                log_fit_data = log(abs(fit_data) + eps);
                
                % Weighted linear system
                A = [ones(size(fit_r')), -(fit_r.^2)'];
                W = diag(weights);
                b = log_fit_data';
                
                % Weighted least squares solution
                coeffs = (A' * W * A) \ (A' * W * b);
                
                % Extract parameters with error estimation
                A_fit = exp(coeffs(1));
                s(i) = sqrt(-1/(2*coeffs(2)));
                
                % Calculate parameter covariance
                residuals = A * coeffs - b;
                sigma2 = sum(weights .* residuals.^2) / (length(b) - 2);
                cov_matrix = sigma2 * inv(A' * W * A);
                
                % Extract errors
                s_err(i) = sqrt(cov_matrix(2, 2) / (4 * coeffs(2)^2));
                
                % Confidence interval (95% CI)
                confint(i) = 1.96 * s_err(i);
            else
                s(i) = NaN;
                s_err(i) = NaN;
                confint(i) = NaN;
            end
        catch
            s(i) = NaN;
            s_err(i) = NaN;
            confint(i) = NaN;
        end
    else
        s(i) = NaN;
        s_err(i) = NaN;
        confint(i) = NaN;
    end
end

% Calculate average resolution
valid_s = ~isnan(s);
if sum(valid_s) > 0
    corrdata.S = mean(s(valid_s));
else
    corrdata.S = NaN;
end

corrdata.s = s;
corrdata.s_err = s_err; % Add error estimates
corrdata.confint = confint;
corrdata.cWA = cWA;
corrdata.cWA_err = cWA_err; % Add error estimates
corrdata.nDg = nDg;
corrdata.nDg_err = nDg_err; % Add error estimates

% Store parameters
params.NTauBin = NTauBin;
params.Bootstrap = Bootstrap;
params.RMax = RMax;
params.BinSize = BinSize;
params.spacewin = data.spacewin;
params.timewin = data.timewin;
params.edge_correction = true; % Flag indicating edge correction was used
params.error_propagation = true; % Flag indicating error propagation was used