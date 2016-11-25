clear all;
close all;

load 'starPlusDataAvgValues';
load 'labelsAvgValues';

labelsAvgValues = cellstr(num2str(labelsAvgValues));
timeStamp=7;

starPlusDataAvgValues=starPlusDataAvgValues(:,((timeStamp-1)*7)+1:end);

totalRoiIndexesAvg=[43:112];

%represent data as a structute
field1='totalRoiIndexesAvg';
value1=totalRoiIndexesAvg;
field2='starPlusDataAvgValues';
value2=starPlusDataAvgValues;

structStarPlusData=struct(field1,value1,field2,value2);

CorrectRate=[];                 %Correct Rate for each feature extraction level
IndexToRemoved=[];              %Number of Features removed in each iteration
NumberOfFeatures=[];            %keep number of features in each iteration;
IndexToKeep=totalRoiIndexesAvg;  %Number of Features removed in each iteration
VoxelsInRoisActivatedTemp=[];
starPlusDataAvgValues=starPlusDataAvgValues;       %initilization

%RFE algorithn
for r=1:13
    
    weights=[];                                                 %# weigths vector for feature
    VoxelsIndexesWithWeights=[];
    k=10;                                                       %# 10 fold cross fold
    cvfolds=crossvalind('kfold',labelsAvgValues,k);            %# get indices of 10-fold CV
    cp=classperf(labelsAvgValues);                             %# init performance tracker
    
    for j=1:k                                       %# for each fold
        testIdx=(cvfolds==j);                       %# get indices of test instances
        trainIdx=~testIdx;                          %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(structStarPlusData.starPlusDataAvgValues(trainIdx,:), labelsAvgValues(trainIdx,:), 'Autoscale',true,...
            'kernel_function','rbf');
        
        
        %# calculate weight of each feature
        SupportVectorIndices=svmModel.SupportVectorIndices;
        alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
        supportVectors=svmModel.SupportVectors;                       %#get supportvectors
        weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
        
        
        %# test using test instances
        pred = svmclassify(svmModel, structStarPlusData.starPlusDataAvgValues(testIdx,:), 'Showplot',false);
        
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
        
    end
    
    meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations
    VoxelsIndexesWithWeights=[IndexToKeep;meanWeigths];
    
    %sort based of voxel weigths
    [sortedWeights,Indexes]=sort(VoxelsIndexesWithWeights(2,:),'descend');
    VoxelsIndexesWithWeights=VoxelsIndexesWithWeights(:,Indexes);
    
    IndexToRemoved=[IndexToRemoved VoxelsIndexesWithWeights(1,end-((size(VoxelsIndexesWithWeights,2))*.15)+1:end)]; %find indexes of irrrevalant voxels;
    
    IndexToKeep=totalRoiIndexesAvg;
    IndexToKeep=setdiff(IndexToKeep,IndexToRemoved);                             %find relevent voxel indexes.
    
    
    [commonValues IdxtotalRoiIndexesAvg IdxIndexToKeep]=intersect(totalRoiIndexesAvg,IndexToKeep);
    starPlusDataAvgValuesTemp=starPlusDataAvgValues(:,IdxtotalRoiIndexesAvg);
    
    structStarPlusData.totalRoiIndexesAvg=IndexToKeep;
    structStarPlusData.starPlusDataAvgValues=starPlusDataAvgValuesTemp;
    
    %# get accuracy
    CorrectRate=[CorrectRate;cp.CorrectRate];
end


IndexesInCalc=[43,50,57,64,71,78,85,92,99,106];
IndexesInLips=IndexesInCalc+1;
IndexesInLipl=IndexesInCalc+5;

ImportantVoxelInPercantage=[size(intersect(IndexToKeep,IndexesInCalc),2)/size(IndexToKeep,2)*100....
    size(intersect(IndexToKeep,IndexesInLips),2)/size(IndexToKeep,2)*100 ...
    size(intersect(IndexToKeep,IndexesInLipl),2)/size(IndexToKeep,2)*100];
