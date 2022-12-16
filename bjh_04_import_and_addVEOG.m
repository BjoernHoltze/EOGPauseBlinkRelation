function bjh_04_import_and_addVEOG(RAWPATH,SOURCEDATAPATH,pathoutSet,sList,delay)
%% imports xdf, selects relevant blocks and computes vertical EOG channel
% imports EEG_cap data of spe01.xdf and spe02.xdf, adds channel locations,
% accounts for time delay, merges both datasets (spe01 and spe02), 
% epochs according to 10 minute blocks ([-10, 610]), computes vertical EOG
% 
% input:    RAWPATH:        path where .xdf files are stored
%           SoURCEDATAPATH: path where electrode location file is stored
%           pathoutSet:     path where .set files are stored
%           sList:          cell array containing number of participants as string
%           delay:          [struct] time delay according to timing test 
%                           separately for Jaeger et al. 2020 (maj) and 
%                           Holtze et al. 2021 (bjh)
%
% author: Björn Holtze
% date: 06.09.22

load([SOURCEDATAPATH,'subj_info_bjh_blink.mat'],'subj_info_bjh_blink');

for s = 1:size(subj_info_bjh_blink,2)
    disp(['Processing subject ',subj_info_bjh_blink(s).subj_id,' ...']);
    
    if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
        SUBPATH = ['Jaeger2020', filesep];
    elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
        SUBPATH = ['Holtze2021', filesep];
    end
    % import spe01.xdf
    EEG_spe(1) = pop_loadxdf([RAWPATH,SUBPATH,subj_info_bjh_blink(s).subj_id,'_spe01.xdf'],'streamname','BrainAmpSeries');
    % import spe02.xdf
    EEG_spe(2) = pop_loadxdf([RAWPATH,SUBPATH,subj_info_bjh_blink(s).subj_id,'_spe02.xdf'],'streamname','BrainAmpSeries');
    
    if strcmp(subj_info_bjh_blink(s).subj_id,'maj_s21')
        EEG_spe(3) = pop_loadxdf([RAWPATH,SUBPATH,subj_info_bjh_blink(s).subj_id,'_spe03.xdf'],'streamname','BrainAmpSeries');
        % merge spe01 and spe02
        EEG = pop_mergeset(EEG_spe,1:3,0);
    else
        % merge spe01 and spe02
        EEG = pop_mergeset(EEG_spe,1:2,0);
    end
    
    % adapt channel information and define time delay (depending on dataset)
    if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj') % Jaeger2020
        EEG = pop_chanedit(EEG, 'load',{[SOURCEDATAPATH 'elec_96ch.elp']});
        delay_in_s = delay.maj; 
    elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh') % Holtze 2021
        EEG = pop_chanedit(EEG, 'load',{[SOURCEDATAPATH 'elec_64ch_original.elp']});
        delay_in_s = delay.bjh;
    end
    
    % account for time delay by shifting event latencies
    for e = 1:size(EEG.event,2)
        EEG.event(e).latency = EEG.event(e).latency + floor(delay_in_s * EEG.srate);
    end
      
    % epoch to extract 10 minute blocks
    EEG = pop_epoch(EEG,{'StartTrigger'},[0  600],'epochinfo','yes');
    
    % concatenate epoched to continuous data
    EEG = eeg_epoch2continuous(EEG);
    
    % sort the events by latency 
    EEG = pop_editeventvals(EEG,'sort',{'latency', 0});
    
    % compute left and right vertical channel
    if strcmp(subj_info_bjh_blink(s).subj_id(1:3),'maj')
        leftVEOG = EEG.data(strcmp({EEG.chanlocs.labels},'E84'),:)-...
            EEG.data(strcmp({EEG.chanlocs.labels},'E29'),:);
        rightVEOG = EEG.data(strcmp({EEG.chanlocs.labels},'E68'),:)-...
            EEG.data(strcmp({EEG.chanlocs.labels},'E30'),:);
        % remove all other channels
        EEG = pop_select(EEG,'channel',{'E84','E29','E68','E30'});
    elseif strcmp(subj_info_bjh_blink(s).subj_id(1:3),'bjh')
        leftVEOG = EEG.data(strcmp({EEG.chanlocs.labels},'E51'),:)-...
            EEG.data(strcmp({EEG.chanlocs.labels},'E19'),:);
        rightVEOG = EEG.data(strcmp({EEG.chanlocs.labels},'E46'),:)-...
            EEG.data(strcmp({EEG.chanlocs.labels},'E20'),:);
        % remove all other channels
        EEG = pop_select(EEG,'channel',{'E51','E19','E46','E20'});
    end
    EEG.data(EEG.nbchan+1,:) = leftVEOG;
    EEG.data(EEG.nbchan+2,:) = rightVEOG;
    EEG.data(EEG.nbchan+3,:) = mean(vertcat(leftVEOG,rightVEOG),1);
    EEG.nbchan = size(EEG.data,1);
    if ~isempty(EEG.chanlocs)
        EEG.chanlocs(EEG.nbchan-2).labels = 'leftVEOG';
        EEG.chanlocs(EEG.nbchan-1).labels = 'rightVEOG';
        EEG.chanlocs(EEG.nbchan).labels = 'avgVEOG';
    end
    
    % add subject subj_info
    EEG.filename = subj_info_bjh_blink(s).subj_id;
    EEG.setname = subj_info_bjh_blink(s).subj_id;
    
    % store EEG in ALLEEG(s)
    pop_saveset( EEG, 'filepath',[pathoutSet,'sub-',sList{s},'.set']);
    clear EEG_spe; clear EEG;
   
end
end

