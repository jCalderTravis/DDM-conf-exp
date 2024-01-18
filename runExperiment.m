function runExperiment(ptpntCode)

% EXPERIMENT DESIGN
% Task: Pick between two clouds of dots (left and right) whcih one is the
% high mean cloud
% Subtleties: The difference between the two means is fixed, but not the
% value halfway between the two means (reference value).
% Conditions: In one type of block participants have inifinite amount of
% time to respond, in the other type of block participants are presented 
% with the stimulus for a fixed (but varied) amount of time. In this 
% condition early responses recieve an error message. When the elapsed time
% is up then the clouds disappear, the fixation cross changes colour and a 
% response can be made.
% Confidence report: Following response, there is a non-speeded confidence
% report


%% Tools

% For screen shots...
% imData = Screen('GetImage', Settings.Win);
% imwrite(imData, 'imData1.png')
% sca


% For debugging...
% PsychDebugWindowConfiguration


%% Initialisation

%collect and save basic participant info
collectParticipantInfo(ptpntCode);
ptpntCode = num2str(ptpntCode);


%seed the random number generator
rng('shuffle');
Settings.RandGenerator = rng;


% Set up the computer
Priority(1);
HideCursor();
ListenChar(2);
KbName('UnifyKeyNames');


Settings = loadSettings(Settings);


% Initialise vars to track highscores
highscore = [NaN NaN];


%check the number of trials is even so that have the same number of trials in each condition, and
%that the number of blocks is even so that we can have the same number of each type of block.
if mod(Settings.BlockTrials, 2) ~= 0 || mod(Settings.NumBlocks, 2) ~= 0
    
    disp('Error: Number of trials or blocks is not even.')
    
    sca
    return
    
    
end


% Randomise whether start with a free response or a fixed reponse block and
% then alternate in the training.
if rand(1) < 0.5
    
    offset = 1;
    
    
else
    
    offset = 0;
    
    
end


trainBlockOrder = mod([1 : Settings.NumBlocks] + offset, 2) +1;


% For the main experiment block randomise the block types in blocks of two.
expBlockOrder = NaN(size(trainBlockOrder, 1), size(trainBlockOrder, 2));

% Consider pairs of blocks at a time, and 50% of the time switch their order
for iBlockPair = 1 : Settings.NumBlocks/2
    
    % Swtich order
    if rand(1) < 0.5
        
        expBlockOrder((iBlockPair * 2)-1) =  trainBlockOrder((iBlockPair * 2));
        expBlockOrder((iBlockPair * 2)) =  trainBlockOrder((iBlockPair * 2)-1);
        
        
    % Don't switch order
    else
        
        expBlockOrder((iBlockPair * 2)-1) =  trainBlockOrder((iBlockPair * 2)-1);
        expBlockOrder((iBlockPair * 2)) =  trainBlockOrder((iBlockPair * 2));
        
        
    end
    
    
end


% Display instructions
displayInstructions(Settings, 1)


% Throughout the experiment we will keep track of the mean and sd RT in the previous free response
% block. These will be used to generate the stimulus durations in the fixed response blocks.
% Lets initialise with a rought guess.
lastMean = 15;
lastSd = 8;


%% Run the training and main experiment

% Only run training if requested
if Settings.RunTraining
    
    schedule = {'train', 'test'};
    
    
else
    
    schedule = {'test'};
    
    
end


