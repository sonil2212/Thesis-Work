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



classes=[-1*ones(50,1);ones(50,1)];
classes = cellstr(num2str(classes));
CorrectRate=[];                                 %# Correct Rate for each feature extraction level
IndexOfFeatsToRemoved=[];
NumberOfFeatures=size(probidData,2);

% ---------------------------------------------------------------
for r=1:10
    
    
    
    if r~=1
        %removedFeaturesIndexes=IndexOfFeatsToRemoved(end-((size(probidaData,2))*.01)+1:end);            %remove 1% of irrelavant vaoxels
        probidData(:,IndexOfFeatsToRemoved(end-((size(probidData,2))*.1)+1:end))=[];
        %NumberOfFeatures=[NumberOfFeatures;size(probidData,2)];
    end    
    
        
    weights=[];

    k=10;
    cvfolds=crossvalind('kfold',classes,k);          %# get indices of 10-fold CV
    cp=classperf(classes);                           %# init performance tracker

    for i=1:k                                       %# for each fold
          testIdx=(cvfolds==i);                     %# get indices of test instances
          trainIdx=~testIdx;                        %# get indices training instances

          %# train an SVM model over training instances  
          svmModel=svmtrain(probidData(trainIdx,:), classes(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');


          %# calculate weight of each feature
           SupportVectorIndices=svmModel.SupportVectorIndices;
           %yn=classes([SupportVectorIndices]);                           %#get corresponding label of supportvectors
           alpha=svmModel.Alpha;                                          %#multiply label with corresponding alpha value                             
           supportVectors=svmModel.SupportVectors;                       %#get supportvectors
           weights=[weights;(alpha)'*supportVectors];                   %#get weigths of each feature 


          %# test using test instances
            pred = svmclassify(svmModel, probidData(testIdx,:), 'Showplot',false);


          %# evaluate and update performance object
          cp = classperf(cp, pred, testIdx);

    end

    %# get accuracy 
      % disp(mean(weights))

      meanWeigths=(mean(weights));                                      %#get Mean weigths for all cross validations 
      [sortedWeights,IndexOfFeatsToRemoved]=sort(abs(meanWeigths),'descend');                  %#Sort meanWeigths 
    %# get accuracy 
       CorrectRate=[CorrectRate;cp.CorrectRate];

    %# get confusion matrix
    %# columns:actual, rows:predicted, last-row: unclassified instances
       %disp(cp.CountingMatrix);
   
end   


finalNoOfFeatures=size(probidData,2);