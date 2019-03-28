function data = translatepts(indata, xshift, yshift, zshift)
% TRANSLATEPTS shift a point dataset in space
%   data = TRANSLATEPTS(indata, xshift, yshift) - move indata.x and indata.y
%       by the displacements given by xshift and yshift, respectively

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