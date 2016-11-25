clear all;
close all;

M=csvread('data_RFE_All_Vs_8-16Ts.csv');
M=M.*100;

bar(M);
%xlabel('Subjects');
%ylabel('Accuracy');
%title('All Vs 7-14 Timestamp accuracy comparision');
legend('All TimeStamps','7-14 TimeStamps','location','northwest');
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\RFE_All_Vs_8-16Ts.png');


 
