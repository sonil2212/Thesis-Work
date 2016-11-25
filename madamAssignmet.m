clear all;
close all;

% % #preparing data and labels
% numSamples = 1000;
% mu = 9;
% sigma = 2;
% samples1 = mu + sigma.*randn(numSamples, 1);    %1st data set
% 
% mu = 10;
% sigma = 2   ;
% samples2 = mu + sigma.*randn(numSamples, 1);    %2nd data set
% 
% samples=[samples1;samples2];                    % generate training data
% labels=[0.*ones(1000,1);ones(1000,1)];         % label -1 and 1 for two different classes.


% Gaussian mean and covariance
d = 10;             % number of dimensions
mu1 = rand(1,d);
sigma = rand(d,d); sigma = sigma*sigma';

% generate 100 samples from above distribution
num = 50;
samples = mvnrnd(mu1, sigma, num);

mu2 = [(mu1(:,1:5)+5),mu1(:,6:end)];
samples = [samples;mvnrnd(mu2, sigma, num)];


labels=[zeros(50,1);ones(50,1)];


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