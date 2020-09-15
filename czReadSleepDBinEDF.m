% function [data, header, Ch_data] = czReadSleepBinEDF(fullFN)
% baded on the code readEDF.m by Shapkin Andrey, 15-OCT-2012
% improved and corrected by Chang'an Zhan Nov 21, 2019
% adapted for reading and save the sleep data
%   - segment the data into smaller blocks and save each block into a .mat file
%   - show the selected block of raw data
% NOTE: This code is designed for a specific study group. 
% IMPORTANT: This code should NOT be distributed to any third party.

% fullFN - File name
% data - Contains a signals in structure of cells
% header  - Contains header
clear all;
close all;
verbose = 0;

rawDataPath = 'D:\大学作业\电子课程设计2\SleepDB_n6-9_n16';
procDataPath = 'D:\大学作业\电子课程设计2\n7prodata';

%fileName = 'n6.edf'; %
fileName = 'sdb1.edf';
%fileName = 'n7.edf'; %

% note: brux1.edf may has some problem, error in reading
fullFN = [rawDataPath, '\', fileName];
fid = fopen(fullFN, 'r', 'ieee-le');

%%% HEADER LOAD

%% PART1: (GENERAL) 
hdr = char(fread(fid, 256, 'uchar')'); 
header.ver=str2num(hdr(1:8));            % 8 ascii : version of this data format (0)
header.patientID  = char(hdr(9:88));     % 80 ascii : local patient identification
header.recordID  = char(hdr(89:168));    % 80 ascii : local recording identification
header.startdate= char(hdr(169:176));     % 8 ascii : startdate of recording (dd.mm.yy)
header.starttime  = char(hdr(177:184));  % 8 ascii : starttime of recording (hh.mm.ss)
header.length = str2num (hdr(185:192));  % 8 ascii : number of bytes in header record - header length
reserved = hdr(193:236); % [EDF+C       ] % 44 ascii : reserved
header.records = str2num (hdr(237:244)); % 8 ascii : number of data records (-1 if unknown)
header.duration = str2num (hdr(245:252)); % 8 ascii : duration of a data record, in seconds
header.channels = str2num (hdr(253:256)); % 4 ascii : number of signals (ns) in data record

% hdrPart2 = char(fread(fid,header.channels*256,'uchar')');fclose(fid), return; % 256 per channel

%% PART2 (DEPENDS ON QUANTITY OF CHANNELS)

header.labels = cellstr(char(fread(fid,[16,header.channels],'char')')); % ns * 16 ascii : ns * label (e.g. EEG FpzCz or Body temp)
header.transducer = cellstr(char(fread(fid,[80,header.channels],'char')')); % ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
header.units = cellstr(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
header.physmin = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
header.physmax = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
header.digmin = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * digital minimum (e.g. -2048)
header.digmax = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * digital maximum (e.g. 2047)
header.prefilt =cellstr(char(fread(fid,[80,header.channels],'char')')); % ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
header.samplesPerRecord = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : nr samples in each channel record duration
header.samplerate = header.samplesPerRecord ./ header.duration;% revised by cz  % sample rates for the ns channels
%%%%% NOTE: there is a KEY error for the sentence in the original
%%%%%     matlab function ReadEDF.m downloaded from mathworks.com
reserved = char(fread(fid,[32, header.channels],'char')'); % ns * 32 ascii : ns * reserved

% fclose(fid); return;

%% to validate some header domains
fileInfo = dir(fullFN);
headerSizeinBytes = 256*(header.channels+1); % Ref. Kemp (1992) "A simple format for ..."
signalBlkinBytes = sum(header.samplesPerRecord)*2;
if header.records == -1 % '-1' means the number of records is unknown
    header.records = (fileInfo.bytes - headerSizeinBytes)...
        /signalBlkinBytes; % signal data blocks
    fprintf('The header.records (originally -1) is reset to %d.\n', header.records);
end

if header.records - round(header.records)
    fprintf('header.records = %f is wrongly specified.\n', header.records);   
%     fclose(fid); return;
end

dataSizeinBytes = header.records*signalBlkinBytes;
byteDiff = headerSizeinBytes + dataSizeinBytes - fileInfo.bytes;

if byteDiff
    fprintf('The EDF file size differs from the number based on header information by %d.\n', byteDiff);
    fclose(fid); return;
else
    fprintf('The EDF file header is correctly specified. Now read the signal data.\n');
end

%% EDF+?
f1 = find(cellfun('isempty', regexp(header.labels, 'EDF Annotations', 'once'))==0); 
% Channels number with the EDF Annotations
f2 = find(cellfun('isempty', regexp(header.labels, 'Status', 'once'))==0); 
% Channels number with the EDF Annotations
f = [f1(:); f2(:)];

%% PART 3: Loading of signals block by block to handle large data files
% Structure of the data in format EDF:
% [block1 block2 .. , block N], where N=header.records
% Block structure:
% [(d seconds of 1 channel) (d seconds of 2 channel) ... (d seconds of Ch channel)], 
% Where Ch - quantity of channels (header.channels), d - header.duration

nRecordsPerBlk = 60*60; % in seconds
blkSize = nRecordsPerBlk .* sum(header.samplesPerRecord);
nBlks = floor(header.records/nRecordsPerBlk);
remRecords = header.records - nRecordsPerBlk*nBlks;

data = cell(1, header.channels);
Rs = cumsum([1; header.samplesPerRecord]); % column indices for reshape
% get ready for amplitude correction >>
sf = (header.physmax - header.physmin)... 
    ./(header.digmax - header.digmin); % resolution of each digitized level
dc = header.physmax - sf.* header.digmax;% 
% << for amplitude correction

for iBlk = 1:nBlks
    Ch_data = fread(fid, blkSize, 'int16'); % Loading of signals
    Ch_data = reshape(Ch_data, [], nRecordsPerBlk);
    for k = 1:header.channels
        data{k} = reshape(Ch_data(Rs(k):Rs(k+1)-1, :), [], 1); % organized by channel
        data{k}=data{k}.*sf(k)+dc(k); % calibration
    end
    finalBlkFlg = 0;
    save([procDataPath, '\', fileName(1:end-4), '_iBlk_', num2str(iBlk), '.mat'], ...
        'header', 'data', 'iBlk', 'nRecordsPerBlk', 'finalBlkFlg');
end

if remRecords
    Ch_data = fread(fid, remRecords*sum(header.samplesPerRecord), 'int16'); % Loading of signals
    Ch_data = reshape(Ch_data, [], remRecords);
    for k = 1:header.channels
        data{k} = reshape(Ch_data(Rs(k):Rs(k+1)-1, :), [], 1); % organized by channel
        data{k}=data{k}.*sf(k)+dc(k); % calibration
    end
    iBlk = iBlk + 1;
    finalBlkFlg = 1;
    save([procDataPath, '\', fileName(1:end-4), '_iBlk_', num2str(iBlk), '.mat'], ...
        'header', 'data', 'iBlk', 'nRecordsPerBlk', 'finalBlkFlg', 'remRecords', '-v7.3');
end

fclose(fid); 

%% display the defined iBlk2Load data block
% or you load a specific data block as follows, then plot the data
iBlk2Load = 1;
load([procDataPath, '\', fileName(1:end-4), '_iBlk_', num2str(iBlk2Load), '.mat']);

nCHs = size(data, 2);
nPlotsPerFig = 4;
for iCH = 1:nCHs
    sigData = data{iCH};
    sigLen = numel(sigData);
    sampRate = header.samplerate(iCH);
    tStart = str2num(header.starttime(1:2))*3600 + ...
        str2num(header.starttime(4:5))*60 + str2num(header.starttime(7:8)) + ...
        (iBlk-1)*nRecordsPerBlk;
    tTick = [tStart: 1/sampRate: tStart+(sigLen-1)/sampRate]/1; % in minutes
    
    iPlot = mod(iCH, nPlotsPerFig);
    if iPlot == 0
        iPlot = nPlotsPerFig;
    end
    if iPlot == 1
        figure('Name', fileName)
    end
    
    ax(iPlot) = subplot(nPlotsPerFig, 1, iPlot);
    plot(tTick, sigData); xlim([tTick(1), tTick(end)]); 
    title(['iBlk=', num2str(iBlk), '; iCH=', header.labels{iCH}, ...
        '; sampRate=', num2str(sampRate)]);
    if iPlot == nPlotsPerFig
        xlabel('time (sec)'); linkaxes(ax, 'x');
    end
end
xlabel('time (sec)'); linkaxes(ax, 'x');

