function tp(EEG) 
% function tp(EEG) 
% plot topoplot 5x13 on figure
figure,
disp('plotting topoplot') ; 
for i=1:64 ; subplot(5,13,i) ; topoplot(squeeze(EEG.icawinv(:,i)),EEG.chanlocs,'electrodes','on') ; title(i) ;  end


end