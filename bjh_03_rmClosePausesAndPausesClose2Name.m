function [pauseStructMaj,pauseStructBjhAtt1,pauseStructBjhAtt2] = ...
    bjh_03_rmClosePausesAndPausesClose2Name(CONFIGPATH,pathoutPause,pauseStructInit)
%% removes pauses which are too close to each other or which are too close to name occurrence (Holtze et al. 2021)
% Input:    CONFIGPATH:         directory from which time points of name
%                               occurrences are retreived
%           pathoutPause:       directory where to save the pause structure
%           pauseStructInit:    initial structure containin all detected pauses
%
% Output:   pauseStructMaj:     structure containing all pauses for
%                               participants from Jaeger et al. 2020
%           pauseStructBjhAtt1: structure containing pauses for
%                               participants from Holtze et al. who attended stream 1
%                               (own name was included in stream 2)
%           pauseStructBjhAtt2: structure containing pauses for
%                               participants from Holtze et al. who attended stream 2
%                               (own name was included in stream 1)
% 
% author: Bjoern Holtze 
% date: 17.08.2022

subfieldStream = {'Stream1','Stream2'};
subfieldBlock = {'Block1','Block2','Block3','Block4','Block5','Block6'};
load([CONFIGPATH,'name_time.mat'],'name_time_c1','name_time_c2');

pauseStructMaj.fsNew = pauseStructInit.fsNew;
pauseStructBjhAtt1.fsNew = pauseStructInit.fsNew;
pauseStructBjhAtt2.fsNew = pauseStructInit.fsNew;

for sNo = 1:size(subfieldStream,2)
    figure('units','normalized','outerposition',[0 0 1 1]);
    for bNo = 1:size(subfieldBlock,2)
        % delete pause p if it starts less than a second after pause p-1 ended
        % delete pause p if pause p+1 starts less than a second after pause p started
        p = 2;
        while p < size(pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
            if (pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p) - ...
                    pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p-1))/pauseStructInit.fsNew <= 1 || ...
                    (pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p+1) - ...
                    pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p))/pauseStructInit.fsNew <= 1
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p) = [];
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p) = [];
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(p) = [];
            else
                p = p + 1;
            end
        end
        % delete pause p if its duration is longer than one second
        p = 1;
        while p <= size(pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
            if pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(p) > 1
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p) = [];
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p) = [];
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(p) = [];
            else
                p = p + 1;
            end
        end
        % update subfield logPause
        pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause = ...
            zeros(size(pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause));
        for p = 1:size(pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
            pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause(...
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p):...
                pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p)) = 1;
        end
        pauseStructMaj.(subfieldStream{sNo}).(subfieldBlock{bNo}) = ...
            pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo});
        
        % plot pause duration histogram
        subplot(2,3,bNo);
        histogram([pauseStructMaj.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration],0:0.01:1);
        xlabel('Pause Duration [s]');
        title(['Block ',num2str(bNo),' (',num2str(size(pauseStructMaj.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration,2)),...
            ' Pauses)']);
        ylim([0,60]);
        
        % initialize pauseStruct adapted to Holtze et al. 2021 (remove
        % pauses closer than +/- 5 seconds to a name occurrence
        pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}) = ...
            pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo});
        pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}) = ...
            pauseStructInit.(subfieldStream{sNo}).(subfieldBlock{bNo});
        % no name occurrence in 1st block, 6th block not included in Holtze et al. (2021)
        if bNo > 1 && bNo < 6
            % create pauseStructBjhAtt1 for those that attended speech
            % stream 1 (where names occured in speech stream 2)
            p = 1;
            while p <= size(pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
                if min(abs(pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p)-...
                        round(name_time_c2(bNo-1,:)*pauseStructInit.fsNew))) < pauseStructInit.fsNew*5 %
                    pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p) = [];
                    pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p) = [];
                    pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(p) = [];
                else
                    p = p + 1;
                end
            end
            % create pauseStructBjhAtt1 for those that attended speech
            % stream 2 (where names occured in speech stream 1)
            p = 1;
            while p <= size(pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
                if min(abs(pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p)-...
                        round(name_time_c1(bNo-1,:)*pauseStructInit.fsNew))) < pauseStructInit.fsNew*5 %
                    pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p) = [];
                    pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p) = [];
                    pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Duration(p) = [];
                else
                    p = p + 1;
                end
            end
            
            % update subfield logPause for pauseStructBjhAtt1
            pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause = ...
                zeros(size(pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause));
            for p = 1:size(pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
                pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause(...
                    pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p):...
                    pauseStructBjhAtt1.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p)) = 1;
            end
            % update subfield logPause for pauseStructBjhAtt2
            pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause = ...
                zeros(size(pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause));
            for p = 1:size(pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset,2)
                pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).logPause(...
                    pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Onset(p):...
                    pauseStructBjhAtt2.(subfieldStream{sNo}).(subfieldBlock{bNo}).Offset(p)) = 1;
            end
        end
    end
    sgtitle(['Stream ',num2str(sNo)]);
    saveas(gcf,[pathoutPause,'pauses_stream_histogram_',num2str(sNo),'.png']);
    close all;
end
end

