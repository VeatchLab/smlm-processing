
function result = fit_two_MSDs(r, gs, taus, locper, startpt, flag)
count = 1;

tauinds = 1:numel(taus)-1;

for tauind = tauinds
    g = gs(1:end, tauind);
    
    f = fit(r', g,'1+alpha/100/MSD1*N*exp(-x.^2/MSD1)+(1-alpha/100)/MSD2*N*exp(-x.^2/MSD2)', 'startpoint', startpt, 'upper', [(4*locper)^2 5000^2 inf 100], 'lower', [(locper)^2 1.1*2*locper^2 0 0]);
    if f.MSD1 > f.MSD2
        f = fit(r', g,'1+alpha/100/MSD1*N*exp(-x.^2/MSD1)+(1-alpha/100)/MSD2*N*exp(-x.^2/MSD2)', 'startpoint', [f.MSD2 f.MSD1 f.N f.alpha], 'upper', [(4*locper)^2 5000^2 inf 100], 'lower', [(locper)^2 1.1*2*locper^2 0 0]);
    end
    
    result.MSDslow(tauind) = f.MSD1;
    result.MSDfast(tauind) = f.MSD2;
    result.alpha(tauind) = f.alpha;
    result.N(tauind) = f.N;
    
    CI = confint(f, .95);
    err = diff(CI)/2;
    result.dMSDslow(tauind) = err(1);
    result.dMSDfast(tauind) = err(2);
    result.dalpha(tauind) = err(4);
    result.tau(tauind) = taus(tauind);

    result.f{tauind} = f;    

    startpt = coeffvalues(f);
    
    
    if flag
        plot(f, r, g);
        f
        xlabel('radius (nm)')
        ylabel('autocorrelation')
        pause
    end
    end

end