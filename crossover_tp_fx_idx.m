clear all ; close all ; 
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\Forex') ; 
fid = fopen('AUDUSD.txt') ; 
data = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 
for idx=1:30
d5 = data{6} ; d5 = d5(idx:30:end) ; 
d5 = d5(length(d5)/2:end) ; 
% make a moving average:
clear mvg p mean
for p = 1:500  
    for i=p+1:length(d5)
        if i==p+1
            mvg(i,p) = mean(d5(i-p+1:i)) ; 
        else
            mvg(i,p) = mvg(i-1,p) + d5(i)/(p) - d5(i-p)/(p) ;
        end  
    end
end

%clear allprofits allntrades alltracks
m1s = 1:5:100 ; m2s = 1:5:100 ; tps = 0.5:2:30 ; 
m1count = 1 ; 
for m1=1:5:100 ; m2count = 1 ; disp(m1) ; 
    for m2=1:5:100 ; tpcount = 1 ; 
        for tp=0.0001:0.0003:0.0050
            trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; 
            for i=201:length(d5)
                if trade == false
                    if d5(i) > mvg(i,m1) % buy mode
                        if d5(i) < mvg(i,m2) && d5(i-1) > mvg(i,m2) % cross down
                            trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ; buyentries(length(buyentries)+1) = i ; 
                        end
                    elseif d5(i) < mvg(i,m1) % sell mode
                        if d5(i) > mvg(i,m2) && d5(i-1) < mvg(i,m2) % cross up
                            trade = true ; entry = d5(i) ; sell = true ; ntrades = ntrades + 1 ; sellentries(length(sellentries)+1) = i ; 
                        end
                    end
                elseif trade == true
                    if buy
                        if d5(i) - entry > tp || d5(i) - entry < -tp
                            buy = false ; profit = profit + d5(i)-entry ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; buyexits(length(buyexits)+1) = i ; 
                        end
                    elseif sell
                        if entry - d5(i) > tp || entry - d5(i) < -tp
                            sell = false ; profit = profit + entry-d5(i) ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; sellexits(length(sellexits)+1) = i ; 
                        end                   
                    end
                end    
            end ; allprofits(m1count,m2count,tpcount,idx) = profit ; allntrades(m1count,m2count,tpcount,idx) = ntrades ; alltracks{m1count,m2count,tpcount,idx} = alltrades ;
            allbuyentries{m1count,m2count,tpcount,idx} = buyentries ; allsellentries{m1count,m2count,tpcount,idx} = sellentries ; allbuyexits{m1count,m2count,tpcount,idx} = buyexits ; allsellexits{m1count,m2count,tpcount} = sellexits ; 
            tpcount = tpcount + 1 ; 
        end ; m2count = m2count + 1 ; 
    end ; m1count = m1count + 1 ; 
end
end



for i=1:20 ; for j=1:10 ; for k=1:17 ; for el = 1:15 ; if ~isempty(alltracks{i,j,k,el}) ; corrs(i,j,k,el) = corr2(cumsum(alltracks{i,j,k,el}),1:length(cumsum(alltracks{i,j,k,el}))) ; end ; end ; end ; end ; end


