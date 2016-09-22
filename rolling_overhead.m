clear all ; close all ; 
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY',...
    'CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK',...
    'EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF',...
    'NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 

cd C:\shared\res ; ls 
bads = {'CADHKD','EURDKK','EURHKD','EURPLN','EURSEK','EURTRY','HKDJPY','USDCNH','USDDKK','USDHKD','USDMXN','USDNOK','USDTRY','USDZAR','XAUUSD','ZARJPY','GBPAUD'} ;
resnames = dir('results_*') ; badinds = [] ; 
for i=1:length(resnames) ; badfound = false ; 
    for j=1:length(bads)
        if ~isempty(strfind(resnames(i).name,bads{j}))
            badfound = true ; 
        end
    end ; if badfound ; badinds(length(badinds)+1) = i ; end
end
resnames(badinds) = []  ; currs(badinds) = [] ; spreads(badinds) = [] ; 

for ccy=1:length(resnames) ;
    cd C:\shared\res ; ls 
    ccy_current = resnames(ccy).name ;  
    if (~isempty(strfind(ccy_current,'JPY')) && isempty(strfind(ccy_current,'HKD')) ) || ~isempty(strfind(ccy_current,'XAG')) || ~isempty(strfind(ccy_current,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    results = load(resnames(ccy).name) ; results = results.results ; 
    allprofits = results{1} ; allntrades = results{2} ; alltracks = results{3} ; alltrackprofits = results{4} ; 
    for i=1:size(alltrackprofits,1);for j=1:size(alltrackprofits,2);for k=1:size(alltrackprofits,3);for el=1:size(alltrackprofits,4);corrs(i,j,k,el)=corr2(squeeze(alltrackprofits(i,j,k,el,:))',1:size(alltrackprofits,5));end;end;end;end
    corrs(isnan(corrs)) = 0 ; 
    [sv,si] = sort(corrs(:),'descend') ; 
    [m1s,m2s,m3s,pts] = ind2sub(size(corrs),si) ; 
    %{
    for i=1:2 ;
        hps(i,:) = imresize(squeeze(alltrackprofits(ix(i),iy(i),iz(i),it(i),:)),[600,1]) ; 
    end
    allhps(ccy,:) = hps(1,:)./mfactor ; 
    %}
    
   
    cd c:/users/acer/documents/indices_4 ;
    filename = dir([currs{ccy},'_*']) ; 
    fid = fopen(filename(1).name) ; 
    dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
    fclose(fid) ; 
    clear p_profits p_ntrades p_tracks p_trackprofits ; 
    offsetcount = 1 ; 
    totalcost = (spreads(ccy) + 0.35 + 0.9)*mfactor ; 

    for offset=1:2:29
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
            disp(['currency = ', currs{ccy},', offset = ', num2str(offset),', mvgparam = ',num2str(mvgparam)]) ; 
            m1 = m1s(mvgparam) ; m2 = m2s(mvgparam) ; m3 = m3s(mvgparam) ; pt = pts(mvgparam) ;     
            trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; 
            alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; trackprofits = [] ; 
            for i=700:length(d5)
                if mod(i,100)== 0 ; trackprofits(length(trackprofits)+1) = profit ; end
                if trade == false
                    if d5(i)-pipthreshs(pt) > mvg(i,(m1)) % buy mode
                        if d5(i) < mvg(i,(m2)) && d5(i-1) > mvg(i,(m2)) % cross down
                            trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ;
                        end
                    elseif d5(i)+pipthreshs(pt) < mvg(i,(m1)) % sell mode
                        if d5(i) > mvg(i,(m2)) && d5(i-1) < mvg(i,(m2)) % cross up
                            trade = true ; entry = d5(i) ; sell = true ; ntrades = ntrades + 1 ;  
                        end
                    end
                elseif trade == true
                    if buy
                        if d5(i) > mvg(i,(m3)) && d5(i-1) < mvg(i,(m3))
                            buy = false ; profit = profit + d5(i)-entry-totalcost ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; 
                        end
                    elseif sell
                        if d5(i) < mvg(i,(m3)) && d5(i-1) > mvg(i,(m3))
                            sell = false ; profit = profit + entry-d5(i)-totalcost ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; 
                        end                   
                    end
                end    
            end  
            p_profits(offsetcount,mvgparam) = profit ; p_ntrades(offsetcount,mvgparam) = ntrades ; p_tracks{offsetcount,mvgparam} = alltrades ; p_trackprofits(offsetcount,mvgparam,:) = trackprofits ; 
        end
        offsetcount = offsetcount + 1 ; 
    end
    postproc{1} = p_profits ; postproc{2} = p_ntrades ; postproc{3} = p_tracks ; postproc{4} = [m1s(1:ntestparams),m2s(1:ntestparams),m3s(1:ntestparams),pts(1:ntestparams)] ; 
    postproc{5} = p_trackprofits ; 
    save(['overhead_postproc_',currs{ccy},'.mat'],'postproc') ;
  %  figure,bar(squeeze(mean(p_trackprofits(:,:,end),1))./squeeze(std(p_trackprofits(:,:,575),0,1))) ; title(resnames(ccy).name) ; 

end