function record = validate_record(record, version)
% VALIDATE_RECORD read record as correct version
%    VALIDATE_RECORD(RECORD, VERSION) update RECORD structure to desired VERSION
%
if ~isfield(record, 'version')
    record.version = 0;
end


while record.version < version
    record = update_record(record);
end

if record.version ~= version
    error('Could not update record to this version. Is record version newer than requested?')
end


function record = update_record(record)
% UPDATE_RECORD update the record struct from its current version to the next one

fprintf('input record was version %f. updating now\n', record.version);
switch record.version
    case 0 % 0 -> 0.1
        % option to transform singleview processed data was added in this version
        % tform_channel is array with the channels to be transformed (possibly empty)
        record = rmfield(record, 'tform_to_channel');
        record.tform_channel = 2;
        if numel(record.cullspecs) == 1 % single channel
            record.tform_channel = [];
        end

        record.version = 0.1;
    otherwise
        error({'update_record: I can''t update this record because I don''t know',...
            'about it''s version'});
end
