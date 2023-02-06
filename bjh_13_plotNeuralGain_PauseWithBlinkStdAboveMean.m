function bjh_13_plotNeuralGain_PauseWithBlinkStdAboveMean(SOURCEDATAPATH,pathoutSegWithBlink,minBlinks100,segWithBlink)
%% plot relation between blink-related and neural measure of attention
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutSegWithBlink: directory where segWithBlinks will be stored
%           minBlink100:    locgical array indicating participants with
%                           more that 100 blink over all epochs
%           segWithBlink:   structure containing the average blink probability 
%                           distribution computed with permutation
%
% author: Björn Holtze
% date: 11.11.22

load([pathoutSegWithBlink,'attGainAllBlocks.mat'],'attGainAllBlocks');
load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');

meanRndSeg = zeros(41,1);
stdRndSeg = zeros(41,1);
pauseWithBlinkInStd = zeros(41,1);

BlinkSubj = {subj_info_bjh_blink(logical(minBlinks100)).subj_id};
inclSubj = ismember(attGainAllBlocks(:,1)',BlinkSubj);

for s = 1:size(subj_info_bjh_blink,2)
    % compute how many standard deviation the blink probability during pauses
    % is away from the mean of the average blink probabilitry distribution
    % compute mean of average blink probability distribution
    meanRndSeg(s) = mean(segWithBlink.rndSegWithBlinkAtt(s,:));
    % compute standard deviation
    stdRndSeg(s) = std(segWithBlink.rndSegWithBlinkAtt(s,:));
    % actual
    pauseWithBlinkInStd(s) = (segWithBlink.pauseWithBlinkAtt(s)-meanRndSeg(s))/stdRndSeg(s);
end

pauseWithBlinkInStdInclS = pauseWithBlinkInStd(logical(minBlinks100));

figure('Units','centimeters','Position',[2,2,7.4,7]);
axNeural = axes;
scatter([attGainAllBlocks{inclSubj,2}],pauseWithBlinkInStdInclS,5,'filled',...
    'MarkerFaceColor','k','MarkerEdgeColor','k');
axNeural.XLabel.String = 'Neural Selective Attention Measure';
axNeural.YLabel.String = ['Blink Probability of Attended Pauses',newline,'Relative to Average Blink Probability [STD]'];
axNeural.XLabel.FontSize = 8;
axNeural.YLabel.FontSize = 8;
axNeural.XLabel.Position(1) = 0.003;
[r,p] = corr([attGainAllBlocks{inclSubj,2}]',pauseWithBlinkInStdInclS);
text(0.004,5.75,['r = ',num2str(round(r,2)),', p = ',num2str(round(p,2))],'FontSize',9);
print(gcf,[pathoutSegWithBlink,'AttGainRosenkranz_Pause-BlinkAttentionMeasure'],'-dtiffn');
print(gcf,[pathoutSegWithBlink,'AttGainRosenkranz_Pause-BlinkAttentionMeasure'],'-dpng','-r300');
print(gcf,[pathoutSegWithBlink,'AttGainRosenkranz_Pause-BlinkAttentionMeasure','.eps'],'-depsc');
close;


end