function [meanRt, sdRt] = computeDtMeanAndSd(Behav)
% Use the structure Behav produced by a single block of the experiment, and compute the mean and
% standard deviation of the response times. mean and sd are returned in number of (50ms) frames. 
%(Reaction times in behav are stored in milliseconds.)

meanRt = mean([Behav.RelativeRT]);
sdRt = std([Behav.RelativeRT]);


% Convert from seconds to frames
meanRt = round(meanRt/0.05);
sdRt = round(sdRt/0.05);


% Defensive programing
if any(isnan([meanRt, sdRt]))
    
    error('Bug in script')
    
    
end


