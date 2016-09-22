clear all ; close all ; 
currs = {'AUDJPY','AUDUSD','CHFJPY','EURAUD','EURCAD','EURCHF','EURGBP','EURJPY','EURUSD','GBPCHF','GBPJPY','GBPUSD','NZDUSD','USDCAD','USDCHF','USDJPY'} ; 
clear allprofits alltracks allntrades

for c=1:length(currs) ; 
    
curr = currs{c} ; 
%{
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\Forex') ; 
fid = fopen([curr,'.txt']) ; 
data = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 
d5 = data{6} ; d5 = d5(2888100:60:end) ;
%}

cd c:/users/acer/documents/indices_4 ; ls 
fid = fopen([curr,'_UTC_1 Min_Bid_2011.12.31_2016.09.01.csv']) ; 
dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
fclose(fid) ; 
d5 = dkdata{6} ; d5 = d5(1:60:end) ; 





mvgs1 = 1:25:700 ; 
mvgs2 = 1:25:700 ; 
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

for m1=1:length(mvgs1) ; disp(['curr=',currs{c},', perc=',num2str(m1./length(mvgs1))]) ;
    for m2=1:length(mvgs2) ; 
        trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; 
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
                        if d5(i) > mvg(i,(m1)) && d5(i-1) < mvg(i,(m1))
                            buy = false ; profit = profit + d5(i)-entry ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; 
                        end
                    elseif sell
                        if d5(i) < mvg(i,(m1)) && d5(i-1) > mvg(i,(m1))
                            sell = false ; profit = profit + entry-d5(i) ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; 
                        end                   
                    end
                end    
            allprofits(m1,m2,c) = profit ; 
            allntrades(m1,m2,c) = ntrades ; 
            alltracks{m1,m2,c} = alltrades ;
        end
    end  
end
%{
divp = allprofits./allntrades ; divp(isnan(divp)) = 0 ;
plot(cumsum(alltracks{18,16})) ; 
for i=1:size(alltracks,1) ; for j=1:size(alltracks,2) ; if ~isempty(alltracks{i,j}) ; corrs(i,j) = corr2(cumsum(alltracks{i,j}),1:length(cumsum(alltracks{i,j}))) ; end ; end ; end
figure,
subplot(2,2,1) ; imagesc(divp,[-.001,.001]) ; subplot(2,2,2) ; imagesc(corrs) ; subplot(2,2,3) ; imagesc(allprofits) ; subplot(2,2,4) ; imagesc(allntrades,[0,1000]);  
%}
end
divp = allprofits./allntrades ; 









