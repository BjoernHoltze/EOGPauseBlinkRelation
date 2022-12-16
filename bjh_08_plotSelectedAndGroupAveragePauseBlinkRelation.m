function bjh_08_plotSelectedAndGroupAveragePauseBlinkRelation(SOURCEDATAPATH,pathoutBlinkRelative2Pause,...
    epoch,edges,minBlinks100,permResults)
%% plot pause-blink-relation of one selected participant and the group average
% input:    SOURCEDATAPATH: directory where participant information is stored
%           pathoutBlinkRelative2Pause: directory where epoched data will be loaded from
%           epoch:          structure containing subfield "start" and "end"
%                           indicating the time relative to pause onset
%                           where the epochs starts and ends
%           edges:          edges of the histogram
%           minBlink100:    locgical array indicating participants with
%                           more that 100 blink over all epochs
%           permResults:    results of the ChiSquare tests
%
% author: Björn Holtze
% date: 12.10.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
load([pathoutBlinkRelative2Pause,'BlinkRelative2Pause.mat'],'blinkRelative2Pause');
load([pathoutBlinkRelative2Pause,'BlinkRelative2PauseSorted.mat'],'blinkRelative2PauseSorted');
load([SOURCEDATAPATH,'jitterX.mat'],'jitterX');
fsNew = 500;
timevec = epoch.start:1/fsNew:epoch.end;
darkOrange = [0.8,0.4,0];
lightOrange = [0.9,0.6,0];
darkBlue = [0,0.45,0.7];
lightBlue = [0.35,0.7,0.9];

figure('Units','centimeters','Position',[2,2,7.4,16]);

%% plot participant 27 (bjh_s12, 029)

%%% ATTENDED SCATTERPLOT
    sp1 = subplot(4,2,1);
    for p = 1:size(blinkRelative2PauseSorted.bjh_s12.allPauseDurAttSorted,2)
        % plot pauses
        rectangle('Position',[0,p,blinkRelative2PauseSorted.bjh_s12.allPauseDurAttSorted(p),1],...
            'LineStyle','none','FaceColor',darkOrange,'EdgeColor','w');
        hold on;
        % plot prepauses
        rectangle('Position',[0-blinkRelative2PauseSorted.bjh_s12.allPauseDurAttSorted(p),p,...
            blinkRelative2PauseSorted.bjh_s12.allPauseDurAttSorted(p),1],...
            'LineStyle','none','FaceColor',lightOrange);
    end
    scatter(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeAttSorted),...
        blinkRelative2PauseSorted.bjh_s12.idxPauseAttSorted,3,'k','filled');
    xline(0);
    sp1.YLabel.String = 'Pause Index';
    sp1.YLim = [0,size(blinkRelative2PauseSorted.bjh_s12.allPauseDurAttSorted,2)];
    sp1.XLim = [-1,1];
    sp1.XTickLabel = '';
    sp1.YTickLabelRotation = 90;
    sp1.Title.String = 'Attended Stream';
    sp1.Title.FontWeight = 'normal';
    sp1.Position(2) = 0.78;

%%% ATTENDED HISTOGRAM
    sp3 = subplot(4,2,3);
    histogram(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeAttSorted),...
        edges,'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
    box off;
    sp3.XLabel.String = 'Time Rel. to Pause [s]';
    sp3.YLabel.String = 'Number of Blinks';
    sp3.YTickLabelRotation = 90;
    sp3.XLim = [-1,1];
    xline(0);
    % compute chi square goodness of fit
    EAtt = size(blinkRelative2PauseSorted.bjh_s12.idxTimeAttSorted,1)/...
        (size(edges,2)-1)*ones((size(edges,2)-1),1);
    [~,pValAtt,statsAtt] = chi2gof(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeAttSorted),...
        'Expected',EAtt,'Edges',edges);
    starsAtt = significant_stars(pValAtt);
    sp3.Title.String = ['\chi^2(',num2str(statsAtt.df),') = ',num2str(round(statsAtt.chi2stat,2)),'^{ ',starsAtt,'}'];
    sp3.Title.Interpreter = 'tex';
    sp3.Title.FontWeight = 'normal';
    sp3.Position([2,4]) = [0.66,0.08];


