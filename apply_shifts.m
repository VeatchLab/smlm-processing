function data = apply_shifts(data, shift_info)

% deal with 2d data structures
if size(data,2) ~= numel(data)
    oldsizet = size(data');
    data = reshape(data', 1, numel(data));
    reshaped = true;
end

%
dx = shift_info.xfit;
dy = shift_info.yfit;

%
for i = 1:numel(data)
    data(i).x = data(i).x - dx(i);
    data(i).y = data(i).y - dy(i);
end


if reshaped % put back in old shape
    data = reshape(data, oldsizet)';
end
