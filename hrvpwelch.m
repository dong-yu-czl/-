function [hrv_power,time_cost,LF,HF,VLF,TP,lf_hf_radio,labels]=hrvpwelch(ecg_tTick,RR_tTick,ecg_sampRate,Overlap)

%如果数据正好是5min的倍数，如何做？？？
ecgpower.Split_order=['TP','VLF','HF','LF0','LF','lf_hf_radio','HF0'];
labels=['From the back ',' Back to front'];

win=300*ecg_sampRate;
disOverlapcounters=round((1-Overlap)*300*ecg_sampRate); 
len_ecg=length(ecg_tTick);
hrv_idxx=RR_tTick;   %%各个R波的横坐标
hrv_diff=diff(hrv_idxx);  %%RR间期
hrv_mean_diff=mean(hrv_diff); %%平均采样时间
hrv_idxx=hrv_idxx(1:end-1);  %%前n-1个R波的横坐标
hrv_x=1:length(hrv_idxx);   %%RR间期的横坐标
hrv_inter=csape(hrv_idxx,hrv_diff,'not-a-knot') ;%%三次样条插值
hrv_fs=4;      %重采样的频率
RR_tTick=hrv_idxx(1):1/hrv_fs:hrv_idxx(end);  %插值后的横坐标序列

K_temp=ceil(length(ecg_tTick)/disOverlapcounters);
len_restecg=len_ecg;
numbers=0;
for n=1:K_temp
    numbers=numbers+1;
    len_restecg=len_restecg-disOverlapcounters;
    if len_restecg<=win
        numbers=numbers+1;
        break;
    end
end

K=numbers;
counters1=0;
counters2=0;
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

if length(ecg_tTick)>=win
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
            if adftest(hrv_diff)
                nfft=2^(nextpow2(length(hrv_diff))); %%求靠近序列长度的最高2次幂数值
                if nfft>length(hrv_diff) 
                     nfft=nfft/2;
                end
                noverlap=round(0.5*nfft);
                window=kaiser(nfft); 
                [pxx_temp,f_temp]=pwelch(hrv_diff,window,noverlap,nfft,hrv_fs);
                counters1=counters1+1;
                   ecgpower.sort(1).section(counters1).power=pxx_temp;
                   ecgpower.sort(1).section(counters1).freq=f_temp;

                %%求总功率
                idx_f_TP=find(f_temp<=0.40);
                TP(1,counters1)=trapz(pxx_temp(idx_f_TP));

                %%求极低频率功率
                idx_f_VLF=find(f_temp>=0.003&f_temp<0.04);
                VLF(1,counters1)=trapz(pxx_temp(idx_f_VLF));

                %%求高频功率
                idx_f_HF=find(f_temp>=0.15&f_temp<0.40);
                HF0(1,counters1)=trapz(pxx_temp(idx_f_HF));
                HF(1,counters1)=100*HF0(1,counters1)/(TP(1,counters1)-VLF(1,counters1));

                %%求低频功率
                idx_f_LF=find(f_temp>=0.04&f_temp<0.15);
                LF0(1,counters1)=trapz(pxx_temp(idx_f_LF));
                LF(1,counters1)=100*LF0(1,counters1)/(TP(1,counters1)-VLF(1,counters1));

                lf_hf_radio(1,counters1)=LF(1,counters1)/HF(1,counters1);
            end
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
            if adftest(hrv_diff)
                 nfft=2^(nextpow2(length(hrv_diff))); %%求靠近序列长度的最高2次幂数值
                if nfft>length(hrv_diff) 
                     nfft=nfft/2;
                end
                window=kaiser(nfft); 
                noverlap=round(0.5*nfft);
                [pxx_temp,f_temp]=pwelch(hrv_diff,window,noverlap,nfft,hrv_fs);
                counters2=counters2+1;
                ecgpower.sort(2).section(counters2).power=pxx_temp;
                ecgpower.sort(2).section(counters2).freq=f_temp;

                %%求总功率
                idx_f_TP=find(f_temp<=0.40);
                TP(2,counters2)=trapz(pxx_temp(idx_f_TP));

                %%求极低频率功率
                idx_f_VLF=find(f_temp>=0.003&f_temp<0.04);
                VLF(2,counters2)=trapz(pxx_temp(idx_f_VLF));

                %%求高频功率
                idx_f_HF=find(f_temp>=0.15&f_temp<0.40);
                HF0(2,counters2)=trapz(pxx_temp(idx_f_HF));
                HF(2,counters2)=100*HF0(2,counters2)/(TP(2,counters2)-VLF(2,counters2));

                %%求低频功率
                idx_f_LF=find(f_temp>=0.04&f_temp<0.15);
                LF0(2,counters2)=trapz(pxx_temp(idx_f_LF));
                LF(2,counters2)=100*LF0(2,counters2)/(TP(2,counters2)-VLF(2,counters2));

                lf_hf_radio(2,counters2)=LF(2,sec)/HF(2,counters2);
            end
        end
    end
    time_cost=ecg_tTick(end)-ecg_tTick(1);
end
ecgpower.finTP=sum([TP(1,:),TP(2,:)])./(counters2+counters1);
ecgpower.finVLF=sum([VLF(1,:),VLF(2,:)])./(counters2+counters1);
ecgpower.finHF=sum([HF(1,:),HF(2,:)])./(counters2+counters1);
ecgpower.finLF0=sum([LF0(1,:),LF0(2,:)])./(counters2+counters1);
ecgpower.finLF=sum([LF(1,:),LF(2,:)])./(counters2+counters1);
ecgpower.finlf_hf_radio=sum([lf_hf_radio(1,:),lf_hf_radio(2,:)])./(counters2+counters1);
ecgpower.finHF0=sum([HF0(1,:),HF0(2,:)])./(counters2+counters1);
hrv_power=ecgpower;

end
