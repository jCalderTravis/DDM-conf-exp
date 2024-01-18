function ConvertedDSet = convertToAlternativeFormat(DSet)
% Function used for converting the data into the format the was used for
% the paper "The Confidence Database", https://doi.org/10.1038/s41562-019-0813-1


%% Conversion
% First step. Make a structures containing the data from all participants.
totalTrials = 0;

for iP = 1 : length(DSet.P)
    totalTrials = totalTrials + length(DSet.P(iP).Data.Resp);
end

SuperStruct.Subj_idx = NaN(totalTrials, 1);
SuperStruct.Stimulus = NaN(totalTrials, 1);
SuperStruct.Response = NaN(totalTrials, 1);
SuperStruct.Confidence = NaN(totalTrials, 1);
SuperStruct.RT_dec = NaN(totalTrials, 1);
SuperStruct.Dot_diff = NaN(totalTrials, 1);
SuperStruct.Stim_duration = NaN(totalTrials, 1);
SuperStruct.Condition = NaN(totalTrials, 1);
SuperStruct.Stim_ref = NaN(totalTrials, 1);


% There is some extra work to do for getting our measure of difficulty:
% Cumulative dots difference shown prior to a response.
for iP = 1 : length(DSet.P)
    
    numTrials = length(DSet.P(iP).Data.Resp);
    DSet.P(iP).Data.Difficulty = NaN(numTrials, 1);
    
    respFrame = ceil(DSet.P(iP).Data.RtPrec * DSet.Spec.Fps);
    
    for iTrial = 1 : numTrials
        
        % Skip trials without a valid response time
        if isnan(DSet.P(iP).Data.RtPrec(iTrial)) ...
                || (DSet.P(iP).Data.RtPrec(iTrial) < 0)
             
            continue
            
        end
        
        DSet.P(iP).Data.Difficulty(iTrial) ...
            = - nansum(DSet.P(iP).Data.Dots(iTrial, 1, 1:respFrame(iTrial))) ...
            + nansum(DSet.P(iP).Data.Dots(iTrial, 2, 1:respFrame(iTrial)));
        
    end
         
end


% Loop through extracting data from all participants
currentIdx = 1;

for iP = 1 : length(DSet.P)
    
    numTrials = length(DSet.P(iP).Data.Resp);
    currentRange = currentIdx : (currentIdx + numTrials -1);

    SuperStruct.Subj_idx(currentRange) = iP;
    SuperStruct.Stimulus(currentRange) = DSet.P(iP).Data.StimLoc;
    SuperStruct.Response(currentRange) = DSet.P(iP).Data.Resp;
    SuperStruct.Confidence(currentRange) = DSet.P(iP).Data.Conf;
    SuperStruct.RT_dec(currentRange) = DSet.P(iP).Data.RtPrec;
    SuperStruct.Dot_diff(currentRange) = DSet.P(iP).Data.Difficulty; 
    SuperStruct.Stim_duration(currentRange) = DSet.P(iP).Data.ActualDurationPrec;
    SuperStruct.Condition(currentRange) = double(DSet.P(iP).Data.IsForcedResp);
    SuperStruct.Stim_ref(currentRange) = DSet.P(iP).Data.Ref;
    
    currentIdx = currentIdx + numTrials;
    
end


%% Checks compared to the input data
% Do some random checking
plot(SuperStruct.Subj_idx)
title('Subject Index')

finalField = {'Stimulus', 'Response', 'Confidence', ...
    'RT_dec', 'Dot_diff', 'Stim_duration', 'Condition', 'Stim_ref'};

originField = {'StimLoc', 'Resp', 'Conf', 'RtPrec', ...
    'Difficulty', 'ActualDurationPrec', 'IsForcedResp', 'Ref'};


for iField = 1 : length(finalField)
    figure
    histogram(SuperStruct.(finalField{iField}))
    title(finalField{iField})
    
end


figure
histogram(SuperStruct.RT_dec - SuperStruct.Stim_duration)
title('RT minus stim duration')


for iField = 1 : length(finalField)
    randIndicies = randi(numTrials, 300, 1);
    [randTrial, randP] = ind2sub([numTrials, length(DSet.P)], randIndicies);
    
    for i = 1 : length(randIndicies)
        
        if ~isequaln(SuperStruct.(finalField{iField})(randIndicies(i)), ...
                DSet.P(randP(i)).Data.(originField{iField})(randTrial(i)))
            
            error('Bug')
            
        end
        
    end
    
end


%% Save
ConvertedDSet = struct2table(SuperStruct);

writetable(ConvertedDSet, 'DSet.csv')
    
    
end




    
    




