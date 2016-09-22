clear all ; close all ; 
cd c:/users/acer/documents/indices_4/ ; 
postprocs = dir('postproc_*') ; 
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY','CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK','EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF','NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 
mvgs = 1:25:700 ; 
for ad=1:length(postprocs)
    if (~isempty(strfind(postprocs(ad).name,'JPY')) && isempty(strfind(postprocs(ad).name,'HKD')) ) || ~isempty(strfind(postprocs(ad).name,'XAG')) || ~isempty(strfind(postprocs(ad).name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    
    postproc = load(postprocs(ad).name) ; postproc = postproc.postproc ; 
    p_profits = postproc{1} ; p_ntrades = postproc{2} ; p_tracks = postproc{3} ; p_params = postproc{4} ; 
   % [sv,si] = sort(mean(p_profits)./sqrt(std(p_profits,0,1)),'descend') ; 
   % subplot(5,10,ad) ;
   % imagesc(p_profits(:,si)./p_ntrades(:,si),[-mfactor*20,mfactor*20]) ; set(gca,'XTickLabel',[],'YTickLabel',[]) ; title([currs{ad},'-',num2str(ad)]) ; 
    for i=1:size(p_tracks,1) ; for j=1:size(p_tracks,2) ; if ~isempty(p_tracks{i,j}) ; corrs(i,j) = corr2(cumsum(p_tracks{i,j}-spreads(ad)*mfactor),1:length(cumsum(p_tracks{i,j}))) ; end ; end ; end
    %[cv,ci] = sort(corrs(:),'descend') ; [ix,iy] = ind2sub(size(corrs),ci) ; 
    subplot(5,10,ad)
    [sv,si] = sort(mean(corrs,1),'descend') ;   
    for i=1:15 ; plot(squeeze(cumsum(p_tracks{i,si(1)}-spreads(ad)*mfactor))) ; hold on ; end ; title([currs{ad},'-',num2str(ad)]) ; hline(0,'k') ; 
    
    
   
    sortm1 = p_params(si,1) ;  sortm2 = p_params(si,2) ; sortm3 = p_params(si,3) ; % sorted mvg indices, according to profit/consistency 
    [mvgs(sortm1(1)),mvgs(sortm2(2)),mvgs(sortm3(3))] ;
    mvec = [mvgs(sortm1);mvgs(sortm2);mvgs(sortm3)] ; 
    avgmvg(ad,1) = mvgs(round(mean(sortm1(1:5)))) ; avgmvg(ad,2) = mvgs(round(mean(sortm2(1:5)))) ; avgmvg(ad,3) = mvgs(round(mean(sortm3(1:5)))) ; 
    dlmwrite(['mvgparams_',currs{ad},'.txt'],mvec',' ')


end









