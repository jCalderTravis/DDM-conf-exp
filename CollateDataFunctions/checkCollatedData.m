function checkCollatedData(DSet, rawDataDir, numParticipants, numBlocks, ...
    trialsPerBlock, Fps)
% Checks that the collated data has some properties identical to the raw data

% INPUT
% DSet: The collated dataset in standard format.
% rawDataDir: The directory containing the raw data
% numParticipants: The expected number of participants
% numBlocks: The expected number of blocks
% trialPerBlock: How many trials expected per block
% Fps: Frames per second in the experiment.

%% Check inputs
if length(DSet.P) ~= numParticipants; error('Bug'); end

for iP = 1 : numParticipants
   
    if length(unique(DSet.P(iP).Data.Block)) ~= numBlocks; error('bug'); end
    
    for iBlock = 1 : numBlocks
        
        if sum(DSet.P(iP).Data.Block == iBlock) ~= trialsPerBlock
            error('Bug')
            
        end
        
    end
    
end

    
%% Check the dataset itself
% Define the location of the data that we want to check in the collated dataset.
collatedLoc = { ...
    @(CollatedData, ptpnt, trial) (double(CollatedData.P(ptpnt).Data.IsForcedResp(trial))+1), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.StimLoc(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.Ref(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.Diff(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.ActualDurationPrec(trial), ...
    @(CollatedData, ptpnt, trial) trimTrailingNaNs( ...
        CollatedData.P(ptpnt).Data.DotsDiff(trial, :)), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.RtPrec(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.Resp(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.Acc(trial), ...
    @(CollatedData, ptpnt, trial) CollatedData.P(ptpnt).Data.Conf(trial)};

% And in the originial dataset
originLoc = { ...
    @(Loaded, trial) Loaded.BlockSettings.BlockType, ...
    @(Loaded, trial) Loaded.TrialSettings(trial).StimLoc, ...
    @(Loaded, trial) Loaded.TrialSettings(trial).RefVal, ...
    @(Loaded, trial) Loaded.Settings.Dots.Diff, ...
    @(Loaded, trial) Loaded.Behav(trial).FramesPresented * (1/Fps), ...
    @(Loaded, trial) Loaded.TrialSettings(trial).Dots(2, :) ...
        - Loaded.TrialSettings(trial).Dots(1, :), ...
    @(Loaded, trial) Loaded.Behav(trial).RelativeRT, ...
    @(Loaded, trial) Loaded.Behav(trial).Response, ...
    @(Loaded, trial) Loaded.Behav(trial).Accuracy, ...
    @(Loaded, trial) Loaded.Behav(trial).Conf};


for iP = 1 : numParticipants
    
    for iBlock = 1 : numBlocks
       
        % Load the original data
        LoadedData = load([rawDataDir '\ptpnt' num2str(iP) '_blockNumber' ...
            num2str(iBlock) '.mat']);
        
        
        % Randomly draw a trial from this block
        trialWithinBlock = randi(trialsPerBlock, 1);
        trialWithinExp = trialWithinBlock + ((iBlock -1) * trialsPerBlock);
        
        
        disp(['Participant: ' num2str(iP) '; Block: ' num2str(iBlock) ...
            '; Trial: ' num2str(trialWithinBlock) '.'])
        
        
        % Make all requested comparisons
        for iComp = 1 : length(collatedLoc)
            
            thisCompOriginLoc = originLoc{iComp};
            originVal = thisCompOriginLoc(LoadedData, trialWithinBlock);
            
            thisCompCollatedLoc = collatedLoc{iComp};
            collatedVal = thisCompCollatedLoc(DSet, iP, trialWithinExp);
            
            if ~isequaln(originVal, collatedVal)
                error('Bug')
            end
            
        end
        
    end
    
end

disp('*** No problems found! ***')

end


function outVector = trimTrailingNaNs(inVector)

vectorShape = size(inVector);
if vectorShape(1) ~= 1; error('Bug'); end


for index = vectorShape(2) : -1 : 1
    if isnan(inVector(index))
        inVector(index) = [];
        
    else
        break
        
    end
end

outVector = inVector;

end
    

