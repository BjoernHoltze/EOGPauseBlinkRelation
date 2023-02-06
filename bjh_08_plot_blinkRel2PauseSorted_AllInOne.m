function [permResults] = bjh_08_plot_blinkRel2PauseSorted_AllInOne(SOURCEDATAPATH,...
    pathoutBlinkRelative2Pause,epoch,edges,minBlinks100,sList)
%% plot blink epochs relative to pause onset as scatter plot and histogram (all individual)
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutBlinkRelative2Pause: directory where epoched data will be loaded from
%           epoch:          structure containing subfield "start" and "end"
%                           indicating the time relative to pause onset
%                           where the epochs starts and ends
%           edges:          edges of the histogram
%           minBlink100:    locgical array indicating participants with
%                           more that 100 blink over all epochs
%           sList:          cell array containing number of participants as string
%
% output:   permResults:    results of the ChiSquare tests
%
% author: Björn Holtze
% date: 28.09.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
load([pathoutBlinkRelative2Pause,'BlinkRelative2PauseSorted.mat'],'blinkRelative2PauseSorted');
fsNew = 500;
timevec = epoch.start:1/fsNew:epoch.end;
darkOrange = [0.8,0.4,0];
lightOrange = [0.9,0.6,0];
darkBlue = [0,0.45,0.7];
lightBlue = [0.35,0.7,0.9];
idxS = 1;
topLeft = [1,3,5,13,15,17,25,27,29];
topRight = [2,4,6,14,16,18,26,28,30];
bottomLeft = [7,9,11,19,21,23,31,33,35];
bottomRight = [8,10,12,20,22,24,32,34,36];
idxSave = 1;
horzShift = 0.012;
vertShift = 0.02;
permResults = struct;



