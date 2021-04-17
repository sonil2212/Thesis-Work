clear all;
close all;

CorrectRate=[];                                 %Correct Rate for each feature extraction level

for i=0:15                                                           %for 16 timestamps
    
    load 'starPlusData_1';
    load 'labels_1';
    load 'roiVoxelsIndexes_1';
    load 'columnsInROI_CALC_1'
    load 'columnsInROI_LIPL_1'
    load 'columnsInROI_LT_1'
    load 'columnsInROI_LTRIA_1'
    load 'columnsInROI_LOPER_1'
    load 'columnsInROI_LIPS_1'
    load 'columnsInROI_LDLPFC_1'
    
    labels = cellstr(num2str(labels));
    roiVoxelNumbers=size(roiVoxelsIndexes,2);

    starPlusData=starPlusData(:,[(i*roiVoxelNumbers)+1:(i*roiVoxelNumbers)+(roiVoxelNumbers)]);
    
    %select columns for given ROI
    [commonValues IdxcolumnsInROI_CALC_LIPL IdxRoiVoxelsIndexes]=intersect([columnsInROI_CALC columnsInROI_LIPL] ,roiVoxelsIndexes);
    starPlusData=starPlusData(:,IdxcolumnsInROI_CALC_LIPL);

    k=10;                                           %# 10 fold cross fold
    cvfolds=crossvalind('kfold',labels,k);          %# get indices of 10-fold CV
    cp=classperf(labels);                           %# init performance tracker
    
    for j=1:k                                       %# for each fold
        testIdx=(cvfolds==j);                     %# get indices of test instances
        trainIdx=~testIdx;                        %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(starPlusData(trainIdx,:), labels(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');
         
        %# test using test instances
        pred = svmclassify(svmModel, starPlusData(testIdx,:), 'Showplot',false);
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
    end
    
    %# get accuracy
    CorrectRate=[CorrectRate cp.CorrectRate];
end

