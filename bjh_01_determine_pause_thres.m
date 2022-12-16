function bjh_01_determine_pause_thres(MAINPATH,pathoutThres,streamNo,fsNew)
%% plots the distribution of sound intensity values to determine an intensity threshold for pauses
% Input:    MAINPATH:       directory to load the audio files from
%           pathoutThres:   directory where to save the visualized
%                           intensity distributions
%           streamNo:       number of audio stream to be processed (1:left, 2:right)
%           fsNew:          sampling rate to which audio will be resampled
% 
% author: Bjoern Holtze 
% date: 10.08.2022

    % extract stream files
    fileList = dir([MAINPATH,'stimuli',filesep,'Jaeger2020',filesep,'Stream',num2str(streamNo),'*.wav']);

    % concatenate streams
    streamConc = [];
    for b = 1:size(fileList,1)
        [stream,fs] = audioread([fileList(b).folder,filesep,fileList(b).name]);
        streamConc = vertcat(streamConc,stream);
    end

    %% Stream 1
    % rectify speech signal 
    absStream = abs(streamConc);
    % moving average over 10 ms
    smoothStream = movmean(absStream,0.01*fs);
    % transform into dB
    dbStream = log10(smoothStream);
    % resample dB waveform
    resampledStream = resample(dbStream,fsNew,fs);


    % plot audio signal, intensity and thresholds
    plotTime = 10;
    timvec = linspace(0,plotTime,plotTime*fs);
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,3,1:2);
    plot(timvec,absStream(1:plotTime*fs));
    hold on;
    plot(timvec,smoothStream(1:plotTime*fs),'k','LineWidth',1);
    xlabel('Time [s]');
    ylabel('Intensity [a.u.]');
    legend('rectified audio','moving average','box','off','Location','northwest');
    box off;
    subplot(2,3,4:5);
    plot(linspace(0,plotTime,plotTime*fsNew),resampledStream(1:plotTime*fsNew));
    hold on;
    xlabel('Time [s]');
    ylabel('Intensity [dB]');
    ylim([min(resampledStream)*1.1,max(resampledStream)*1.1]);
    title('Transformed to dB and resampled to 500 Hz');
    box off;
    subplot(2,3,6);
    histogram(resampledStream,-5:0.05:0,'Orientation','horizontal');
    ylabel('Intensity [dB]');
    ylim([min(resampledStream)*1.1,max(resampledStream)*1.1]);
    box off;

    saveas(gcf,[pathoutThres,'pauseThres_stream_',num2str(streamNo),'.png']);
    close;

end

