%% display the defined iBlk2Load data block
% or you load a specific data block as follows, then plot the data
[fileName, pathName] = uigetfile('*.mat','Select the .mat file to display');

% iBlk2Load = 1;
load([pathName, fileName]);

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
    plot(tTick, sigData); xlim([tTick(1), tTick(end)]); grid on;
    title(['iBlk=', num2str(iBlk), '; iCH=', header.labels{iCH}, ...
        '; sampRate=', num2str(sampRate)]);
    if iPlot == nPlotsPerFig
        xlabel('time (sec)'); linkaxes(ax, 'x');
    end
end
xlabel('time (sec)'); linkaxes(ax, 'x');