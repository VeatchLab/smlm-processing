function aligned = apply_drift_block(data, record)

drift_info = record.drift_info;

aligned.data = cellfun(@(d) apply_shifts(d, drift_info), data.data, 'UniformOutput', false);
aligned.date = datetime;
aligned.produced_by = 'compute_drift';
aligned.units = 'nm';
aligned.drift_info = drift_info;
