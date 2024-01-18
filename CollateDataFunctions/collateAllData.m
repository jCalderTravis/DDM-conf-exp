function collateAllData(directory)


%change formatting ready for reports
format compact


%% Locate which participant files there are

% look through the files and work out how many participants there are
block1_FileNames = [directory '\ptpnt*_blockNumber1.mat'];
block1_files = dir(block1_FileNames);


% report processing details
disp('Processing report...')
numParticipants = length(block1_files)


% we need to identify all the participant numbers
participantNums = []; %initialise vectore to store result
for index = 1:numParticipants
    
    %is the 7th letter of the name a number? If so we are into double digits of participants
    if isstrprop(block1_files(index).name(7), 'digit')
        
        relevantIndicies = [6 7];
        
        
    else
        
        relevantIndicies = 6;
        
        
    end
    
    
    % find the participant number
    participantNum = str2num(block1_files(index).name(relevantIndicies));
    
    
    % store in the vector of all the participant numbers
    participantNums = [participantNums, participantNum];
    
end


participantNums = sort(participantNums);


% report the identified participants
disp('Participants identified...')
disp(participantNums)


% Check numbering of participants
if length(participantNums) ~= (max(participantNums) - min(participantNums) + 1)
    
    error('Participants numbered with gaps')
    
    
elseif length(unique(participantNums)) ~= length(participantNums)
    
    error('Duplicate entries')
    
    
end


totalParticipants = length(participantNums);


%% Loop through participants collating data
for iPtpnt = 1 : totalParticipants
    
    % Numbering of participants may not star from 1 so we must account for this
    ptpntNum = iPtpnt + min(participantNums) -1;

    
    PtpntData = collateOnePtpntData(directory, ptpntNum);
    
    
    % For compatibility accross pilots
    if ~isfield(PtpntData, 'MeanFrames')
        
        PtpntData.MeanFrames = [];
        
        
    end
        
        
    if ~isfield(PtpntData, 'FramesSd')
        
        PtpntData.FramesSd = [];
        
        
    end
    
    
    if iPtpnt == 1
        
        Data = PtpntData;
        
        
    else
        
        Data(iPtpnt) = PtpntData;
        
        
    end
     
    
end


save([directory '\collatedData'], 'Data')


    
    
    
    