function [segWithBlink] = bjh_09_createPrepauseAndPauseCompared2Random(SOURCEDATAPATH,pathoutPause,...
    fileoutBlink,pathoutSegWithBlink,nPerm,sList)
%% create structure containing the average blink probability distribution
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutPause:   directory where pause structure will be loaded
%           fileoutBlink:   directory where blink structure will be loaded 
%           pathoutSegWithBlink: directory where segWithBlinks will be stored
%           nPerm:          number of permutations for average blink
%                           probability distribution
%           sList:          cell array containing number of participants as string
%
% output:   segWithBlink:   structure containing the average blink probability 
%                           distribution computed with permutation
%
% author: Björn Holtze
% date: 18.10.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
load([pathoutPause,'pauseStruct.mat'],'pauseStructMaj','pauseStructBjhAtt1','pauseStructBjhAtt2');
subfieldBlock = {'Block1','Block2','Block3','Block4','Block5','Block6'};
% proportion of pauses in the attended speech stream with at least one blink
pauseWithBlinkAtt = zeros(size(subj_info_bjh_blink)); 
% proportion of prepauses in the attended speech stream with at least one blink
prepauseWithBlinkAtt = zeros(size(subj_info_bjh_blink)); 
% proportion of shifted pauses (random segments) in the attended speech stream with at least one blink
rndSegWithBlinkAtt = zeros(size(subj_info_bjh_blink,2),nPerm);
% same variable for ignored stream
pauseWithBlinkIgn = zeros(size(subj_info_bjh_blink));
prepauseWithBlinkIgn = zeros(size(subj_info_bjh_blink));
rndSegWithBlinkIgn = zeros(size(subj_info_bjh_blink,2),nPerm);
segWithBlink = struct;

