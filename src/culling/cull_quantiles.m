function [inds,qlow,qhigh] = cull_quantiles(v, plow, phigh)
% return indices between quantiles at cumulative probability plow and phigh

if plow < 0 || plow > 1 || phigh < 0 || phigh > 1
    error('Cumulative probabilities must be between 0 and 1');
end

qlow = quantile(v, plow);
qhigh = quantile(v, phigh);

inds = find(and(v > qlow, v < qhigh));


end