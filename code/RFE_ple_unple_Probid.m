clear all;
close all;

% data preparation
load 'healthy controls_subj1_ple';      %loads 10 time slices data for person 1 seeing plesant image
probidData = class_n';

load 'healthy controls_subj2_ple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 2 seeing plesant image

load 'healthy controls_subj3_ple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 3 seeing plesant image

load 'healthy controls_subj4_ple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 4 seeing plesant image

load 'healthy controls_subj5_ple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 5 seeing plesant image

load 'healthy controls_subj1_unple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 1 seeing unplesant image

load 'healthy controls_subj2_unple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 2 seeing unplesant image

load 'healthy controls_subj3_unple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 3 seeing unplesant image

load 'healthy controls_subj4_unple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 4 seeing unplesant image

load 'healthy controls_subj5_unple';
probidData = [probidData;class_n'];     %loads 10 time slices data for person 5 seeing unplesant image

% fiinal probid data is 100(10 time slices for 10 persons) by 217927(no of voxels)

classes=[-1*ones(50,1);ones(50,1)];     %assigns lable 1 for pleasant class and -1 to unpleasant class
classes = cellstr(num2str(classes));
CorrectRate=[];                                 %# Correct Rate for each feature extraction level
IndexOfFeatsToRemoved=[];


for r=1:10                              %10 feature extraction level
    
    if r~=1                             %intially will take all voxels
        probidData(:,IndexOfFeatsToRemoved(end-((size(probidData,2))*.1)+1:end))=[]; % remove 1 %irrelvant voxel
    end
    weights=[];
    
    k=10;
    cvfolds=crossvalind('kfold',classes,k);       %# get indices of 10-fold CV
    cp=classperf(classes);                        %# init performance tracker
    
    for i=1:k                                     %# for each fold
        testIdx=(cvfolds==i);                     %# get indices of test instances
        trainIdx=~testIdx;                        %# get indices training instances
        
        %# train an SVM model over training instances
        svmModel=svmtrain(probidData(trainIdx,:), classes(trainIdx,:), 'Autoscale',true, 'kernel_function','linear');
        
        
        
        SupportVectorIndices=svmModel.SupportVectorIndices;          %#get supportvectors Indices 
        alpha=svmModel.Alpha;                                        %#get alpha values for support vectors
        supportVectors=svmModel.SupportVectors;                      %#get supportvectors
        weights=[weights;(alpha)'*supportVectors];                   %#get weigths of each feature
        
        
        %# test using test instances
        pred = svmclassify(svmModel, probidData(testIdx,:), 'Showplot',false);
        
        
        %# evaluate and update performance object
        cp = classperf(cp, pred, testIdx);
        
    end
    
    
    meanWeigths=(mean(weights));                                                %#get Mean weigths for all cross validations
    [sortedWeights,IndexOfFeatsToRemoved]=sort(abs(meanWeigths),'descend');     %#Sort meanWeigths
    
    %# get accuracy
    CorrectRate=[CorrectRate;cp.CorrectRate];
    
    %# get confusion matrix
    %# columns:actual, rows:predicted, last-row: unclassified instances
    %disp(cp.CountingMatrix);
    
end


finalNoOfFeatures=size(probidData,2);            %final number of features after 10 feature extraction levels.