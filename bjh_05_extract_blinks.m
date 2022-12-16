function [corrCoeffVec] = bjh_05_extract_blinks(MAINPATH,SOURCEDATAPATH,fileoutBlink,sList,visTimeSeries,signalSTD,...
            correlationThresholdTop,zThres,showMaxDist)
%% extracts eye blinks using the BLINKER toolbox 
% input:    MAINPATH:       directory used to load .set files
%           SOURCEDATAPATH: directory where participant information is stored
%           fileoutBlink:   directory including first part of filename
%                           where blink structure will be stored
%           sList:          cell array containing number of participants as string
%           visTimeSeries:  boolean indicating whether detected blink
%                           should be visualized
%           signalSTD:      standard deviation used to detect potential blinks
%           correlationThresholdTop: correlation threshold for "best" blinks
%           zThres:         array containing correlation threshold and
%                           robust std for "best" and "good" blinks
%           showMaxDist:    boolean indicating whether blimk amplitude
%                           distribution should be shown
% 
% Output:   corrCoeffVec:   vector containing correlation coefficients
%                           of the left and right vertical EOG
%
% author: Björn Holtze
% date: 12.09.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');
corrCoeffVec = zeros(size(subj_info_bjh_blink,2),1);
    

for s = 1:size(subj_info_bjh_blink,2)
    EEG = pop_loadset('filename',['sub-',sList{s},'_task-attendedSpeakerParadigm_eeg.set'],...
        'filepath',[MAINPATH,'bjh_pause_blink',filesep,'sub-',sList{s},filesep,'eeg',filesep]);   
    
    % specify parameters
    clear params;
    params = checkBlinkerDefaults(struct(), getBlinkerDefaults(EEG));
    params.signalTypeIndicator = 'UseLabels';
    EEG_filt = pop_eegfiltnew(EEG, params.lowCutoffHz, params.highCutoffHz);
    corrCoeffMat = corrcoef(EEG_filt.data(strcmp({EEG_filt.chanlocs.labels},'leftVEOG'),:),...
        EEG_filt.data(strcmp({EEG_filt.chanlocs.labels},'rightVEOG'),:));
    corrCoeffVec(s,:) = corrCoeffMat(1,2);
    if corrCoeffMat(1,2) > 0.7
        params.signalLabels = {'avgVEOG'};
    else
        eegplot(EEG_filt.data(strcmp({EEG_filt.chanlocs.labels},'leftVEOG') | ...
            strcmp({EEG_filt.chanlocs.labels},'rightVEOG'),:),...
            'eloc_file',EEG_filt.chanlocs,'winlength',10);
        params.signalLabels = input('leftVEOG or rightVEOG: ');
    end
    params.subjectID = ['sub-',sList{s}];
    params.uniqueName = '';
    params.experiment = '';
    params.task = 'Competing Speaker Paradigm';
    params.excludeLabels = '';
    params.dumpBlinkerStructures = true;
    params.showMaxDistribution = showMaxDist;
    params.dumpBlinkImages = false;
    params.verbose = false;
    params.dumpBlinkPositions = false;
    params.fileName = [MAINPATH,'bjh_pause_blink',filesep,'sub-',sList{s},filesep,'eeg',filesep,...
        'sub-',sList{s},'_task-attendedSpeakerParadigm_eeg.set'];
    params.blinkerSaveFile = [fileoutBlink,'_sub-',sList{s},'.mat'];
    params.blinkerDumpDir = '';
    params.keepSignals = false;
    params.blinkAmpRange = [3,50];
    % these were changed after visual inspection of the extracted blinks
    params.stdThreshold = signalSTD; % a higher value removes those peaks with a very small amplitude
    % a lower correlationThresholdTop leads to a lower bestMedian and
    % consequently removes less blinks later on based on the zThres criteria
    params.correlationThresholdTop = correlationThresholdTop;
    % a lower threshold for good blinks (0.8) and a lower threshold for
    % best blinks (0.9) removes less blinks which according to visual
    % inspection are in fact blinks
    params.zThresholds = zThres;
    
    [EEG, ~, blinks, blinkFits, ~, ~, ~] = pop_blinker(EEG,params);
    
    
    if visTimeSeries
        %% visual inspection
        blinkMarker = nan(1,EEG.pnts);
        blinkMarker([blinkFits.maxFrame]) = 100;
        
        
        for t = 1:30000:EEG.pnts-30000
            figure('units','normalized','outerposition',[0 0 1 1]);
            originalAxes = axes;
            axPos = originalAxes.Position;
            plot((t:t+30000)/EEG.srate,blinks.signalData([blinks.signalData.signalNumber] == abs(blinks.usedSignal)).signal(1,t:t+30000));
            hold on;
            ylim([-200,400]);
            xlim([t/EEG.srate,(t+30000)/EEG.srate]);
            plot((t:t+30000)/EEG.srate,blinkMarker(t:t+30000),'*');
            xlabel('Time [s]');
            ylabel('Voltage [\muV]');
            sgtitle(['Used: ',blinks.signalData([blinks.signalData.signalNumber] == abs(blinks.usedSignal)).signalLabel]);
            xAxisWidth = 1-axPos(1)-(1-axPos(3));
            currentMarkers = find([blinkFits.maxFrame] > t & [blinkFits.maxFrame] < t+30000);
            for m = 1:size(currentMarkers,2)
                axes('position',[axPos(1)+((blinkFits(currentMarkers(m)).maxFrame-(t-1))/30000)*xAxisWidth 0.2 .1 .1 ]);
                topoplot(EEG_filt.data(:,blinkFits(currentMarkers(m)).maxFrame),EEG_filt.chanlocs,'gridscale',200,'whitebk','on','headrad',0);
            end
            waitforbuttonpress;
            close;
        end
        
        while(1)
            i = input('Enter "1" to continue: ');
            if i == 1
                break;
            end
        end
    end
end
end


