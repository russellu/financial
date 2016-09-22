clear all ; close all  ;
cd c:/users/acer/documents/indices_4 ;
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY','CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK','EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF','NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 
mvgs1 = 1:25:700 ; 
alldatas = dir('datas_*') ; 


corrps = dir('corrp_postproc*') ; 
for c=1:length(corrps)
    if (~isempty(strfind(alldatas(c).name,'JPY')) && isempty(strfind(alldatas(c).name,'HKD')) ) || ~isempty(strfind(alldatas(c).name,'XAG')) || ~isempty(strfind(alldatas(c).name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    datas = load(corrps(c).name) ; datas = datas.postproc ; 
    profits = datas{1} ; ntrades = datas{2} ; tracks = datas{3} ; params = datas{4} ; 
    mps = mean(profits./ntrades)-spreads(c)*mfactor*2 ; 
    stds = std(profits./ntrades,0,1) ; 
    [sv,si] = sort(mps./stds,'descend') ; 
    figure ; ind = 1 ;
    for i=1:15 
        for j=1:10
        %plot(cumsum(squeeze(tracks{i,si(ind)}./mfactor))) ; hold on ;
        if ~isempty(cumsum(tracks{i,si(j)}))
        mts(c,i,j,:) = imresize(cumsum(tracks{i,si(j)}./mfactor),[1,300]) ; 
        end
        end
    end
%    i1 = allm1s(params(si(ind))) ; i2 = allm2s(params(si(ind))) ; i3 = allm3s(params(si(ind))) ; 
%    mpars(c,:) = [mvgs1(i1),mvgs1(i2),mvgs1(i3)]; 

end