for iPhase = 1 : length(schedule)
    
    if strcmp(schedule{iPhase}, 'train')
        
        numBlocks = 2;
        blockOrder = trainBlockOrder;
        performance = [NaN NaN];
    
        
    elseif strcmp(schedule{iPhase}, 'test')
        
        numBlocks = Settings.NumBlocks;
        blockOrder = expBlockOrder;
        
        
        displayInstructions(Settings, 2)
        
        
        % At test we also want to track highscores
        highscore = {'None completed', 'None completed'};
        
        
    end
        
        
    for iBlock = 1 : numBlocks
        
        BlockSettings.BlockNum = iBlock;
        BlockSettings.BlockType = blockOrder(iBlock);
        
        
        % If we are in a forced respose block then base the stimulus duration stats on the RT
        % summary stats from the last fixed response block.
        if BlockSettings.BlockType == 2
            
            BlockSettings.MeanFrames = lastMean;
            BlockSettings.FramesSd = lastSd;
            
            
        elseif BlockSettings.BlockType == 1
            
            BlockSettings.MeanFrames = NaN;
            BlockSettings.FramesSd = NaN;
            
            
        end
            
        
        % Display progress
        if strcmp(schedule{iPhase}, 'train')
            
            text = ['The next block is training block ' ...
                num2str(iBlock) ' of a maximum possible ' num2str(numBlocks) '.'];
            
        elseif strcmp(schedule{iPhase}, 'test')
            
            text = ['The next block is block ' ...
                num2str(iBlock) ' of ' num2str(Settings.NumBlocks) '.'];
            
            
        end
        
        
        Screen('TextSize', Settings.Win, Settings.Text.Size2);
        DrawFormattedText(Settings.Win, text, ...
            'center', 'center', [255 255 255], 1000, 0, 0, 1.3);
        Screen('Flip', Settings.Win);
        
        
        waitForInput
        
        
        [TrialSettings, Behav, Logs, BlockSettings] = runBlock(Settings, BlockSettings);
        
        
        %save the data
        if strcmp(schedule{iPhase}, 'train')
            
            prefex = 'trainData_';
            
        elseif strcmp(schedule{iPhase}, 'test')
            
            prefex = '';
            
            
        end
        
        
        filename = ([prefex 'ptpnt' ptpntCode '_blockNumber' num2str(iBlock)]);
        
        save([pwd '/Data/' filename], 'Settings', 'BlockSettings', 'TrialSettings', 'Behav', 'Logs');
        
        
        % If this was a free response block we need to record the mean and sd of RT for use in
        % setting the stimulus duration in the next fixed response block.
        if BlockSettings.BlockType == 1
            
            [lastMean, lastSd] = computeDtMeanAndSd(Behav);
            
            
        end
        
        
        % Work out the fraction of correct responses
        acc = NaN(Settings.BlockTrials, 1);
        
        for iTrial = 1 : Settings.BlockTrials
            
            acc(iTrial) = Behav(iTrial).Accuracy;
            
            
        end
        
        
        % Depending on the type of block we are in we either want to monitor performance, or update
        % highscores, but in either case we want to provide results to the participant.
        if strcmp(schedule{iPhase}, 'train')
            
            performance(BlockSettings.BlockType) = sum(acc == 1)/Settings.BlockTrials;
            
            
            % Report this performance to the participant
            Screen('TextSize', Settings.Win, Settings.Text.Size2);
            DrawFormattedText(Settings.Win, ['Thanks for completing the block.' ...
                '\n\nYou got ' num2str(sum(acc == 1)) ' out of ' num2str(length(acc)) ' correct.'], ...
                'center', 'center', [255 255 255], 1000, 0, 0, 1.3);
            Screen('Flip', Settings.Win);
            
            
        elseif strcmp(schedule{iPhase}, 'test')
            
            % Update highscore if necessary
            if strcmp(highscore{BlockSettings.BlockType}, 'None completed') || ...
                    sum(acc == 1) > str2double(highscore{BlockSettings.BlockType})
                
                highscore{BlockSettings.BlockType} = num2str(sum(acc == 1));
                
                
            end
            
            
            % Report score and highscore to the participant
            blockTypeNames = {'free response', 'deadline'};
            
            Screen('TextSize', Settings.Win, Settings.Text.Size2);
            DrawFormattedText(Settings.Win, ['Thanks for completing the block.' ...
                '\n\nYou got ' num2str(sum(acc == 1)) ' out of ' num2str(length(acc)), ...
                '\ncorrect in this ' blockTypeNames{BlockSettings.BlockType} ' block.', ...
                '\n\nYour highscores are ...', ...
                '\nFree response blocks: ' highscore{1}, ...
                '\nDeadline blocks: ' highscore{2}], ...
                'center', 'center', [255 255 255], 1000, 0, 0, 1.3);
            Screen('Flip', Settings.Win);
            
            
        end
        
        
        waitForInput
        
        
        % If we are training and peformance is up to a specific level in both blocks then don't
        % do any further training
        if strcmp(schedule{iPhase}, 'train') && all(performance > 0.7)
            
            break
            
            
        end
        
        
    end
    
    
end


%% Finish up

% Display instructions
displayInstructions(Settings, 3)


% Display final highscores
Screen('FillRect', Settings.Win, Settings.Colour.Background);
DrawFormattedText(Settings.Win, ['Your final highscores are ...', ...
        '\nFree response blocks: ' highscore{1}, ...
        '\nDeadline blocks: ' highscore{2}], ...
        'center', 'center', [255 255 255], 1000, 0, 0, 1.3);
Screen('Flip', Settings.Win);


waitForInput


% Close down
Priority(0);
sca
ListenChar(1);


