function [Behav, Logs, TrialSettings] = runTrial(Settings, BlockSettings, TrialSettings)
% Selects a subset of dots in the two clouds to display each frame. Whilst displaying this the
% function monitors for a response.


%% Initialisation

% Defensive programming
if length(TrialSettings) ~= 1; error('Bug'); end
if length(BlockSettings) ~= 1; error('Bug'); end
if ~any(TrialSettings.StimLoc == [1 2]); error('Bug'); end


% Assign the number of dots in the two clouds
if TrialSettings.StimLoc == 1; assign = [1, -1];
elseif TrialSettings.StimLoc == 2; assign = [-1, 1]; 
end


dotsMean1 = TrialSettings.RefVal + (assign(1) * (0.5 * Settings.Dots.Diff));
dotsMean2 = TrialSettings.RefVal + (assign(2) * (0.5 * Settings.Dots.Diff));


% Measure trial duration for debugging 
trialStart = tic;


% Intialise vars
response = NaN;
Logs.Timestamps.Clear = NaN(1, 4);
Logs.Timestamps.Fixation = NaN(1, 2);
Logs.Timestamps.FixAppearTimeMes2 = NaN;
Logs.Timestamps.ForceResp = NaN(1, 4);
Logs.Timestamps.Frames = NaN(10 * Settings.Timing.Fps, 4);
TrialSettings.DotsSet1 =[];
TrialSettings.DotsSet2 = [];


%for convenience...
screenCenter = [ Settings.WinArea(3)/2 ; Settings.WinArea(4)/2 ]; 
dotSize = Settings.Dots.Size;
dotColour = Settings.Colour.Dots;
fps = Settings.Timing.Fps;
framesISI = Settings.Timing.FramesISI;


%code to use for square dots depends on whether on experimental machine or in office
if Settings.ExperimentalMachine == 1
    
    dotCode = 0;
    
    
else
    
    dotCode = 4;
    
    
end


% Wait until all keys are released
pressed = 1;

while pressed
    
    [~, ~, buttons, ~, ~, ~] = GetMouse;
    
    
    if ~any(buttons)
        
        pressed = 0;
        
        
    end
    
        
end


%% Present fixation cross

Screen('DrawLines', Settings.Win, ...
    [screenCenter(1) screenCenter(1) (3*dotSize)+screenCenter(1) (-3*dotSize)+screenCenter(1);
    (3*dotSize)+screenCenter(2) (-3*dotSize)+screenCenter(2) screenCenter(2) screenCenter(2)],...
    1.2*dotSize, [255 255 255]);


[fixAppearTime, ~, fixFlipEndTime, ~, ~] = Screen('Flip', Settings.Win);


% Timestamps and timing info
Logs.Timestamps.FixAppearTimeMes2 = GetSecs;
Logs.Timestamps.Fixation = [fixAppearTime, fixFlipEndTime];                       
Logs.StimulusOnset = fixAppearTime + (framesISI*(1/fps));


%% Present the stimulus