%%% IGNORED HISTOGRAM
    sp2 = subplot(4,2,2);
    for p = 1:size(blinkRelative2PauseSorted.bjh_s12.allPauseDurIgnSorted,2)
        % plot pauses
        rectangle('Position',[0,p,blinkRelative2PauseSorted.bjh_s12.allPauseDurIgnSorted(p),1],...
            'LineStyle','none','FaceColor',darkBlue,'EdgeColor','w');
        hold on;
        % plot prepauses
        rectangle('Position',[0-blinkRelative2PauseSorted.bjh_s12.allPauseDurIgnSorted(p),p,...
            blinkRelative2PauseSorted.bjh_s12.allPauseDurIgnSorted(p),1],...
            'LineStyle','none','FaceColor',lightBlue);
    end
    scatter(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeIgnSorted),...
        blinkRelative2PauseSorted.bjh_s12.idxPauseIgnSorted,3,'k','filled');
    xline(0);
    sp2.YLim = [0,size(blinkRelative2PauseSorted.bjh_s12.allPauseDurIgnSorted,2)];
    sp2.XLim = [-1,1];
    sp2.XTickLabel = '';
    sp2.YTickLabelRotation = 90;
    sp2.Title.String = 'Ignored Stream';
    sp2.Title.FontWeight = 'normal';
    sp2.Position(2) = 0.78;
    
%%% IGNORED HISTOGRAM
    sp4 = subplot(4,2,4);
    histogram(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeIgnSorted),...
        edges,'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
    box off;
    sp4.XLabel.String = 'Time Rel. to Pause [s]';
    sp4.XLim = [-1,1];
    sp4.YTickLabelRotation = 90;
    xline(0);
    % compute chi square goodness of fit
    EIgn = size(blinkRelative2PauseSorted.bjh_s12.idxTimeIgnSorted,1)/...
        (size(edges,2)-1)*ones((size(edges,2)-1),1);
    [~,pValIgn,statsIgn] = chi2gof(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeIgnSorted),...
        'Expected',EIgn,'Edges',edges);
    starsIgn = significant_stars(pValIgn);
    sp4.Title.String = ['\chi^2(',num2str(statsIgn.df),') = ',num2str(round(statsIgn.chi2stat,2)),'^{ ',starsIgn,'}'];
    sp4.Title.Interpreter = 'tex';
    sp4.Title.FontWeight = 'normal';
    sp4.Position([2,4]) = [0.66,0.08];
    countAtt = histcounts(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeAttSorted),edges);
    countIgn = histcounts(timevec(blinkRelative2PauseSorted.bjh_s12.idxTimeIgnSorted),edges);
    sp3.YLim = [0,max([countAtt,countIgn])+1];
    sp4.YLim = [0,max([countAtt,countIgn])+1];
    titleS27 = annotation('textbox',[0.5,0.9,0.1,0.1],'String','Single Case Blink Patterns (Participant 029)',...
        'FontSize',8,'EdgeColor','none','FontWeight','bold','HorizontalAlignment','center');
    titleS27.Position = [0.07,0.9,0.9,0.1];
   

