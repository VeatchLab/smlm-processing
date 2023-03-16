function olddata = new_to_old(newdata, data_fieldname, transposex_flag,swapxy)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

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
if nargin < 2
    data_fieldname = 'data';
end
if nargin < 3
    transposex_flag = true;
end
if nargin < 4
    swapxy = true;
end

[nmovies,nframes] = size(newdata);

olddata = repmat(struct(data_fieldname,[]),1,nmovies);

for imov = 1:nmovies
    olddata(imov).(data_fieldname) = newdata(imov,:);
    for iframe = 1:nframes
        n = numel(newdata(imov,iframe).x);
        olddata(imov).(data_fieldname)(iframe).tI = newdata(imov, iframe).I;
        olddata(imov).(data_fieldname)(iframe).AR = ones(size(newdata(imov, iframe).I));
        if transposex_flag
            olddata(imov).(data_fieldname)(iframe).x = reshape(newdata(imov,iframe).y, n,1);
            olddata(imov).(data_fieldname)(iframe).y = reshape(newdata(imov,iframe).x, n,1);
        end
        if swapxy
            x = olddata(imov).(data_fieldname)(iframe).x;
            olddata(imov).(data_fieldname)(iframe).x = ...
                olddata(imov).(data_fieldname)(iframe).y;
            olddata(imov).(data_fieldname)(iframe).y = x;
        end
    end
end

