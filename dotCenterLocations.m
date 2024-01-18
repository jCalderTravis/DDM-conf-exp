function [locations, dotSize] = dotCenterLocations(centerLocation, ...
screenFraction, noDots, gapSize, winArea)
% Finds the dot locations that correspond to a circular cloud of dots

%INPUTS
% centerLocation    1x2 row vecotor specifying the center of the cloud
%screenFraction:    Fraction of the height of the screen that will be covered in dots
%noDots:            Number of dots from the center, horizontally outwards.
%gapSize            Number of pixels between two dots
%winArea:           Info on size of screen, as returned by a call to Screen('OpenWindow', ...)

%OUTPUTS
%locations:         Locations of the dots ready for use in DrawDots
%dotSize:           Diameter of dots in pixels


%% Initialisation

%find center of the screen
if (mod(winArea(3)-winArea(1), 2)~= 0 ) || (mod(winArea(4)-winArea(2), 2)~= 0 )
    disp('ERROR: screen has odd number of pixels, script needs rewritting')
    return
end

if (winArea(1)~= 0 ) || (winArea(2)~= 0 )
    disp('ERROR: Code was wirtten assuming that co-ordinates of top left hand corner of screen are', ...
            '0 , 0 but they are not')
    return
end


%% Calculate the required dot size

%first calculate required stimulus size
stimSize = screenFraction * (winArea(4) - winArea(2));


%then calcualte dotSize
dotSize = (1/noDots) * ( (stimSize/2) - ( (noDots-0.5)*gapSize ) );
dotSize = floor(dotSize);


%% Calculate the possible dot locations 

%initialise variable to store locations
locations = zeros(2, noDots^2);


%initialise counter for tracking entries into locations
entry = 1;

%calculate distance of center of final dot from the center
finalDot = ( (noDots - 0.5)*dotSize ) + ( (noDots - 0.5)*gapSize );

%loop through columns
for col = -finalDot : dotSize + gapSize : finalDot
    
    %loop through rows
    for row = -finalDot : dotSize + gapSize : finalDot
        
        %store results
        locations(:, entry) = [row ; col];
        
        entry = entry + 1;
        
    end
    
end

assert((entry-1) == size(locations, 2))

%but we only want those dots whose centers fall within a circle or radius finalDot
locations = locations(:, (locations(1, :).^2)+(locations(2,:).^2)<(finalDot^2));


% locations has the required dot locations but centered on (0, 0) when we require it centered on
% centerLocation

% Check for row vector
if size(centerLocation, 1) ~= 1; error('Bug'); end 


centerMatrix = repmat(centerLocation, length(locations), 1);


locations = locations + centerMatrix';



