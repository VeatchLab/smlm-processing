function [ data ] = apply_tilt_correction( data, coeffs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if size(data,2) ~= numel(data)
    oldsizet = size(data);
    data = reshape(data, 1, numel(data));
    reshaped = true;
end

for i = 1:numel(data)
    data(i).z = data(i).z-coeffs(1)-coeffs(2)*data(i).x -coeffs(3)*data(i).y;
end

if reshaped % put back in old shape
    data = reshape(data, oldsizet);
end