%Present dots until a response or until the max number of frames has elapsed
for iFrame = 1 : TrialSettings.FramesToPresent
 
    % Select dots to be active this frame
    [TrialSettings, Logs] = selectActiveDots(Logs, TrialSettings, Settings, dotsMean1, dotsMean2);
    
    
    % Prepare the next frame ready for flipping later
    active1 = Settings.Dots.Locations1(:, logical(TrialSettings.DotsSet1(:, iFrame)));
    active2 = Settings.Dots.Locations2(:, logical(TrialSettings.DotsSet2(:, iFrame)));
    
    
    % Prepare fixation cross
    Screen('DrawLines', Settings.Win, ...
        [screenCenter(1) screenCenter(1) (3*dotSize)+screenCenter(1) (-3*dotSize)+screenCenter(1);
        (3*dotSize)+screenCenter(2) (-3*dotSize)+screenCenter(2) screenCenter(2) screenCenter(2)],...
        1.2*dotSize, [255 255 255]);
    
    
    % Defensive programming
    if any(isempty([active1 active2]))
        sca
        error('Bug')
    end
    
    
    % Draw the dots
    Screen('DrawDots',Settings.Win, [active1, active2], dotSize, dotColour, [0 0], dotCode);
    
    
    %Monitor the mouse for a press, until it is time for the next frame
    timeForFlip = Logs.StimulusOnset + ((iFrame-1)*(1/fps));
    
    while GetSecs < timeForFlip - 0.005  
        
        %monitor the mouse
        [~, ~, buttons, ~, ~, ~] = GetMouse;
        
        if buttons(1); response = 1;
        elseif buttons(3); response = 2; 
        end
                
                
        if ~isnan(response)
            
            Rt = GetSecs;
            
            break
            
            
        end
        
        
    end    
        
    
    %Flip the screen to show the next frame, unless a key has been pressed while we were waiting to
    %present the next frame
    if ~isnan(response)
        
        framesPresented = iFrame -1;
        
        
        break
        
        
    end
    
    
    % Flip
    [VBLtime, ~, flipEndTime, ~, ~] = Screen('Flip', Settings.Win); 
    
    Logs.Timestamps.Frames(iFrame, 1) = VBLtime;
    Logs.Timestamps.Frames(iFrame, 2) = VBLtime - Logs.StimulusOnset;
    Logs.Timestamps.Frames(iFrame, 3) = VBLtime - timeForFlip;
    Logs.Timestamps.Frames(iFrame, 4) = flipEndTime;

    
    % Check whether need to allocate a larger array to store the
    % timestamps
    if iFrame == size(Logs.Timestamps.Frames, 1)
    
        Logs.Timestamps.Frames = ...
            [Logs.Timestamps.Frames; NaN(10 * Settings.Timing.Fps, 4)];
        
        
    end

    
end


%If no response has been made we still need to mointor the final frame
if isnan(response)
     
    iFrame = iFrame + 1;
    timeForFlip = Logs.StimulusOnset + ((iFrame-1)*(1/fps)); 
    % This is the flip that will clear the screen and present the red fixation cross
    
    
    % Draw a red fixation cross ready for the case that no response is made. It indicates a response
    % must be made.
    Screen('FillRect', Settings.Win, Settings.Colour.Background);
    
    Screen('DrawLines', Settings.Win, ...
        [screenCenter(1) screenCenter(1) (9*dotSize)+screenCenter(1) (-9*dotSize)+screenCenter(1);
        (9*dotSize)+screenCenter(2) (-9*dotSize)+screenCenter(2) screenCenter(2) screenCenter(2)],...
        2*dotSize, [255 0 0]);
    
    
    while GetSecs < timeForFlip - 0.005
        
        % Monitor mouse
        [~, ~, buttons, ~, ~, ~] = GetMouse;
        
        if buttons(1); response = 1;
        elseif buttons(3); response = 2; 
        end
        
        
        if ~isnan(response)
            
            Rt = GetSecs;
            framesPresented = size(TrialSettings.DotsSet1, 2);
            
            break
            
            
        end
        
        
    end
        
    
end
   

%% Force a response if necessary

if isnan(response)
    
    % All the frames were shown.
    framesPresented = size(TrialSettings.DotsSet1, 2);
    
    
    % Flip to show the red fixation cross
    [Logs.Timestamps.ForceResp(1), ~, Logs.Timestamps.ForceResp(4), ~, ~] = ...
        Screen('Flip', Settings.Win, timeForFlip -0.005);
    
    
    Logs.Timestamps.ForceResp(2) = Logs.Timestamps.ForceResp(1) - Logs.StimulusOnset;
    Logs.Timestamps.ForceResp(3) = Logs.Timestamps.ForceResp(1) - timeForFlip;
    

    % Give time to respond
    timeForFlip = timeForFlip + Settings.ForcedResposeWindow;
    
    
    % Monitor while we wait for a response
    while GetSecs < timeForFlip - 0.005
        
        
        % Monitor mouse
        [~, ~, buttons, ~, ~, ~] = GetMouse;
        
        if buttons(1); response = 1;
        elseif buttons(3); response = 2; 
        end
        
        
        if ~isnan(response)
            
            Rt = GetSecs;
            
            % Bring forward the time that the screen will be cleared.
            timeForFlip = GetSecs + 0.01;
            
            
            break
            
            
        end
        
        
    end


    
    
    
