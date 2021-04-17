clear all;
close all;

M=csvread('data_Accuracy_Diff_Sub_Diff_Ts.csv');
M=M.*100;


X=[1:16];
y1 = M(1,:)';
y2 = M(2,:)';
y3 = M(3,:)';
y4 = M(4,:)';
y5 = M(5,:)';


plot(X,y1,'-b',X,y2,'-r',X,y3,'-b',X,y4,'-c',X,y5,'-m');
legend('sub1','sub2','sub3','sub4','sub5','location','northwest');
%xlabel('Timestamp');
%ylabel('Accuracy');
%title('Accuracy in different timestamps')
axis([1 16 40 100])
saveas(gcf,'D:\thesis\Latex\IIITB_Thesis_v1_2_2014Guidelines\Images\Accuracy_Diff_Sub_Diff_Ts.png');



