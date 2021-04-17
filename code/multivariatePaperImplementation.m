clear all;
close all;

% data preparation
load 'healthy controls_subj1_ple';
probidData = class_n';

load 'healthy controls_subj2_ple';
probidData = [probidData;class_n'];

load 'healthy controls_subj3_ple';
probidData = [probidData;class_n'];

load 'healthy controls_subj4_ple';
probidData = [probidData;class_n'];

load 'healthy controls_subj5_ple';
probidData = [probidData;class_n'];

load 'healthy controls_subj1_unple';
probidData = [probidData;class_n'];

load 'healthy controls_subj2_unple';
probidData = [probidData;class_n'];

load 'healthy controls_subj3_unple';
probidData = [probidData;class_n'];

load 'healthy controls_subj4_unple';
probidData = [probidData;class_n'];

load 'healthy controls_subj5_unple';
probidData = [probidData;class_n'];

groups=[zeros(50,1);ones(50,1)];
% ---------------------------------------------------------------


k=8;
featureIndices=(1:size(probidData,2));
accuracy=[];                             %# accuracy in each feature extraction level    
 
for r=1:10
   cvfolds=crossvalind('kfold',groups,k);   %# get indices of 8-fold CV
   cp=classperf(groups);                    %# init performance tracker
   weights=[];                              %# contains avg weigths of each of the vector    
   
   
   for i=1:k                                %# for each fold
      testIdx=(cvfolds==i);                 %# get indices of test instances
      trainIdx=~testIdx;                    %# get indices training instances
        
      %# train an SVM model over training instances  
      svmModel=svmtrain(probidData(trainIdx,featureIndices), groups(trainIdx), 'Autoscale',true, 'Showplot',false);
       
      %# calculate weight of each feature
      %yn=groups(svmModel.SupportVectorIndices); %#get corresponding label of supportvectors
      alpha=svmModel.Alpha;                                          %#multiply label with corresponding alpha value                             
      supportVectors=svmModel.SupportVectors;   %#get supportvectors
      weights=[weights;(alpha)'*supportVectors];                   %#get weigths of each feature 
      
      
      %# test using test instances
      pred = svmclassify(svmModel, probidData(testIdx,featureIndices), 'Showplot',false);
      
      %# evaluate and update performance object
      cp = classperf(cp, pred, testIdx);
             
   end
   
   %#calculate average weigths after each feature extraction level
   avgWeight=(mean(weights))';            
   
   
   %#sort and remove irrelevent features
   [sortedWeights,Index]=sort(avgWeight,'descend');
   removedIndex=Index(end-100+1:end);   %#keep indexes of 100 least relevent feature 
   featureIndices(removedIndex)=[];         
   
    
 %# get accuracy 
   accuracy=[accuracy;cp.CorrectRate];

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
%cp.CountingMatrix
 end    
    
    
    
