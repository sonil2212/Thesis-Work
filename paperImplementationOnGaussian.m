clear all;
close all;


% Gaussian mean and covariance
d = 10;             % number of dimensions
mu1 = rand(1,d);
sigma = rand(d,d); sigma = sigma*sigma';

% generate 100 samples from above distribution
num = 500   ;
sampleData = mvnrnd(mu1, sigma, num);

mu2 = [(mu1(:,1:5)+5),mu1(:,6:end)];
sampleData = [sampleData;mvnrnd(mu2, sigma, num)];


lables=[-1*ones(500,1);ones(500,1)];


k=10;
featureIndices=(1:size(sampleData,2));
accuracy=[];                             %# accuracy in each feature extraction level    
 
%for r=1:10
   cvfolds=crossvalind('kfold',lables,k);   %# get indices of 10-fold CV
   cp=classperf(lables);                    %# init performance tracker
   
   
   
   %for i=1:k                                %# for each fold
      testIdx=(cvfolds==1);                 %# get indices of test instances
      trainIdx=~testIdx;                    %# get indices training instances
      weights=[];                           %# contains avg weigths of each of the vector    
   
      k = find(trainIdx);                    %# finding indeices of traing data                
      
      trainingsubData=reshape(k,9,100);       %#creates non overlapping subsets of training data 
      
      for subsetIndex=1:9
         %# train an SVM model over training instances  
         svmModel=svmtrain(sampleData(trainingsubData(subsetIndex,:),featureIndices), lables(trainingsubData(subsetIndex,:)), 'Autoscale',true, 'Showplot',false);
         
         %# calculate weight of each feature
         sampleDataIndex=trainingsubData(subsetIndex,:);                                        %#finding index of support vectors in sample data                         
         yn=lables(sampleDataIndex([svmModel.SupportVectorIndices]));                           %#get corresponding label of supportvectors
         %temp=svmModel.Alpha.*yn;                                                               %#multiply label with corresponding alpha value                             
         supportVectors=svmModel.SupportVectors;                                                %#get supportvectors
         weights=[weights;(svmModel.Alpha.*yn)'*supportVectors];                                                %#get weigths of each feature 
      
      end
      
      avgWeight=(mean(weights));              %#average weigths for all subsets of training data         
      b=(1./yn)-(avgWeight*supportVectors')';
      
      %# test using test instances
      pred = svmclassify(svmModel, sampleData(testIdx,featureIndices), 'Showplot',false);
      
   %end
   
%end   