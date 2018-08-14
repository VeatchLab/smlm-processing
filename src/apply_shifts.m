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


if isfield(shift_info, 'zfit')  % avoiding the if statement in the big loop.  maybe not needed?
    dz = shift_info.zfit;
    for i = 1:numel(data)
        data(i).x = data(i).x - dx(i);
        data(i).y = data(i).y - dy(i);
        data(i).z = data(i).z - dz(i);
    end
else
    
    %
    for i = 1:numel(data)
        data(i).x = data(i).x - dx(i);
        data(i).y = data(i).y - dy(i);
    end
    
end


if reshaped % put back in old shape
    data = reshape(data, oldsizet)';
end
