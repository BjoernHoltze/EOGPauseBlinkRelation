function minBlinks100 = bjh_07_create_blinkRelative2Pause(SOURCEDATAPATH,pathoutPause,fileoutBlink,...
    pathoutBlinkRelative2Pause,sList,epoch)
%% epoch average EOG channel relative to pause onsets
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutPause:   directory where pauses structure will be loaded from
%           fileoutBlink:   directory where blink structure will be loaded from
%           pathoutBlinkRelative2Pause: directory where epoched data will be stored
%           sList:          cell array containing number of participants as string
%           epoch:          structure containing subfield "start" and "end"
%                           indicating the time relative to pause onset
%                           where the epochs starts and ends
% 
% Output:   minBlink100:   locgical array indicating participants with
%                           more that 100 blink over all epochs
%
% author: Björn Holtze
% date: 17.09.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
load([pathoutPause,'pauseStruct.mat'],'pauseStructMaj','pauseStructBjhAtt1','pauseStructBjhAtt2');
subfieldBlock = {'Block1','Block2','Block3','Block4','Block5','Block6'};
blinkRelative2Pause = struct;
minBlinks100 = ones(size(subj_info_bjh_blink));

for s = 1:size(subj_info_bjh_blink,2)
    disp(['Processing Participant ',sList{s},' ...']);
    load([fileoutBlink,'_sub-',sList{s},'.mat'],'blinkFits');
    idxAllPauseAtt = 1; % pause index over all blocks
    idxAllPauseIgn = 1;
    
    if subj_info_bjh_blink(s).attended_ch == 1
        if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
            pauseStruct = pauseStructMaj;
        elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
            pauseStruct = pauseStructBjhAtt1;
        end
        for block = 1:size(subfieldBlock,2)
            if ismember(block,subj_info_bjh_blink(s).selected_bl)
                idxPauseAtt = 1; % pause index for each block reset to 1
                while idxPauseAtt <= size(pauseStruct.Stream1.(subfieldBlock{block}).Onset,2)
                    % find blink peaks in time window +/- 1 second around each
                    % pause onset in the attended speech stream
                    blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_att(idxAllPauseAtt,:) = ...
                        ismember((pauseStruct.Stream1.(subfieldBlock{block}).Onset(idxPauseAtt)+ ...
                        epoch.start*pauseStruct.fsNew:...
                        pauseStruct.Stream1.(subfieldBlock{block}).Onset(idxPauseAtt)+...
                        epoch.end*pauseStruct.fsNew) + ...
                        (block-1)*pauseStruct.fsNew*60*10,... % add first sample of that block
                        [blinkFits.maxFrame]);
                    idxPauseAtt = idxPauseAtt + 1;
                    idxAllPauseAtt = idxAllPauseAtt + 1;
                end
                idxPauseIgn = 1;
                while idxPauseIgn <= size(pauseStruct.Stream2.(subfieldBlock{block}).Onset,2)
                    blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_ign(idxAllPauseIgn,:) = ...
                        ismember((pauseStruct.Stream2.(subfieldBlock{block}).Onset(idxPauseIgn)+ ...
                        epoch.start*pauseStruct.fsNew:...
                        pauseStruct.Stream2.(subfieldBlock{block}).Onset(idxPauseIgn)+...
                        epoch.end*pauseStruct.fsNew) + ...
                        (block-1)*pauseStruct.fsNew*60*10,... % add first sample of that block
                        [blinkFits.maxFrame]);
                    idxPauseIgn = idxPauseIgn + 1;
                    idxAllPauseIgn = idxAllPauseIgn + 1;
                end
            end
        end
    elseif subj_info_bjh_blink(s).attended_ch == 2
        if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
            pauseStruct = pauseStructMaj;
        elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
            pauseStruct = pauseStructBjhAtt2;
        end
        for block = 1:size(subfieldBlock,2)
            if ismember(block,subj_info_bjh_blink(s).selected_bl)
                idxPauseAtt = 1;
                while idxPauseAtt <= size(pauseStruct.Stream2.(subfieldBlock{block}).Onset,2)
                    blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_att(idxAllPauseAtt,:) = ...
                        ismember((pauseStruct.Stream2.(subfieldBlock{block}).Onset(idxPauseAtt)+ ...
                        epoch.start*pauseStruct.fsNew:...
                        pauseStruct.Stream2.(subfieldBlock{block}).Onset(idxPauseAtt)+...
                        epoch.end*pauseStruct.fsNew) + ...
                        (block-1)*pauseStruct.fsNew*60*10,... % add first sample of that block
                        [blinkFits.maxFrame]);
                    idxPauseAtt = idxPauseAtt + 1;
                    idxAllPauseAtt = idxAllPauseAtt + 1;
                end
                idxPauseIgn = 1;
                while idxPauseIgn <= size(pauseStruct.Stream1.(subfieldBlock{block}).Onset,2)
                    blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_ign(idxAllPauseIgn,:) = ...
                        ismember((pauseStruct.Stream1.(subfieldBlock{block}).Onset(idxPauseIgn)+ ...
                        epoch.start*pauseStruct.fsNew:...
                        pauseStruct.Stream1.(subfieldBlock{block}).Onset(idxPauseIgn)+...
                        epoch.end*pauseStruct.fsNew) + ...
                        (block-1)*pauseStruct.fsNew*60*10,... % add first sample of that block
                        [blinkFits.maxFrame]);
                    idxPauseIgn = idxPauseIgn + 1;
                    idxAllPauseIgn = idxAllPauseIgn + 1;
                end
            end
        end
    end
    if sum(sum(blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_ign)) < 100 || ...
            sum(sum(blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_att)) < 100
        minBlinks100(s) = 0;
    end
end
save([pathoutBlinkRelative2Pause,'BlinkRelative2Pause.mat'],'blinkRelative2Pause');
end

