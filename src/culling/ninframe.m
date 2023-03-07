function n = ninframe(data)

nmov = numel(data);
nframe = numel(data(1).data);

n = zeros(1,nmov*nframe);

for i = 1:nmov
    for j = 1:nframe
        n((i-1)*nframe + j) = numel(data(i).data(j).x);
    end
end