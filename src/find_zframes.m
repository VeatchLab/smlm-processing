function [nTimeBin, firstframe_cell, lastframe_cell, firstframe, lastframe, firstTimeBin, lastTimeBin, nTimeBin_cut] = find_zframes(nTimeBin, binwidth, nframes, segments)
 % divides each cut into some number (potentially 0) of time bins
 
firstframe =[];
lastframe = [];
ncut = length(segments);
nTimeBin_cut = zeros(ncut, 1);
binspacing_cut = zeros(ncut, 1);
firstframe_cell = cell(ncut, 1);
lastframe_cell = cell(ncut, 1);
firstTimeBin = NaN(ncut, 1);
lastTimeBin = NaN(ncut, 1);
nTimeBin_assigned = 0;

for i = 1:ncut
    nframes_cut = segments{i}(2) - segments{i}(1) + 1;
    if nframes_cut <= binwidth % we have to throw out the whole cut
        continue
    end
%     
%     nTimeBin_cut(i) = ceil(nTimeBin * (nframes_cut - binwidth) / nframes);
    nTimeBin_cut(i) = floor(nTimeBin * (nframes_cut - binwidth) / nframes) + 1;
    firstTimeBin(i) = nTimeBin_assigned + 1; 
    lastTimeBin(i) = nTimeBin_assigned + nTimeBin_cut(i); 
    nTimeBin_assigned = nTimeBin_assigned + nTimeBin_cut(i);
    
    if nTimeBin_cut(i) == 1
        firstframe_cell{i} = segments{i}(1);
        lastframe_cell{i} = segments{i}(1) + binwidth - 1;
        continue
    else
        binspacing_cut(i) = (nframes_cut - binwidth)/(nTimeBin_cut(i)-1);
        firstframe_cell{i} = segments{i}(1) + round((0:nTimeBin_cut(i)-1)*binspacing_cut(i));
        lastframe_cell{i} = firstframe_cell{i} + binwidth - 1;
    end
        
end

for i = 1:ncut
    if nTimeBin_cut(i) > 0
        firstframe = [firstframe firstframe_cell{i}];
        lastframe = [lastframe lastframe_cell{i}];
    end
end
    
nTimeBin = length(firstframe);

end