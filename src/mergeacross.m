function mergeddata = mergeacross(data)
% MERGEDDATA = MERGEACROSS(DATA)

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

mergeddata = repmat(struct(), size(data,1), 1);

fields = fieldnames(data);

for i = 1:size(data, 1)
    for j = 1:numel(fields)
        f = fields{j};
        mergeddata(i,1).(f) = [data(i, :).(f)];
    end
end
