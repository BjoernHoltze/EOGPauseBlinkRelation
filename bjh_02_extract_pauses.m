function [pauseStructInit] = bjh_02_extract_pauses(MAINPATH,pathoutPause,ampThres1,ampThres2,minPause,minSpeech,fsNew)
%% determines pauses based on intensity threshold, minimum pause and speech duration
% Input:    MAINPATH:       directory to load the audio files from
%           pathoutPause:   directory where to save the pause structure
%           ampThres1:      intensity threshold for stream 1
%           ampThres2:      intensity threshold for stream 2
%           minPause:       minimum pause duration
%           minSpeech:      minimum speech duration
%           fsNew:          sampling rate to which audio will be resampled
% 
% author: Bjoern Holtze 
% date: 13.08.2022

% create output structure
pauseStructInit = struct;
subfieldStream = {'Stream1','Stream2'};
subfieldBlock = {'Block1','Block2','Block3','Block4','Block5','Block6'};

for sNo = 1:2
    disp(['Stream ',num2str(sNo),' processing ...']);
    fileList = dir([MAINPATH,'stimuli',filesep,'Jaeger2020',filesep,'Stream',num2str(sNo),'*.wav']);
    if sNo == 1
        ampThres = ampThres1;
    elseif sNo == 2
        ampThres = ampThres2;
    end
    figure('units','normalized','outerposition',[0 0 1 1]);
    for bNo = 1:6
        disp(['   Block ',num2str(bNo),' processing ...']);
        [stream,fs] = audioread([fileList(bNo).folder,filesep,fileList(bNo).name]);
        
        % rectify speech signal
        absStream = abs(stream);
        % moving average over 10 ms
        smoothStream = movmean(absStream,0.01*fs);
        % transform into dB
        dbStream = log10(smoothStream);
        % resample dB waveform
        resampledStream = resample(dbStream,fsNew,fs);
        
        
        % find edges in the initial pause vector
        logPauseInit = resampledStream < ampThres;
        logPauseEdge = zeros(size(logPauseInit,1),1);
        for sample = 1:size(logPauseInit,1)-minPause*fsNew
            if logPauseInit(sample) == 0 && logPauseInit(sample+1) == 1
                logPauseEdge(sample) = 0.5;
            elseif logPauseInit(sample) == 1 && logPauseInit(sample+1) == 0
                logPauseEdge(sample) = 1;
            else
                logPauseEdge(sample) = 0;
            end
        end
        
        % convert speech segments which are shorter than minSpeech to pauses
        logPauseEdge(end) = 0.5;
        logSpeech = logPauseEdge;
        for sample = 1:size(logSpeech,1)
            if logPauseEdge(sample) == 1 && find(logPauseEdge(sample:end) == 0.5,1,'first')/fsNew <= minSpeech
                logSpeech(sample) = 0;
                logSpeech(sample+find(logPauseEdge(sample:end) == 0.5,1,'first')-1) = 0;
            end
        end
        
        % convert pauses which are shorter than than minPause to speech
        logSpeech(end) = 1;
        logOnOff = logSpeech;
        for sample = 1:size(logPauseInit,1)
            if logSpeech(sample) == 0.5 && find(logSpeech(sample:end) == 1,1,'first')/fsNew <= minPause
                logOnOff(sample) = 0;
                logOnOff(sample+find(logSpeech(sample:end) == 1,1,'first')-1) = 0;
            end
        end
        
        
        % extract pause features (onset,offset,duration)
        idx = 1;
        pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause = zeros(size(logOnOff));
        for sample = 1:size(logPauseInit,1)
            if logOnOff(sample) == 0.5
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(idx) = sample;
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(idx) = ...
                    sample + find(logOnOff(sample:end) == 1,1,'first') - 1;
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(idx) = ...
                    (pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(idx) - ...
                    pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(idx))/fsNew;
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause(...
                    sample:sample+find(logOnOff(sample:end) == 1,1,'first')-1) = 1;
                
                % create table for markers in audacity
                markerTable(idx,:) = [pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(idx)/fsNew,...
                    pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(idx)/fsNew,idx];
                
                idx = idx + 1;
            end
        end
        
        pauseStructInit.fsNew = fsNew;
        
        % plotting
        subplot(2,3,bNo);
        plotTimeMin = 0; % in s
        plotTimeMax = 10; % in s
        plot(linspace(plotTimeMin,plotTimeMax,(plotTimeMax-plotTimeMin)*fs),stream(plotTimeMin*fs+1:plotTimeMax*fs));
        ylim([-1,1]);
        hold on;
        plot(linspace(plotTimeMin,plotTimeMax,(plotTimeMax-plotTimeMin)*fsNew),...
            pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause(plotTimeMin*fsNew+1:plotTimeMax*fsNew));
        xlabel('Pause Duration [s]');
        ylim([-1,1]);
        title(['First 10s of Block ',num2str(bNo)]);
        
            % write marker
            if sNo == 1 && bNo == 1
            dlmwrite([MAINPATH,'stimuli',filesep,'Jaeger2020',filesep,'pauseMarker_stream_',...
                num2str(sNo),'block_',num2str(bNo),'_',num2str(ampThres),'_',num2str(minSpeech),'.txt'],markerTable,'\t');
            elseif sNo == 2 && bNo == 1
            dlmwrite([MAINPATH,'stimuli',filesep,'Jaeger2020',filesep,'pauseMarker_stream_',...
                num2str(sNo),'block_',num2str(bNo),'_',num2str(ampThres),'_',num2str(minSpeech),'.txt'],markerTable,'\t');
            end
            clear markerTable;
            
    end
    sgtitle(['Stream ',num2str(sNo)]);
    saveas(gcf,[pathoutPause,'pauses_stream_waveform_',num2str(sNo),'.png']);
    close all;
end



end

