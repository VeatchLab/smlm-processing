function [ data ] = apply_tilt_correction( data, coeffs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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

if size(data,2) ~= numel(data)
    oldsizet = size(data);
    data = reshape(data, 1, numel(data));
    reshaped = true;
end

%TODO: this only rotates z, but x and y should also change (if tilt is non-trivial)
if isnumeric(coeffs)
    for i = 1:numel(data)
        data(i).z = data(i).z-coeffs(1)-coeffs(2)*data(i).x -coeffs(3)*data(i).y;
    end
else
    for i = 1:numel(data)
        data(i).z=data(i).z-coeffs(data(i).x, data(i).y);
    end
end

if reshaped % put back in old shape
    data = reshape(data, oldsizet);
end
