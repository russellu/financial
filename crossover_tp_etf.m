% run all the currencies through separately and save a log file at the end.
% the log file should have the results of the back-testing and the forward
% testing, the standard deviation, etc 
% break it up into blocks, and bar increments 

clear all ; close all ; 
rawtps = 0.5:1:10 ; 
curr = 'EWJ' ; 
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\ETFs') ; 
fid = fopen([curr,'.txt']) ; 
data = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 

for tshift = 1  
    orig = data{6} ; orig = orig(tshift:15:end) ; mtimes = data{1} ; mtimes = mtimes(tshift:15:end) ; 
    orig = orig(length(orig)/2:end) ; mtimes = mtimes(length(mtimes)/2:end) ; 
    nincrs = 25 ; incrl = length(orig)/25 ; 
    d5incr = length(orig)./nincrs ; 
    for d5i=1:nincrs ; 
        startindex = (d5i-1)*d5incr + 1 ; endindex = startindex+incrl ; if endindex > length(orig) ; endindex = length(orig) ; end 
        d5 = orig(startindex:endindex) ; 

        tps = rawtps; 
        mvgs1 = 1:10:350 ; 
        mvgs2 = 1:10:350 ; 

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

        for m1=1:length(mvgs1) ; disp(['tshift=',num2str(tshift),', d5i=',num2str(d5i),', m1=',num2str(m1)]) ;
            for m2=1:length(mvgs2) ; 
                for tp=1:length(tps)
                    trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ; 
                    for i=700:length(d5)
                        if trade == false
                            if d5(i) > mvg(i,(m1)) % buy mode
                                if d5(i) < mvg(i,(m2)) && d5(i-1) > mvg(i,(m2)) % cross down
                                    trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ; buyentries(length(buyentries)+1) = i ; 
                                end
                            elseif d5(i) < mvg(i,(m1)) % sell mode
                                if d5(i) > mvg(i,(m2)) && d5(i-1) < mvg(i,(m2)) % cross up
                                    trade = true ; entry = d5(i) ; sell = true ; ntrades = ntrades + 1 ; sellentries(length(sellentries)+1) = i ; 
                                end
                            end
                        elseif trade == true
                            if buy
                                if d5(i) - entry > tps(tp) || d5(i) - entry < -tps(tp)
                                    buy = false ; profit = profit + d5(i)-entry ; trade = false ; alltrades(length(alltrades)+1) = d5(i) - entry ; buyexits(length(buyexits)+1) = i ; 
                                end
                            elseif sell
                                if entry - d5(i) > tps(tp) || entry - d5(i) < -tps(tp)
                                    sell = false ; profit = profit + entry-d5(i) ; trade = false ; alltrades(length(alltrades)+1) = entry - d5(i) ; sellexits(length(sellexits)+1) = i ; 
                                end                   
                            end
                        end    
                    end  
                    allprofits(m1,m2,tp,d5i,tshift) = profit ; 
                    allntrades(m1,m2,tp,d5i,tshift) = ntrades ; 
                    alltracks{m1,m2,tp,d5i,tshift} = alltrades ;
                    allbuyentries{m1,m2,tp,d5i,tshift} = buyentries ; 
                    allsellentries{m1,m2,tp,d5i,tshift} = sellentries ; 
                    allbuyexits{m1,m2,tp,d5i,tshift} = buyexits ; 
                    allsellexits{m1,m2,tp,d5i,tshift} = sellexits ; 
                end 
            end 
        end
    end
end

divp = allprofits./allntrades ; divp(isnan(divp)) = 0 ; 
mdiv = squeeze(mean(divp,4)) ; 



