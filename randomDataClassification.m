clear all;
close all;

% #preparing data and labels
numSamples = 1000;
mu = 2;
sigma = 4;
samples1 = mu + sigma.*randn(numSamples, 1);    %1st data set

mu = 1;
sigma = 7;
samples2 = mu + sigma.*randn(numSamples, 1);    %2nd data set

samples=[samples1;samples2];                    % generate training data
labels=[0.*ones(1000,1);ones(1000,1)];         % label -1 and 1 for two different classes.

k=10;
cvfolds=crossvalind('kfold',labels,k);          %# get indices of 8-fold CV
cp=classperf(labels);                           %# init performance tracker
   
for i=1:k                                       %# for each fold
      testIdx=(cvfolds==i);                     %# get indices of test instances
      trainIdx=~testIdx;                        %# get indices training instances
        
      %# train an SVM model over training instances  
      svmModel=svmtrain(samples(trainIdx), labels(trainIdx), 'Autoscale',true, 'Showplot',false);
      
      %# test using test instances
      pred = svmclassify(svmModel, samples(testIdx), 'Showplot',false);
      
      
      %# evaluate and update performance object
      cp = classperf(cp, pred, testIdx);
      
end

%# get accuracy 
   disp(cp.CorrectRate);

%# get confusion matrix
%# columns:actual, rows:predicted, last-row: unclassified instances
   disp(cp.CountingMatrix);