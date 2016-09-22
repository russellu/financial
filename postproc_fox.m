currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY','CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK','EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF','NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 
cd c:/shared/processed_forex ; 
alldatas = dir('datas_*') ; 
allmaxdds = load('allmaxdds.mat') ; allmaxdds = allmaxdds.allmaxdds ; 
allntrades = load('allntrades.mat') ; allntrades = allntrades.allntrades ; 
allprofits = load('allprofits.mat') ; allprofits = allprofits.allprofits ; 
alltradeprofits = load('alltradeprofits.mat') ; alltradeprofits = alltradeprofits.alltradeprofits ; 
corrs = load('corrs.mat') ; allcorrs = corrs.corrs ; 

for ad=37:length(currs)  % USDCAD
        
    if (~isempty(strfind(alldatas(ad).name,'JPY')) && isempty(strfind(alldatas(ad).name,'HKD')) ) || ~isempty(strfind(alldatas(ad).name,'XAG')) || ~isempty(strfind(alldatas(ad).name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    costad = (squeeze(alltradeprofits(:,:,:,ad)) + allmaxdds(:,:,:,ad)) .* (allntrades(:,:,:,ad)>200) ; 
   % figure,for i=1:28 ; subplot(4,7,i) ; imagesc(squeeze(costad(:,:,i)),[-mfactor*3000,mfactor*3000]) ; title(i) ; end
    [sv,si] = sort(costad(:),'descend') ; 
    [m1s,m2s,m3s] = ind2sub(size(costad),si) ; 
    %allmvgs = [m1,m2,m3] ; 
    
    cd c:/users/acer/documents/indices_4 ;
    filename = dir([currs{ad},'_*']) ; 
    fid = fopen(filename(1).name) ; 
    dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
    fclose(fid) ; 
    clear p_profits p_ntrades p_tracks
    offsetcount = 1 ; 
    for offset=1:2:29
        d5 = dkdata{6} ; d5 = d5(offset:30:end) ; 

        mvgs1 = 1:25:700 ; 
        % make a moving average:
        clear mvg p mean
        for p = 1:length(mvgs1)  
            for i=mvgs1(p)+1:length(d5)
                if i==mvgs1(p)+1
                    mvg(i,p) = mean(d5(i-mvgs1(p)+1:i)) ; 
                else
                    mvg(i,p) = mvg(i-1,p) + d5(i)/(mvgs1(p)) - d5(i-mvgs1(p))/(mvgs1(p)) ;
                end  
            end
        end
        allm1s = m1s(1:500) ; allm2s = m2s(1:500) ; allm3s = m3s(1:500) ; 
        for mvgparam = 1:500 %length(m1)      
            disp(['currency = ', currs{ad},', offset = ', num2str(offset),', mvgparam = ',num2str(mvgparam)]) ; 
            m1 = m1s(mvgparam) ; m2 = m2s(mvgparam) ; m3 = m3s(mvgparam) ;      
            trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; 
            alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; 
            for i=700:length(d5)
                if trade == false
                    if d5(i) > mvg(i,(m1)) % buy mode
                        if d5(i) < mvg(i,(m2)) && d5(i-1) > mvg(i,(m2)) % cross down
                            trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ;
                        end
                    elseif d5(i) < mvg(i,(m1)) % sell mode
                        if d5(i) > mvg(i,(m2)) && d5(i-1) < mvg(i,(m2)) % cross up
                            trade = true ; entry = d5(i) ; sell = true ; ntrades = ntrades + 1 ;  
                        end
                    end
                elseif trade == true
                    if buy
                        if d5(i) > mvg(i,(m3)) && d5(i-1) < mvg(i,(m3))
                            buy = false ; profit = profit + d5(i)-entry ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; 
                        end
                    elseif sell
                        if d5(i) < mvg(i,(m3)) && d5(i-1) > mvg(i,(m3))
                            sell = false ; profit = profit + entry-d5(i) ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; 
                        end                   
                    end
                end    
            end  
            p_profits(offsetcount,mvgparam) = profit ; p_ntrades(offsetcount,mvgparam) = ntrades ; p_tracks{offsetcount,mvgparam} = alltrades ; 
        end
        offsetcount = offsetcount + 1 ; 
    end
    postproc{1} = p_profits ; postproc{2} = p_ntrades ; postproc{3} = p_tracks ; postproc{4} = [allm1s,allm2s,allm3s] ; 
    save(['postproc_',currs{ad},'.mat'],'postproc') ;
end
     
%[sv,si] = sort(mean(p_profits)./sqrt(std(p_profits,0,1)),'descend') ; 
