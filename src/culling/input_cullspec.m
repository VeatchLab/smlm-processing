function cullspec = input_cullspec(varargin)
% CULLSPEC = INPUT_CULLSPEC(VARARGIN)

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

% Deal with arguments
if ~nargin % No args, use default
    cullspec = cull_defaults();
else
    if nargin > 1
        error('Too many input args');
    end
    cullspec = varargin{1};
    if ~isfield(cullspec, 'field') 
        error('input cullspec is not proper');
    end
end

% See if there are corrections to make
for i = 1:numel(cullspec)
    f = cullspec(i).field;
    prompt = sprintf('Field %s, culltype %s, min %f, max %f.\n Change?', ...
                f, cullspec(i).culltype, cullspec(i).min, cullspec(i).max);
    if yesno(prompt, 0) % change this field?

        % Culltype
        prompt = sprintf(['Cull type for %s? Current type: %s.\n' ...
                    ' (none, quantile, absolute) [leave blank for no change]\n'],...
                             f, cullspec(i).culltype);
        instr = input(prompt, 's');
        if ~strcmp(instr, '')
            if regexp('none', instr)
                cullspec(i).culltype = 'none';
            elseif regexp('quantile', instr)
                cullspec(i).culltype = 'quantile';
            elseif regexp('absolute', instr)
                cullspec(i).culltype = 'absolute';
            else
                warning(['unknown culltype ' instr '. Skipping...']);
            end
        end

        if strcmp(cullspec(i).culltype, 'none')
            continue;
        end

        % min
        prompt = sprintf('New min? Current min = %f. [leave blank for no change]\n',...
                            cullspec(i).min);
        instr = input(prompt, 's');

        if ~strcmp(instr, '')
            num = str2num(instr);
            if numel(num)
                cullspec(i).min = num(1);
            else
                warning(sprintf('Failed to parse response %s to a number, skipping...', instr));
            end
        end

        % max
        prompt = sprintf('New max? Current max = %f. [leave blank for no change]\n',...
                            cullspec(i).max);
        instr = input(prompt, 's');

        if ~strcmp(instr, '')
            num = str2num(instr);
            if numel(num)
                cullspec(i).max = num(1);
            else
                warning(sprintf('Failed to parse response %s to a number, skipping...', instr));
            end
        end
    end
end

display('Summary of cull specs');
cullspec_summary(cullspec);



function val = yesno(prompt, defaultval)
if defaultval
    defaultstring = '[Y]';
else
    defaultstring = '[N]';
end
    
prompt = [prompt ' (Y/N) ' defaultstring '\n'];
instr = input(prompt, 's');

if strcmp(instr, 'Y') || strcmp(instr, 'y')
    val = 1;
elseif strcmp(instr, 'N') || strcmp(instr, 'n')
    val = 0;
else
    val = defaultval;
end

