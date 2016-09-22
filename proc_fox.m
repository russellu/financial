clear all ; close all ; 
cd C:\shared\processed_forex ; ls 
alldatas = dir('datas_*') ; 
currs =   {'AUDCAD','AUDCHF','AUDJPY','AUDNZD','AUDSGD','AUDUSD','CADCHF','CADHKD','CADJPY','CHFJPY','CHFSGD','EURAUD','EURCAD','EURCHF','EURDKK','EURGBP','EURHKD','EURJPY','EURNZD','EURPLN','EURSEK','EURSGD','EURTRY','EURUSD','GBPAUD','GBPCAD','GBPCHF','GBPJPY','GBPNZD','GBPUSD','HKDJPY','NZDCAD','NZDCHF','NZDJPY','NZDUSD','SGDJPY','USDCAD','USDCHF','USDCNH','USDDKK','USDHKD','USDJPY','USDMXN','USDNOK','USDSGD','USDTRY','USDZAR','XAGUSD','XAUUSD','ZARJPY'} ; 
spreads = [ 2.5,     2.5,     0.95,    2.33,    5,       0.9,     1.95,    16.0     1.05,    1.5,     9,       1.9,     1.85,    1.0      4.0      0.85,    18.0,    0.6,     3.6,     20.0,    19.0,    5.25,    9.0,     0.25,    3.35,    3.5,     2.2,     1.6,     5.0,     0.96,    28.0,    3.0,     2.1,     2.1,     1.05,    2.5,     0.9,     1.05,    2.5,     4.9,     3.0,     0.35,    50.0,     22.0,    2.0,     6.0,     100.0,   3.05,    28.0,    0.7   ]; 
% XAG, JPY, XAU
% HKD/JPY => 0.0001
for ad=1:length(alldatas) 
    dat = load(alldatas(ad).name) ;  
    dat = dat.datas ; 
    profits = dat{1} ; 
    ntrades = dat{2} ; 
    tracks = dat{3} ; 
   
    allprofits(:,:,:,ad) = profits ; allntrades(:,:,:,ad) = ntrades ; alltracks{ad} = tracks ; 
    divp = profits./ntrades ; divp(isnan(divp)) = 0 ; divp(isinf(divp)) = 0 ; 
    if (~isempty(strfind(alldatas(ad).name,'JPY')) && isempty(strfind(alldatas(ad).name,'HKD')) ) || ~isempty(strfind(alldatas(ad).name,'XAG')) || ~isempty(strfind(alldatas(ad).name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
   
    for i=1:size(tracks,1) ; 
        for j=1:size(tracks,2)
            for k=1:size(tracks,3)          
                if ~isempty(tracks{i,j,k})
                    corrs(i,j,k,ad) = corr2(cumsum(tracks{i,j,k}),1:length(cumsum(tracks{i,j,k}))) ; 
                end
            end
        end
    end
    %figure,
    %for i=1:28 ; subplot(4,7,i) ; imagesc((squeeze(allprofits(:,:,i,ad)-mfactor*spreads(ad)*allntrades(:,:,i,ad)).*(corrs(:,:,i,ad)>.90)),[0,lim2*100]) ; title(i) ; end
    %suptitle(alldatas(ad).name) ;    
 
    % for the output 
    corrsad = squeeze(corrs(:,:,:,ad)) ;  
   % for i=1:28 ; subplot(4,7,i) ; 
   %     imagesc((squeeze(profits(:,:,i)-mfactor*spreads(ad)*allntrades(:,:,i)).*(corrsad(:,:,i)>.90)),[0,lim2*100]) ; title(i) ;      
   % end
%    maski = squeeze(profits(:,:,:)-mfactor*spreads(ad)*allntrades(:,:,:)).*(corrsad(:,:,:)>.90) ; 
    % compute another stat => the total profit./max drawdown => see if its
    % similar to the correlation
    tradecost = mfactor*spreads(ad) + mfactor*0.35 + mfactor *0.9 ; % spread + commission + slippage
    for i=1:size(tracks,1)
        for j=1:size(tracks,2)
            for k=1:size(tracks,3)
                trackijk = cumsum(tracks{i,j,k}) ; 
                maxdd = 0 ; 
                for t=1:length(trackijk)
                    maxt = max(trackijk(1:t)) ; 
                    if trackijk(t)-maxt < maxdd
                        maxdd = trackijk(t)-maxt ; 
                    end                    
                end
                if ~isempty(trackijk)
                    maxdds(i,j,k) = maxdd ; 
                    totalp = cumsum(tracks{i,j,k}-tradecost) ; 
                    tradeprofits(i,j,k) = totalp(end) ;
                else
                    maxdds(i,j,k) = -1 ;
                    tradeprofits(i,j,k) = -1 ; 
                end
            end
        end
    end
    %for i=1:28 ; subplot(4,7,i ) ; imagesc(squeeze(maxdds(:,:,i)),[-.1,0]) ; title(i) ; end   
    figure,for i=1:28 ; subplot(4,7,i) ; imagesc((medfilt2(squeeze(tradeprofits(:,:,i)) + maxdds(:,:,i))) .* (ntrades(:,:,i)>200),[-3000*mfactor,3000*mfactor]) ; title(i) ; end
    allmaxdds(:,:,:,ad) = maxdds ; 
    alltradeprofits(:,:,:,ad) = tradeprofits ; 
    suptitle(currs{ad}) ; 

end

save('alltradeprofits','alltradeprofits') ; save('allmaxdds','allmaxdds') ; save('corrs','corrs') ; 
save('allntrades','allntrades') ; save('allprofits','allprofits') ;


for ad=1:length(currs)  
    if (~isempty(strfind(alldatas(ad).name,'JPY')) && isempty(strfind(alldatas(ad).name,'HKD')) ) || ~isempty(strfind(alldatas(ad).name,'XAG')) || ~isempty(strfind(alldatas(ad).name,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; 
    end
    costad = (squeeze(alltradeprofits(:,:,:,ad)) + allmaxdds(:,:,:,ad)) .* (allntrades(:,:,:,ad)>200) ; 
    figure,for i=1:28 ; subplot(4,7,i) ; imagesc(squeeze(costad(:,:,i)),[-mfactor*3000,mfactor*3000]) ; end
    [sv,si] = sort(costad(:)) ; 
    [m1,m2,m3] = ind2sub(size(costad),si) ; 
    allmvgs = [m1,m2,m3] ; 
end


% make more profit matrices => across time periods, and offsets this time
%{
alldivp = allprofits./allntrades ; 
for i=1:3 ; figure ; for j=1:28 ; subplot(4,7,j) ; imagesc(squeeze(corrs(:,:,j,i)),[.95,1]) ; title(j) ; end ; suptitle(alldatas(i).name(7:12)) ; end
a = [25,13,8,18] ;
figure,plot(cumsum(alltracks{a(4)}{a(1),a(2),a(3)})) ; title(num2str(alldivp(a(1),a(2),a(3),a(4)))) ; 
mvg = 1:25:700 ; 
[mvg(a(1)),mvg(a(2)),mvg(a(3))]
%}