end


%% Clear screen

% Clear screen
Screen('FillRect', Settings.Win, Settings.Colour.Background);

[Logs.Timestamps.Clear(1), ~, Logs.Timestamps.Clear(4), ~, ~] = ...
    Screen('Flip', Settings.Win, timeForFlip -0.005);
    

Logs.Timestamps.Clear(2) = Logs.Timestamps.Clear(1) - Logs.StimulusOnset;
Logs.Timestamps.Clear(3) = Logs.Timestamps.Clear(1) - timeForFlip;


%% Store data and provide speed feedback if required

% Response during fixation cross
if ~isnan(response) && (Rt - Logs.StimulusOnset < 0)
    
    collectConf = false;
    waitTime = 6;
    
    accuracy = NaN;
    relativeRT = Rt - Logs.StimulusOnset;
    
    text4disp = 'Please don''t click before the dots appear';
    textColour = [255 255 255];
    
    
% No response made    
elseif isnan(response)
    
    collectConf = false;
    waitTime = 2;
    
    accuracy = NaN;
    Rt = NaN;
    relativeRT = NaN;
    
    text4disp = 'Too slow';
    textColour = [255 0 0];
    
    
% There was a response
else
    
    % We are in fixed response block and the response was too early
    if (BlockSettings.BlockType == 2) && ...
            ((Rt - Logs.StimulusOnset) < ((1/fps) * TrialSettings.FramesToPresent))
        
        collectConf = false;
        waitTime = 2;
        
        accuracy = NaN;
        relativeRT = Rt - Logs.StimulusOnset;
        
        text4disp = 'Too early';
        textColour = [255 0 0];

        
    % We are in the fixed response block and response was permitted, or in the free response block
    else
        
        collectConf = true;
        waitTime = 0.4;
        
        % It was correct
        if response == TrialSettings.StimLoc
            
            accuracy = 1;
            relativeRT = Rt - Logs.StimulusOnset;
            
            text4disp = [];
            textColour = [0 255 0];
            
            
        % It was incorrect.
        else
            
            % Defensive programming
            if ~any(response == [1 2]); error('Bug'); end
            
            
            accuracy = 0;
            relativeRT = Rt - Logs.StimulusOnset;
            
            text4disp = [];
            textColour = [255 255 255];
            
            
        end
        
    end
    
end


%% Collect confidence report

if collectConf

    confidence = collectConfReport(Settings);
    
    
else 
    
    confidence = NaN;
    
    
end


%% Display results

Screen('TextSize', Settings.Win, Settings.Text.Size2);
DrawFormattedText(Settings.Win, text4disp, 'center', 'center', textColour,  1000, 0, 0, 1.3);


Screen('Flip', Settings.Win);
WaitSecs(waitTime)


%% Finish up

%store behavioural results
Behav = struct( 'Response', response, ...
                    'Accuracy', accuracy, ...
                    'Rt', Rt, ...
                    'RelativeRT', relativeRT, ...
                    'Conf', confidence, ...
                    'FramesPresented', framesPresented);
              

%log trial duration
Logs.TrialDuration = toc(trialStart);


% Logs.Timestamps.Frames is preallocated, and may be bigger than necessary
% because of this. Trim down to size.
toKeep = ~all(isnan(Logs.Timestamps.Frames), 2);

Logs.Timestamps.Frames = Logs.Timestamps.Frames(toKeep, :);


% Defensive programming: The indicies to keep should be in a clump. Check this.
if sum(abs(diff(toKeep))) ~= 1 && sum(abs(diff(toKeep))) ~= 0; error('Bug'); end


