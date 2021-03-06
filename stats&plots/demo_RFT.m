% demo for RFT simulations

clear all
close all
clc


%--- RFT: specificity
L = 2e3; % size of the 1D field
N = 1e3; % number of Monte-Carlo simulations
v = ([1:5:50]/2.355).^2; % smoothing kernel variances
v = v(end);
for j=1:length(v)
    j
    kernel = exp(-0.5.*([1:L]-L/2).^2/v(j));
    kernel = kernel./sum(kernel);
    for ii=1:N
        X = randn(L,1);
        sX(:,ii) = conv(X,kernel,'same');
    end
    vX = var(sX,[],2);
    sX = sX./repmat(sqrt(vX),1,N);
    for ii=1:N
        % apply RFT
        [out] = RFT_main(2+sX(:,ii),[],1);
        pause
        hpeak(j,ii) = length(find(out.peaks.prft<0.05))>=1;
        hclu(j,ii) = length(find(out.clusters.prft<0.05))>=1;
        f(j,ii) = out.fwhm;
        % apply Bonferroni
        p = 1-normcdf(sX(:,ii));
        h(j,ii) = length(find(p<0.05./L))>=1;
    end
end
hf = figure('color',[1 1 1]);
ha = subplot(2,1,1,'parent',hf,'nextplot','add');
errorbar(sqrt(v*8*log(2)),mean(hpeak'),std(hpeak')/sqrt(N),'parent',ha)
errorbar(sqrt(v*8*log(2)),mean(hclu'),std(hclu')/sqrt(N),'parent',ha,'color','r')
errorbar(sqrt(v*8*log(2)),mean(h'),std(h')/sqrt(N),'parent',ha,'color','k')
plot(ha,sqrt(v*8*log(2)),0.05*ones(size(v)),'k--')
xlabel(ha,'smoothing kernel FWHM')
ylabel(ha,'controlled FPR')
legend(ha,{'RFT: peak','RFT: cluster','Bonferroni'})
ha = subplot(2,1,2,'parent',hf,'nextplot','add');
errorbar(sqrt(v*8*log(2)),mean(f'),std(f')/sqrt(N),'parent',ha)
plot(ha,sqrt(v*8*log(2)),sqrt(v*8*log(2)),'k--')
xlabel(ha,'smoothing kernel FWHM')
ylabel(ha,'RFT-FWHM')
getSubplots

save RFT.mat