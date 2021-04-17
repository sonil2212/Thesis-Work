%clear all;
close all;

% data preparation
    
    load '5';                         %load data for sub1
    TrailsToRemoved=[];             %contains unwanted trails
    PicFirstStimulus=[];            %trails in which picture was first stimulus
    SenFirstStimulus=[];            %trails in which Sentence was first stimulus
    roisNumber=[1,2,5,6,8,12,13];   %find voxel numbers of ROIs {'CALC' 'LIPL' 'LT' 'LTRIA' 'LOPER' 'LIPS' 'LDLPFC'};
    starPlusData=[];                %contain final starplus data
    labels=[];                      %label 1 for picture(task1) ,-1 for sentence(task2)
    roiVoxelsIndexes=[];            %voxel indexex for 6 ROIs
    
    columnsInROI_CALC=meta.rois(1,1).columns;
    columnsInROI_LIPL=meta.rois(1,2).columns;
    columnsInROI_LT=meta.rois(1,5).columns;
    columnsInROI_LTRIA=meta.rois(1,6).columns;
    columnsInROI_LOPER=meta.rois(1,8).columns;
    columnsInROI_LIPS=meta.rois(1,12).columns;
    columnsInROI_LDLPFC=meta.rois(1,13).columns;
    
    %find voxels of ROIs
    for idx = 1:numel(roisNumber)
        element = roisNumber(idx);
        roiVoxelsIndexes=[roiVoxelsIndexes meta.rois(1,element).columns];
    end
    
    % remove trails of Rest states
    for i=1:54
        if info(1,i).cond==0 || info(1,i).cond==1
            TrailsToRemoved=[TrailsToRemoved;i];
        end
    end
    
    data(TrailsToRemoved,:)=[];
    info(TrailsToRemoved)=[];
    
    
    %find trails having picture as first stimulus
    for i=1:40
        if info(1, i).firstStimulus=='P'
            PicFirstStimulus=[PicFirstStimulus;i];
        end
    end
    
    
    %find trails having Sentence as first stimulus
    for i=1:40
        if info(1, i).firstStimulus=='S'
            SenFirstStimulus=[SenFirstStimulus;i];
        end
    end
    
    %preparing data
    for idx = 1:numel(PicFirstStimulus)
        trailNumber = PicFirstStimulus(idx);
        tempData=[];
        
        for i=1:16
            tempData =[tempData mean(data{trailNumber,1}(i,columnsInROI_CALC)) mean(data{trailNumber,1}(i,columnsInROI_LIPL)) ...
                mean(data{trailNumber,1}(i,columnsInROI_LIPS))];
        end
        
        starPlusData=[starPlusData;tempData];
        labels=[labels;1];
        
        tempData=[];
        for i=17:32
            tempData =[tempData mean(data{trailNumber,1}(i,columnsInROI_CALC)) mean(data{trailNumber,1}(i,columnsInROI_LIPL)) ...
                mean(data{trailNumber,1}(i,columnsInROI_LIPS))];
        end
        
        starPlusData=[starPlusData;tempData];
        labels=[labels;-1];
    end
    
    %for Sentence First stimulus
    for idx = 1:numel(SenFirstStimulus)
        trailNumber = SenFirstStimulus(idx);
        tempData=[];
        
        for i=1:16
            tempData =[tempData mean(data{trailNumber,1}(i,columnsInROI_CALC)) mean(data{trailNumber,1}(i,columnsInROI_LIPL)) ...
                mean(data{trailNumber,1}(i,columnsInROI_LIPS))];
        end
        
        starPlusData=[starPlusData;tempData];
        labels=[labels;-1];
        
        tempData=[];
        for i=17:32
            tempData =[tempData mean(data{trailNumber,1}(i,columnsInROI_CALC)) mean(data{trailNumber,1}(i,columnsInROI_LIPL)) ...
                mean(data{trailNumber,1}(i,columnsInROI_LIPS))];
        end
        
        starPlusData=[starPlusData;tempData];
        labels=[labels;1];
        
    end
    
