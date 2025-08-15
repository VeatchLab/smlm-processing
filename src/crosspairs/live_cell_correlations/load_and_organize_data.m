function [data1,data2, timings, units, mask] = load_and_organize_data(FOLDER)
%load in imagedata and return position and timing information for
%constructing correlation functions

if nargin<1, FOLDER = './'; end

%% Load in the data
load ([FOLDER 'imagedata1'], 'alignment_data', 'res_specs', 'final_image_specs', 'timing_data');
alignment_data1 = alignment_data;
load ([FOLDER 'imagedata2'], 'alignment_data');
alignment_data2 = alignment_data;
load ([FOLDER 'allmsddata1'], 'meanmsdfitdata'); % has timings relative to stim (in minutes)

%% Arrange data as 1xn struct
data1 = [alignment_data1.alldata_track.rawdata];
data2 = [alignment_data2.alldata_track.rawdata];

%% Determine all times relative to stimulation
movienum = numel(alignment_data1.alldata_track);
framespermovie = numel(alignment_data1.alldata_track(1).rawdata);
nframes = movienum * framespermovie;
frame_time = timing_data(end).frame_time/60; % in min

units.frame_time_min = frame_time;
units.frame_time_sec = frame_time*60;
units.calib = final_image_specs.calib;
units.resolution = final_image_specs.resolution;
mask = res_specs.mask;

timings = zeros(nframes, 1);
for i = 1:movienum
    timings((1:framespermovie) + (i - 1) * framespermovie) = frame_time * (1:framespermovie) + ...
        (meanmsdfitdata.times(i));
end

end

