clear all;
close all;

load 'starPlusData_OnlyPic_1';
load 'roiVoxelsIndexes_1'

roiVoxelsNumbers=size(roiVoxelsIndexes,2);

starPlusDataTemp1=starPlusData_OnlyPic([1:20],[(14*roiVoxelsNumbers)+1:(14*roiVoxelsNumbers)+(roiVoxelsNumbers)]);   %8th timestamp data
starPlusDataTemp2=starPlusData_OnlyPic([21:40],[(16 *roiVoxelsNumbers)+1:(16*roiVoxelsNumbers)+(roiVoxelsNumbers)]);   %9th timestamp data

starPlusDataWorking=[starPlusDataTemp1;starPlusDataTemp1];

labels=[ones(20,1);-1*ones(20,1)];
labels = cellstr(num2str(labels));

CorrectRate=[];                 %Correct Rate for each feature extraction level
IndexToKeep=[1:1874];  %Number of Features removed in each iteration

weights=[];                                                 %# weigths vector for feature
VoxelsIndexesWithWeights=[];
k=10;                                                       %# 10 fold cross fold
cvfolds=crossvalind('kfold',labels,k);            %# get indices of 10-fold CV
cp=classperf(labels);                             %# init performance tracker

for j=1:k                                       %# for each fold
    testIdx=(cvfolds==j);                       %# get indices of test instances
    trainIdx=~testIdx;                          %# get indices training instances
    
    %# train an SVM model over training instances
    svmModel=svmtrain(starPlusDataWorking(trainIdx,:), labels(trainIdx,:), 'Autoscale',true, 'kernel_function','rbf');
    
    %# calculate weight of each feature
    SupportVectorIndices=svmModel.SupportVectorIndices;
    alpha=svmModel.Alpha;                                         %#multiply label with corresponding alpha value
    supportVectors=svmModel.SupportVectors;                       %#get supportvectors
    weights=[weights;(alpha)'*supportVectors];                    %#get weigths of each feature
    
    %# test using test instances
    pred = svmclassify(svmModel, starPlusDataWorking(testIdx,:), 'Showplot',false);
    
    %# evaluate and update performance object
    cp = classperf(cp, pred, testIdx);
end

meanWeigths=(mean(abs(weights)));                                      %#get Mean weigths for all cross validations
VoxelsIndexesWithWeights=[IndexToKeep;meanWeigths];

%sort based of voxel weigths
[sortedWeights,Indexes]=sort(VoxelsIndexesWithWeights(2,:),'ascend');
VoxelsIndexesWithWeights=VoxelsIndexesWithWeights(:,Indexes);

IndexToKeep=[VoxelsIndexesWithWeights(1,end-((size(VoxelsIndexesWithWeights,2))*.01)+1:end)]; %find indexes of irrrevalant voxels;

%# get accuracy
cp.correctRate

