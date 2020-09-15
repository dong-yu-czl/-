clear all
clc
[fileName, pathName] = uigetfile('*.mat','Select the .mat file to display');
%get the .mat file from ecgprocData file
load([pathName, fileName]);


% mark=['r','g','b','m','c','k','b','g','r:'];
% m=1;
ecgprodata_bystage=ecgSeg_sleepstage;
% figure
% for n=1:6
%     for i=1:length(ecgprodata_bystage.S(n).sec)
%    plot(ecgprodata_bystage.S(n).sec(i).ecg_tTick,ecgprodata_bystage.S(n).sec(i).ecgSignal,mark(m));
%    m=m+1;
%    hold on
%     end
% end
%  xlabel('time(s)');ylabel('Amp');
%  title(['ECG by sleepStage of iBlk ',num2str(ecgprodata_bystage.iBlkNo)]);

%%  rename 
 personal_ID=ecgprodata_bystage.ID;
 iBlkNo=ecgprodata_bystage.iBlkNo;
 ecg_sampRate=ecgprodata_bystage.ecg_sampRate;
 Stage_labels=ecgprodata_bystage.labels'; 
 ecgdatabyStage=ecgprodata_bystage.S;
 samp_period=1;
 fs= ecg_sampRate;
 %% choose stage ? section ?
Num_stage=1;
Num_sec_onestage=1;
ecg_tTick=ecgprodata_bystage.S(Num_stage).sec(Num_sec_onestage).ecg_tTick; 
ecgSignal=ecgprodata_bystage.S(Num_stage).sec(Num_sec_onestage).ecgSignal;
RR_tTick=ecgprodata_bystage.S(Num_stage).sec(Num_sec_onestage).RR_tTick;
Overlap=0.5;
ecgpower.Split_order=['From the back ',' Back to front'];
labels=['From the back ',' Back to front'];
win=300*ecg_sampRate;
disOverlapcounters=(1-Overlap)*300*ecg_sampRate; 
len_ecg=length(ecg_tTick);
K=ceil(length(ecg_tTick)/disOverlapcounters);
%% 分段问题？？？？？？？
for 

if  len_ecg-(K-1)*disOverlapcounters==win-disOverlapcounters
    K=K-1;
else
    K=K;
end
%%

counters=0;
hrv_power=0;
fs=0;
time_cost=0;
LF=zeros(2,K);
HF=zeros(2,K);
LF0=zeros(2,K);
HF0=zeros(2,K);
VLF=zeros(2,K);
TP=zeros(2,K);
lf_hf_radio=zeros(2,K);

if length(ecg_tTick)>=180*ecg_sampRate
    for sec=1:K
        if sec~=K
            ecg_tTick_temp=ecg_tTick(1+disOverlapcounters*(sec-1):win+disOverlapcounters*(sec-1));
            idx_RR_temp=find(RR_tTick>=ecg_tTick(1+disOverlapcounters*(sec-1))&RR_tTick<=ecg_tTick(win+disOverlapcounters*(sec-1)));
        else 
            ecg_tTick_temp=ecg_tTick(1+disOverlapcounters*(sec-1):end);
            idx_RR_temp=find(RR_tTick>=ecg_tTick(1+disOverlapcounters*(sec-1))&RR_tTick<=ecg_tTick(len_ecg));
        end
        hrv_idxx=RR_tTick(idx_RR_temp);
        hrv_diff=diff(hrv_idxx)*1000;
        if numel(hrv_diff)~=0
            [pxx_temp,f_temp]=plomb(hrv_diff,1:length(hrv_idxx)-1,0.4,20);
            counters=counters+1;
                pxx.sort(1).section(sec).power=pxx_temp;
                f.sort(1).section(sec).freq=f_temp;
            
            %%求总功率
            idx_f_TP=find(f_temp<=0.40);
            TP(1,sec)=trapz(pxx_temp(idx_f_TP));

            %%求极低频率功率
            idx_f_VLF=find(f_temp>=0.003&f_temp<0.04);
            VLF(1,sec)=trapz(pxx_temp(idx_f_VLF));

            %%求高频功率
            idx_f_HF=find(f_temp>=0.15&f_temp<0.40);
            HF0(1,sec)=trapz(pxx_temp(idx_f_HF));
            HF(1,sec)=100*HF0(1,sec)/(TP(1,sec)-VLF(1,sec));

            %%求低频功率
            idx_f_LF=find(f_temp>=0.04&f_temp<0.15);
            LF0(1,sec)=trapz(pxx_temp(idx_f_LF));
            LF(1,sec)=100*LF0(1,sec)/(TP(1,sec)-VLF(1,sec));

            lf_hf_radio(1,sec)=LF(1,sec)/HF(1,sec);
        else
            TP(1,sec)=0;
            VLF(1,sec)=0;
            HF(1,sec)=0;
            LF0(1,sec)=0;
            LF(1,sec)=0;
            lf_hf_radio(1,sec)=0;
            HF0(1,sec)=0;
        end
    end

    for sec=1:K
        if sec~=K
            ecg_tTick_temp=ecg_tTick(len_ecg-win+1-(sec-1)*disOverlapcounters:len_ecg-(sec-1)*disOverlapcounters);
            idx_RR_temp=find(RR_tTick>=ecg_tTick(len_ecg-win+1-(sec-1)*disOverlapcounters)&RR_tTick<=ecg_tTick(len_ecg-(sec-1)*disOverlapcounters));
        else
            ecg_tTick_temp=ecg_tTick(1:len_ecg-(sec-1)*disOverlapcounters);
            idx_RR_temp=find(RR_tTick>=ecg_tTick(1)&RR_tTick<=ecg_tTick(len_ecg-(sec-1)*disOverlapcounters));
        end
        hrv_idxx=RR_tTick(idx_RR_temp);
        hrv_diff=diff(hrv_idxx)*1000;
        if numel(hrv_diff)~=0
            [pxx_temp,f_temp]=plomb(hrv_diff,1:length(hrv_idxx)-1,0.4,20);
            counters=counters+1;
            ecgpower.sort(2).section(sec).power=pxx_temp;
            ecgpower.sort(2).section(sec).freq=f_temp;
            
            %%求总功率
            idx_f_TP=find(f_temp<=0.40);
            TP(2,sec)=trapz(pxx_temp(idx_f_TP));

            %%求极低频率功率
            idx_f_VLF=find(f_temp>=0.003&f_temp<0.04);
            VLF(2,sec)=trapz(pxx_temp(idx_f_VLF));

            %%求高频功率
            idx_f_HF=find(f_temp>=0.15&f_temp<0.40);
            HF0(2,sec)=trapz(pxx_temp(idx_f_HF));
            HF(2,sec)=100*HF0(2,sec)/(TP(2,sec)-VLF(2,sec));

            %%求低频功率
            idx_f_LF=find(f_temp>=0.04&f_temp<0.15);
            LF0(2,sec)=trapz(pxx_temp(idx_f_LF));
            LF(2,sec)=100*LF0(2,sec)/(TP(2,sec)-VLF(2,sec));

            lf_hf_radio(2,sec)=LF(2,sec)/HF(2,sec);
        else
            TP(1,sec)=0;
            VLF(1,sec)=0;
            HF(1,sec)=0;
            LF0(1,sec)=0;
            LF(1,sec)=0;
            lf_hf_radio(1,sec)=0;
            HF0(1,sec)=0;
        end
    end
    time_cost=ecg_tTick(end)-ecg_tTick(1);
end
hrv_power=ecgpower;