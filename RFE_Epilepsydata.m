close all;
close all;

load 'epi_linear_feat'
epi_linear_feat_data=L;

%keeping only 2 classes instead of 3 classes
epi_linear_feat_data(1:100,:)=[];

epi_linear_feat_data(:,2)=real(epi_linear_feat_data(:,2));

%  epi_linear_feat_data(:,4)=[];
%  epi_linear_feat_data(:,3)=[];
%  epi_linear_feat_data(:,3)=[];
%  epi_linear_feat_data(:,3)=[];
%  epi_linear_feat_data(:,1)=[];

classes=[-1*ones(200,1);ones(200,1)];
classes = cellstr(num2str(classes));
weights=[];

k=10;
cvfolds=crossvalind('kfold',classes,k);          %# get indices of 10-fold CV
cp=classperf(classes);                           %# init performance tracker
   
for i=1:k                                       %# for each fold
      testIdx=(cvfolds==i);                     %# get indices of test instances
      trainIdx=~testIdx;                        %# get indices training instances
        
      %# train an SVM model over training instances  
      svmModel=svmtrain(epi_linear_feat_data(trainIdx,[1,2]), classes(trainIdx,:), 'Autoscale',true, 'Showplot',false,'kernel_function','linear');
      
      
      %# calculate weight of each feature
       SupportVectorIndices=svmModel.SupportVectorIndices;
       %yn=classes([SupportVectorIndices]);                           %#get corresponding label of supportvectors
       alpha=svmModel.Alpha;                                          %#multiply label with corresponding alpha value                             
       supportVectors=svmModel.SupportVectors;                       %#get supportvectors
       weights=[weights;(alpha)'*supportVectors];                   %#get weigths of each feature 
      
      
      %# test using test instances
        pred = svmclassify(svmModel, epi_linear_feat_data(testIdx,[1,2]), 'Showplot',false);
      
      
      %# evaluate and update performance object
      cp = classperf(cp, pred, testIdx);
      
end

%# get accuracy 
   disp(mean(weights))
%# get accuracy 
   disp(cp.CorrectRate);

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
   disp(cp.CountingMatrix)  ;