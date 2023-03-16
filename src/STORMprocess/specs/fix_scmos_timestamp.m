function ts = fix_scmos_timestamp(ts)
% TS = FIX_SCMOS_TIMESTAMP(TS)

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
                    
    ts.cropdims = [ts.AOILeft, (ts.AOILeft + ts.AOIWidth - 1),...
                    ts.AOITop, (ts.AOITop + ts.AOIHeight - 1)];
