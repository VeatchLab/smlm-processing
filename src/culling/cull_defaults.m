function cullspec = cull_defaults(fit_type)
% CULLSPEC = CULL_DEFAULTS(FIT_TYPE)

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
% Default culling stuff

if nargin<1, fit_type = 'gaussianPSF'; end

switch fit_type
    case 'gaussianPSF'
        cullspeccell = {... % cell array of cullspecs: field, culltype, min, max
            'xroi', 'absolute', -1.5, 1.5 ;
            'yroi', 'absolute', -1.5, 1.5 ;
            'I', 'permoviequantile', .05, .95 ;
            'd', 'quantile', .05, .95 ;
            'errorx', 'quantile', .00, .95 ;
            'errory', 'quantile', .00, .95 ;
            'LL', 'permoviequantile', .05, 1 };
    case 'spline'
        cullspeccell = {... % cell array of cullspecs: field, culltype, min, max
            'xroi', 'absolute', -2, 2 ;
            'yroi', 'absolute', -2, 2 ;
            'z', 'absolute', -1000, 1000;
            'I', 'permoviequantile', .05, .95 ;
            'errorx', 'quantile', .00, .95 ;
            'errory', 'quantile', .00, .95 ;
            'errorz', 'quantile', .00, .95 ;
            'LL', 'permoviequantile', .05, 1 };
end
        
cullspec = cell2struct(cullspeccell, {'field', 'culltype', 'min', 'max'}, 2);
