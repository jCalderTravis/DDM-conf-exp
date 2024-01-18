function displayInstructions(Settings, instructionSet)
% Loads images containing the participant instructions and displays them.

% INPUTS
% instructionSet        Specifies which set of instructions to display.


% Specify which slides belong to which instruction set
set1 = {'1', '2', '3', '4', '5', '6'};
set2 = {'7'};
set3 = {'8'};
setSpecificaiton = {set1, set2, set3};


% Select the relevant set of slides 
relSlides = setSpecificaiton{instructionSet};


% Display them in turn
for iSlide = 1 : length(relSlides)
    
    % Load the images
    instructIm = imread([pwd '/Instructions/Slide' relSlides{iSlide} '.png']);
    
    
    % Display the images
    instrctTexture = Screen('MakeTexture', Settings.Win, instructIm);
    Screen('FillRect', Settings.Win, [254, 254, 254]);
    Screen('DrawTexture', Settings.Win, instrctTexture, [], Settings.WinArea);
    Screen('Flip', Settings.Win)
    
    
    waitForInput
    
    
end


% Clear screen
Screen('FillRect', Settings.Win, Settings.Colour.Background);
Screen('Flip', Settings.Win);


