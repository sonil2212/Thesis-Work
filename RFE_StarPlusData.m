clear all;
close all;
    
    
%RFE algorithn
for r=1:10
    if r~=1
        starPlusData(:,IndexOfFeatsToRemoved(end-((size(starPlusData,2))*.25)+1:end))=[];
        NumberOfFeatures=[NumberOfFeatures;size(starPlusData,2)];
    end    
    
    weights=[];                                     %# weigths vector for feature                    
    k=10;                                           %# 10 fold cross fold                    
    cvfolds=crossvalind('kfold',labels,k);          %# get indices of 10-fold CV
    cp=classperf(labels);                           %# init performance tracker

    for i=1:k                                       %# for each fold
          testIdx=(cvfolds==i);                     %# get indices of test instances
          trainIdx=~testIdx;                        %# get indices training instances

          %# train an SVM model over training instances  
          svmModel=svmtrain(starPlusData(trainIdx,:), labels(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');


          %# calculate weight of each feature
           SupportVectorIndices=svmModel.SupportVectorIndices;
           alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value                             
           supportVectors=svmModel.SupportVectors;                       %#get supportvectors
           weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature 


          %# test using test instances
            pred = svmclassify(svmModel, starPlusData(testIdx,:), 'Showplot',false);


          %# evaluate and update performance object
          cp = classperf(cp, pred, testIdx);

    end

      meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations 
      [sortedWeights,IndexOfFeatsToRemoved]=sort(meanWeigths,'descend');  %#Sort meanWeigths 
    
      %# get accuracy 
       CorrectRate=[CorrectRate;cp.CorrectRate];
end

finalNoOfFeatures=size(starPlusData,2);
    
