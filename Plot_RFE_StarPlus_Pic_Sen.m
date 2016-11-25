clear all;
close all;

M=csvread('Data_RFE_StarPlus_Pic_Sen.csv');
M=M.*100;

x=[0:9];
y1 = M(:,1);
y2 = M(:,2);
y3 = M(:,3);
y4 = M(:,4);
y5 = M(:,5);
y6 = M(:,6);
y7 = M(:,7);

plot(x,y1,'-k',x,y2,'-y',x,y3,'-y',x,y4,'-k',x,y5,'-y',x,y6,'-y',x,y7,'-k');
%xlabel('Feature Extraction Level');
%ylabel('Accuracy');
%title('RFE on StarPlus Picture Vs Sentence cognitive state');
legend('1','2','5','10','15','20','25','location','southeast');
axis([0 9 50 100])
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\RFE_StarPlus_Pic_Sen.jpg');
