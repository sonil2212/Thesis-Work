clear all;
close all;

M=csvread('data_RFE_GeneralizedSubStarPlusData2.csv');
X=[1:5];
bar(X,M,'stacked');
legend('CALC','LIPL','LIPS','location','northwest');
%xlabel('Feature Extraction Level & Percantage Of Voxels Removed');
%ylabel('Percantage of Important Voxels');
set(gca, 'XTick',1:5, 'XTickLabel',{'(20,10)' '(12,10)' '(10,20)' '(15,15)' '(13,15)'})
%title('Important Voxel Analysis Regionwise for generalized subjects');
saveas(gcf,'D:\thesis\myWork\graphs\RFE_GeneralizedSubStarPlusData2.png');
 
