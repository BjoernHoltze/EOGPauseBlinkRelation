function permResults = bjh_11_plotPrepauseVsPause(SOURCEDATAPATH,pathoutSegWithBlink,nPerm,...
    minBlinks100,permResults,sList,segWithBlink)
%% plot pre-pause vs. pause blink probability (once for attended, once for ignored speech stream)
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutSegWithBlink: directory where segWithBlinks will be stored
%           nPerm:          number of permutations for average blink
%                           probability distribution
%           minBlink100:    locgical array indicating participants with
%                           more that 100 blink over all epochs
%           permResult:     structure where the p-values of the
%                           permutation statistic will be added as subfield
%           sList:          cell array containing number of participants as string
%           segWithBlink:   structure containing the average blink probability 
%                           distribution computed with permutation
%
% output:   permResult:     structure containing the p-values of the
%                           permutation statistic
%
% author: Björn Holtze
% date: 01.11.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
diffPropAttSwapped = zeros(sum(minBlinks100),nPerm);
diffPropIgnSwapped = zeros(sum(minBlinks100),nPerm);
darkOrange = [0.8,0.4,0];
darkBlue = [0,0.45,0.7];
lightGrey = [0.8,0.8,0.8];

%%% ATTENDED STREAM
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            disp(['Processing Participant ',sList{s},' ...']);
            prepausesWithBlinkAtt = segWithBlink.blinksPerPrepauseAtt.(subj_info_bjh_blink(s).subj_id) > 0;
            pausesWithBlinkAtt = segWithBlink.blinksPerPauseAtt.(subj_info_bjh_blink(s).subj_id) > 0;
            
            idx = 1:size(pausesWithBlinkAtt,2);
            prepausesWithBlinkAttSwapped = repmat(prepausesWithBlinkAtt',1,nPerm);
            pausesWithBlinkAttSwapped = repmat(pausesWithBlinkAtt',1,nPerm);
            
            for perm = 1:nPerm
                idxPerm = randperm(size(idx,2));
                % assign the pause value to 50% of prepauses
                prepausesWithBlinkAttSwapped(idxPerm(1:round(0.5*size(pausesWithBlinkAtt,2))),perm) = ...
                    pausesWithBlinkAtt(idxPerm(1:round(0.5*size(pausesWithBlinkAtt,2))));
                % assign the prepause value to 50% of pauses
                pausesWithBlinkAttSwapped(idxPerm(1:round(0.5*size(prepausesWithBlinkAtt,2))),perm) = ...
                    prepausesWithBlinkAtt(idxPerm(1:round(0.5*size(prepausesWithBlinkAtt,2))));
            end
            
            diffPropAttSwapped(idxS,:) = sum(pausesWithBlinkAttSwapped,1)/size(pausesWithBlinkAtt,2) - ...
                sum(prepausesWithBlinkAttSwapped,1)/size(pausesWithBlinkAtt,2);
            
            subplot(6,6,idxS);
            % plot null distribution (proportion of pauses with a blink -
            % proportion of prepauses with a blink after switching 50% of labels
            h = histogram(diffPropAttSwapped(idxS,:),'EdgeColor',darkOrange,'FaceColor',lightGrey);
            ylim([0,max(h.Values)*1.3]);
            % plot 95 percentile
            diffPropSwappedAttSorted = sort(diffPropAttSwapped(idxS,:));
            xline(diffPropSwappedAttSorted(ceil(0.95*nPerm)),'LineStyle','--');
            % plot actual difference (proportion of pauses with a blink -
            % proportion of prepauses with a blink)
            propPauseMinusPropPrepauseAtt = sum(pausesWithBlinkAtt)/size(pausesWithBlinkAtt,2)-...
                sum(prepausesWithBlinkAtt)/size(prepausesWithBlinkAtt,2);
            xdark = xline(propPauseMinusPropPrepauseAtt,'LineWidth',2,'Color','k');
            xdark.Alpha = 1;
            % compute p-value of actual difference
            pValAtt = sum(propPauseMinusPropPrepauseAtt <= diffPropSwappedAttSorted)/nPerm;
            title(['Participant ',sList{s},newline...
                '\rm (','Difference = ',num2str(round(propPauseMinusPropPrepauseAtt,3)),...
                ', p = ',num2str(round(pValAtt,3)),')']);
            % save p value
            permResults.prepauseVsPause.att.pval(idxS) = pValAtt;
            box off;
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('Difference null distribution',...
                    '95^{th} percentile','Actual difference');
                lgnd.Position(1) = 0.81;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Diff. in Proportion: Pause - Prepause');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Difference in Proportion of Segments with at Least One Blink',newline,...
        'Pause - Prepause (Attended Stream)']);
    print(gcf,[pathoutSegWithBlink,'PrepauseVsPauseAtt_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'PrepauseVsPauseAtt_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;
    
%%% IGNORED STREAM
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            disp(['Processing Participant ',sList{s},' ...']);
            prepausesWithBlinkIgn = segWithBlink.blinksPerPrepauseIgn.(subj_info_bjh_blink(s).subj_id) > 0;
            pausesWithBlinkIgn = segWithBlink.blinksPerPauseIgn.(subj_info_bjh_blink(s).subj_id) > 0;
            
            idx = 1:size(pausesWithBlinkIgn,2);
            prepausesWithBlinkIgnSwapped = repmat(prepausesWithBlinkIgn',1,nPerm);
            pausesWithBlinkIgnSwapped = repmat(pausesWithBlinkIgn',1,nPerm);
            
            for perm = 1:nPerm
                idxPerm = randperm(size(idx,2));
                % assign the pause value to 50% of prepauses
                prepausesWithBlinkIgnSwapped(idxPerm(1:round(0.5*size(pausesWithBlinkIgn,2))),perm) = ...
                    pausesWithBlinkIgn(idxPerm(1:round(0.5*size(pausesWithBlinkIgn,2))));
                % assign the prepause value to 50% of pauses
                pausesWithBlinkIgnSwapped(idxPerm(1:round(0.5*size(prepausesWithBlinkIgn,2))),perm) = ...
                    prepausesWithBlinkIgn(idxPerm(1:round(0.5*size(prepausesWithBlinkIgn,2))));
            end
            
            diffPropIgnSwapped(idxS,:) = sum(pausesWithBlinkIgnSwapped,1)/size(pausesWithBlinkIgn,2) - ...
                sum(prepausesWithBlinkIgnSwapped,1)/size(pausesWithBlinkIgn,2);
            
            subplot(6,6,idxS);
            % plot null distribution (proportion of pauses with a blink -
            % proportion of prepauses with a blink after switching 50% of labels
            h = histogram(diffPropIgnSwapped(idxS,:),'EdgeColor',darkBlue,'FaceColor',lightGrey);
            ylim([0,max(h.Values)*1.3]);
            % plot 95 percentile
            diffPropSwappedIgnSorted = sort(diffPropIgnSwapped(idxS,:));
            xline(diffPropSwappedIgnSorted(ceil(0.95*nPerm)),'LineStyle','--');
            % plot actual difference (proportion of pauses with a blink -
            % proportion of prepauses with a blink)
            propPauseMinusPropPrepauseIgn = sum(pausesWithBlinkIgn)/size(pausesWithBlinkIgn,2)-...
                sum(prepausesWithBlinkIgn)/size(prepausesWithBlinkIgn,2);
            xdark = xline(propPauseMinusPropPrepauseIgn,'LineWidth',2,'Color','k');
            xdark.Alpha = 1;
            % compute p-value of actual difference
            pValIgn = sum(propPauseMinusPropPrepauseIgn <= diffPropSwappedIgnSorted)/nPerm;
            title(['Participant ',sList{s},newline...
                '\rm (','Difference = ',num2str(round(propPauseMinusPropPrepauseIgn,3)),...
                ', p = ',num2str(round(pValIgn,3)),')']);
            % save p value
            permResults.prepauseVsPause.ign.pval(idxS) = pValIgn;
            box off;
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('Difference null distribution',...
                    '95^{th} percentile','Actual difference');
                lgnd.Position(1) = 0.81;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Diff. in Proportion: Pause - Prepause');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Difference in Proportion of Segments with at Least One Blink',newline,...
        'Pause - Prepause (Ignored Stream)']);
    print(gcf,[pathoutSegWithBlink,'PrepauseVsPauseIgn_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'PrepauseVsPauseIgn_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;


end

