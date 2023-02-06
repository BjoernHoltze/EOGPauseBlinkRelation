function permResults = bjh_10_plotPrepauseAndPauseCompared2Random(SOURCEDATAPATH,pathoutSegWithBlink,...
    nPerm,minBlinks100,permResults,sList,segWithBlink)
%% plot pause and pre-pause blink probability compared to the average blink probability
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
% date: 25.10.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
darkOrange = [0.8,0.4,0];
lightOrange = [0.9,0.6,0];
darkBlue = [0,0.45,0.7];
lightBlue = [0.35,0.7,0.9];
lightGrey = [0.8,0.8,0.8];
    
%%% ATTENDED STREAM
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            subplot(6,6,idxS);
            % plot distribution of segments with blinks (randomly shifted pause windows)
            h = histogram(segWithBlink.rndSegWithBlinkAtt(s,:),... % in percent
                'FaceColor',lightGrey,'EdgeColor',darkOrange);
            % plot 95 confidence interval
            segWithBlinkAttSorted = sort(segWithBlink.rndSegWithBlinkAtt(s,:)); % sort all values
            xline(segWithBlinkAttSorted(ceil(0.05*nPerm)),'LineStyle','--'); % plot 2.5 %
            xline(segWithBlinkAttSorted(ceil(0.95*nPerm)),'LineStyle','--'); % plot 97.5 %
            % plot proportion of prepauses with blinks
            prepauseLineAtt = xline(segWithBlink.prepauseWithBlinkAtt(s),'Color',lightOrange,'LineWidth',3);
            prepauseLineAtt.Alpha = 1;
            % plot proportion of actual pauses with blinks
            pauseLineAtt = xline(segWithBlink.pauseWithBlinkAtt(s),'Color',darkOrange,'LineWidth',3);
            pauseLineAtt.Alpha = 1;
            ylim([0,max(h.Values)*1.2]);
            % p value = proportion of samples from random distribution smaller than or equal observed value
            pValPrepauseAtt = sum(segWithBlinkAttSorted <= segWithBlink.prepauseWithBlinkAtt(s))/...
                size(segWithBlinkAttSorted,2);
            % p value = proportion of samples from random distribution larger than or equal observed value
            pValPauseAtt = sum(segWithBlinkAttSorted >= segWithBlink.pauseWithBlinkAtt(s))/...
                size(segWithBlinkAttSorted,2);
            title(['Participant ',num2str(str2double(sList{s})),newline,...
                '{\color[rgb]{',num2str(lightOrange),'}p_{Prepause} = ',num2str(round(pValPrepauseAtt,3)),'}'...
                ', {\color[rgb]{',num2str(darkOrange),'}p_{Pause} = ',num2str(round(pValPauseAtt,3)),'}']);
            % save p values
            permResults.prepauseVsBase.att.pval(idxS) = pValPrepauseAtt;
            permResults.pauseVsBase.att.pval(idxS) = pValPauseAtt;
            box off;
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('randomly shifted segments','5^{th} percentile',...
                    '95^{th} percentile','prepauses with a blink','pauses with a blink');
                lgnd.Position(1) = 0.81;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Proportion of Segments with a Blink');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Proportion of Segments with at Least One Blink',newline,'Attended Stream']);
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomAtt_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomAtt_nPerm',num2str(nPerm)],'-dpng','-r300');
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomAtt_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;
    
%%% IGNORED STREAM
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            subplot(6,6,idxS);
            % plot distribution of segments with blinks (randomly shifted pause windows)
            h = histogram(segWithBlink.rndSegWithBlinkIgn(s,:),... % in percent
                'FaceColor',lightGrey,'EdgeColor',darkBlue);
            % plot 95 confidence interval
            segWithBlinkIgnSorted = sort(segWithBlink.rndSegWithBlinkIgn(s,:)); % sort all values
            xline(segWithBlinkIgnSorted(ceil(0.05*nPerm)),'LineStyle','--'); % plot 2.5 %
            xline(segWithBlinkIgnSorted(ceil(0.95*nPerm)),'LineStyle','--'); % plot 97.5 %
            % plot proportion of prepauses with blinks
            prepauseLineIgn = xline(segWithBlink.prepauseWithBlinkIgn(s),'Color',lightBlue,'LineWidth',3);
            prepauseLineIgn.Alpha = 1;
            % plot proportion of actual pauses with blinks
            pauseLineIgn = xline(segWithBlink.pauseWithBlinkIgn(s),'Color',darkBlue,'LineWidth',3);
            pauseLineIgn.Alpha = 1;
            ylim([0,max(h.Values)*1.2]);
            % p value = proportion of samples from random distribution smaller than or equal observed value
            pValPrepauseIgn = sum(segWithBlinkIgnSorted <= segWithBlink.prepauseWithBlinkIgn(s))/...
                size(segWithBlinkIgnSorted,2);
            % p value = proportion of samples from random distribution larger than or equal observed value
            pValPauseIgn = sum(segWithBlinkIgnSorted >= segWithBlink.pauseWithBlinkIgn(s))/...
                size(segWithBlinkIgnSorted,2);
            title(['Participant ',num2str(str2double(sList{s})),newline,...
                '{\color[rgb]{',num2str(lightBlue),'}p_{Prepause} = ',num2str(round(pValPrepauseIgn,3)),'}'...
                ', {\color[rgb]{',num2str(darkBlue),'}p_{Pause} = ',num2str(round(pValPauseIgn,3)),'}']);
            % save p values
            permResults.prepauseVsBase.ign.pval(idxS) = pValPrepauseIgn;
            permResults.pauseVsBase.ign.pval(idxS) = pValPauseIgn;
            box off;
            if s == size(subj_info_bjh_blink,2)
                 lgnd = legend('randomly shifted segments','5^{th} percentile',...
                    '95^{th} percentile','prepauses with a blink','pauses with a blink');
                lgnd.Position(1) = 0.81;
                lgnd.Position(2) = 0.12;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Proportion of Segments with a Blink');
                ylabel('Counts');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Proportion of Segments with at Least One Blink',newline,'Ignored Stream']);
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomIgn_nPerm',num2str(nPerm)],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomIgn_nPerm',num2str(nPerm)],'-dpng','-r300');
    print(gcf,[pathoutSegWithBlink,'PrepauseAndPauseCompared2RandomIgn_nPerm',num2str(nPerm),'.eps'],'-depsc');
    close;

end