for s = 1:size(subj_info_bjh_blink,2)
    disp(['Processing Participant ',sList{s},' ...']);
    load([fileoutBlink,'_',sList{s},'.mat'],'blinkFits');
    
    % choose the correct pauseStruct depending
    % on the dataset and the attended speaker
    pauseOnsetAtt = []; pauseOffsetAtt = []; pauseDurAtt = [];
    pauseOnsetIgn = []; pauseOffsetIgn = []; pauseDurIgn = []; 
    selectedBlockStr = subfieldBlock(subj_info_bjh_blink(s).selected_bl);
    selectedBlockInt = subj_info_bjh_blink(s).selected_bl;
    for bNo = 1:size(selectedBlockStr,2)
        if subj_info_bjh_blink(s).attended_ch == 1
            if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
                pauseStruct = pauseStructMaj;
            elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
                pauseStruct = pauseStructBjhAtt1;
            end
            %%% ATTENDED STREAM
            % concatenate all selected blocks
            pauseOnsetAtt = ... % add first sample of a block (e.g. 300000 for block 2)
                [pauseOnsetAtt,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream1.(selectedBlockStr{bNo}).Onset];
            pauseOffsetAtt = ...
                [pauseOffsetAtt,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream1.(selectedBlockStr{bNo}).Offset];
            pauseDurAtt = [pauseDurAtt,pauseStruct.Stream1.(selectedBlockStr{bNo}).Duration];
            %%% IGNORED STREAM
            pauseOnsetIgn = ... % add first sample of a block (e.g. 300000 for block 2)
                [pauseOnsetIgn,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream2.(selectedBlockStr{bNo}).Onset];
            pauseOffsetIgn = ...
                [pauseOffsetIgn,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream2.(selectedBlockStr{bNo}).Offset];
            pauseDurIgn = [pauseDurIgn,pauseStruct.Stream2.(selectedBlockStr{bNo}).Duration];
        elseif subj_info_bjh_blink(s).attended_ch == 2
            if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
                pauseStruct = pauseStructMaj;
            elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
                pauseStruct = pauseStructBjhAtt2;
            end
            %%% ATTENDED STREAM
            pauseOnsetAtt = ...
                [pauseOnsetAtt,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream2.(selectedBlockStr{bNo}).Onset];
            pauseOffsetAtt = ...
                [pauseOffsetAtt,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream2.(selectedBlockStr{bNo}).Offset];
            pauseDurAtt = [pauseDurAtt,pauseStruct.Stream2.(selectedBlockStr{bNo}).Duration];
            %%% IGNORED STREAM
            pauseOnsetIgn = ...
                [pauseOnsetIgn,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream1.(selectedBlockStr{bNo}).Onset];
            pauseOffsetIgn = ...
                [pauseOffsetIgn,(selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600 + ...
                pauseStruct.Stream1.(selectedBlockStr{bNo}).Offset];
            pauseDurIgn = [pauseDurIgn,pauseStruct.Stream1.(selectedBlockStr{bNo}).Duration];
        end
    end
    
%% ATTENDED STREAM
    % Pauses
    % compute the number of blinks within each pause
    blinksPerPauseAtt = zeros(size(pauseOnsetAtt));
    for p = 1:size(pauseOnsetAtt,2)
        % how many blinks are within pause p
        blinksPerPauseAtt(p) = sum(ismember(pauseOnsetAtt(p):pauseOffsetAtt(p),[blinkFits.maxFrame]));
    end
    % compute the proportion of pauses containing at least 1 blink
    pauseWithBlinkAtt(s) = sum(blinksPerPauseAtt > 0)/size(blinksPerPauseAtt,2);
    
    
    % Pre-Pauses
    % compute the number of blinks within each pre-pause
    blinksPerPrepauseAtt = zeros(size(pauseOnsetAtt));
    for p = 1:size(pauseOnsetAtt,2)
        % how many blinks are within pause p
        blinksPerPrepauseAtt(p) = sum(ismember(pauseOnsetAtt(p)-...
            (pauseOffsetAtt(p)-pauseOnsetAtt(p)): ... % onset minus pause duration
            pauseOnsetAtt(p),[blinkFits.maxFrame])); % until pause onset
    end
    % compute the proportion of pre-pauses containing at least 1 blink
    prepauseWithBlinkAtt(s) = sum(blinksPerPrepauseAtt > 0)/size(blinksPerPrepauseAtt,2);
    
    
    % Randomly shift pause segements without overlap
    % define all possible pause onsets (all samples)
    posblOnset = [];
    for bNo = 1:size(subj_info_bjh_blink(s).selected_bl,2)
        % exclude the last second of each block such that a pause cannot be
        % postioned accross two blocks
        posblOnset = [posblOnset, ...
            (selectedBlockInt(bNo)-1)*pauseStruct.fsNew*600+1:...
            selectedBlockInt(bNo)*pauseStruct.fsNew*600-1*pauseStruct.fsNew];
    end
    
    % preallocate space
    rndPauseOnsetAtt = zeros(nPerm,size(pauseOnsetAtt,2));
    rndPauseOffsetAtt = zeros(nPerm,size(pauseOnsetAtt,2));
    for perm = 1:nPerm
        %logPause = false(size(posblOnset));
        for pause = 1:size(pauseOnsetAtt,2)
            % randomly chose onset of first pause
            rndPauseOnsetAtt(perm,pause) = posblOnset(randi(size(posblOnset,2)));
            % assign the corresponding pause duration
            rndPauseOffsetAtt(perm,pause) = rndPauseOnsetAtt(perm,pause) + pauseDurAtt(pause)*pauseStruct.fsNew;
            overlap = true;
            if pause > 1
                while overlap == true
                    for p = 1:pause-1
                        % test whether the onset of the newly chosen pause 
                        % is with a previously selected pause
                        if rndPauseOnsetAtt(perm,pause) > rndPauseOnsetAtt(perm,p) && ...
                                rndPauseOnsetAtt(perm,pause) < rndPauseOffsetAtt(perm,p)
                            overlap = true;
                        % test whether the offset of the newly chosen pause
                        % is within a previously selected pause
                        elseif rndPauseOffsetAtt(perm,pause) > rndPauseOnsetAtt(perm,p) && ...
                                rndPauseOffsetAtt(perm,pause) < rndPauseOffsetAtt(perm,p)
                            overlap = true;
                        else
                            overlap = false;
                        end
                    end
                    if overlap == true
                        % randomly chose onset of first pause
                        rndPauseOnsetAtt(perm,pause) = posblOnset(randi(size(posblOnset,2)));
                        % assign the corresponding pause duration
                        rndPauseOffsetAtt(perm,pause) = rndPauseOnsetAtt(perm,pause) + pauseDurAtt(pause)*pauseStruct.fsNew;
                    end
                end
            end
        end
    end
    
    % compute blinks per randomly shifted windows
    blinksPerRndIntAtt = zeros(nPerm,size(pauseOnsetAtt,2));
    for perm = 1:nPerm
        for p = 1:size(pauseOnsetAtt,2)
            % how many blinks are within pause p
            blinksPerRndIntAtt(perm,p) = sum(ismember(rndPauseOnsetAtt(perm,p):rndPauseOffsetAtt(perm,p),[blinkFits.maxFrame]));
        end
        % compute the proportion of segments containing at least 1 blink
        rndSegWithBlinkAtt(s,perm) = sum(blinksPerRndIntAtt(perm,:) > 0)/size(blinksPerRndIntAtt,2);
    end
    
%% IGNORED STREAM
    % Pauses
    % compute the number of blinks within each pause
    blinksPerPauseIgn = zeros(size(pauseOnsetIgn));
    for p = 1:size(pauseOnsetIgn,2)
        % how many blinks are within pause p
        blinksPerPauseIgn(p) = sum(ismember(pauseOnsetIgn(p):pauseOffsetIgn(p),[blinkFits.maxFrame]));
    end
    % compute the proportion of pauses containing at least 1 blink
    pauseWithBlinkIgn(s) = sum(blinksPerPauseIgn > 0)/size(blinksPerPauseIgn,2);
    
    
    % Pre-Pauses
    % compute the number of blinks within each pre-pause
    blinksPerPrepauseIgn = zeros(size(pauseOnsetIgn));
    for p = 1:size(pauseOnsetIgn,2)
        % how many blinks are within pause p
        blinksPerPrepauseIgn(p) = sum(ismember(pauseOnsetIgn(p)-...
            (pauseOffsetIgn(p)-pauseOnsetIgn(p)): ... % onset minus pause duration
            pauseOnsetIgn(p),[blinkFits.maxFrame])); % until pause onset
    end
    % compute the proportion of pre-pauses containing at least 1 blink
    prepauseWithBlinkIgn(s) = sum(blinksPerPrepauseIgn > 0)/size(blinksPerPrepauseIgn,2);
    
    % preallocate space
    rndPauseOnsetIgn = zeros(nPerm,size(pauseOnsetIgn,2));
    rndPauseOffsetIgn = zeros(nPerm,size(pauseOnsetIgn,2));
    for perm = 1:nPerm
        %logPause = false(size(posblOnset));
        for pause = 1:size(pauseOnsetIgn,2)
            % randomly chose onset of first pause
            rndPauseOnsetIgn(perm,pause) = posblOnset(randi(size(posblOnset,2)));
            % assign the corresponding pause duration
            rndPauseOffsetIgn(perm,pause) = rndPauseOnsetIgn(perm,pause) + pauseDurIgn(pause)*pauseStruct.fsNew;
            overlap = true;
            if pause > 1
                while overlap == true
                    for p = 1:pause-1
                        % test whether the onset of the newly chosen pause 
                        % is with a previously selected pause
                        if rndPauseOnsetIgn(perm,pause) > rndPauseOnsetIgn(perm,p) && ...
                                rndPauseOnsetIgn(perm,pause) < rndPauseOffsetIgn(perm,p)
                            overlap = true;
                        % test whether the offset of the newly chosen pause
                        % is within a previously selected pause
                        elseif rndPauseOffsetIgn(perm,pause) > rndPauseOnsetIgn(perm,p) && ...
                                rndPauseOffsetIgn(perm,pause) < rndPauseOffsetIgn(perm,p)
                            overlap = true;
                        else
                            overlap = false;
                        end
                    end
                    if overlap == true
                        % randomly chose onset of first pause
                        rndPauseOnsetIgn(perm,pause) = posblOnset(randi(size(posblOnset,2)));
                        % assign the corresponding pause duration
                        rndPauseOffsetIgn(perm,pause) = rndPauseOnsetIgn(perm,pause) + pauseDurIgn(pause)*pauseStruct.fsNew;
                    end
                end
            end
        end
    end
    
    % compute blinks per randomly shifted windows
    blinksPerRndIntIgn = zeros(nPerm,size(pauseOnsetIgn,2));
    for perm = 1:nPerm
        for p = 1:size(pauseOnsetIgn,2)
            % how many blinks are within pause p
            blinksPerRndIntIgn(perm,p) = sum(ismember(rndPauseOnsetIgn(perm,p):rndPauseOffsetIgn(perm,p),[blinkFits.maxFrame]));
        end
        % compute the proportion of segments containing at least 1 blink
        rndSegWithBlinkIgn(s,perm) = sum(blinksPerRndIntIgn(perm,:) > 0)/size(blinksPerRndIntIgn,2);
    end
    
    %% SAVING RESULTS
    % attended stream
    segWithBlink.blinksPerPauseAtt.(subj_info_bjh_blink(s).subj_id) = blinksPerPauseAtt;
    segWithBlink.blinksPerPrepauseAtt.(subj_info_bjh_blink(s).subj_id) = blinksPerPrepauseAtt;
    segWithBlink.pauseWithBlinkAtt(s) = pauseWithBlinkAtt(s);
    segWithBlink.prepauseWithBlinkAtt(s) = prepauseWithBlinkAtt(s);
    segWithBlink.rndSegWithBlinkAtt(s,:) = rndSegWithBlinkAtt(s,:);
    segWithBlink.rndSeg.(subj_info_bjh_blink(s).subj_id).rndPauseOnsetAtt = rndPauseOnsetAtt;
    segWithBlink.rndSeg.(subj_info_bjh_blink(s).subj_id).rndPauseOffsetAtt = rndPauseOffsetAtt;
    segWithBlink.pauseDur(s).Att = pauseDurAtt;
    % ignored stream
    segWithBlink.blinksPerPauseIgn.(subj_info_bjh_blink(s).subj_id) = blinksPerPauseIgn;
    segWithBlink.blinksPerPrepauseIgn.(subj_info_bjh_blink(s).subj_id) = blinksPerPrepauseIgn;
    segWithBlink.pauseWithBlinkIgn(s) = pauseWithBlinkIgn(s);
    segWithBlink.prepauseWithBlinkIgn(s) = prepauseWithBlinkIgn(s);
    segWithBlink.rndSegWithBlinkIgn(s,:) = rndSegWithBlinkIgn(s,:);
    segWithBlink.rndSeg.(subj_info_bjh_blink(s).subj_id).rndPauseOnsetIgn = rndPauseOnsetIgn;
    segWithBlink.rndSeg.(subj_info_bjh_blink(s).subj_id).rndPauseOffsetIgn = rndPauseOffsetIgn;
    segWithBlink.pauseDur(s).Ign = pauseDurIgn;

    clear('rndPauseOnsetAtt','rndPauseOffsetAtt','rndPauseOnsetIgn','rndPauseOffsetIgn');
end
save([pathoutSegWithBlink,'SegWithBlink.mat'],'segWithBlink','-v7.3');
end

