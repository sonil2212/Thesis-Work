# Thesis
## Objective :

- Analyze part of the brain responsible for performaing a specific task.
- Analyze brain activation time while performing a specific task.

## Data 
- Starplus Data : FMRI images of 5 persons seeing the picture and sentence.
- Probid Data : FMRI images of 5 persons seeing plesant , unpleasant and neutral images (ie while seeing a beautiful scenery or seeing a wound )
- Further data is processed in tabular format where each row present a task while column represnts a feature, called voxel.
- Starplus and probid data contains 4500 and 219727 voxels respectively.
 

## Algorithms and Language
- Multivariate feature extraction algorithm RFE (recursive feature elimination) along with SVM classifier is used to remove irrelavant features.
- Matlab is used for writing code and plotting the results.

## Results and findings
- As irrelevant features are eliminated, classification accuracy is increased.
- ROIs (Regions of Interest) are narrowed down to 3 from 7, which contains 70% of the discriminating voxels. The regions are (CALC, LIPS, LIPL).
- Reverse RFE implementation (ie removing relavant features) resulted in decreased classification accuracy. 

## Conclusion 
Machine learning algorithm can be successfully utilized for fMR data analysis.

## Other Details 
Supervised by : Prof Neelam Sinha (https://www.iiitb.ac.in/faculty/neelam-sinha)