%% individual chi square values
    sp7 = subplot(4,2,[5,6]);
    % find critical value
    crit = chi2inv(1-0.05,19);
    h(1) = line([0.5,2.5],[crit,crit],'Color','k','LineStyle','--');
    hold on;
    % define a variable that holds all indices but the single case from above
    selectedSubj = 27;
    allSubj = 1:35;
    allBut27 = allSubj ~= selectedSubj;
    % include jitter in x direction to avoid overlap
    % jitterX = (rand(size(chiSquareStats.att.chi2stat))-0.5)/2; (variable is loaded above)
    % plot lines connecting chi square value of attended and ignored for each participant
    line(cat(1,ones(size(permResults.chi2.att.stat(allBut27)))+jitterX(allBut27),...
        ones(size(permResults.chi2.ign.stat(allBut27)))+1+jitterX(allBut27)),...
        cat(2,permResults.chi2.att.stat(allBut27)',permResults.chi2.ign.stat(allBut27)')',...
        'color',[0.7,0.7,0.7],'linestyle','-');
    %pause(0.5);
    % plot chi square value
    scatter(ones(size(permResults.chi2.att.stat(allBut27)))+jitterX(allBut27),...
        permResults.chi2.att.stat(allBut27)',10,'k','filled');
    scatter(ones(size(permResults.chi2.ign.stat(allBut27)))+1+jitterX(allBut27),...
        permResults.chi2.ign.stat(allBut27)',10,'k','filled');
    % plot selected single case plotted in subplot A
    h(5) = scatter(1+jitterX(selectedSubj),permResults.chi2.att.stat(selectedSubj),20,'r','filled');
    scatter(2+jitterX(selectedSubj),permResults.chi2.ign.stat(selectedSubj),20,'r','filled');
    % plot connecting line of selected single case
    line(cat(1,1+jitterX(selectedSubj),2+jitterX(selectedSubj)),...
        cat(2,permResults.chi2.att.stat(selectedSubj)',permResults.chi2.ign.stat(selectedSubj)')',...
        'color','r','linestyle','-');
    [~,icons] = legend(h([1,5]),{'Critical \chi^2(19)','Participant 029'},'box','off','FontSize',7);
    % or for Patch plots 
    icons = findobj(icons, 'type', 'patch'); % objects of legend of type patch
    set(icons, 'Markersize', 4); % set marker size as desired
    sp7.XTick = [1,2];
    sp7.XTickLabel = {'Attended Stream','Ignored Stream'};    
    sp7.XAxis.FontSize = 8;
    sp7.XLabel.String = '';
    sp7.YLabel.String = '\chi^2 Value';
    sp7.YTickLabelRotation = 90;
    sp7.XLim = [0.5,2.5];
    sp7.YLim = [0,100];
    sp7.Box = 'off';
    sp7.Position([2,4]) = [0.317,0.2];
    titleChi2 = annotation('textbox',[0.5,0.3,0.1,0.1],'String','\chi^2 Results of Individual Blink Histograms',...
        'FontSize',8,'EdgeColor','none','FontWeight','bold','HorizontalAlignment','center');
    titleChi2.Position = [0.065,0.47,0.9,0.1];
 
    
%% grand average histogram
    %%% compute grand average (normalized)
    countAttPercent = zeros(sum(minBlinks100),20);
    countIgnPercent = zeros(sum(minBlinks100),20);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        % only plot graphic and compute statistic for those participants with
        % at least 100 blinks within +/- 1 second around pause onset
        if logical(minBlinks100(s))
            % idenftify pause index and corresponding time index where a blink occurred
            [~,idxTimeAtt] = find(blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_att == 1);
            [~,idxTimeIgn] = find(blinkRelative2Pause.(subj_info_bjh_blink(s).subj_id).pause_ign == 1);
            % normalized as percentage
            countAttPercent(idxS,:) = histcounts(timevec(idxTimeAtt),edges)/size(idxTimeAtt,1)*100;
            countIgnPercent(idxS,:) = histcounts(timevec(idxTimeIgn),edges)/size(idxTimeIgn,1)*100;
            clear('idxPauseAtt','idxPauseIgn');
            idxS = idxS + 1;
        end
    end
    
    %%% ATTENDED STREAM
    sp5 = subplot(4,2,7);
    histogram('BinEdges',edges,'BinCounts',squeeze(mean(countAttPercent,1)),...
        'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
    hold on;
    sp5.XLim = [-1,1];
    sp5.YLim = [3,max([max(squeeze(mean(countAttPercent,1))),...
        max(squeeze(mean(countIgnPercent,1)))])+1]; % in percent
    sp5.XLabel.String = 'Time Rel. to Pause [s]';
    sp5.XLabel.FontSize = 8;
    sp5.YLabel.String = 'Prop. of Blinks [%]';
    sp5.YLabel.FontSize = 8;
    sp5.YTickLabelRotation = 90;
    sp5.Title.String = 'Attended Stream';
    sp5.Title.FontWeight = 'normal';
    sp5.Position([2,4]) = [0.08,0.1];
    xline(0);
    box off;
    
    sp6 = subplot(4,2,8);
    histogram('BinEdges',edges,'BinCounts',squeeze(mean(countIgnPercent,1)),...
        'FaceColor','k','FaceAlpha',1,'EdgeColor','w');
    hold on;
    sp6.XLim = [-1,1];
    sp6.YLim = [3,max([max(squeeze(mean(countAttPercent,1))),...
        max(squeeze(mean(countIgnPercent,1)))])+1]; % in percent
    sp6.XLabel.String = 'Time Rel. to Pause [s]';
    sp6.XLabel.FontSize = 8;
    sp6.YTickLabelRotation = 90;
    sp6.Title.String = 'Ignored Stream';
    sp6.Title.FontWeight = 'normal';
    sp6.Position([2,4]) = [0.08,0.1];
    xline(0);
    box off;
    titleAvg = annotation('textbox',[0.5,0.47,0.7,0.1],'String','Group Average Blink Histograms',...
        'FontSize',8,'EdgeColor','none','FontWeight','bold');
    titleAvg.Position = [0.2,0.15,0.7,0.1];
    
    annotation('textbox',[0.01,titleS27.Position(2),0.1,0.1],'String','A','FontSize',10,'EdgeColor','none','FontWeight','bold');
    annotation('textbox',[0.01,titleChi2.Position(2),0.1,0.1],'String','B','FontSize',10,'EdgeColor','none','FontWeight','bold');
    annotation('textbox',[0.01,titleAvg.Position(2),0.1,0.1],'String','C','FontSize',10,'EdgeColor','none','FontWeight','bold');
    
    print(gcf,[pathoutBlinkRelative2Pause,'figure2'],'-dtiffn');
    print(gcf,[pathoutBlinkRelative2Pause,'figure2','.eps'],'-depsc');
    close;

end

