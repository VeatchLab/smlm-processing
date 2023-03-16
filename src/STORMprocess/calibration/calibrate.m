function Iall = calibrate(Iall, camera_specs, timestamp)
% IALL = CALIBRATE(IALL, CAMERA_SPECS, TIMESTAMP)

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
switch camera_specs.type
    case 'emccd'
        Iall = calibrate_emccd(Iall, camera_specs, timestamp);
    case 'scmos'
        Iall = calibrate_scmos(Iall, camera_specs, timestamp);
    otherwise
        error('Unknown camera type');
end
