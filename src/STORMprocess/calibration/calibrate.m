function Iall = calibrate(Iall, camera_specs, timestamp)
switch camera_specs.type
    case 'emccd'
        Iall = calibrate_emccd(Iall, camera_specs, timestamp);
    case 'scmos'
        Iall = calibrate_scmos(Iall, camera_specs, timestamp);
    otherwise
        error('Unknown camera type');
end
