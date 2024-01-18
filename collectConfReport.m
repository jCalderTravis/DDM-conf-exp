function confReport = collectConfReport(Settings)
% Display a confidence scale as an arc with markers, and collect a
% confidence report.

% OUTPUT
% confReport        Measures the angle in degrees clicked on the arc confidence scale, with -90
%                   for definite error, and +90 for definite correct.


% Set the mouse to the center of the screen
SetMouse(Settings.WinArea(3)/2, Settings.WinArea(4)/2);


% Show the mouse
ShowCursor(Settings.Win);


% Wait for a click on the arc
response = 0;


while response == 0
    
    % Draw an arc
    height = 0.3 * Settings.WinArea(4);
    
    arcContainer = [Settings.WinArea(3)/2 - (0.5 * height), ...
        Settings.WinArea(4)/2 - (0.5 * height), ...
        Settings.WinArea(3)/2 + (0.5 * height), ...
        Settings.WinArea(4)/2 + (0.5 * height)];
    
    penWidth = height / 6;
    
    Screen('FrameArc', Settings.Win, Settings.Colour.Arc, ...
        arcContainer, -90, 180, penWidth, penWidth, NaN)
    
    
    % Add lables to the arc
    Screen('TextSize', Settings.Win, Settings.Text.Size1);
    
    DrawFormattedText(Settings.Win, 'Definitely\n   wrong', 'right', arcContainer(4) -(height/2) -25, ...
        [0 0 0], 1000, 0, 0, 1.5, 0, ...
        [Settings.WinArea(1), Settings.WinArea(2), arcContainer(1)-15, Settings.WinArea(4)]);
    
    
    DrawFormattedText(Settings.Win, 'Definitely\ncorrect', arcContainer(3)+15, arcContainer(4) -(height/2) -25, ...
        [0 255 0], 1000, 0, 0, 1.5, 0);
    
    
    DrawFormattedText(Settings.Win, 'Don''t\nknow', 'center', arcContainer(2) -70, ...
        [255 255 255], 1000, 0, 0, 1.5, 0, ...
        [arcContainer(1), Settings.WinArea(2), arcContainer(3), Settings.WinArea(4)]);
    
    
    % Where is the mouse?
    
    % Find mouse location
    [x,y,buttons,~,~,~] = GetMouse;
    
    
    % Find mouse displacement from center
    xDisp = x - (Settings.WinArea(3)/2);
    yDisp = y - (Settings.WinArea(4)/2);
    
    
    % Find distance of mouse to center
    dist = ((xDisp^2) + (yDisp^2))^0.5;
    
    
    % Find the angle the mouse makes to the center
    angle = asin(xDisp / dist);
    
    
    % If the mouse is below the center of the screen then all responses are
    % invalid.
    if yDisp > 0
        
        angle = NaN;
        
        
    end
    
    
    % Convert to degrees
    angle = 360 * (1/(2*pi)) * angle;
  
    
    % Is the mouse on the arc?
    if (dist >= (height/2) - penWidth) && (dist <= (height/2) + penWidth) && ...
            (angle >= -90) && (angle <= 90)
        
        % Highlight this section of the ark by drawing a small section of
        % lighter arc over the old arc.
        Screen('FrameArc', Settings.Win, Settings.Colour.Arc + 100, arcContainer, ...
            (angle -5), 10, penWidth, penWidth, NaN)
        
        
        % Has a response been made?
        if buttons(1) == 1 || buttons(3) == 1
            
            % store confReport
            confReport = angle;
            
            
            response = 1;
       
            
        end

        
    end
    
    
    Screen('Flip', Settings.Win);
    
    
end


%Hide the mouse
HideCursor();

