clear all;
close all;

M=csvread('data_RFE_Probid_Ple_Neu.csv');
M=M.*100;

x=[0:9];
y1 = M(:,1);
y2 = M(:,2);
y3 = M(:,3);
y4 = M(:,4);
y5 = M(:,5);
y6 = M(:,6);
y7 = M(:,7);
y8 = M(:,8);

plot(x,y1,'-b',x,y2,'-m',x,y3,'-k',x,y4,'-r',x,y5,'-g',x,y6,'-b',x,y7,'-k',x,y8,'-m');
%xlabel('Feature Extraction Level');
%ylabel('Accuracy');
%title('RFE on Probid Pleasant Vs Neutral cognitive state');
legend('1','2','5','10','15','20','25','30','location','southeast');
axis([0 9 60 100])
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\RFE_Probid_Ple_Neu.jpg');


