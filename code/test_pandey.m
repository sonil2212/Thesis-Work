clear all;  
close all;

load 'test_train3';
load 'lables'';
lables = cellstr(num2str(lables));



%roiVoxelNumbers=size(roiVoxelsIndexes,2);
CorrectRate=[];                 %Correct Rate for each feature extraction level
IndexOfFeatsToRemoved=[];       %Number of Features removed in each iteration
NumberOfFeatures=[];            %keep number of features in each iteration;
%timeStamp=7;                    %timestamp from which data required

%test_train3=test_train3(:,[((timeStamp-1)*1)+1:end]);

%RFE algorithn
for r=1:30
    if r~=1
        test_train3(:,IndexOfFeatsToRemoved(end-((size(test_train3,2))*.1)+1:end))=[];
        %NumberOfFeatures=[NumberOfFeatures;size(test_train3,2)];
    end
        
    weights=[];                                     %# weigths vector for feature
    k=10;                                           %# 10 fold cross fold
    cvfolds=crossvalind('kfold',lables,k);          %# get indices of 10-fold CV
    cp=classperf(lables);                           %# init performance tracker
    
    for i=1:k                                       %# for each fold
        testIdx=(cvfolds==i);                       %# get indices of test instances
        trainIdx=~testIdx;                          %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(test_train3(trainIdx,:), lables(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');
        
        
        %# calculate weight of each feature
        alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
        supportVectors=svmModel.SupportVectors;                       %#get supportvectors
        weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
        
        
        %# test using test instances
        pred = svmclassify(svmModel, test_train3(testIdx,:), 'Showplot',false);
        
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
        
    end
    
    meanWeigths=(abs(mean(weights)));                                       %#get Mean weigths for all cross validations
    [sortedWeights,IndexOfFeatsToRemoved]=sort(meanWeigths,'descend');      %#Sort meanWeigths and finding indexes of the features to be removed
    
    %# get accuracy
    CorrectRate=[CorrectRate;cp.CorrectRate];
end


