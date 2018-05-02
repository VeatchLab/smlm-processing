function mergeddata = mergeacross(data)

mergeddata = repmat(struct(), size(data,1), 1);

fields = fieldnames(data);

for i = 1:size(data, 1)
    for j = 1:numel(fields)
        f = fields{j};
        mergeddata(i,1).(f) = [data(i, :).(f)];
    end
end
