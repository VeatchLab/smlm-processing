function options = resolution_default(units)
% OPTIONS = RESOLUTION_DEFAULT(UNITS)

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

fac = 1;
if nargin < 1
    units = 'px';
end

switch units
    case 'nm'
        fac = 1;
    case {'pix', 'px', 'pixel', 'pixels'}
        fac = 1/160;
        units = 'px';
    case 'um'
        fac = 1e-3;
end
   
options.Npts = 12;
options.rmax = 200*fac;
options.binsize = 5*fac;
options.units = units;
options.show_diagnostics = 0;
options.version = 0.1;

% add in fields from prior version
options.maxr = 500*fac;
options.how = 'sequential';
options.niter = 5;
options.binsize = 10*fac;
options.units = units;
options.range = [.1 .9 .1 .9 .2 .8];


end
