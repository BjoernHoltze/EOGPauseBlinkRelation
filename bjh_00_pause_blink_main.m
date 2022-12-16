%% Pause-Blink-Relation
% author: Bjoern Holtze
% date: 15.12.2022

%%%%%% General Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MAINPATH = fullfile(pwd, '..', filesep);
    RAWPATH = [MAINPATH,'..',filesep,'raw_data',filesep];
    SOURCEDATAPATH = fullfile(MAINPATH,'bjh_pause_blink',filesep, 'sourcedata', filesep);
    addpath(fullfile(MAINPATH,'..','software', filesep, 'eeglab2020_0', filesep)); 
    eeglab;
    close 'EEGLAB v2020.0';
    
    DATAPATH = [MAINPATH, 'data', filesep];
    if ~exist(DATAPATH,'dir')
        mkdir(DATAPATH);
    end
    
    sList = {'001','002','003','004','005','006','007','008','009','010','011','012','013','014','015',...
    '016','017','018','019','020','021','022','023','024','025','026','027','028','029','030',...
    '031','032','033','034','035','036','037','038','039','040','041'};
    
    % needs to be switched off, does not work without original sound files
    % (original sound files cannot be provided due to data security issues)
    config.det_pause_thres = 0; % switched off
    % needs to be switched off, does not work without original sound files
    config.extract_pauses = 0; % switched off
    config.rmClosePausesAndPausesClose2Name = 1; 
    % needs to be switched off, this has been done when creating the .set files for BIDS
    % raw data connot be provided due to data security of the EEG data
    config.import_select_addVEOG = 0; % switched off
    config.extract_blinks = 1; 
    config.blinkRelative2Pause = 1;
    config.blinkRelative2PauseSorted = 1;
    config.plotBlinkHistRelative2PauseSortedByPauseDur = 1;
    config.plotblinkRelative2PauseFigure2 = 1;
    config.plot_BlinkRel2PauseSorted_AllInOne = 1;
    % should be switched off as it takes multiple hours to complete 
    % the resulting structure can be found in the sourcedata folder 
    config.computeSegWithBlink = 0; % switched off
    config.plotPrepauseAndPauseCompared2Random = 1;
    config.plotPrepauseVsPause = 1;
    config.plotAttSegVsIgnSeg = 1;
    config.plotCorrWithNeuralMeasure = 1;
    
%% determine amplitude threshold for pauses
    pathoutThres = [DATAPATH,'pauses',filesep];
    if ~exist(pathoutThres,'dir')
        mkdir(pathoutThres);
    end
    streamNo = [1,2];
    fsNew = 500;
    
    if config.det_pause_thres
        for s = 1:size(streamNo,2)
            % determine the intensity threshold for pause detection
            bjh_01_determine_pause_thres(MAINPATH,pathoutThres,streamNo(s),fsNew);
        end
    end
    
%% extract pauses (onsets, offsets, duration)
    pathoutPause = [DATAPATH,'pauses',filesep];
    if ~exist(pathoutPause,'dir')
        mkdir(pathoutPause);
    end
    ampThres1 = -1.9;
    ampThres2 = -2.2;
    minPause = 0.2;
    minSpeech = 0.015;
    fsNew = 500;
    
    if config.extract_pauses
        % identify pauses based on intensity threshold, minimum pause and speech duration
        % creates structure containing pause onsets, pause offsets and pause durations
        % write text file which can be loaded into Audacity to inspect detected pauses
        [pauseStructInit] = bjh_02_extract_pauses(MAINPATH,pathoutPause,ampThres1,ampThres2,minPause,minSpeech,fsNew);
        save([pathoutPause,'pauseStructInit.mat'],'pauseStructInit');
    else
        load([SOURCEDATAPATH,'pauseStructInit.mat'],'pauseStructInit');
    end
    
%% remove pauses which are to close to each other or which are closer than +/- 5 seconds to a name occurrence

    if config.rmClosePausesAndPausesClose2Name
        % delete pause p if it starts less than a second after pause p-1 ended
        % delete pause p if pause p+1 starts less than a second after pause p started
        % delete pause p if its duration is longer than one second
        % for data from Holtze et al. (2021) remove pauses which are closer
        % than +/- 5 seconds to a name occurence
        [pauseStructMaj,pauseStructBjhAtt1,pauseStructBjhAtt2] = ...
        bjh_03_rmClosePausesAndPausesClose2Name(SOURCEDATAPATH,pathoutPause,pauseStructInit);
        save([pathoutPause,'pauseStruct.mat'],'pauseStructMaj','pauseStructBjhAtt1','pauseStructBjhAtt2');
    else
        load([pathoutPause,'pauseStruct.mat'],'pauseStructMaj','pauseStructBjhAtt1','pauseStructBjhAtt2');
    end

    
%% Immport EEG cap data from Jaeger et al. 2020 and Holtze et al. 2021
    delay.maj = 88/1000; % in s
    delay.bjh = 102/1000; % in s

    if config.import_select_addVEOG
        pathoutSet = [DATAPATH,'set_files',filesep];
        if ~exist(pathoutSet,'dir')
            mkdir(pathoutSet);
        end
        % imports EEG cap data of spe01.xdf and spe02.xdf, merges both, and
        % epochs according to 10-minute blocks [-5, 605]
        bjh_04_import_and_addVEOG(RAWPATH,SOURCEDATAPATH,pathoutSet,sList,delay);
    end

