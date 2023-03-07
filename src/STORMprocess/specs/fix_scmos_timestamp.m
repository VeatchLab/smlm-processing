function ts = fix_scmos_timestamp(ts)
                    
    ts.cropdims = [ts.AOILeft, (ts.AOILeft + ts.AOIWidth - 1),...
                    ts.AOITop, (ts.AOITop + ts.AOIHeight - 1)];
