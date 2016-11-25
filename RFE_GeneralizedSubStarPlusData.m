clear all;  
close all;

load 'starPlusDataAvgValues';
load 'labelsAvgValues';
labelsAvgValues = cellstr(num2str(labelsAvgValues));

%roiVoxelNumbers=size(roiVoxelsIndexes,2);
CorrectRate=[];                 %Correct Rate for each feature extraction level
IndexOfFeatsToRemoved=[];       %Number of Features removed in each iteration
NumberOfFeatures=[];            %keep number of features in each iteration;
timeStamp=7;                    %timestamp from which data required

starPlusDataAvgValues=starPlusDataAvgValues(:,[((timeStamp-1)*1)+1:end]);

%RFE algorithn
for r=1:10
    if r~=1
        starPlusDataAvgValues(:,IndexOfFeatsToRemoved(end-((size(starPlusDataAvgValues,2))*.1)+1:end))=[];
        %NumberOfFeatures=[NumberOfFeatures;size(starPlusDataAvgValues,2)];
    end
    
    weights=[];                                     %# weigths vector for feature
    k=10;                                           %# 10 fold cross fold
    cvfolds=crossvalind('kfold',labelsAvgValues,k);          %# get indices of 10-fold CV
    cp=classperf(labelsAvgValues);                           %# init performance tracker
    
    for i=1:k                                       %# for each fold
        testIdx=(cvfolds==i);                       %# get indices of test instances
        trainIdx=~testIdx;                          %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(starPlusDataAvgValues(trainIdx,:), labelsAvgValues(trainIdx,:), 'Autoscale',true, 'kernel_function','rbf');
        
        
        %# calculate weight of each feature
        alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
        supportVectors=svmModel.SupportVectors;                       %#get supportvectors
        weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
        
        
        %# test using test instances
        pred = svmclassify(svmModel, starPlusDataAvgValues(testIdx,:), 'Showplot',false);
        
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
        
    end
    
    meanWeigths=(abs(mean(weights)));                                       %#get Mean weigths for all cross validations
    [sortedWeights,IndexOfFeatsToRemoved]=sort(meanWeigths,'descend');      %#Sort meanWeigths and finding indexes of the features to be removed
    
    %# get accuracy
    CorrectRate=[CorrectRate;cp.CorrectRate];
end