%% Extract eye blinks (Blinker Toolbox)
    pathoutBlink = [DATAPATH,'blinks',filesep];
    if ~exist(pathoutBlink,'dir')
        mkdir(pathoutBlink);
    end
    fileoutBlink = [pathoutBlink,'Blink'];
    visTimeSeries = 0; % switch on to visualize EOG data and detected blinks
    signalSTD = 5; % initial standard deviation criterion to detect potential blinks
    correlationThresholdTop = 0.9; % correlation threshold for "best" blinks
    zThres = [0.8,2;0.9,5]; % correlation and robust standard deviation for "good" and "best" blinks
    showMaxDist = false; % switch on to show blink amplitude distribution
    
    if config.extract_blinks
        corrCoeffVec = bjh_05_extract_blinks(MAINPATH,SOURCEDATAPATH,fileoutBlink,sList,visTimeSeries,signalSTD,...
            correlationThresholdTop,zThres,showMaxDist);
    end

    
%% create blink epochs time-locked to pause onsets
    pathoutBlinkRelative2Pause = [DATAPATH,'BlinkRelative2Pause',filesep];
    if ~exist(pathoutBlinkRelative2Pause,'dir')
        mkdir(pathoutBlinkRelative2Pause);
    end
    epoch.start = -1; % time before pause onset
    epoch.end = 1; % time after onset
    
    if config.blinkRelative2Pause
        minBlinks100 = bjh_07_create_blinkRelative2Pause(SOURCEDATAPATH,pathoutPause,fileoutBlink,...
            pathoutBlinkRelative2Pause,sList,epoch);
        save([pathoutBlinkRelative2Pause,'minBlinks100.mat'],'minBlinks100');
    else
        load([pathoutBlinkRelative2Pause,'minBlinks100.mat'],'minBlinks100');
    end
  
%% create blink epochs sorted by pause duration
    if config.blinkRelative2PauseSorted
        bjh_07_create_blinkRelative2PauseSorted(SOURCEDATAPATH,pathoutPause,pathoutBlinkRelative2Pause);
    end
   
%% plot all individual blink scatterplots and histograms (Supplementary Figure 1)
    edges = epoch.start:0.1:epoch.end;
    if config.plot_BlinkRel2PauseSorted_AllInOne
        permResults = bjh_08_plot_blinkRel2PauseSorted_AllInOne(SOURCEDATAPATH,...
        pathoutBlinkRelative2Pause,epoch,edges,minBlinks100,sList);
    end
    
%% plot blink distribution relative to pause onset (Figure 2)
    if config.plotblinkRelative2PauseFigure2
        bjh_08_plotSelectedAndGroupAveragePauseBlinkRelation(SOURCEDATAPATH,...
            pathoutBlinkRelative2Pause,epoch,edges,minBlinks100,permResults);
    end
    
%% pauses and pre-pauses with blinks compared to random segments
    pathoutSegWithBlink = [MAINPATH,'data',filesep,'SegWithBlinks',filesep];
    if ~exist(pathoutSegWithBlink,'dir')
        mkdir(pathoutSegWithBlink);
    end
    nPerm = 10000;
    
    if config.computeSegWithBlink
        segWithBlink = bjh_09_createPrepauseAndPauseCompared2Random(SOURCEDATAPATH,pathoutPause,fileoutBlink,pathoutSegWithBlink,nPerm);
    else
        load([SOURCEDATAPATH,'SegWithBlink.mat'],'segWithBlink');
    end
    
%% plot pre-pause and pause with blinks compared to random distribution (Supplementary Figure 2,3)
    if config.plotPrepauseAndPauseCompared2Random
        permResults = bjh_10_plotPrepauseAndPauseCompared2Random(SOURCEDATAPATH,pathoutSegWithBlink,nPerm,...
            minBlinks100,permResults,sList,segWithBlink);
    end
    
%% plot difference in proportion of segments with blinks (Supplementary Figure 4,5)
    if config.plotPrepauseVsPause
        permResults = bjh_11_plotPrepauseVsPause(SOURCEDATAPATH,pathoutSegWithBlink,nPerm,minBlinks100,...
            permResults,sList,segWithBlink);
    end
    
%% plot difference in proportion of segments with blinks (Supplementary Figure 6,7)
    if config.plotAttSegVsIgnSeg
        bjh_12_plotAttSegVsIgnSeg(SOURCEDATAPATH,pathoutSegWithBlink,nPerm,minBlinks100,sList,segWithBlink);
    end

%% plot correlation between chiSquare and neural measure of attention (Figure 4)
    if config.plotCorrWithNeuralMeasure
        bjh_13_plotNeuralGain_PauseWithBlinkStdAboveMean(SOURCEDATAPATH,pathoutSegWithBlink,minBlinks100,segWithBlink);
    end

