function dump_settings(record)

if ischar(record)
   if exist(record, 'file')
       record = load(record);
   end
end

if ~isstruct(record)
    error('record should either be a struct or the filename of a .mat file');
end


