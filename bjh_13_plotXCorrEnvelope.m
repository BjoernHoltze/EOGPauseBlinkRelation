function bjh_13_plotXCorrEnvelope(SOURCEDATAPATH,pathoutSegWithBlink,minBlinks100,sList)
%% plot grand average cross-correlation (speech envelope and EEG) and corresponding GFP
% input:    SOURCEDATAPATH:     path from which the .mat file about all
%                               participants is drawn
%           pathoutSegWithBlink path where figures and the attentional gain
%                               values are stored
%           minBlink100         locgical array indicating participants with
%                               more that 100 blink over all epochs 
%           sList               cell array containing the participant's ID as string
%
% author: Marc Rosenkranz and Bjoern Holtze
% date: 01.02.2023

load([SOURCEDATAPATH,'xcorr_mar.mat'],'xcorr_mar');
load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');

% Time lag
lag = xcorr_mar.FF.s6.block1.lag; % same for all participants
lag_ms = lag*(1000/250); % sampling rate 250
lag_ms = lag_ms(1:1000);


dataSets = {'FF','HP'};
subj.HP = {'1','2','3','5','6','8','9','11','12','13','14',...
    '15','17','18','19','20','21','22','23','24','25'};
inclBlock.HP = {[1 2 4], [1 3 5],[1,2,4],[1,2,4],[1,3,5],...
            [1,3,5],[1,2,4],[1,2,4],[1,3,5],[1,2,4],...
            [1,3,5],[1,2,4],[1,2,4],[1,3,5],[1,2,4],...
            [1,3,5],[1,2,4],[1,3,5],[1,2,4],[1,3,5],[1,2,4]};
subj.FF={'6','7','8','9','10','11','12','13','14','15','16',...
    '18','20','21','22','23','24','25','26','27'};
inclBlock.FF = repmat({1:6},1,length(subj.FF));
inclBlock.FF{11} = 1:5; % last block of this pp is missing

% Grand average global field power
avAtt=[]; avIgn=[];
cnt=1;
for d=1:2
    currSet = dataSets{d};
    for s=1:length(subj.(currSet))
        currSub = ['s',subj.(currSet){s}];
        blocks = inclBlock.(currSet){s};
        for bl=1:length(blocks)
            currBlock = ['block',num2str(blocks(bl))];
            % xcorr average over epochs for each block
            blockAveragAtt(bl,:,:)=mean(xcorr_mar.(currSet).(currSub).(currBlock).att,3);
            blockAveragIgn(bl,:,:)=mean(xcorr_mar.(currSet).(currSub).(currBlock).ign,3);
            disp([currSet,' ',currSub,' ',currBlock])
        end
        % xcorr average over blocks for each participant
        avAtt(cnt,:,:) = squeeze(mean(blockAveragAtt));
        avIgn(cnt,:,:) = squeeze(mean(blockAveragIgn));
        cnt=cnt+1;
    end
end

%% Plotting
    darkOrange = [0.8,0.4,0];
    darkBlue = [0,0.45,0.7];

% plot grand average cross-correlation function
    figure('Units','centimeters','Position',[2,2,12,14]);
    ylimXCorr = [-0.015,0.015];
    % cross-correlation of attended speech envelope
    subplot(3,1,1);
    plot(lag_ms,squeeze(mean(avAtt)),'Color',darkOrange);
    xlim([-100,400]);
    ylim(ylimXCorr);
    ylabel('Correlation [a.u.]');
    title('Cross-Correlation (Attended Stream)');
    % cross-correlation of ignored speech envelope
    subplot(3,1,2);
    plot(lag_ms,squeeze(mean(avIgn)),'Color',darkBlue);
    xlim([-100,400]);
    ylim(ylimXCorr);
    ylabel('Correlation [a.u.]');
    title('Cross-Correlation (Ignored Stream)');
    % global field power of cross-correlation functions
    sp3 = subplot(3,1,3);
    rectangle('Position',[50 0 150 0.01],'FaceColor',[0.9,0.9,0.9],'EdgeColor','none');
    hold on;
    plot(lag_ms,std(squeeze(mean(avAtt)),[],1),'Color',darkOrange,'LineWidth',2);
    plot(lag_ms,std(squeeze(mean(avIgn)),[],1),'Color',darkBlue,'LineWidth',2);
    hold off;
    xlim([-100,400]);
    ylim([0,0.008]);
    set(gca, "Layer", "top");
    title('Global Field Power of Cross-Correlation');
    sp3.YLabel.String = 'Global Field Power [a.u.]';
    sp3.YLabel.Position(1) = -140;
    sp3.XLabel.String = 'Time Lag [ms]';
    
    print(gcf,[pathoutSegWithBlink,'GrandAverageCrossCorr'],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'GrandAverageCrossCorr'],'-dpng','-r300'); 
    close;
    
    
%% plot individual global field power functions
    gfpAtt = squeeze(std(avAtt,[],2));
    gfpIgn = squeeze(std(avIgn,[],2));
 
    figure('units','normalized','outerposition',[0 0 1 1]);
    idxS = 1;
    for s = 1:size(subj_info_bjh_blink,2)
        if logical(minBlinks100(s))
            subplot(6,6,idxS);
            rectangle('Position',[50 0 150 0.028],'FaceColor',[0.9,0.9,0.9],'EdgeColor','none');
            hold on;
            plot(lag_ms,gfpAtt(s,:,:),'Color',darkOrange,'LineWidth',2);
            plot(lag_ms,gfpIgn(s,:,:),'Color',darkBlue,'LineWidth',2);
            xlim([-100,400]);
            ylim([0,0.028]);
            set(gca, "Layer", "top");
            title(['Participant ',num2str(str2double(sList{s}))]);
            if s == size(subj_info_bjh_blink,2)
                lgnd = legend('Attended Stream','Ignored Stream');
                lgnd.Position(1) = 0.81;
                lgnd.Position(2) = 0.15;
                lgnd.Box = 'off';
                lgnd.FontSize = 8;
                xlabel('Time Lag [ms]');
                ylabel('GFP [a.u.]');
            end
            idxS = idxS + 1;
        end
    end
    sgtitle(['Global Field Power of Individual Cross-Correlation Functions',newline,...
        'Between the EEG and the Speech Envelope']);
    print(gcf,[pathoutSegWithBlink,'IndividualGFP'],'-dtiffn');
    print(gcf,[pathoutSegWithBlink,'IndividualGFP'],'-dpng','-r300'); 
    close;

%% Extract neural measure of attention (attentional gain)
    attGainAllBlocks = cell(size(subj_info_bjh_blink,2),2);
    % Calculate attentional gain values (50 - 200 ms)
    peak_range = lag_ms >=50 & lag_ms <=200;
    
    for s = 1:size(subj_info_bjh_blink,2)
        attGainAllBlocks{s,1} = subj_info_bjh_blink(s).subj_id;
        % Calculate difference over time-averaged window
        attGainAllBlocks{s,2} = mean(gfpAtt(s,peak_range),2) - mean(gfpIgn(s,peak_range),2);
    end
    save([pathoutSegWithBlink,'attGainAllBlocks.mat'],'attGainAllBlocks');

end

