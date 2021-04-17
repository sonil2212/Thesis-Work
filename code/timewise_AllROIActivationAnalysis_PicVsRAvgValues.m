clear all;
close all;

finalCorrectRate=[];
VoxelsInRoisActivated=[];

for i=0:15                                                           %for 16 timestamps
    
    load 'starPlusData_PicVsRestAvgValues_6';
    load 'labels_PicVsRestAvgValues_6';
    load 'roiVoxelsIndexes_6';
    load 'totalVoxelNumbers_6'
    load 'AllRoisVoxelSize_6'
    load 'AllRoisVoxelIndexes_6'
    
    labels_PicVsRestAvgValues = cellstr(num2str(labels_PicVsRestAvgValues));
    
    totalRoiIndexes=[1:25];
    starPlusData_PicVsRestAvgValues=starPlusData_PicVsRestAvgValues(:,[(i*25)+1:(i*25)+(25)]);
    
    %represent data as a structute
    field1='totalRoiIndexes';
    value1=totalRoiIndexes;
    field2='starPlusData_PicVsRestAvgValues';
    value2=starPlusData_PicVsRestAvgValues;
    
    
     
    structStarPlusData=struct(field1,value1,field2,value2);
    
    CorrectRate=[];                 %Correct Rate for each feature extraction level
    IndexToRemoved=[];              %Number of Features removed in each iteration
    NumberOfFeatures=[];            %keep number of features in each iteration;
    IndexToKeep=totalRoiIndexes;  %Number of Features removed in each iteration
    VoxelsInRoisActivatedTemp=[];   
    starPlusData_PicVsRestTemp=starPlusData_PicVsRestAvgValues;       %initilization
    
    %RFE algorithn
    for r=1:10
        
        weights=[];                                                 %# weigths vector for feature
        VoxelsIndexesWithWeights=[];
        k=10;                                                       %# 10 fold cross fold
        cvfolds=crossvalind('kfold',labels_PicVsRestAvgValues,k);            %# get indices of 10-fold CV
        cp=classperf(labels_PicVsRestAvgValues);                             %# init performance tracker
 
        for j=1:k                                       %# for each fold
            testIdx=(cvfolds==j);                       %# get indices of test instances
            trainIdx=~testIdx;                          %# get indices training instances
            
            %# train an SVM model over training instances
            svmModel=svmtrain(structStarPlusData.starPlusData_PicVsRestAvgValues(trainIdx,:), labels_PicVsRestAvgValues(trainIdx,:), 'Autoscale',true,...
                'kernel_function','linear');
            
            
            %# calculate weight of each feature
            SupportVectorIndices=svmModel.SupportVectorIndices;
            alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
            supportVectors=svmModel.SupportVectors;                       %#get supportvectors
            weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
            
            
            %# test using test instances
            pred = svmclassify(svmModel, structStarPlusData.starPlusData_PicVsRestAvgValues(testIdx,:), 'Showplot',false);
            
            
            %# evaluate and update performance object
            cp = classperf(cp, pred, testIdx);
            
        end
        
        meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations
        VoxelsIndexesWithWeights=[IndexToKeep;meanWeigths];
        
        %sort based of voxel weigths
        [sortedWeights,Indexes]=sort(VoxelsIndexesWithWeights(2,:),'descend');
        VoxelsIndexesWithWeights=VoxelsIndexesWithWeights(:,Indexes);
        
        IndexToRemoved=[IndexToRemoved VoxelsIndexesWithWeights(1,end-((size(VoxelsIndexesWithWeights,2))*.1)+1:end)]; %find indexes of irrrevalant voxels;
        
        IndexToKeep=totalRoiIndexes;
        IndexToKeep=setdiff(IndexToKeep,IndexToRemoved);                             %find relevent voxel indexes.
        
        
        [commonValues IdxtotalRoiIndexes IdxIndexToKeep]=intersect(totalRoiIndexes,IndexToKeep);
        starPlusData_PicVsRestTemp=starPlusData_PicVsRestAvgValues(:,IdxtotalRoiIndexes);
        
        structStarPlusData.totalRoiIndexes=IndexToKeep;
        structStarPlusData.starPlusData_PicVsRestAvgValues=starPlusData_PicVsRestTemp;
        
        %# get accuracy
        CorrectRate=[CorrectRate;cp.CorrectRate];
    end
    
    finalCorrectRate=[finalCorrectRate CorrectRate];               %correct rate for all iteration
    
    %out of import voxels find mapping in different ROIs
    left=1;
    right=AllRoisVoxelSize(1);
    VoxelsInRoisActivatedTemp=size(intersect(IndexToKeep,AllRoisVoxelIndexes(left:right)),2)/size(IndexToKeep,2)*100;
    
    for l=2:25
        left=right+1;
        right=left+AllRoisVoxelSize(l)-1;
        VoxelsInRoisActivatedTemp=[VoxelsInRoisActivatedTemp size(intersect(IndexToKeep,AllRoisVoxelIndexes(left:right)),2)/size(IndexToKeep,2)*100];
    end
    
    VoxelsInRoisActivated=[VoxelsInRoisActivated;VoxelsInRoisActivatedTemp];
end

VoxelsInRoisActivated=VoxelsInRoisActivated';