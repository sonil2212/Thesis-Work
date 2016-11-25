clear all;
close all;

finalCorrectRate=[];
VoxelsInRoisActivated=[];

for i=0:15                                                           %for 16 timestamps
    
    load 'starPlusData_6';
    load 'labels_6';
    load 'roiVoxelsIndexes_6';
    load 'columnsInROI_CALC_6'
    load 'columnsInROI_LIPL_6'
    load 'columnsInROI_LT_6'
    load 'columnsInROI_LTRIA_6'
    load 'columnsInROI_LOPER_6'
    load 'columnsInROI_LIPS_6'
    load 'columnsInROI_LDLPFC_6'
    
    labels = cellstr(num2str(labels));
    roiVoxelNumbers=size(roiVoxelsIndexes,2);
    
    starPlusData=starPlusData(:,[(i*roiVoxelNumbers)+1:(i*roiVoxelNumbers)+(roiVoxelNumbers)]);
    
    %represent data as a structute
    field1='roiVoxelsIndexes';
    value1=roiVoxelsIndexes;
    field2='starPlusData';
    value2=starPlusData;
    
    structStarPlusData=struct(field1,value1,field2,value2);
    
    CorrectRate=[];                 %Cor    rect Rate for each feature extraction level
    IndexToRemoved=[];       %Number of Features removed in each iteration
    NumberOfFeatures=[];             %keep number of features in each iteration;
    %roiVoxelsIndexes=[columnsInROI_CALC columnsInROI_LIPL columnsInROI_LT columnsInROI_LTRIA columnsInROI_LOPER columnsInROI_LIPS columnsInROI_LDLPFC];      %total no of voxels
    IndexToKeep=roiVoxelsIndexes;              %Number of Features removed in each iteration
    
    starPlusDataTemp=starPlusData;       %initilization
    
    %RFE algorithn
    for r=1:10
        %
        weights=[];                                     %# weigths vector for feature
        k=10;                                           %# 10 fold cross fold
        cvfolds=crossvalind('kfold',labels,k);          %# get indices of 10-fold CV
        cp=classperf(labels);                           %# init performance tracker
        VoxelsIndexesWithWeights=[];
        
        
        for i=1:k                                       %# for each fold
            testIdx=(cvfolds==i);                     %# get indices of test instances
            trainIdx=~testIdx;                        %# get indices training instances
            
            %# train an SVM model over training instances
            svmModel=svmtrain(structStarPlusData.starPlusData(trainIdx,:), labels(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');
            
            
            %# calculate weight of each feature
            SupportVectorIndices=svmModel.SupportVectorIndices;
            alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
            supportVectors=svmModel.SupportVectors;                       %#get supportvectors
            weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
            
            
            %# test using test instances
            pred = svmclassify(svmModel, structStarPlusData.starPlusData(testIdx,:), 'Showplot',false);
            
            
            %# evaluate and update performance object
            cp = classperf(cp, pred, testIdx);
            
        end
        
        meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations
        VoxelsIndexesWithWeights=[IndexToKeep;meanWeigths];
        
        %sort based of voxel weigths
        [sortedWeights,Indexes]=sort(VoxelsIndexesWithWeights(2,:),'descend');
        VoxelsIndexesWithWeights=VoxelsIndexesWithWeights(:,Indexes);
        
        IndexToRemoved=[IndexToRemoved VoxelsIndexesWithWeights(1,end-((size(VoxelsIndexesWithWeights,2))*.1)+1:end)]; %find indexes of irrrevalant voxels;
        
        IndexToKeep=roiVoxelsIndexes;
        IndexToKeep=setdiff(IndexToKeep,IndexToRemoved);                             %find relevent voxel indexes.
        %sort(IndexToKeep,'ascend');
        
        %starPlusDataTemp=starPlusData(:,IndexToKeep);
        
        
        [commonValues IdxRoiVoxelsIndexes IdxIndexToKeep]=intersect(roiVoxelsIndexes,IndexToKeep);
        starPlusDataTemp=starPlusData(:,IdxRoiVoxelsIndexes);
        
        structStarPlusData.roiVoxelsIndexes=IndexToKeep;
        structStarPlusData.starPlusData=starPlusDataTemp;
        
        %# get accuracy
        CorrectRate=[CorrectRate;cp.CorrectRate];
    end
    
    finalCorrectRate=[finalCorrectRate CorrectRate];               %correct rate for all iteration
    VoxelsInRoisActivated=[VoxelsInRoisActivated;size(intersect(IndexToKeep,columnsInROI_CALC),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LIPL),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LT),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LTRIA),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LOPER),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LIPS),2)/size(IndexToKeep,2)*100 size(intersect(IndexToKeep,columnsInROI_LDLPFC),2)/size(IndexToKeep,2)*100];
end

VoxelsInRoisActivated=VoxelsInRoisActivated';