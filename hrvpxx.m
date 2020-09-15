clc;clear;
load('D:\大学作业\电子课程设计2\subjectcode\n7_ECG_SegbySleepstage_of_iBlk2.mat')
samprate=128; %The sampling rate of ecg signals
ecg_tTick=ecgprodata_bystage.S(1).sec(1).ecg_tTick(1:300*samprate);
ecg_data=-ecgprodata_bystage.S(1).sec(1).ecgSignal(1:300*samprate);

%% plot the ECG
% figure 
% plot(ecg_tTick,ecg_data)
% xlabel('time(s)'),ylabel('voltage(mV)')

%% Identify the R wave
[qrs_amp_raw,idx_RR,delay]=pan_tompkin(ecg_data,samprate,0);
% figure,plot(ecg_tTick,ecg_data,'b',ecg_tTick(idx_RR),ecg_data(idx_RR),'r.');
% title('The R wave detection of ECG'),xlabel('time/s'),ylabel('voltage(mV)')

%% cubic spline interpolation
hrv_idxx=ecg_tTick(idx_RR);   % The x-coordinate of the R wave
hrv_diff=diff(hrv_idxx);      % RR interval difference
hrv_mean_diff=mean(hrv_diff); % Mean sampling time
hrv_idxx=hrv_idxx(1:end-1);   % The x-coordinate of the first n-1 R waves
hrv_x=1:length(hrv_idxx);     % The abscissa of the RR interval
hrv_inter=csape(hrv_idxx,hrv_diff,'not-a-knot') ; % cubic spline interpolation
hrv_fs=4;      % The frequency of resampling
hrv_xx=hrv_idxx(1):1/hrv_fs:hrv_idxx(end);  % The interpolated x-coordinate sequence
hrv_lenxx=1:length(hrv_xx);   % The abscissa of the RR interval after interpolation
hrv_resample=ppval(hrv_inter,hrv_xx);  % The RR interval after resampling
hrv_HRV=hrv_resample-mean(hrv_resample);  % Minus the homogeneous HRV signal

%% plot the original HRV signal and the interpolated HRV signal
figure
plot(hrv_x,hrv_diff)
title('The HRV signal'),xlabel('time points'),ylabel('RR interval(s)')
axis([hrv_x(1) hrv_x(end) hrv_mean_diff-0.5 hrv_mean_diff+0.5])
figure
subplot(211),plot(hrv_x,hrv_diff);
axis([hrv_x(1) hrv_x(end) hrv_mean_diff-0.5 hrv_mean_diff+0.5])
title('The HRV signal before resampling'),xlabel('time points'),ylabel('RR interval(s)')
subplot(212),plot(hrv_lenxx,hrv_HRV);
axis([hrv_lenxx(1) hrv_lenxx(end) mean(hrv_HRV)-0.5 mean(hrv_HRV)+0.5])
title('The HRV signal after resampling'),xlabel('time points'),ylabel('RR interval(s)')


%% plot the spectrogram of the HRV signal
% hrv_Nlenxx=length(hrv_lenxx);
% hrv_fft=abs(fft(hrv_HRV,hrv_Nlenxx))*2/hrv_Nlenxx;
% hrv_fft_fs=(0:length(hrv_fft)-1)'*hrv_fs/hrv_Nlenxx;
% figure
% plot(hrv_fft_fs,hrv_fft);
% xlim([0 0.5])
% xlabel('frequency(Hz)')
% ylabel('smplitude')
% title('The spectrum of HRV signal')

%% plot the PSD of the HRV signal
nfft=2^(nextpow2(length(hrv_lenxx))); % Find the highest power of 2 near the sequence length
if nfft>length(hrv_lenxx) 
    nfft=nfft/2;
end
noverlap=round(0.5*nfft);  % Number of overlaps
window=kaiser(nfft);  % window function
[Pxx,F]=pwelch(hrv_HRV,window,noverlap,nfft,hrv_fs);
Pxx=1000000*Pxx;
figure
plot(F,Pxx)
xlabel('frequency(Hz)');
axis([0 0.5 min(Pxx) 1.8*max(Pxx)])
ylabel('PSD')
orderl=50;
range='onesided';
hold on
xlim1=0.003*ones(2);
xlim2=0.04*ones(2);
xlim3=0.15*ones(2);
xlim4=0.4*ones(2);

ylim=[0 1.8*max(Pxx)];
plot(xlim1,ylim,'red','LineWidth',1)
hold on
plot(xlim2,ylim,'red','LineWidth',1)
hold on
plot(xlim3,ylim,'red','LineWidth',1)
hold on
plot(xlim4,ylim,'red','LineWidth',1)

ylim1=1.5*max(Pxx);

text(0.008,ylim1,'VLF','FontSize',16)
text(0.09,ylim1,'L F','FontSize',16)
text(0.25,ylim1,'H F','FontSize',16)

%% The total power
TP0=0;
for hrv_lenTP=1:length(F)
    if F(hrv_lenTP)<=0.4
        TP0=TP0+Pxx(hrv_lenTP);
    end
end

%% Very low frequency power
VLF0=0;
for hrv_lenVLF=1:length(F)
    if ((F(hrv_lenVLF)>=0.003)&(F(hrv_lenVLF)<=0.04))
        VLF0=VLF0+Pxx(hrv_lenVLF);
    end
end


%% high-frequency power
HF0=0;
for hrv_lenHF=1:length(F)
    if ((F(hrv_lenHF)>=0.15)&(F(hrv_lenHF)<=0.4))
        HF0=HF0+Pxx(hrv_lenHF);
    end
end

nHF=100*HF0/(TP0-VLF0);


%% Low-frequency power
LF0=0;
for hrv_lenLF=1:length(F)
    if ((F(hrv_lenLF)>=0.04)&(F(hrv_lenLF)<=0.15))
        LF0=LF0+Pxx(hrv_lenLF);
    end
end

nLF=100*LF0/(TP0-VLF0);

ER=LF0/HF0;


