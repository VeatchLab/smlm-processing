function is = imagestruct_default(fname)
% IS = IMAGESTRUCT_DEFAULT(FNAME)

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

if ischar(fname)
    dentry = dir(fname);
    if ~isempty(dentry)
        fullname = fullfile(dentry.folder, dentry.name);
        ds = load(fullname);
        is.data_fname = fullname; %which(fname);
        fprintf('Using absolute path: %s\n', is.data_fname);
    else
        error('imagestruct_default: Can''t find file %d', fname);
    end
    is.data = [];
else
    ds = fname;
    is.data = ds;
    is.data_fname = [];
end

nchan = numel(ds.data);
is.channels = nchan;
is.units = ds.units;
switch is.units
    case 'nm'
        fac = 1;
    case 'um'
        fac = 1e-3;
    case 'px'
        fac = 1/160;
end
is.psize = 16*fac;
is.imageref = default_iref(ds.data{1}, is.psize);
is.sigmablur = repmat(20, 1, nchan)*fac;
is.cmin = zeros(1, nchan);
is.cmax = is.cmin + 1;
if nchan == 1
    is.color = {'white'};
else
    is.color = {'green', 'magenta'};
end

is.channel_names = cell(1,nchan);
is.maskx = cell(1,0);
is.masky = cell(1,0);
