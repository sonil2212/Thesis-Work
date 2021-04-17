clear all;
close all;

M=csvread('data_timewise_ROIActivation_Analysis.csv');
M=M(:,8:16);
X=[8:16];
bar(X,M','stacked');
legend('CALC','LIPL','LT','LTRIA','LOPER','LIPS','LDLPFC','location','northwest');
%xlabel('TimeStamp');
%ylabel('Percantage of Important Voxels');
%title('Important Voxel Analysis Region/Timewise');
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\timewise_ROIActivation_Analysis.png');
 
