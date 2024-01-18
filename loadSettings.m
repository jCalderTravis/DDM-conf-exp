function Settings = loadSettings(Settings)
%function to set all the settings which are univeral to all trials including training


%some settings depend on whether we are on the experimental machine or not, and whether we want to
%skip the training
Settings.ExperimentalMachine = 1;
Settings.RunTraining = true;


%% Timing settings

% Set the number of trials in the block, and number of blocks
% Note: noTrials must be a multiple of the number of conditions (2)
Settings.NumBlocks = 16;
Settings.BlockTrials = 40;


%set the number of frames per second
Settings.Timing.Fps = 20;


%set the number of frames of the fixation cross
Settings.Timing.FramesISI = 10;


% Number of frames for the deadline condition.
Settings.Timing.FramesMin = 4;
Settings.Timing.FramesMax = 80;


% Set the about of time participants have to respond in the deadline condition
Settings.ForcedResposeWindow = 1; % measured in seconds


%% Psychtoolbox settings

if Settings.ExperimentalMachine == 1
    
    windowPtr = 0;
    
    
else
    
    windowPtr = 2;
    
    
end


[Settings.Win, Settings.WinArea] = Screen('OpenWindow', windowPtr);    


%test that the refresh rate is as expected
Settings.RefreshRate = Screen('NominalFrameRate', Settings.Win);


if Settings.ExperimentalMachine == 1
    if Settings.RefreshRate ~= 60 || ~isequal(Settings.WinArea, [0 0 1600 1200]) 
        disp('Error: Unexpected refresh rate or screen size.')
        sca
        return
    end
    
else
    if Settings.RefreshRate ~=60
        disp('Error: Unexpected refresh rate.')
        sca
        return
    end
end


% Set the colours to use
Settings.Colour.Background = [80 80 80];
Settings.Colour.Dots = [200 200 200];
Settings.Colour.Arc = [100 100 100];


%fill screen with background colour
Screen('FillRect', Settings.Win, Settings.Colour.Background);


%Set standard text sizes
Settings.Text.Size1 = 20;
Settings.Text.Size2 = 30;


Screen('TextSize', Settings.Win, Settings.Text.Size1);


%set text font
Screen('TextFont', Settings.Win, 'Helvetica');


%% Dot settings

% Set the reference number of dots (half way between the high and low mean)
% and the SD of this value accross trials
Settings.Dots.RefMean = 1000;
Settings.Dots.RefSd = 100;
Settings.Dots.RefMax = 1500;
Settings.Dots.RefMin = 500;
Settings.Dots.Diff = 90;


%set the standard deviation of fluctuations around the mean number of dots displayed
Settings.Dots.SdDots = 220;


% Find the location of dots that form two circular dot clouds
[Settings.Dots.Locations1, dotSize1] = dotCenterLocations(...
    [Settings.WinArea(3)*(5/12), Settings.WinArea(4)/2], 0.2, 32, 1, Settings.WinArea);
[Settings.Dots.Locations2, dotSize2] = dotCenterLocations(...
    [Settings.WinArea(3)*(7/12), Settings.WinArea(4)/2], 0.2, 32, 1, Settings.WinArea);


% Defensive programming
if (dotSize1 ~= dotSize2) || ...
    (length(Settings.Dots.Locations1) ~= length(Settings.Dots.Locations2))

    error('Bug')


else

    Settings.Dots.Size = dotSize1;
    Settings.Dots.Max = length(Settings.Dots.Locations1);


end


