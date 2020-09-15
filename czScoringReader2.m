%% oringially developed by a group in Politecnico di Milano, Italy
% Major revisions made by CZ, Feb 23, 2020   czScoringReader.m
%   - organize the result into a struct, and save it into a single file
%   - change the file name to be descriptive, and relating to the raw data file
%   - save the file into (procData) for intermediate data and results
%   - change some variables to be more descriptive
% note: Sleep stage (W=wake, S1-S4=sleep stages, R=REM, MT=body movements)
%
%

%% REMlogic report reader
% this file reads .txt files with sleep macrostructure and microstructure
% annotations exported from REMlogic
% returns the vectors
% hyp___________containing the hypnogram evaluated for each 30 s epochs
% time_tot______containing the starting time in seconds of CAP phases A
% duration______containing the duration of each phase A in seconds
% type_ar_______containing the type of phase A (A1, A2 or A3)

% The format of the header is
% Sleep Stage	Position	Time [hh:mm:ss]	Event	Duration[s]	Location

% Developed by Sara Mariani, MSc (sara1.mariani@mail.polimi.it), under the
% supervision of Professor Anna M. Bianchi and Professor Sergio Cerutti,
% at the Bioengineering Department of Politecnico di Milano, Italy. 


clear all;

% close all;
% 
procDataPath='D:\大学作业\电子课程设计2\n7prodata';
startFlag = 0;
hypnogram = []; % hypnogram
tHour = [];    % hours
tMinute = [];    % minutes
tSecond = [];    % seconds

[fileName, pathName] = uigetfile('*.txt','Select report with annotations');
fid = fopen([pathName, fileName],'r'); % opens the .txt files and returns the id
fnBase=fileName(1:numel(fileName)-4);
fnHypnogram=[fnBase,'_Hypnogram.mat'];
fullfile(procDataPath,fnHypnogram);




%% read the file 
display(['Reading file... fileName=', fileName]);
iLine = 0;
while 1
    
    tline = fgetl(fid); 
    iLine = iLine + 1;
%     disp([num2str(iLine), ': ', tline]);
    if ~ischar(tline)
        break,
    end
    if numel(tline)>10
%         disp(['iLine=', num2str(iLine), ' ... ', tline]);
        if tline(1:11) == 'Sleep Stage'
           startFlag = 1;
           hyp_k = 0; % hyp counter
           cap_j = 0; % CAP counter
        end
        if startFlag==1
            colPos = strfind(tline,':');
            if numel(colPos)==0
                colPos = strfind(tline,'.');
            end
            
           %% sleep stages 0-5, 7
            if tline(colPos(2)+4:colPos(2)+8)=='SLEEP' % sleep stage: write on hyp
                hyp_k = hyp_k+1; % 
                if tline(colPos(2)+11)=='E' % REM
                    hypnogram(hyp_k,1) = 5;
                elseif tline(colPos(2)+11)=='T' % MT - body movement
                    hypnogram(hyp_k,1) = 7;
                    display('MT');
                else
                    hypnogram(hyp_k,1) = str2num(tline(colPos(2)+11)); %sleep stage 0 1 2 3 4
                end

                tHour(hyp_k) = str2num(tline(colPos(1)-2:colPos(1)-1));
                tMinute(hyp_k) = str2num(tline(colPos(1)+1:colPos(1)+2));
                tSecond(hyp_k) = str2num(tline(colPos(2)+1:colPos(2)+2));
                if tHour(hyp_k)<10 % asumption: sleep at night, 0 means 24, 1 means 25, ...
                    hypnogram(hyp_k,2) = (tHour(hyp_k)+24)*3600+tMinute(hyp_k)*60+tSecond(hyp_k);
                else
                    hypnogram(hyp_k,2) = tHour(hyp_k)*3600+tMinute(hyp_k)*60+tSecond(hyp_k);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prepare the alertness: awake = 6; REM = 5; light sleep = 4; ... deep sleep (NREM s4) 
                hypHeight(hyp_k)=hypnogram(hyp_k,1);
                if hypnogram(hyp_k,1) == 0
                    hypHeight(hyp_k) = 6;
                elseif hypnogram(hyp_k,1) < 5
                    hypHeight(hyp_k) = 5-hypnogram(hyp_k,1);
                end
                    
                    
           %% Cyclic Alternating Pattern (CAP) A1-A3 
            elseif tline(colPos(2)+4:colPos(2)+7)=='MCAP' % CAP A phase: write on time_tot, duration, type
                cap_j = cap_j+1;
                t = strfind(tline,'-');
                type_ar(cap_j) = str2num(tline(t(1)+2));
                duration(cap_j,1) = str2num(tline(t(1)+4:t(1)+5));

                hCAP(cap_j) = str2num(tline(colPos(1)-2:colPos(1)-1));
                mCAP(cap_j) = str2num(tline(colPos(1)+1:colPos(1)+2));
                sCAP(cap_j) = str2num(tline(colPos(2)+1:colPos(2)+2));
                if hCAP(cap_j)<10
                    timevector(cap_j,1) = (hCAP(cap_j)+24)*3600+mCAP(cap_j)*60+sCAP(cap_j);
                else
                    timevector(cap_j,1) = hCAP(cap_j)*3600+mCAP(cap_j)*60+sCAP(cap_j);
                end
            end
        end
    end
