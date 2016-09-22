clear all ; close all ; 
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY','CHFSGD',...
    'EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK','EURSGD','EURTRY',...
    'EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF','NZDJPY','NZDUSD',...
    'SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ;

badis = {'CADHKD','CHFSGD','EURDKK','EURHKD','EURPLN','EURSEK','EURTRY','SGDJPY','AUDSGD','HKDJPY','USDDKK','USDNOK','USDHKD','USDTRY','USDZAR','XAUUSD','ZARJPY','EURPLN','USDCNH','USDMXN','XAGUSD'} ;
badinds = [] ; for i=1:length(badis) ; ind = find(strcmp(badis{i},currs)) ; badinds(i) = ind ; end 
currs(badinds) = [] ; 
clear allparams 
for c=1:length(currs)
    cd(['C:\Users\Acer\Documents\indices_4\',currs{c}]) ; 
    params = dir('corr*') ; 
    if (~isempty(strfind(currs{c},'JPY')) && isempty(strfind(currs{c},'HKD')) ) || ~isempty(strfind(currs{c},'XAG')) || ~isempty(strfind(currs{c},'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    
    for p=1:length(params) ; disp(p) ; 
        x = dlmread(params(p).name) ; 
        allparams(c,p,:,:) = x(:,1:2250)./mfactor ; 
        %allparams(c,p,:,:) = x(:,1:35)./mfactor ; 
    end
end

for i=1:size(allparams,1)
    plot(squeeze(mean(mean(allparams(i,1:5,:,:),3),2))) ; hold on ; 
end
for i=1:50 ; 
subplot(5,5,i) 
mps = squeeze(mean(mean(mean(allparams(:,i,:,:),1),2),3)) ; 
plot(1:length(mps),mps,'k.') ; lsline ; xlim([1,2250]) ; ylim([0,2500]) ; title(['maxdd=',num2str(totaldd(mps)),' cc=',num2str(corr2(mps,(1:length(mps))'))]) ; 
end

csums = squeeze(sum(mean(allparams(:,1,:,:),3),1)) ; 

