clear all;
close all;

M=csvread('data_timewise_ROIActivation_PVsRAvg.csv');
M=M([9,10],7:16);
X=[7:16];
bar(X,M','stacked');
legend('LDLPFC','RDLPFC');
xlabel('TimeStamp');
ylabel('Percantage of Important Voxels');
axis([7 16 0 100])
title('SUBJECT 5 Important Voxel Analysis for Picture Region/Timewise');
saveas(gcf,'D:\thesis\myWork\graphs\timewise_ROIActivation_PVsRAvg_Sub5.png');
 
