clear all ; close all ; 
%{
currs = {'AUDJPY','AUDUSD','CHFJPY','EURAUD','EURCAD','EURCHF','EURGBP','EURJPY','EURUSD','GBPCHF','GBPJPY','GBPUSD','NZDUSD','USDCAD','USDCHF','USDJPY'} ; 
curr = 'EURJPY' ; 
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\Forex') ; 
fid = fopen([curr,'.txt']) ; 
data = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 
d5 = data{6} ; d5 = d5((end/1.5+5):5:end) ;
%}

cd c:/users/acer/documents/indices_4 ; ls 
fid = fopen('EURUSD_UTC_1 Min_Bid_2011.12.31_2016.09.01.csv') ; 
dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
fclose(fid) ; 
d5 = dkdata{6} ; d5 = d5(1:30:end) ; 

mvgs1 = 1:25:400 ; 
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
pipthreshs = [0.0001,.0005,.001,.002,.004] ; 
clear allprofits alltracks allntrades
for m1=1:length(mvgs1) ; disp(['m1=',num2str(m1)]) ;
    for m2=1:length(mvgs1) ; 
        for m3=1:length(mvgs1) ; 
            for pipthresh=1:length(pipthreshs)
            trade = false ; entry = 0 ; buy = false ; sell = false ; profit = 0 ; ntrades = 0 ; 
            alltrades = [] ; sellentries = [] ; buyentries = [] ; sellexits = [] ; buyexits = [] ;trackprofits = [] ; 
            for i=700:length(d5)
                if mod(i,100)== 0 ; trackprofits(length(trackprofits)+1) = profit ; end
                if trade == false
                    if d5(i)-pipthreshs(pipthresh) > mvg(i,(m1)) % buy mode
                        if d5(i) < mvg(i,(m2)) && d5(i-1) > mvg(i,(m2)) % cross down
                            trade = true ; entry = d5(i) ; buy = true ; ntrades = ntrades + 1  ;
                        end
                    elseif d5(i)+ pipthreshs(pipthresh) < mvg(i,(m1)) % sell mode
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
            allprofits(m1,m2,m3,pipthresh) = profit ; 
            allntrades(m1,m2,m3,pipthresh) = ntrades ; 
            alltracks{m1,m2,m3,pipthresh} = alltrades ;
            alltrackprofits(m1,m2,m3,pipthresh,:) = trackprofits ; 
            end
        end
    end  
end




%{
divp = allprofits./allntrades ; divp(isnan(divp)) = 0 ; 
for i=1:size(alltrackprofits,1);for j=1:size(alltrackprofits,2);for k=1:size(alltrackprofits,3);for el=1:size(alltrackprofits,4);corrs(i,j,k,el)=corr2(squeeze(alltrackprofits(i,j,k,el,:))',1:size(alltrackprofits,5));end;end;end;end
corrs(isnan(corrs)) = 0 ; 
[sv,si] = sort(corrs(:),'descend') ; 
[ix,iy,iz,it] = ind2sub(size(corrs),si) ; 
for i=1:100 ;
    hps(i,:) = squeeze(alltrackprofits(ix(i),iy(i),iz(i),it(i),:)) ; 
    % figure,plot(squeeze(alltrackprofits(ix(i),iy(i),iz(i),it(i),:))) ; hold on ;  
end
%}
%{
for i=1:size(alltracks,1);for j=1:size(alltracks,2) ; for k=1:size(alltracks,3) ; if ~isempty(alltracks{i,j,k}) ; corrs(i,j,k) = corr2(cumsum(alltracks{i,j,k}),1:length(cumsum(alltracks{i,j,k}))) ; end ; end ; end ; end
for i=1:size(corrs,2) ; subplot(5,7,i) ; imagesc((squeeze(corrs(:,:,i))>.98).*allprofits(:,:,i),[0,.5]) ; title(i) ; end
xyz = [19,2,2] ; plot(cumsum(alltracks{xyz(1),xyz(2),xyz(3)})) ; title(num2str(corrs(xyz(1),xyz(2),xyz(3)))) ; 
rands = rand(21952,253)-.5 ; 
clear corrsz
for i=1:size(rands,1) ; corrsz(i) = corr2(cumsum(rands(i,:)),1:length(cumsum(rands(i,:)))) ; end
%}



