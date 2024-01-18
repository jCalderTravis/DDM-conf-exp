function Data = collateOnePtpntData(directory, ptpntNum)


% Load settings from block 1 so we know how many blocks and trials there are.
loadedFile = load([directory '\ptpnt' num2str(ptpntNum) '_blockNumber1.mat']);
Settings = loadedFile.Settings;


AllBehav = [];
AllBlockSettings = [];
AllTrialSettings = [];


for iBlock = 1 : Settings.NumBlocks

    loadedFile = load([directory '\ptpnt' num2str(ptpntNum) '_blockNumber' ...
        num2str(iBlock) '.mat']);
    Behav = loadedFile.Behav;
    BlockSettings = loadedFile.BlockSettings;
    TrialSettings = loadedFile.TrialSettings;


    % Block settings is a single strcutre. Make it into a struct array as long as the number of trials
    % ready for concatination.
    BlockSettings = repmat(BlockSettings, 1, Settings.BlockTrials);


    % We need to do some work on TrialSettings. Remove the fields specifying the location of every dot
    % in every frame.
    TrialSettings = rmfield(TrialSettings, 'DotsSet1');
    TrialSettings = rmfield(TrialSettings, 'DotsSet2');


    AllBehav = [AllBehav, Behav];
    AllBlockSettings = [AllBlockSettings, BlockSettings];
    AllTrialSettings = [AllTrialSettings, TrialSettings];


    clear Behav
    clear BlockSettings
    clear TrialSettings


end

% Turn the array of structs into a struct containing arrays
behavTable = struct2table(AllBehav);
blockTable = struct2table(AllBlockSettings);
trialTable = struct2table(AllTrialSettings);

Data = table2struct([blockTable, behavTable, trialTable], 'ToScalar',true);


% Also add info on the dots difference used
Data.Diff = ones(length(Data.Rt), 1) * Settings.Dots.Diff;

