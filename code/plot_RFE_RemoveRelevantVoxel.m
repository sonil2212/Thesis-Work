clear all;
close all;

M=csvread('data_RFE_RemoveRelevantVoxels.csv');
M=M.*100;

x = [0:9];
y1 = M(:,1);
y2 = M(:,2);
plot(x,y1,'-b',x,y2,'-r');
l=legend('10%','30%');
xlabel('Feature Extraction level');
ylabel('Accuracy');
title('Accuracy Vs Feature Extraction Level')'
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\RFE_RemoveRelevantVoxels.jpg');
 
