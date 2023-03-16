function specs = default_specs_dualview(varargin)
% DEFAULT_SPECS_DUALVIEW return a struct with specs for STORMprocess
%    specs = DEFAULT_SPECS_DUALVIEW() uses defaults for all fields.
%       MOVIE_FNAMES is filled using the glob 'mov*.tif'. Other parameters are
%       chosen to be be good starting points.
%
%    specs = DEFAULT_SPECS_DUALVIEW('PARAM1', VALUE1, ...) As above, but use
%       VALUE1 for specs.PARAM1.
%
%    specs = DEFAULT_SPECS_DUALVIEW(..., 'MovieRE', GLOB, ...) As above, but
%       use GLOB to glob for MOVIE_FNAMES
%
%    See also DEFAULT_SPECS_SINGLEVIEW, STORMPROCESS

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
args1 = varargin;
args2 = varargin;

if nargin / 2 ~= round(nargin/2)
    error('default_specs_singleview: args need to come in pairs!!');
end

dims1 = [1, 256, 1, 512];
dims2 = [257,512,1,512];

for i=1:(nargin/2)
    field = varargin{2*i - 1};
    value = varargin{2*i};

    if iscell(value)
        args1(2*i) = value(1);
        args2(2*i) = value(2);
    end
    if strcmp(field, 'channel_dims')
        if iscell(value)
            dims1 = value{1};
            dims2 = value{2};
        else
            warning('setting both channels to same dims -- are you sure?');
            dims1 = value;
            dims2 = value;
        end
    end
        
end

specs(1) = default_specs_singleview(args1{:});
specs(2) = default_specs_singleview(args2{:});

specs(1).channel_dims = dims1;
specs(2).channel_dims = dims2;
