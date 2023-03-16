function poll_and_process(varargin)
% POLL_AND_PROCESS(VARARGIN)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>
OLDDIRS = {};
here = cd;
while true
    tmp = dir();
    dirs = {tmp.name};

    newdirs = setdiff(dirs, olddirs);
    olddirs = dirs;

    if isempty(newdirs)
        disp('No new dirs to process');
        pause(600);
    end
    for i = 1:numel(newdirs)
        if ~isempty(regexp(newdirs{i}, '[Cc]ell', 'once'))
            disp(['fitting to do in ' newdirs{i}]);
            cd(newdirs{i});
            files = dir();
            while true
                pause(60);
                if isequal(files, dir())
                    break;
                else
                    files = dir();
                    disp('new files in last minute -- waiting to see if there are more');
                end
            end
            run_batch_fitting(2, varargin{:});
        elseif ~isempty(regexp(newdirs{i}, 'beads', 'once'))
            disp(['fiducials to do in ' newdirs{i}]);
            cd(newdirs{i});
            files = dir();
            while true
                pause(60);
                if isequal(files, dir())
                    break;
                else
                    files = dir();
                    disp('new files in last minute -- waiting to see if there are more');
                end
            end
            do_fidfind();
        end
        cd(here);
    end
end
