function data = translatepts(indata, xshift, yshift, zshift)
% TRANSLATEPTS shift a point dataset in space
%   data = TRANSLATEPTS(indata, xshift, yshift) - move indata.x and indata.y
%       by the displacements given by xshift and yshift, respectively

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

if numel(xshift) ~= 1 || numel(yshift) ~= 1
    error('translatepts: xshift and yshift must be scalar');
end

if nargin<4
    data = arrayfun(@(s) translate_once(s, xshift, yshift), indata);
else
    data = arrayfun(@(s) translate_once(s, xshift, yshift, zshift), indata);
end

function data = translate_once(data, xshift, yshift, zshift)
    data.x = data.x + xshift;
    data.y = data.y + yshift;
    if nargin==4
        data.z = data.z + zshift;
    end
