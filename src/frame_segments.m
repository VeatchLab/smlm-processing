function [segments, timevec, endpointswithTPC] = frame_segments(data, mdata, activenotif)
% [SEGMENTS, TIMEVEC, ENDPOINTSWITHTPC] = FRAME_SEGMENTS(DATA, MDATA, ACTIVENOTIF)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>
    
   % Convert times to s from start of experiment.
    [movienum, Nframes] = size(data);
    totalNframes = movienum * Nframes;
    timevec = zeros(totalNframes, 1);
    moviei_start_time = zeros(movienum, 1);
    for i = 1:movienum
        moviei_start_time(i) = 60 * 60 * 24 * rem(mdata(i).start_time, 1);
        timevec((1:Nframes) + (i - 1) * Nframes) = mdata(i).timestamp + ...
            (moviei_start_time(i) - moviei_start_time(1));
    end
    final_time = timevec(end);
    
    TPCtimes = activenotif(:, 1);
    adjTPCtimes = 0.001 * (TPCtimes - 1000 * moviei_start_time(1));
    adjTPC = horzcat(adjTPCtimes, 10*(activenotif(:, 2) - activenotif(1, 2)));
    
    endpoints = [adjTPCtimes(1)];
    TPCofendpoints = [0];
    maxadjustmenttime = 0;
    for i = 2:length(adjTPCtimes)
        if adjTPCtimes(i) < 0
            endpoints = [adjTPCtimes(i)];
            continue
        end
        if adjTPCtimes(i) - adjTPCtimes(i - 1) <= 1
            endpoints(end) = adjTPCtimes(i);
            TPCofendpoints(end) = adjTPC(i, 2);
            if adjTPCtimes(i) - adjTPCtimes(i - 1) > maxadjustmenttime
                maxadjustmenttime = adjTPCtimes(i) - adjTPCtimes(i - 1);
            end
        else
            endpoints = [endpoints; adjTPCtimes(i)];
            TPCofendpoints = [TPCofendpoints; adjTPC(i, 2)];
        end
    end

    if final_time > endpoints(end)
        endpoints = [endpoints; final_time];
        TPCofendpoints = [TPCofendpoints; TPCofendpoints(end)];
    end

    endpointswithTPC = horzcat(endpoints, TPCofendpoints);

    numofrows = length(endpointswithTPC);
    rownum = 2;
    rowstodelete = [];
    while rownum <= numofrows - 1
        % If the TPC spikes go back to the previous value, we'll consider
        % the regions the same.
        if endpointswithTPC(rownum, 2) == endpointswithTPC(rownum - 1, 2)
            rowstodelete = [rowstodelete; rownum];
        elseif endpointswithTPC(rownum, 1) > final_time
            rowstodelete = [rowstodelete; rownum];
        end
        
        rownum = rownum + 1;
    end
    % Delete the unwanted rows
    endpointswithTPC(rowstodelete, :) = [];

    timesegments = cell(size(endpointswithTPC, 1) - 1, 1);
    numcut = length(timesegments);
    for i = 1:numcut
        timesegments{i} = [endpointswithTPC(i, 1); endpointswithTPC(i + 1, 1)];
    end
    
    % convert time segments to frames
    segments = cell(size(endpointswithTPC, 1) - 1, 1);
    for i = 1:numcut
        frame_lower = find(timevec >= timesegments{i}(1), 1, 'first');
        frame_upper = find(timevec <= timesegments{i}(2), 1, 'last');
        segments{i} = [frame_lower; frame_upper];
    end

end
