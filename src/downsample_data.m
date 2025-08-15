function downsampled_data = downsample_data(data, points_per_frame)
% DOWNSAMPLE_DATA Randomly sample points from data structure
%   DOWNSAMPLE_DATA(DATA, POINTS_PER_FRAME) randomly samples POINTS_PER_FRAME
%   points from the data structure DATA. If DATA has fewer points than
%   POINTS_PER_FRAME, all points are returned.
%
%   Inputs:
%       data - structure array with fields x, y, z (optional), frame
%       points_per_frame - number of points to sample per frame
%
%   Outputs:
%       downsampled_data - structure array with randomly sampled points

if isempty(data)
    downsampled_data = data;
    return;
end

% Get total number of points
total_points = numel(data);

% If we have fewer points than requested, return all points
if total_points <= points_per_frame
    downsampled_data = data;
    return;
end

% Randomly sample points using randperm (no toolbox required)
inds = randperm(total_points, points_per_frame);

% Return sampled data
downsampled_data = data(inds);
end 