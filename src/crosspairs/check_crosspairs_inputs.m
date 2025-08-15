function check_crosspairs_inputs(varargin)
    % CHECK_CROSSPAIRS_INPUTS make sure inputs are the right shape.
    % CHECK_CROSSPAIRS_INPUTS(X, ...)     Check that X is a row or column and that
    %                                      all of the ... are the same shape as X.
    %                                      If these conditions do not hold, produce an error.

    n = numel(varargin);

    if n == 0
        return
    end

    if ~isvector(varargin{1})
        error('check_crosspairs_inputs: First input is not a vector');
    end

    sz = size(varargin{1});

    for i=2:n
        if any(size(varargin{i}) ~= sz)
            error('check_crosspairs_inputs: input %d does not match shape of input 1', i);
        end
    end
end
