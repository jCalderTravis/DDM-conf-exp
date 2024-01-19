function saveAsCsv(DSet, saveName)
% Save as CSV for easy reuse outside of matlab.

% INPUT
% DSet: The dataset to convert.
% saveName. str. The filename to use for saving.

fieldsToKeep = {...
    'Block'
    'BlockType'
    'IsForcedResp'
    'StimLoc'
    'Ref'
    'ActualDurationPrec'
    'RtPrec'
    'Resp'
    'Acc'
    'Diff'
    'Conf'
};

for iP = 1 : length(DSet.P)
    ThisData = struct();

    for iF = 1 : length(fieldsToKeep)
        ThisData.(fieldsToKeep{iF}) = DSet.P(iP).Data.(fieldsToKeep{iF});
    end

    ThisData = struct2table(ThisData);
    writetable(ThisData, [saveName '_P' num2str(iP) '_main.csv'])

    for stimulus = [1, 2]
        origSize = size(DSet.P(iP).Data.Dots);
        ThisStim = DSet.P(iP).Data.Dots(:, stimulus, :);
        ThisStim = squeeze(ThisStim);
        assert(isequal(size(ThisStim), [origSize(1), origSize(3)]))
        writematrix(ThisStim, [saveName '_P' num2str(iP) '_stimulus'...
            num2str(stimulus) '.csv'])
    end
end