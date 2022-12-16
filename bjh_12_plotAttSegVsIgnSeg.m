function bjh_12_plotAttSegVsIgnSeg(SOURCEDATAPATH,pathoutSegWithBlink,nPerm,minBlinks100,sList,segWithBlink)
%% plot pre-pause and pause blink probability (attend vs. ignored)
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutSegWithBlink: directory where segWithBlinks will be stored
%           nPerm:          number of permutations for average blink
%                           probability distribution
%           minBlink100:    locgical array indicating participants with
%                           more that 100 blink over all epochs
%           sList:          cell array containing number of participants as string
%           segWithBlink:   structure containing the average blink probability 
%                           distribution computed with permutation
%
% author: Björn Holtze
% date: 06.11.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
lightGrey = [0.8,0.8,0.8];
diffPrepausesPropSwapped = zeros(sum(minBlinks100),nPerm);
diffPausesPropSwapped = zeros(sum(minBlinks100),nPerm);
    
%%% PRE-PAUSES
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            disp(['Processing Participant ',sList{s},' ...']);
            % find pauses with at least 1 blinks
            attPrepausesWithBlink = segWithBlink.blinksPerPrepauseAtt.(subj_info_bjh_blink(s).subj_id) > 0;
            ignPrepausesWithBlink = segWithBlink.blinksPerPrepauseIgn.(subj_info_bjh_blink(s).subj_id) > 0;
            
            concatPrepauseWithBlink = cat(2,attPrepausesWithBlink,ignPrepausesWithBlink);
            % att: 1, ign: 2
            concLabels = cat(2,ones(size(attPrepausesWithBlink)),ones(size(ignPrepausesWithBlink))+1);
            concIdx = 1:size(concLabels,2);
            % preallocate space
            attPrepausesWithBlinkSwapped = repmat(attPrepausesWithBlink',1,nPerm);
            ignPrepausesWithBlinkSwapped = repmat(ignPrepausesWithBlink',1,nPerm);
            
            for perm = 1:nPerm
                % randomly permute indeces
                idxPerm = randperm(size(concIdx,2));
                % use permuted indeces to permute labels
                concLabelsPerm = concLabels(idxPerm);
                % assign values with label 1 (att) to attended pauses
                attPrepausesWithBlinkSwapped(:,perm) = concatPrepauseWithBlink(concLabelsPerm == 1);
                % assign values with label 2 (ign) to ignored pauses
                ignPrepausesWithBlinkSwapped(:,perm) = concatPrepauseWithBlink(concLabelsPerm == 2);
            end
            
            diffPrepausesPropSwapped(idxS,:) = sum(attPrepausesWithBlinkSwapped,1)/size(attPrepausesWithBlink,2) - ...
                sum(ignPrepausesWithBlinkSwapped,1)/size(ignPrepausesWithBlink,2);            
            
            subplot(6,6,idxS);
            % plot null distribution (proportion of attended pauses with a
            % blink minus proportion of ignored pauses with a blink after
            % permuting of labels
            histogram(diffPrepausesPropSwapped(idxS,:),'FaceColor',lightGrey,'EdgeColor',[0.5,0.5,0.5]);
            % plot 95 percentile
            diffPrepausePropSwappedSorted = sort(diffPrepausesPropSwapped(idxS,:));
            critLine = xline(diffPrepausePropSwappedSorted(ceil(0.05*nPerm)),'LineStyle','--');
            critLine.Alpha = 1; 
            % plot actual difference (proportion of attended pauses with a blink
            % minus proportion of ignored pauses with a blink)
            propPrepauseAttMinusPropPrepauseIgn = sum(attPrepausesWithBlink)/size(attPrepausesWithBlink,2)-...
                sum(ignPrepausesWithBlink)/size(ignPrepausesWithBlink,2);
            % plot actual difference with two color
            prepauseBlue = xline(propPrepauseAttMinusPropPrepauseIgn,'Color','k','LineWidth',2);
            prepauseBlue.Alpha = 1;
            % compute p-value of actual difference
            pValPrepause = sum(propPrepauseAttMinusPropPrepauseIgn >= diffPrepausePropSwappedSorted)/nPerm;
            title(['\bf{Participant ',sList{s},'}',newline,...
                '\rm Diff =  ',num2str(round(propPrepauseAttMinusPropPrepauseIgn,3)),...
                ' ,p = ',num2str(round(pValPrepause,3)),newline,'Number of Blinks: ',num2str(sum(attPrepausesWithBlink)),...
                '/',num2str(sum(ignPrepausesWithBlink)),newline,...
                'Number of Pauses: ',num2str(size(attPrepausesWithBlink,2)),'/',...
                num2str(size(ignPrepausesWithBlink,2)),newline,'Average Pause Duration: '...
                num2str(round(mean(segWithBlink.pauseDur(s).Att,2)*1000)),'/',...
                num2str(round(mean(segWithBlink.pauseDur(s).Ign,2)*1000)),' ms'],...
                'FontSize',8);
            box off;
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('Diff. null distribution',...
                    '5^{th} percentile','Actual difference');
                lgnd.Position(1) = 0.823;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Diff. in Proportion: Prepause_{Att} - Prepause_{Ign}');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Difference in Proportion of Segments with at Least One Blink',newline,...
        'Attended Prepauses - Ignored Prepauses']);
    print(gcf,[pathoutSegWithBlink,'prepauseAttVsPrepauseIgn_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'prepauseAttVsPrepauseIgn_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;

%%% PAUSES
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            disp(['Processing Participant ',sList{s},' ...']);
            % find pauses with at least 1 blinks
            attPausesWithBlink = segWithBlink.blinksPerPauseAtt.(subj_info_bjh_blink(s).subj_id) > 0;
            ignPausesWithBlink = segWithBlink.blinksPerPauseIgn.(subj_info_bjh_blink(s).subj_id) > 0;
            
            concatPauseWithBlink = cat(2,attPausesWithBlink,ignPausesWithBlink);
            % att: 1, ign: 2
            concLabels = cat(2,ones(size(attPausesWithBlink)),ones(size(ignPausesWithBlink))+1);
            concIdx = 1:size(concLabels,2);
            % preallocate space
            attPausesWithBlinkSwapped = repmat(attPausesWithBlink',1,nPerm);
            ignPausesWithBlinkSwapped = repmat(ignPausesWithBlink',1,nPerm);
            
            for perm = 1:nPerm
                % randomly permute indeces
                idxPerm = randperm(size(concIdx,2));
                % use permuted indeces to permute labels
                concLabelsPerm = concLabels(idxPerm);
                % assign values with label 1 (att) to attended pauses
                attPausesWithBlinkSwapped(:,perm) = concatPauseWithBlink(concLabelsPerm == 1);
                % assign values with label 2 (ign) to ignored pauses
                ignPausesWithBlinkSwapped(:,perm) = concatPauseWithBlink(concLabelsPerm == 2);
            end
            
            diffPausesPropSwapped(idxS,:) = sum(attPausesWithBlinkSwapped,1)/size(attPausesWithBlink,2) - ...
                sum(ignPausesWithBlinkSwapped,1)/size(ignPausesWithBlink,2);
            
            subplot(6,6,idxS);
            % plot null distribution (proportion of attended pauses with a
            % blink minus proportion of ignored pauses with a blink after
            % permuting of labels
            histogram(diffPausesPropSwapped(idxS,:),'FaceColor',lightGrey,'EdgeColor',[0.5,0.5,0.5]);
            % plot 95 percentile
            diffPausePropSwappedSorted = sort(diffPausesPropSwapped(idxS,:));
            critLine = xline(diffPausePropSwappedSorted(ceil(0.95*nPerm)),'LineStyle','--');
            critLine.Alpha = 1; 
            % plot actual difference (proportion of attended pauses with a blink
            % minus proportion of ignored pauses with a blink)
            propPauseAttMinusPropPauseIgn = sum(attPausesWithBlink)/size(attPausesWithBlink,2)-...
                sum(ignPausesWithBlink)/size(ignPausesWithBlink,2);
             % plot actual difference with two color
            pauseBlue = xline(propPauseAttMinusPropPauseIgn,'Color','k','LineWidth',2);
            pauseBlue.Alpha = 1;
            % compute p-value of actual difference
            pValPause = sum(propPauseAttMinusPropPauseIgn <= diffPausePropSwappedSorted)/nPerm;
            title(['\bf{Participant ',sList{s},'}',newline,...
                '\rm Diff =  ',num2str(round(propPauseAttMinusPropPauseIgn,3)),...
                ' ,p = ',num2str(round(pValPause,3)),newline,'Number of Blinks: ',num2str(sum(attPausesWithBlink)),...
                '/',num2str(sum(ignPrepausesWithBlink)),newline,...
                'Number of Pauses: ',num2str(size(attPrepausesWithBlink,2)),'/',...
                num2str(size(ignPrepausesWithBlink,2)),newline,'Average Pause Duration: '...
                num2str(round(mean(segWithBlink.pauseDur(s).Att,2)*1000)),'/',...
                num2str(round(mean(segWithBlink.pauseDur(s).Ign,2)*1000)),' ms'],...
                'FontSize',8);
            box off;
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('Diff. null distribution',...
                    '95^{th} percentile','Actual difference');
                lgnd.Position(1) = 0.823;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Diff. in Proportion: Pause_{Att} - Pause_{Ign}');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Difference in Proportion of Segments with at Least One Blink',newline,...
        'Attended Pauses - Ignored Pauses']);
    print(gcf,[pathoutSegWithBlink,'pauseAttVsPauseIgn_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'pauseAttVsPauseIgn_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;

end

