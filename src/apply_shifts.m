function data = apply_shifts(data, shift_info)
% DATA = APPLY_SHIFTS(DATA, SHIFT_INFO)

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

% deal with 2d data structures
if size(data,2) ~= numel(data)
    oldsizet = size(data');
    data = reshape(data', 1, numel(data));
    reshaped = true;
else
    reshaped = false;
end

%
dx = shift_info.xfit;
dy = shift_info.yfit;


if isfield(shift_info, 'zfit')  % avoiding the if statement in the big loop.  maybe not needed?
    dz = shift_info.zfit;
    for i = 1:numel(data)
        data(i).x = data(i).x - dx(i);
        data(i).y = data(i).y - dy(i);
        data(i).z = data(i).z - dz(i);
    end
else
    
    %
    for i = 1:numel(data)
        data(i).x = data(i).x - dx(i);
        data(i).y = data(i).y - dy(i);
    end
    
end


if reshaped % put back in old shape
    data = reshape(data, oldsizet)';
end
