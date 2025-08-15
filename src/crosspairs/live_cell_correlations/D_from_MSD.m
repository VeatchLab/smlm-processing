function [D] = D_from_MSD(MSD, integration_time, locper, flag)
taus = MSD.tau;
tau_effective = taus.*(1-integration_time/3./taus);
MSDfast_effective = MSD.MSDfast-2*locper^2;
MSDslow_effective = MSD.MSDslow-2*locper^2;
Dfast = MSDfast_effective./tau_effective/4*1e-6; %um^2/sec
Dslow = MSDslow_effective./tau_effective/4*1e-6; %um^2/sec

dDfast = MSD.dMSDfast./tau_effective/4*1e-6;
dDslow = MSD.dMSDslow./tau_effective/4*1e-6;

alpha = MSD.alpha;
dalpha = MSD.dalpha;

Dweighted = Dfast.*(1-alpha/100) + Dslow.*alpha/100;
dDweighted = sqrt((dDfast.*(1-alpha/100)).^2 + ((Dslow-Dfast).*dalpha/100).^2 + (dDslow.*alpha/100).^2);  

D.tau_effective = tau_effective;
D.MSDfast_effective = MSDfast_effective;
D.MSDslow_effective = MSDslow_effective;
D.Dfast = Dfast;
D.Dslow = Dslow;
D.dDfast = dDfast;
D.dDslow= dDslow;
D.alpha = alpha;
D.dalpha = dalpha;
D.Dweighted = Dweighted;
D.dDweighted = dDweighted;

if nargin<4, flag=0; end
if flag 
    plot(tau_effective, Dfast, 'o-', tau_effective, Dslow, 's-'); 
    xlabel('\tau (sec)'); ylabel('D (\mum^2/sec)'); legend('Dfast', 'Dslow'); 
end

end

