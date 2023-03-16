function [Ibg, In, Ip] = selective_mean(Iall, coords, radius)
% [IBG, IN, IP] = SELECTIVE_MEAN(IALL, COORDS, RADIUS)

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
    [height, width, nFrames] = size(Iall);
    
    radius = round(radius-.5);

    %% set stuff near coords to nan
    for i = 1:nFrames % loop over frames
        c = coords{i};
        n = size(c,1);
        for j = 1:n % loop over points in frame
            xinds = round(c(j,1)) + (-radius:radius);
            yinds = round(c(j,2)) + (-radius:radius);
            [xinds, yinds] = meshgrid(xinds, yinds);
            for k = 1:numel(xinds) % loop over assembled points
                if (xinds(k) <= width && xinds(k) >0 ...
                        && yinds(k) <= height && yinds(k) > 0)
                    Iall(yinds(k), xinds(k), i) = NaN;
                end
            end
        end
    end


    % Set outputs
    Ibg = mean(Iall, 3, 'omitnan');
    Ivar = var(Iall, 0, 3, 'omitnan');
    In = sum(~isnan(Iall),3);
    Ichisq = In .* Ivar ./ Ibg;
    Ip = 1 - chi2cdf(Ichisq, In);