for s = 1:size(subj_info_bjh_blink,2)
    if idxS == 1 || idxS == 10 || idxS == 19 || idxS == 28
        idxSPlot = 1;
        figure('Units','normalized','Position',[0,0,1,1]);
    end
    % only plot graphic and compute statistic for those participants with
    % at least 100 blinks within +/- 1 second around pause onset
    if logical(minBlinks100(s))
        % concatenate pause duration vectors of selected blocks
        disp(['Plot Participant ',sList{s},' ...']);

        %% SCATTERPLOT ATTENDED %%%
        sp1 = subplot(6,6,topLeft(idxSPlot));
        % plot pauses as shaded rectangle
        for p = 1:size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted,2)
            % plot pauses
            rectangle('Position',[0,p,blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted(p),1],...
                'LineStyle','none','FaceColor',darkOrange,'EdgeColor','w');
            hold on;
            % plot prepauses
            rectangle('Position',[0-blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted(p),...
                p,blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted(p),1],...
                'LineStyle','none','FaceColor',lightOrange);
        end
        % plot individual blinks
        scatter(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted),...
            blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseAttSorted,3,'k','filled');
        xline(0);
        ylim([0,size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted,2)]);
        xlim([-1,1]);
        sp1.XTickLabel = '';
        title([' Attended Stream (Participant ',num2str(str2double(sList{s})),')',newline,...
            '(',num2str(size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurAttSorted,2)),...
            ' Pauses, ',num2str(size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseAttSorted,1)),...
            ' Blinks)'],'Interpreter','none');
        sp1.Position = [sp1.Position(1)+horzShift, sp1.Position(2)-vertShift, 0.09, 0.07];
        
        %% HISTOGRAM ATTENDED %%%
        sp2 = subplot(6,6,bottomLeft(idxSPlot));
        histogram(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted),...
            edges,'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
        box off;
        xlim([-1,1]);
        xline(0);
        % compute chi square goodness of fit
        EAtt = size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted,1)...
            /(size(edges,2)-1)*ones((size(edges,2)-1),1);
        [~,pValAtt,statsAtt] = chi2gof(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted),...
            'Expected',EAtt,'Edges',edges);
        if pValAtt < 0.001
            title(['\chi^2(',num2str(statsAtt.df),') = ',num2str(round(statsAtt.chi2stat,2)),', p < 0.001'],...
                'Interpreter','tex');
        else
            title(['\chi^2(',num2str(statsAtt.df),') = ',num2str(round(statsAtt.chi2stat,2)),', p = ',...
                num2str(round(pValAtt,3))],'Interpreter','tex');
        end
        sp2.Position = [sp2.Position(1)+horzShift, sp2.Position(2)+vertShift, 0.09, 0.07];
        
        % save chi square statistics
        permResults.chi2.att.stat(idxS) = statsAtt.chi2stat;
        permResults.chi2.att.pval(idxS) = pValAtt;
        
        
        %% SCATTERPLOT IGNORED %%%
        sp3 = subplot(6,6,topRight(idxSPlot));
        % plot pauses as shaded rectangle
        for p = 1:size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted,2)
            % plot pauses
            rectangle('Position',[0,p,blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted(p),1],...
                'LineStyle','none','FaceColor',darkBlue);
            hold on;
            % plot prepauses
            rectangle('Position',[0-blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted(p),...
                p,blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted(p),1],...
                'LineStyle','none','FaceColor',lightBlue);
        end
        scatter(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted),...
            blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseIgnSorted,3,'k','filled');
        xline(0);
        ylim([0,size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted,2)]);
        xlim([-1,1]);
        sp3.XTickLabel = '';
        title([' Ignored Stream (Participant ',num2str(str2double(sList{s})),')',newline,...
            '(',num2str(size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).allPauseDurIgnSorted,2)),...
            ' Pauses, ',num2str(size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxPauseIgnSorted,1)),...
            ' Blinks)'],'Interpreter','none');
        sp3.Position = [sp3.Position(1)-horzShift, sp3.Position(2)-vertShift, 0.09, 0.07];
        
        
        %% HISTOGRAM IGNORED %%%
        sp4 = subplot(6,6,bottomRight(idxSPlot));
        histogram(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted),...
            edges,'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
        box off;
        xlim([-1,1]);
        xline(0);
        % compute chi square goodness of fit
        EIgn = size(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted,1)/...
            (size(edges,2)-1)*ones((size(edges,2)-1),1);
        [~,pValIgn,statsIgn] = chi2gof(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted),...
            'Expected',EIgn,'Edges',edges);
        if pValIgn < 0.001
            title(['\chi^2(',num2str(statsIgn.df),') = ',num2str(round(statsIgn.chi2stat,2)),', p < 0.001 '],...
                'Interpreter','tex');
        else
            title(['\chi^2(',num2str(statsIgn.df),') = ',num2str(round(statsIgn.chi2stat,2)),', p = ',...
                num2str(round(pValIgn,3))],'Interpreter','tex');
        end
        sp4.Position = [sp4.Position(1)-horzShift, sp4.Position(2)+vertShift, 0.09, 0.07];
        countAtt = histcounts(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeAttSorted),edges);
        countIgn = histcounts(timevec(blinkRelative2PauseSorted.(subj_info_bjh_blink(s).subj_id).idxTimeIgnSorted),edges);
        sp2.YLim = [0,max([countAtt,countIgn])+1];
        sp4.YLim = [0,max([countAtt,countIgn])+1];
        
        % save chi square statistics
        permResults.chi2.ign.stat(idxS) = statsIgn.chi2stat;
        permResults.chi2.ign.pval(idxS) = pValIgn;
        
        clear('pauseAttSorted','pauseIgnSorted','allPauseDurAttSorted','allPauseDurAttSortedIdx',...
            'allPauseDurIgnSorted','allPauseDurIgnSortedIdx','idxPauseAttSorted','idxTimeAttSorted',...
            'idxPauseIgnSorted','idxTimeIgnSorted','pauseDurAtt','pauseDurIgn','countAtt','countIgn');
        if idxS == 9 || idxS == 18 || idxS == 27 || idxS == 35
            sp2.XLabel.String = 'Time Relative to Pause Onset [s]';
            sp4.XLabel.String = 'Time Relative to Pause Onset [s]';
            sp1.YLabel.String = 'Pause Index';
            sp2.YLabel.String = 'Blink Counts';
            print(gcf,[pathoutBlinkRelative2Pause,'IndividualScatterHistAllInOnePlot',num2str(idxSave)],'-dtiffn');
            print(gcf,[pathoutBlinkRelative2Pause,'IndividualScatterHistAllInOnePlot',num2str(idxSave),'.eps'],'-depsc');
            close;  
            idxSave = idxSave + 1;
        end
        idxS = idxS + 1;
        idxSPlot = idxSPlot + 1;
    end
end
end