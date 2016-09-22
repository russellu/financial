clear all ; close all ; 
currs = {'AUDJPY','AUDUSD','CHFJPY','EURAUD','EURCAD','EURCHF','EURGBP','EURJPY','EURUSD','GBPCHF','GBPJPY','GBPUSD','NZDUSD','USDCAD','USDCHF','USDJPY'} ; 
pipsz = [0.01,0.0001,0.01,0.0001,0.0001,0.0001,0.0001,0.01,0.0001,0.0001,0.01,0.0001,0.0001,0.0001,0.0001,0.01] ;

for i=1:length(currs) ; 
curr = currs{i} ; 
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\Forex') ; 
fid = fopen([curr,'.txt']) ; 
data = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 
d5 = data{6} ; d5 = d5(end-100000:end) ; 
times = data{2} ; alltimes{i} = times(end) ; 
alldata(i,:) = d5./(pipsz(i)*100) ; 
disp(currs{i}) ; 
end

plot(alldata') ; 

hpdata = eegfiltfft(alldata,1/60,1/(60*60*24),1/60) ; 
[weights,sphere] = runica(hpdata) ; 
acts = weights*sphere*alldata ; 


f = fft(acts,[],2) ; 







