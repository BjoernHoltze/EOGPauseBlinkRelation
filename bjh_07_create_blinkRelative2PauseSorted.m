function bjh_07_create_blinkRelative2PauseSorted(SOURCEDATAPATH,pathoutPause,pathoutBlinkRelative2Pause)
%% sorts blink epochs relative to pause onset according to pause duration
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutPause:   directory where pauses structure will be loaded from
%           pathoutBlinkRelative2Pause: directory where epoched data will be loaded from
%                           more that 100 blink over all epochs
%
% author: Björn Holtze
% date: 18.09.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
load([pathoutBlinkRelative2Pause,'BlinkRelative2Pause.mat'],'blinkRelative2Pause');
load([pathoutPause,'pauseStruct.mat'],'pauseStructMaj','pauseStructBjhAtt1','pauseStructBjhAtt2');
subfieldBlock = {'Block1','Block2','Block3','Block4','Block5','Block6'};
blinkRelative2PauseSorted = struct;

for s = 1:size(subj_info_bjh_blink,2)
    disp(['Process participant ',num2str(s),' ...']);
    % concatenate pause duration vectors of selected blocks
    pauseDurAtt = []; pauseDurIgn = [];
    selected_bl = subfieldBlock(subj_info_bjh_blink(s).selected_bl);
    for b = 1:size(selected_bl,2)
        if subj_info_bjh_blink(s).attended_ch == 1
            if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
                pauseStruct = pauseStructMaj;
            elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
                pauseStruct = pauseStructBjhAtt1;
            end
            pauseDurAtt = [pauseDurAtt,pauseStruct.Stream1.(selected_bl{b}).Duration];
            pauseDurIgn = [pauseDurIgn,pauseStruct.Stream2.(selected_bl{b}).Duration];
        elseif subj_info_bjh_blink(s).attended_ch == 2
            if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
                pauseStruct = pauseStructMaj;
            elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
                pauseStruct = pauseStructBjhAtt2;
            end
            pauseDurAtt = [pauseDurAtt,pauseStruct.Stream2.(selected_bl{b}).Duration];
            pauseDurIgn = [pauseDurIgn,pauseStruct.Stream1.(selected_bl{b}).Duration];
        end
    end
    
    % sort pauses according to duration
    % attended
    [allPauseDurAttSorted,allPauseDurAttSortedIdx] = sort(pauseDurAtt);
    pauseAttSorted = blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_att(allPauseDurAttSortedIdx,:);
    % ignored
    [allPauseDurIgnSorted,allPauseDurIgnSortedIdx] = sort(pauseDurIgn);
    pauseIgnSorted = blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_ign(allPauseDurIgnSortedIdx,:);
    
    % idenftify pause index and corresponding time index where a blink occurred
    [idxPauseAttSorted,idxTimeAttSorted] = find(pauseAttSorted == 1);
    [idxPauseIgnSorted,idxTimeIgnSorted] = find(pauseIgnSorted == 1);
    
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted = allPauseDurAttSorted;
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted = allPauseDurIgnSorted;
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseAttSorted = idxPauseAttSorted;
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted = idxTimeAttSorted;
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseIgnSorted = idxPauseIgnSorted;
    blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted = idxTimeIgnSorted;
    
    clear('pauseAttSorted','pauseAttSorted','allPauseDurAttSorted','allPauseDurAttSortedIdx',...
        'allPauseDurIgnSorted','allPauseDurIgnSortedIdx','idxPauseAttSorted','idxTimeAttSorted',...
        'idxPauseIgnSorted','idxTimeIgnSorted');
end
save([pathoutBlinkRelative2Pause,'BlinkRelative2PauseSorted.mat'],'blinkRelative2PauseSorted');

end

