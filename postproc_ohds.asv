clear all ; close all ; 
cd c:/users/acer/documents/indices_4 ; ls 

resnames = dir('*overhead*') ; 
for ccy = 1:length(resnames)  
    ccy_current = resnames(ccy).name ;  
    if (~isempty(strfind(ccy_current,'JPY')) && isempty(strfind(ccy_current,'HKD')) ) || ~isempty(strfind(ccy_current,'XAG')) || ~isempty(strfind(ccy_current,'XAU')) 
        lim1 = -0.4 ; lim2 = 0.4 ; mfactor = 0.01 ; minlim = 3 ; 
    else 
        lim1 = -0.004 ; lim2 = 0.004 ; mfactor = 0.0001 ; minlim = 0.03 ; 
    end
    data = load(resnames(ccy).name) ; data = data.postproc ; 
    mvgs1 = [5,15,30,50,90,150,220,320,450,600,900] ; 
    pipthreshs = [1,5,10,20,40,80]*mfactor ; 
  %  subplot(5,7,ccy),imagesc(data{1}./data{2},[lim1,lim2]) ;title(ccy_current) ; 
    profits = data{1} ; ntrades = data{2} ; tracks = data{5} ; badps = find(mean(profits,1)<minlim) ; profits(:,badps) = -1 ; 
    clear trackcorrs ; 
    for i=1:size(tracks,1) ; for j=1:size(tracks,2) ; trackcorrs(i,j) = corr2(squeeze(tracks(i,j,:))',1:size(tracks,3)) ; end ; end
    smalltrades = find(ntrades<100) ; profits(smalltrades) = 0 ; 
    params = data{4} ;% mvp = squeeze(mean(trackcorrs,1)) ;
    f mvp = mean(profits); mvp(isnan(mvp)) = 0 ; 
    [sv,si] = sort(mvp,'descend') ; 
    mtracks = squeeze(mean(tracks,1)) ; 
    allprofits(ccy,:) = imresize(mean(mtracks(si(1),:),1)./mfactor,[1,600]) ;
    allmeans(ccy,:) = mean((profits(:,si)./ntrades(:,si))./mfactor,1) ; 
    allparams(ccy,:) = params(si(1),:) ; 
    name = strrep(resnames(ccy).name,'overhead_postproc_','') ; name = strrep(name,'.mat','') ; 
    bestparam = params(si(1:50),:) ; save(['bestparam_',name],'bestparam') ; 
    bestparam(:,1) = mvgs1(bestparam(:,1)) ;  bestparam(:,2) = mvgs1(bestparam(:,2)) ;  bestparam(:,3) = mvgs1(bestparam(:,3)) ;  bestparam(:,4) = pipthreshs(bestparam(:,4)) ; 
    dlmwrite(['txt_bestparam-',name,'-.txt'],bestparam) ;

end
plot(sum(allprofits))
% expected growth rate: compound
sprofits = sum(allprofits) ; balance = 20000 ; 
dprofits = diff(sprofits) ; pipsz = balance/10000 ;
for i=1:length(dprofits)
    balance = balance + dprofits(i)*pipsz ;
    newbalance(i) = balance ; 
    pipsz = balance/10000 ; 
end
for i=1:size(allprofits,1)
    corrs(i) = corr2(allprofits(i,:),1:600) ; 
end
[sv,si] = sort(corrs,'descend') ; 











