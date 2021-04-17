clear all;
close all;

finalCorrectRate=[];
VoxelsInRoisActivated=[];

for i=0:15                                                           %for 16 timestamps
    
    load 'starPlusData_PicVsRest_5';
    load 'labels_PicVsRest_5';
    load 'roiVoxelsIndexes_5';
    load 'totalVoxelNumbers_5'
    load 'AllRoisVoxelSize_5'
    load 'AllRoisVoxelIndexes_5'
    
    labels_PicVsRest = cellstr(num2str(labels_PicVsRest));
    
    totalVoxelIndexes=[1:totalVoxelNumbers];
    starPlusData_PicVsRest=starPlusData_PicVsRest(:,[(i*totalVoxelNumbers)+1:(i*totalVoxelNumbers)+(totalVoxelNumbers)]);
    
    %represent data as a structute
    field1='totalVoxelIndexes';
    value1=totalVoxelIndexes;
    field2='starPlusData_PicVsRest';
    value2=starPlusData_PicVsRest;
    
    
     
    structStarPlusData=struct(field1,value1,field2,value2);
    
    CorrectRate=[];                 %Correct Rate for each feature extraction level
    IndexToRemoved=[];              %Number of Features removed in each iteration
    NumberOfFeatures=[];            %keep number of features in each iteration;
    IndexToKeep=totalVoxelIndexes;  %Number of Features removed in each iteration
    VoxelsInRoisActivatedTemp=[];   
    starPlusData_PicVsRestTemp=starPlusData_PicVsRest;       %initilization
    
    %RFE algorithn
    for r=1:20
        
        weights=[];                                                 %# weigths vector for feature
        VoxelsIndexesWithWeights=[];
        k=10;                                                       %# 10 fold cross fold
        cvfolds=crossvalind('kfold',labels_PicVsRest,k);            %# get indices of 10-fold CV
        cp=classperf(labels_PicVsRest);                             %# init performance tracker
 
        for j=1:k                                       %# for each fold
            testIdx=(cvfolds==j);                       %# get indices of test instances
            trainIdx=~testIdx;                          %# get indices training instances
            
            %# train an SVM model over training instances
            svmModel=svmtrain(structStarPlusData.starPlusData_PicVsRest(trainIdx,:), labels_PicVsRest(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');
            
            
            %# calculate weight of each feature
            SupportVectorIndices=svmModel.SupportVectorIndices;
            alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
            supportVectors=svmModel.SupportVectors;                       %#get supportvectors
            weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
            
            
            %# test using test instances
            pred = svmclassify(svmModel, structStarPlusData.starPlusData_PicVsRest(testIdx,:), 'Showplot',false);
            
            
            %# evaluate and update performance object
            cp = classperf(cp, pred, testIdx);
            
        end
        
        meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations
        VoxelsIndexesWithWeights=[IndexToKeep;meanWeigths];
        
        %sort based of voxel weigths
        [sortedWeights,Indexes]=sort(VoxelsIndexesWithWeights(2,:),'descend');
        VoxelsIndexesWithWeights=VoxelsIndexesWithWeights(:,Indexes);
        
        IndexToRemoved=[IndexToRemoved VoxelsIndexesWithWeights(1,end-((size(VoxelsIndexesWithWeights,2))*.2)+1:end)]; %find indexes of irrrevalant voxels;
        
        IndexToKeep=totalVoxelIndexes;
        IndexToKeep=setdiff(IndexToKeep,IndexToRemoved);                             %find relevent voxel indexes.
        
        
        [commonValues IdxtotalVoxelIndexes IdxIndexToKeep]=intersect(totalVoxelIndexes,IndexToKeep);
        starPlusData_PicVsRestTemp=starPlusData_PicVsRest(:,IdxtotalVoxelIndexes);
        
        structStarPlusData.totalVoxelIndexes=IndexToKeep;
        structStarPlusData.starPlusData_PicVsRest=starPlusData_PicVsRestTemp;
        
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