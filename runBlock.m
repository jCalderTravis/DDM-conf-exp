function [TrialSettings, Behav, Logs, BlockSettings] = runBlock(Settings, BlockSettings)

% INPUT
% blockType     If 1 runs as free response block, if 2 runs a block with
%               response at interogation time.


%% Set up

% Initialise
BlockSettings.DurationReasigns = 0;
BlockSettings.RefReassigns = 0;


% Give participant type of block, and instructions refresher
if BlockSettings.BlockType == 1
    
    text4disp = ['This block is free response.' ...
        '\n\nRemember, in this block you can respond whenever you like.' ...
        '\nTry to be as fast and accurate as possible.' ...
        '\n\nClick the mouse to begin.'];
    
    
elseif BlockSettings.BlockType == 2
    
    text4disp = ['This block is a deadline block.' ...
        '\n\nRemember, in this block you must respond when the red cross appears.' ...
        '\n\nClick the mouse to begin.'];
    
    
end


Screen('TextSize', Settings.Win, Settings.Text.Size2);

DrawFormattedText(Settings.Win, text4disp, 'center', 'center', [255 255 255], 1000, 0, 0, 1.3);
Screen('Flip', Settings.Win);


waitForInput


%% Randomisation of trials to conditions

% Set the location of the high mean box
conditionOrder = randperm(Settings.BlockTrials);
stimLoc = mod(conditionOrder, 2) +1;

for iTrial = 1 : Settings.BlockTrials
    
    TrialSettings(iTrial).StimLoc = stimLoc(iTrial);
    
    
end


% Set duration of trials. This will depend on the blockType
if BlockSettings.BlockType == 1
    
    % Free resp block. Set maximum duration of trials to a very high number.
    for iTrial = 1 : Settings.BlockTrials
        
        TrialSettings(iTrial).FramesToPresent = 10 * 60 * Settings.Timing.Fps;
        
        
    end
    
    
elseif BlockSettings.BlockType == 2
    
    % Interrogation block. Randomise duration of trials.
    for iTrial = 1 : Settings.BlockTrials
        
        TrialSettings(iTrial).FramesToPresent = BlockSettings.MeanFrames + ...
            round(randn(1) * BlockSettings.FramesSd);
        
        
        % If this is above or below max and min values then reassign        
        while TrialSettings(iTrial).FramesToPresent < Settings.Timing.FramesMin || ...
                TrialSettings(iTrial).FramesToPresent > Settings.Timing.FramesMax
            
            BlockSettings.DurationReasigns = BlockSettings.DurationReasigns + 1;
            
            
            TrialSettings(iTrial).FramesToPresent = BlockSettings.MeanFrames + ...
                round(randn(1) * BlockSettings.FramesSd);
            
            
        end
        
        
    end
    
    
end


%% Other randomisation

% Randomly assign the number of dots that will be half way between the
% number of dots in the high mean and low mean dot clouds
for iTrial = 1 : Settings.BlockTrials
        
    TrialSettings(iTrial).RefVal = round(randn(1)*Settings.Dots.RefSd) + Settings.Dots.RefMean;
    
    
    % If this is above or below max and min values then reassign    
    while TrialSettings(iTrial).RefVal > Settings.Dots.RefMax || ...
            TrialSettings(iTrial).RefVal < Settings.Dots.RefMin
        
        BlockSettings.RefReassigns = BlockSettings.RefReassigns + 1;
        
        
        TrialSettings(iTrial).RefVal = ...
            round(randn(1)*Settings.Dots.RefSd) + Settings.Dots.RefMean;
        
        
    end
    
    
end



%% Loop through trials and store results

for iTrial = 1 : Settings.BlockTrials
    
    %run a trial...  
    [Behav(iTrial), Logs(iTrial), CurrentTrialSettings] = runTrial(Settings, BlockSettings, ...
        TrialSettings(iTrial));
    
    
    % Add information to TrialSettings
    TrialSettings(iTrial).DotsSet1 = CurrentTrialSettings.DotsSet1;
    TrialSettings(iTrial).DotsSet2 = CurrentTrialSettings.DotsSet2;
    
    
    % While we are here, also compute and store the number of dots shown each frame.
    TrialSettings(iTrial).Dots = [sum(TrialSettings(iTrial).DotsSet1, 1); ...
        sum(TrialSettings(iTrial).DotsSet2, 1)];
    
    
    % This array will now include the details of every frame that was prepared for flipping, but the
    % final frame prepared may not have actually been displayed. If this is the case then trim the
    % array.
    if Behav(iTrial).FramesPresented == size(TrialSettings(iTrial).Dots, 2) -1
        
        TrialSettings(iTrial).Dots(:, end) = [];
        
        
    elseif Behav(iTrial).FramesPresented ~= size(TrialSettings(iTrial).Dots, 2)
        
        save('errorData')
        sca
        error('Bug. See saved file ''errorData''')
        
        
    end
    
 
end                           

 
