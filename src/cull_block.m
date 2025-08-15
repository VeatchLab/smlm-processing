function [culled, cullinds] = cull_block(data, record)

cs = record.cullspecs;

[culled.data, cullinds] = cellfun(@cullSTORM, data.data, cs,...
    'UniformOutput', false);

culled.date = datetime;
culled.produced_by = 'cullSTORM';
culled.units = data.units;