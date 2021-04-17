clear all;  
close all;

% %for All Rois
% starPlusData_GeneralizedPicVsRestAllRois=[];
% labels_GeneralizedPicVsRestAllRois=[];
% 
% 
% load 'starPlusData_PicVsRestAvgValues_1';
% starPlusData_GeneralizedPicVsRestAllRois=starPlusData_PicVsRestAvgValues;
% 
% load 'starPlusData_PicVsRestAvgValues_2';
% starPlusData_GeneralizedPicVsRestAllRois=[starPlusData_GeneralizedPicVsRestAllRois;starPlusData_PicVsRestAvgValues];
% 
% load 'starPlusData_PicVsRestAvgValues_3';
% starPlusData_GeneralizedPicVsRestAllRois=[starPlusData_GeneralizedPicVsRestAllRois;starPlusData_PicVsRestAvgValues];
% 
% load 'starPlusData_PicVsRestAvgValues_5';
% starPlusData_GeneralizedPicVsRestAllRois=[starPlusData_GeneralizedPicVsRestAllRois;starPlusData_PicVsRestAvgValues];
% 
% load 'starPlusData_PicVsRestAvgValues_6';
% starPlusData_GeneralizedPicVsRestAllRois=[starPlusData_GeneralizedPicVsRestAllRois;starPlusData_PicVsRestAvgValues];
% 
% load 'labels_PicVsRestAvgValues_1';
% labels_GeneralizedPicVsRestAllRois=[labels_GeneralizedPicVsRestAllRois;labels_PicVsRestAvgValues];
% 
% load 'labels_PicVsRestAvgValues_2';
% labels_GeneralizedPicVsRestAllRois=[labels_GeneralizedPicVsRestAllRois;labels_PicVsRestAvgValues];
% 
% load 'labels_PicVsRestAvgValues_3';
% labels_GeneralizedPicVsRestAllRois=[labels_GeneralizedPicVsRestAllRois;labels_PicVsRestAvgValues];
% 
% load 'labels_PicVsRestAvgValues_5';
% labels_GeneralizedPicVsRestAllRois=[labels_GeneralizedPicVsRestAllRois;labels_PicVsRestAvgValues];
% 
% load 'labels_PicVsRestAvgValues_6';
% labels_GeneralizedPicVsRestAllRois=[labels_GeneralizedPicVsRestAllRois;labels_PicVsRestAvgValues];

%labels_GeneralizedPicVsRestAllRois = cellstr(num2str(labels_GeneralizedPicVsRestAllRois));
% 
% 
% %roiVoxelNumbers=size(roiVoxelsIndexes,2);

%for 2 Rois
load 'starPlusData_GeneralizedSubPicVsRest2Rois'
load 'labels_GeneralizedSubPicVsRest2Rois'

labels_GeneralizedSubPicVsRest2Rois = cellstr(num2str(labels_GeneralizedSubPicVsRest2Rois));

CorrectRate=[];                 %Correct Rate for each feature extraction level
IndexOfFeatsToRemoved=[];       %Number of Features removed in each iteration
NumberOfFeatures=[];            %keep number of features in each iteration;
timeStamp=7;                    %timestamp from which data required

starPlusData_GeneralizedSubPicVsRest2Rois=starPlusData_GeneralizedSubPicVsRest2Rois(:,[((timeStamp-1)*2)+1:end]);

%RFE algorithn
for r=1:10
    if r~=1
        starPlusData_GeneralizedSubPicVsRest2Rois(:,IndexOfFeatsToRemoved(end-((size(starPlusData_GeneralizedSubPicVsRest2Rois,2))*.1)+1:end))=[];
        %NumberOfFeatures=[NumberOfFeatures;size(starPlusData_GeneralizedPicVsRestAllRois,2)];
    end
    
    weights=[];                                     %# weigths vector for feature
    k=10;                                           %# 10 fold cross fold
    cvfolds=crossvalind('kfold',labels_GeneralizedSubPicVsRest2Rois,k);          %# get indices of 10-fold CV
    cp=classperf(labels_GeneralizedSubPicVsRest2Rois);                           %# init performance tracker
    
    for i=1:k                                       %# for each fold
        testIdx=(cvfolds==i);                       %# get indices of test instances
        trainIdx=~testIdx;                          %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(starPlusData_GeneralizedSubPicVsRest2Rois(trainIdx,:), labels_GeneralizedSubPicVsRest2Rois(trainIdx,:), 'Autoscale',true, 'kernel_function','rbf');
        
        
        %# calculate weight of each feature
        alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
        supportVectors=svmModel.SupportVectors;                       %#get supportvectors
        weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
        
        
        %# test using test instances
        pred = svmclassify(svmModel, starPlusData_GeneralizedSubPicVsRest2Rois(testIdx,:), 'Showplot',false);
        
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
        
    end
    
    meanWeigths=(abs(mean(weights)));                                       %#get Mean weigths for all cross validations
    [sortedWeights,IndexOfFeatsToRemoved]=sort(meanWeigths,'descend');      %#Sort meanWeigths and finding indexes of the features to be removed
    
    %# get accuracy
    CorrectRate=[CorrectRate;cp.CorrectRate];
end


