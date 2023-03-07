function cullspec = cull_defaults(fit_type)
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
