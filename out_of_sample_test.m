clear all ; close all ; 
cd c:\users\acer\documents\indices_4
bestps = dir('bestparam_*') ; 
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY',...
    'CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK',...
    'EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF',...
    'NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 
badinds = [] ; 
for i=1:length(bestps) ; badfound = false ; 
    for j=1:length(currs)
        if ~isempty(strfind(bestps(i).name,currs{j}))
            badfound = true ; break ; 
        end
    end ; if badfound ; badinds(length(badinds)+1) = j ; end
end
currs = currs(badinds) ; spreads = spreads(badinds) ; 

for bp = 1:length(bestps)
    cd c:\users\acer\documents\indices_4
    bpi = load(bestps(bp).name) ; bpi = bpi.bestparam ; 
    name = strrep(bestps(bp).name,'bestparam_','') ; name = strrep(name,'.mat','') ; 
    cd c:/users/acer/documents/fwd_test ;
    filename = dir(['*',name,'*']) ; 
    fid = fopen(filename(1).name) ; 
    dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
    fclose(fid) ; 
    
    if (~isempty(strfind(name,'JPY')) && isempty(strfind(name,'HKD')) ) || ~isempty(strfind(name,'XAG')) || ~isempty(strfind(name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    
    
    clear p_profits p_ntrades p_tracks p_trackprofits p_tradets ; 
    offsetcount = 1 ; 
    totalcost = (spreads(bp) + 0.35 + 0.9)*mfactor ; 
      for offset=1:4:29
        d5 = dkdata{6} ; d5 = d5(offset:30:end) ; 

         mvgs1 = [5,15,30,50,90,150,220,320,450,600,900] ; 
         pipthreshs = [1,5,10,20,40,80]*mfactor ; 
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
        ntestparams = 50 ; 
        for mvgparam = 1:ntestparams     
            disp(['currency = ', currs{bp},', offset = ', num2str(offset),', mvgparam = ',num2str(mvgparam)]) ; 
            m1 = bpi(mvgparam,1) ; m2 = bpi(mvgparam,2) ; m3 = bpi(mvgparam,3) ; pt = bpi(mvgparam,4) ;     
            trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; 
            alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; trackprofits = [] ; tradets = [] ; entry = 0 ; 
            for i=700:length(d5)
                if mod(i,100)== 0 ; trackprofits(length(trackprofits)+1) = profit ; end
                if trade == false
                    if d5(i)-pipthreshs(pt) > mvg(i,(m1)) % buy mode
                        if d5(i) < mvg(i,(m2)) && d5(i-1) > mvg(i,(m2)) % cross down
                            trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ; entryt = i ; 
                        end
                    elseif d5(i)+pipthreshs(pt) < mvg(i,(m1)) % sell mode
                        if d5(i) > mvg(i,(m2)) && d5(i-1) < mvg(i,(m2)) % cross up
                            trade = true ; entry = d5(i) ; sell = true ; ntrades = ntrades + 1 ;  entryt = i ; 
                        end
                    end
                elseif trade == true
                    if buy
                        if d5(i) > mvg(i,(m3)) && d5(i-1) < mvg(i,(m3))
                            buy = false ; profit = profit + d5(i)-entry-totalcost ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; 
                            tradets(length(tradets)+1) = i-entryt ; 
                        end
                    elseif sell
                        if d5(i) < mvg(i,(m3)) && d5(i-1) > mvg(i,(m3))
                            sell = false ; profit = profit + entry-d5(i)-totalcost ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; 
                            tradets(length(tradets)+1) = i-entryt ; 
                        end                   
                    end
                end    
            end  
            p_profits(offsetcount,mvgparam) = profit ; p_ntrades(offsetcount,mvgparam) = ntrades ; 
            p_tracks{offsetcount,mvgparam} = alltrades ; p_trackprofits(offsetcount,mvgparam,:) = trackprofits ; 
            p_tradets{offsetcount,mvgparam} = tradets ; 
        end
        offsetcount = offsetcount + 1 ; 
      end
      allprofits(bp,:,:) = (p_profits./mfactor) ; allntrades(bp,:,:) = p_ntrades ; all_tradets{bp} = p_tradets ; 
end