end
fclose(fid);
figure, 
ax(1) = subplot(3, 1, 1); plot(hypnogram(:, 2)/3600, hypHeight, '.-');
yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
title(['sleep staging: ', fileName]);
xlabel('time (hour)'); ylabel('sleep stages'); grid on;
xlim([hypnogram(1, 2)/3600 hypnogram(end, 2)/3600]);
ax(2) = subplot(3, 1, 2);  plot(hypnogram(:, 2), hypHeight, '.-'); % sleep stage
yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
title(['sleep staging: ', fileName]);
xlabel('time (sec)'); ylabel('sleep stages'); grid on;
xlim([hypnogram(1, 2) hypnogram(end, 2)]);

ax(3) = subplot(3, 1, 3);  plot(hypnogram(:, 2), hypHeight, '.-'); % sleep stage
yticks([1:6]); yticklabels({'S4', 'S3', 'S2', 'S1', 'REM', 'AWAKE'});
title(['sleep staging: ', fileName]);
xlabel('time (sec)'); ylabel('sleep stages'); grid on;
xlim([hypnogram(1, 2) hypnogram(end, 2)]);
save(fullfile(procDataPath,fnHypnogram),'hypnogram','fnBase');




return;



%% cz: code below to be reviewed !
%% Process the hypnogram
display('Processing the hypnogram')

hypo=hyp;
hyp2=[];
jump=[];
nj=[];
x=1;
for cap_j=1:length(hyp)-1
    if hyp(cap_j+1,2)-hyp(cap_j,2)>30
        jump(x)=cap_j;
        if hyp(cap_j+1,2)-hyp(cap_j,2)==60
            nj(x)=1;
        elseif hyp(cap_j+1,2)-hyp(cap_j,2)==90
            nj(x)=2;
        elseif hyp(cap_j+1,2)-hyp(cap_j,2)==120
            nj(x)=3;
        end
        x=x+1;
    end
end
for i=1:length(jump)
    if nj(i)==1
        hyp2=[hyp(1:jump(i),:);[hyp(jump(i),1) hyp(jump(i),2)+30]; ...
            hyp(jump(i)+1:end,:)]; 
        jump(i:end)=jump(i:end)+1;
    elseif nj(i)==2
        hyp2=[hyp(1:jump(i),:);[hyp(jump(i),1) hyp(jump(i),2)+30]; ...
            [hyp(jump(i),1) hyp(jump(i),2)+60]; hyp(jump(i)+1:end,:)]; 
        jump(i:end)=jump(i:end)+2;
    else
        hyp2=[hyp(1:jump(i),:);[hyp(jump(i),1) hyp(jump(i),2)+30];...
            [hyp(jump(i),1) hyp(jump(i),2)+60];[hyp(jump(i),1) ...
            hyp(jump(i),2)+90];hyp(jump(i)+1:end,:)]; 
        jump(i:end)=jump(i:end)+3;
    end
        hyp=hyp2;
end
di=diff(hyp(:,2));
if di==30*ones(length(hyp)-1,1)
    display('check completed')
else
    display('error')
end
fclose(fid);

cd ..
display('saving')
start_time.h=tHour(1);
start_time.m=tMinute(1);
start_time.s=tSecond(1);
timestart=hyp(1,2);
time_tot=timevector-timestart;
hyp(:,2)=hyp(:,2)-hyp(1,2);
eval (['save micro_str' fileName(1:end-4) ' time_tot duration type_ar start_time'])
eval (['save hyp' fileName(1:end-4) ' hyp'])

