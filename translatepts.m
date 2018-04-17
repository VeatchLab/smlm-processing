function data = translatepts(indata, xshift, yshift)
% TRANSLATEPTS shift a point dataset in space
%   data = TRANSLATEPTS(indata, xshift, yshift) - move indata.x and indata.y
%       by the displacements given by xshift and yshift, respectively

if numel(xshift) ~= 1 || numel(yshift) ~= 1
    error('translatepts: xshift and yshift must be scalar');
end

data = arrayfun(@(s) translate_once(s, xshift, yshift), indata);


function data = translate_once(data, xshift, yshift)
    data.x = data.x + xshift;
    data.y = data.y + yshift;
