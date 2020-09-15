% team01_DA_ECGDataSegbySleepStage_v01.m
% just a simple example showing how to segment ECG data for any stages
% what we need:
% -- load 'data', 'header', 'iBlk', ect. from *_iBlk_*.mat file
% -- 'hypHeight',for the stage information in fliplr(hypnogram(:, 1)'), and ...
% -- 'hyp', for correspondent time stamps in hyp(:, 2);

%clear all;
chLabel = 'ECG';      
%% load data
[fileName, pathName] = uigetfile('*.mat','Select the .mat file to display'); % only n7_iBlk_x.mat for now
load([pathName, fileName]); % 'data', 'header', ...
idx = strfind(fileName, '_');
fnBase = fileName(1:idx(1)-1);
fnHypnogram = [fnBase, '_Hypnogram.mat'];
load(fullfile(pathName, fnHypnogram));

%% define chNO for ECG / chLabel
for iCH = 1:numel(header.labels)
    if strcmp(header.labels(iCH), chLabel)
        chNO = iCH;
        break;
    end
end

startTimeStr = header.starttime;
idx = findstr(startTimeStr, '.');
startTimeH = str2num(startTimeStr(1:idx(1)-1));
startTimeM = str2num(startTimeStr(idx(1)+1:idx(2)-1));
startTimeS = str2num(startTimeStr(idx(2)+1:end));
startTime0 = startTimeH*3600 + startTimeM*60 + startTimeS; % startTime(s) for the very first data point 

startTime_iBlk = startTime0 + (iBlk-1)*3600; % startTime (s) for the i-th Blk data
tTick_iBlk = startTime_iBlk + [0:numel(data{chNO})-1]/header.samplerate(chNO); % time stamp for the iBlk data

%% subject data basic statement
subjectData.ID=fnBase;                             
subjectData.iBlkNo=iBlk;
subjectData.ecg_sampRate=sampRate;  
subjectData.labels={'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'};

%%
nRecordsPerBlk = 60*60; % in seconds
last_Blk = ceil(header.records/nRecordsPerBlk);
nEpochs=numel(tTick_iBlk)/header.samplerate(chNO)/30;%compute the number of points in one block of sleep stage gram
hypnogram=hypnogram(:,2);
idx_hypnogram_iBlk_start=find(hypnogram==tTick_iBlk(1));%find the beginning idex of hypnogram in every block

if iBlk==last_Blk
hypnogram_iBlk_stage=hypHeight(1,idx_hypnogram_iBlk_start:end)';
hypnogram_iBlk_tTick=hypnogram(idx_hypnogram_iBlk_start:end);
else
%% extract block n of EEG 
idx_hypnogram_iBlk_end=find((hypnogram-3600)==hypnogram(idx_hypnogram_iBlk_start));%find the ending idex of hypnogram in every block
hypnogram_iBlk_stage=hypHeight(1,idx_hypnogram_iBlk_start:idx_hypnogram_iBlk_end)';
hypnogram_iBlk_tTick=hypnogram(idx_hypnogram_iBlk_start:idx_hypnogram_iBlk_end);
end
figure,plot(hypnogram_iBlk_tTick,hypnogram_iBlk_stage)
yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
title(['sleep staging of iBlk ',num2str(iBlk)])

%% Store the data of channel 6 into ecgdata
ecgData=data{chNO};
figure;
%% Traversing all sleep stages,Complete ECG acquisition at each sleep stage
for hyp_anystage=1:6 
%% find indexs of all points and Corresponding timestamps in sleep stage you choose
idx_Sn=find(hypnogram_iBlk_stage==hyp_anystage); 
tTick_Sn=hypnogram_iBlk_tTick(idx_Sn);

%% improvement: row 70-75 may be simplified
% idx_diff=idx_Sn(2:end)-idx_Sn(1:end-1);
% idx_break=[0 find(idx_diff~=1)];
if length(idx_Sn(:))~=0 %determine if the stage exists
    %% find the break point
    idx_break=0;
    for n=1:length(idx_Sn)-1
        if  (idx_Sn(n+1)-idx_Sn(n))~=1 % break point=difference is not 1
            idx_break=[idx_break n];%push the index of each breakpoint onto variable break_point
        end
    end
    %%  Segment ECGs based on sleep staging breakpoints
    for n=1:length(idx_break)
        ecg_tTick_Sn_secn(n)=(tTick_Sn(1+idx_break(n))-hypnogram_iBlk_tTick(1))*sampRate;%Starting point of each segment ECG
        if n<=length(idx_break)-1   %Determine if it is the last segment, index processing is different
            dur_Sn_secn(n)=tTick_Sn(idx_break(n+1))-tTick_Sn(1+idx_break(n));
            
            %% validate the segmentationn by sleep stage
%             plot(hypnogram_iBlk_tTick(1+idx_break(n):idx_break(n+1)),hypnogram_iBlk_stage(1+idx_break(n):idx_break(n+1)),'r*')
%             hold on
%             yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
%             title(['sleep staging of iBlk ',num2str(iBlk)])
        else
            dur_Sn_secn(n)=tTick_Sn(end)-tTick_Sn(idx_break(n)+1);%the last segment
            
          %% validate the segmentationn by sleep stage
%             plot(hypnogram_iBlk_tTick(1+idx_break(n):end),hypnogram_iBlk_stage(1+idx_break(n):end),'r*')
%             hold on
%             yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
%             title(['sleep staging of iBlk ',num2str(iBlk)])
        end
        if ecg_tTick_Sn_secn(n)~=0  % Determine if it is the first stage in the hypnogram,because if it is,there will be an error in index
            Sn(n).ecgSignal=ecgData(ecg_tTick_Sn_secn(n):(ecg_tTick_Sn_secn(n)+dur_Sn_secn(n)*sampRate));
            Sn(n).ecg_tTick=tTick_iBlk(ecg_tTick_Sn_secn(n):(ecg_tTick_Sn_secn(n)+dur_Sn_secn(n)*sampRate));
        else
            Sn(n).ecgSignal=ecgData(1:(1+dur_Sn_secn(n)*sampRate));
            Sn(n).ecg_tTick=tTick_iBlk(1:(1+dur_Sn_secn(n)*sampRate));
        end
        subjectData.S(hyp_anystage).sec(n).ecgSignal=Sn(n).ecgSignal;
        subjectData.S(hyp_anystage).sec(n).ecg_tTick=Sn(n).ecg_tTick;
    end
else
    subjectData.S(hyp_anystage).sec(1).ecgSignal=[];
    subjectData.S(hyp_anystage).sec(1).ecg_tTick=[];
end
clear ecg_tTick_Sn_secn dur_Sn_secn Sn idx_Sn tTick_Sn idx_break

%% choose any code you like
% idx_break=1;
% for n=1:length(idx_Sn)-1
%     if(find((idx_Sn(n+1)-idx_Sn(n))~=1)) % break point=difference is not 1
%         idx_break=[idx_break  n  n+1];
%     end
% end
%  idx_break=[idx_break idx_Sn(end)];
% for n=1:2:length(idx_break)
%     ecg_tTick_Sn_secn_start(floor((n+1)/2)=(tTick_Sn(idx_break(n))-hypnogram_iBlk_tTick(1))*sampRate;
%     ecg_tTick_Sn_secn_end(floor((n+2)/2)=(tTick_Sn(idx_break(n+1))-hypnogram_iBlk_tTick(1))*sampRate;
% end
% for n=1:length(idx_break)/2
%     Sn(n).ecgSignal=ecgData(ecg_tTick_Sn_secn_start(n):ecg_tTick_Sn_secn_end(n));
%     Sn(n).ecg_tTick=tTick_iBlk(ecg_tTick_Sn_secn_start(n):ecg_tTick_Sn_secn_end(n));
%     subjectData.S(input_hyp_stage).sec(n).ecgSignal=Sn(n).ecgSignal;
%     subjectData.S(input_hyp_stage).sec(n).ecg_tTick=Sn(n).ecg_tTick;
% end
end

%% store the collected data for .mat
further_procdataPath ='D:\大学作业\电子课程设计2\subjectcode';
fnECGdata = [fnBase,'_ECG_SegbySleepstage_of_iBlk',num2str(iBlk),'.mat'];
ecgprodata_bystage = subjectData;
save(fullfile(further_procdataPath,fnECGdata),'ecgprodata_bystage');

%% Choose any sleep stage data you want to 
while(1)
    disp('Which stage in hypnogram you want to collect?');
    disp('Options: 1.S4   2.S3   3.S2   4.S1   5.REM   6.AWAKE  7.Exit ');
    prompt='Please Enter the number before the option : ';
    choice_ofsleepstage=input(prompt);
    %% Visualization of ECG in all sections of hypnogram stage ? of iBlk ?
    mark=['r*','b*','c*','m*','g*'];
    if 1<=choice_ofsleepstage && choice_ofsleepstage<=6
        figure;
        for n=1:length(subjectData.S(choice_ofsleepstage).sec)
            % subplot(length(idx_break),1,n)
            % plot(Sn(n).ecg_tTick,Sn(n).ecgSignal,'b');% Plot separately
            plot(subjectData.S(choice_ofsleepstage).sec(n).ecg_tTick,subjectData.S(choice_ofsleepstage).sec(n).ecgSignal,mark(n));%plot in one figure
            hold on
        end
        xlabel('time(s)');ylabel('Amp');
        if 1<=choice_ofsleepstage && choice_ofsleepstage<=4
            title(['ECG in S',num2str(5-choice_ofsleepstage) ,' of iBlk ',num2str(iBlk)])
        elseif choice_ofsleepstage==5
            title(['ECG in REM of iBlk ',num2str(iBlk)])   
        else choice_ofsleepstage==6
            title(['ECG in AWAKE iBlk ',num2str(iBlk)]) 
        end
    else
        clear subjectData;
        disp('Exit...');
        break;
    end
end

    


