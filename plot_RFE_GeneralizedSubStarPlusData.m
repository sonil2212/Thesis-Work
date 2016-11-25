clear all;
close all;

M=csvread('data_RFE_GeneralizedSubStarPlusData.csv');
M=M.*100;

x = [0:9];
y1 = M(:,1);
y2 = M(:,2);
plot(x,y1,'*k',x,y2,'*b');
%plot(x,y1,'*k');
l=legend('7 Rois Voxels','CALC,LIPS,LIPL Voxels');
%xlabel('Feature Extraction level');
%ylabel('Accuracy');
%title('Generalized Subject Performance')
axis([0 9 0 100])
saveas(gcf,'D:\thesis\myWork\graphs\RFE_GeneralizedSubStarPlus.png');
 
