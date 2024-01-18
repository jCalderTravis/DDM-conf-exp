function convertToStandardFormat(directory)
% Takes the file directory/collatedData.mat produced by 'collateAllData' and 
% converts the way the data is stored to a standard data format. Saves as 
% directory/_standardFormatData.mat

% All time measurements are converted to and stored in seconds

DSet.Spec.DotsSd = 220;

loadedFile = load([directory '\collatedData.mat']);
oldData = loadedFile.Data;


DSet.Spec.TimeUnit = 1;
DSet.Spec.Fps = 20;
DSet.Spec.CenterPoint = 0;


for iPtpnt = 1 : length(oldData)
    
    DSet.P(iPtpnt).Data.Block = oldData(iPtpnt).BlockNum;
    
    
    DSet.P(iPtpnt).Data.BlockType = oldData(iPtpnt).BlockType;
    
    
    DSet.P(iPtpnt).Data.IsForcedResp = NaN(length(DSet.P(iPtpnt).Data.BlockType), 1);
    
    for blockType = unique(DSet.P(iPtpnt).Data.BlockType)'
        
        blockLabelToIsForcedMapping = {false, true};
        
        
        DSet.P(iPtpnt).Data.IsForcedResp( ...
            DSet.P(iPtpnt).Data.BlockType == blockType) = ...
            blockLabelToIsForcedMapping{blockType};
        
        
    end
    
    
    DSet.P(iPtpnt).Data.StimLoc = oldData(iPtpnt).StimLoc;
    
    
    DSet.P(iPtpnt).Data.Ref = oldData(iPtpnt).RefVal;
    
    
    DSet.P(iPtpnt).Data.Diff = oldData(iPtpnt).Diff;
    
    
    DSet.P(iPtpnt).Data.RefReassigns = oldData(iPtpnt).RefReassigns;
    
    
    % Converting to seconds...
    DSet.P(iPtpnt).Data.PlannedDuration = oldData(iPtpnt).FramesToPresent ...
        * (1/DSet.Spec.Fps);
    
    
    DSet.P(iPtpnt).Data.ActualDurationPrec = oldData(iPtpnt).FramesPresented ...
        * (1/DSet.Spec.Fps);
    
    
    DSet.P(iPtpnt).Data.DurationMean = oldData(iPtpnt).MeanFrames ...
        * (1/DSet.Spec.Fps);
    
    
    DSet.P(iPtpnt).Data.DurationSd = oldData(iPtpnt).FramesSd ...
        * (1/DSet.Spec.Fps);
    
    
    DSet.P(iPtpnt).Data.DurationReassigns = oldData(iPtpnt).DurationReasigns;
    
    % The dots will take a bit more work. We want them in a trial x box x frame array, but currently
    % they are in a cell array as the number of frames is different in each trial.
    
    % Find the longest trial
    trialLength = cellfun(@length, oldData(iPtpnt).Dots);
    
    maxTrial = max(trialLength) + 15;    
    
    % Now we are going to work through all the trials putting the relevant data into a matrix of the
    % desired size (dream matrix)
    dreamMatrix = NaN(length(oldData(iPtpnt).Dots), 2, maxTrial);
    
    
    for iTrial = 1 : length(oldData(iPtpnt).Dots)
        
        dreamMatrix(iTrial, :, 1 : length(oldData(iPtpnt).Dots{iTrial})) = oldData(iPtpnt).Dots{iTrial};
        
        
    end
    
    
    DSet.P(iPtpnt).Data.Dots = dreamMatrix;
    
    
    % Also add a field containing the difference in dots between the two boxes
    DSet.P(iPtpnt).Data.DotsDiff(:, :) ...
        = DSet.P(iPtpnt).Data.Dots(:, 2, :) - DSet.P(iPtpnt).Data.Dots(:, 1, :);
    
   
    DSet.P(iPtpnt).Data.RtPrec = oldData(iPtpnt).RelativeRT;
    
    
    DSet.P(iPtpnt).Data.Resp = oldData(iPtpnt).Response;
    
    
    DSet.P(iPtpnt).Data.Acc = oldData(iPtpnt).Accuracy;
    
    
    DSet.P(iPtpnt).Data.Conf = oldData(iPtpnt).Conf;
    
    
end


% Add dot settings for simulation of similar datasets
DSet.Spec.Dots.Max = 3096;
DSet.Spec.Dots.Sd = 220;

save([directory '\_standardFormatData'], 'DSet')







