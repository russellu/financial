clear all ; close all ; 
currs = {'AUDJPY','AUDUSD','CHFJPY','EURAUD','EURCAD','EURCHF','EURGBP','EURJPY','EURUSD','GBPCHF','GBPJPY','GBPUSD','NZDUSD','USDCAD','USDCHF','USDJPY'} ; 
curr = 'USDCAD' ; 
cd('C:\Users\Acer\Downloads\market_081916_russell_butler\Market 081916\Forex') ; 
fid = fopen([curr,'.txt']) ; 
pidata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',',','Headerlines',1) ; 
fclose(fid) ; 
pid5 = pidata{6} ; pid5 = pid5(2888100:10:end) ;

cd c:/users/acer/documents/indices_4 ; ls 
fid = fopen('USDCAD_UTC_1 Min_Bid_2011.12.31_2016.09.01.csv') ; 
dkdata = textscan(fid,'%s %s %f %f %f %f %f','delimiter',' ') ; 
fclose(fid) ; 
dkd5 = dkdata{6} ; dkd5 = dkd5(1:10:end) ; 




