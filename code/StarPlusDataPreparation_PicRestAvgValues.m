%clear all;
close all;

% data preparation


load 6;                         %load data for sub1
TrailsToRemoved=[];             %contains unwanted trails
PicFirstStimulus=[];            %trails in which picture was first stimulus
SenFirstStimulus=[];            %trails in which Sentence was first stimulus
starPlusData_GeneralizedPicVsRest2Rois=[];                %ontain final starplus data
labels_GeneralizedPicVsRest2Rois=[];                      %label 1 for picture(task1) ,-1 for sentence(task2)
restTrails=[];
totalVoxelNumbers=size(data{1, 1},2);     %contain total number of voxels
AllRoisVoxelIndexes=[];         %contain all voxel indexes from ROI 1 to 25
AllRoisVoxelSize=[];            %contain number of voxels in each region from ROI 1 to 25


for i=1:25
    AllRoisVoxelIndexes=[AllRoisVoxelIndexes meta.rois(1, i).columns];
    AllRoisVoxelSize=[AllRoisVoxelSize size(meta.rois(1, i).columns,2)];
    
end

% remove unwanted trails
for i=1:54
    if info(1,i).cond==0
        TrailsToRemoved=[TrailsToRemoved;i];
    end
end

data(TrailsToRemoved,:)=[];
info(TrailsToRemoved)=[];

for i=1:50
    if info(1,i).cond==1
        restTrails=[restTrails;i];
    end
end

%find trails having picture as first stimulus
for i=1:50
    if info(1, i).firstStimulus=='P' && info(1, i).cond~=1
        PicFirstStimulus=[PicFirstStimulus;i];
    end
end


%find trails having Sentence as first stimulus
for i=1:50
    if info(1, i).firstStimulus=='S'&& info(1, i).cond~=1
        SenFirstStimulus=[SenFirstStimulus;i];
    end
end

%preparing data
for idx = 1:numel(PicFirstStimulus)
    trailNumber = PicFirstStimulus(idx);
    
    tempData=[];
    for i=1:16                                  %for each timestamp
        for j=1:25                              %for each ROI
            if(j==1 || j==2 || j=5 || j=6 || j=7 || j=8 || j=12 || j=13 || j=14)
                tempData =[tempData mean(data{trailNumber,1}(i,meta.rois(1,j).columns))];
            end
        end
    end
    
    starPlusData_GeneralizedPicVsRest2Rois=[starPlusData_GeneralizedPicVsRest2Rois;tempData];
    labels_GeneralizedPicVsRest2Rois=[labels_GeneralizedPicVsRest2Rois;1];
    
end

%for Sentence First stimulus
for idx = 1:numel(SenFirstStimulus)
    trailNumber = SenFirstStimulus(idx);
    
    tempData=[];
    for i=17:32
        for j=1:25                              %for each ROI
            if(j==1 || j==2 || j=5 || j=6 || j=7 || j=8 || j=12 || j=13 || j=14)
                tempData =[tempData mean(data{trailNumber,1}(i,meta.rois(1,j).columns))];
            end
        end
    end
    
    starPlusData_GeneralizedPicVsRest2Rois=[starPlusData_GeneralizedPicVsRest2Rois;tempData];
    labels_GeneralizedPicVsRest2Rois=[labels_GeneralizedPicVsRest2Rois;1];
    
end

%for rest trails
for trailNumber = 1:50
    if info(1,trailNumber).cond==1
        
        tempData=[];
        for i=1:16
            for j=1:25                              %for each ROI
                if(j==1 || j==2 || j=5 || j=6 || j=7 || j=8 || j=12 || j=13 || j=14)
                    tempData =[tempData mean(data{trailNumber,1}(i,meta.rois(1,j).columns))];
                end
            end
        end
        
        starPlusData_GeneralizedPicVsRest2Rois=[starPlusData_GeneralizedPicVsRest2Rois;tempData];
        labels_GeneralizedPicVsRest2Rois=[labels_GeneralizedPicVsRest2Rois;-1];
        
        tempData=[];
        for i=17:32
            for j=1:25                              %for each ROI
                if(j==1 || j==2 || j=5 || j=6 || j=7 || j=8 || j=12 || j=13 || j=14)
                    tempData =[tempData mean(data{trailNumber,1}(i,meta.rois(1,j).columns))];
                end
            end
        end
        
        starPlusData_GeneralizedPicVsRest2Rois=[starPlusData_GeneralizedPicVsRest2Rois;tempData];
        labels_GeneralizedPicVsRest2Rois=[labels_GeneralizedPicVsRest2Rois;-1];
        
        tempData=[];
        for i=33:48
            for j=1:25                              %for each ROI
                if(j==1 || j==2 || j=5 || j=6 || j=7 || j=8 || j=12 || j=13 || j=14)
                    tempData =[tempData mean(data{trailNumber,1}(i,meta.rois(1,j).columns))];
                end
            end
        end
        
        starPlusData_GeneralizedPicVsRest2Rois=[starPlusData_GeneralizedPicVsRest2Rois;tempData];
        labels_GeneralizedPicVsRest2Rois=[labels_GeneralizedPicVsRest2Rois;-1];
        
    end
    
end

