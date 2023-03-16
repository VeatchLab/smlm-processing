function [inds,qlow,qhigh] = cull_quantiles(v, plow, phigh)
% [INDS,QLOW,QHIGH] = CULL_QUANTILES(V, PLOW, PHIGH)

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
% return indices between quantiles at cumulative probability plow and phigh

if plow < 0 || plow > 1 || phigh < 0 || phigh > 1
    error('Cumulative probabilities must be between 0 and 1');
end

qlow = quantile(v, plow);
qhigh = quantile(v, phigh);

inds = find(and(v > qlow, v < qhigh));


end
