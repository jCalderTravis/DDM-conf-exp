function [TrialSettings, Logs] = selectActiveDots(Logs, TrialSettings, Settings, dotsMean1, dotsMean2)
% Assign the number of dots for the next frame for the high and low mean blobs

%We are going to assign the number dots to display each frame, but want to track the number of
%reassignments due to reandomly selected value for number of dots being smaller than zero or greater 
%than the maximum number of dots
Logs.Reassignments(1) = 0;


%Assign the number of dots to display in each frame, in each of the blobs
noDots = round(randn(1, 2)*Settings.Dots.SdDots) + [dotsMean1 dotsMean2];


% Check that neither number of dots of the two blobs is greater than
% the max possible, or smaller than zero
while any(noDots > Settings.Dots.Max) || any(noDots <= 0)
    
    % If so randomly reassign
    noDots = round(randn(1, 2)*Settings.Dots.SdDots) + [dotsMean1 dotsMean2];
    
    
    Logs.Reassignments = Logs.Reassignments +1;
    
    
end


% Lengthen TrialSettings.DotsSet1 and 2 for an extra frame, and set all the dots
% in the new frame to zero
TrialSettings.DotsSet1 = [TrialSettings.DotsSet1, zeros(Settings.Dots.Max, 1)];
TrialSettings.DotsSet2 = [TrialSettings.DotsSet2, zeros(Settings.Dots.Max, 1)];


% Set the active dots in the frame
% The number of active locations of each blob in a frame being determined by noDots
shuffledLocations1 = randperm(Settings.Dots.Max);
shuffledLocations2 = randperm(Settings.Dots.Max);


activeLocations1 = shuffledLocations1(1 : noDots(1));
activeLocations2 = shuffledLocations2(1 : noDots(2));


TrialSettings.DotsSet1(activeLocations1, end) = 1;
TrialSettings.DotsSet2(activeLocations2, end) = 1;


