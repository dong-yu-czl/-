% ecg_tTick=ecgprodata_bystage.S(5).sec.ecg_tTick(1:1000);
% ecg_data=ecgprodata_bystage.S(5).sec.ecgSignal(1:1000);
% 
% S=lomb(ecg_tTick,ecg_data,0.1,40,0.001)


% %%
% fs=128; %%采样频率
% ecg_N=1024;
% ecg_n=0:ecg_N-1;
% %%FFT
% ecg_fft=fft(ecg_data,ecg_N);
% ecg_mag=abs(ecg_fft);
% ecg_f=(0:length(ecg_fft)-1)'*fs/length(ecg_fft);
% figure
% plot(ecg_f,ecg_mag)
% axis([ecg_f(1) ecg_f(end)/2 min(ecg_mag) max(ecg_mag)])
% title('频谱图')
% xlabel('频率')
% ylabel('幅值')
% set(gcf,'unit','centimeters','position',[1 3 30 15]);
% set(gca,'Position',[.1 .2 .8 .6]);
% 
% %功率谱
% 
% figure
% window=boxcar(length(ecg_data));
% [Pxx,f]=periodogram(ecg_data,window,ecg_N,fs); 
% plot(f,10*log10(Pxx));
% 
% 
% % ecg_c=xcorr(ecg_data,'unbiased');
% % ecg_p=abs(fft(ecg_c,ecg_N));
% % ecg_index=0:round(ecg_N/2-1);
% % ecg_k=ecg_index*fs/ecg_N;
% % Pxx=10*log10(ecg_p(ecg_index+1));
% % figure
% % plot(ecg_k,Pxx)
% % xlabel('频率(Hz)');ylabel('功率(dB)');title('心电信号的功率谱');
% % set(gcf,'unit','centimeters','position',[1 3 30 15]);
% % set(gca,'Position',[.1 .2 .8 .6]);
% 
% 
% 
% % ecg_P=10*log10(abs(fft(ecg_data).^2)/ecg_N);
% % f=0:length(ecg_P)-1;
% % figure
% % plot(f,ecg_P);grid
% % xlabel('频率(Hz)');ylabel('功率(dB)');title('心电信号的功率谱');
% % set(gcf,'unit','centimeters','position',[1 3 30 15]);
% % set(gca,'Position',[.1 .2 .8 .6]);
% 
% % plot(ecg_f,ecg_p);
% % xlabel('频率（Hz)');
% % ylabel('功率谱');
% % title('心电信号功率谱')
% % axis([ecg_f(1) ecg_f(end)/2 min(ecg_p) max(ecg_p)])
% % set(gcf,'unit','centimeters','position',[1 3 30 15]);
% % set(gca,'Position',[.1 .2 .8 .6]);
% 
% 
% 
% 
% 
% 
% 
% % Fs=128;                        %采样频率  
% % fp=20;fs=30;                    %通带截止频率，阻带截止频率  
% % rp=1.4;rs=1.6;                    %通带、阻带衰减  
% % wp=2*pi*fp;ws=2*pi*fs;     
% % [n,wn]=buttord(wp,ws,rp,rs,'s');     %’s’是确定巴特沃斯模拟滤波器阶次和3dB  
% %                                
% % [z,P,k]=buttap(n);   %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益  
% % [bp,ap]=zp2tf(z,P,k)  %转换为Ha(p),bp为分子系数，ap为分母系数  
% % [bs,as]=lp2lp(bp,ap,wp) %Ha(p)转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数  
% %   
% % [hs,ws]=freqs(bs,as);         %模拟滤波器的幅频响应  
% % [bz,az]=bilinear(bs,as,Fs);     %对模拟滤波器双线性变换  
% % [h1,w1]=freqz(bz,az);         %数字滤波器的幅频响应  
% % m=filter(bz,az,y(:,1));  
% %         
% % figure
% % subplot(211)
% % plot(x,m);  
% % xlabel('t(s');ylabel('mv');title('低通滤波后的时域图形');
% % F2=abs(fft(m));
% % subplot(212)
% % plot(f,F2(1:round(N/2)))

% clc;clear;
% Fs = 10000;
% f0 = 175;
% f1 = 400;
% 
% t = 0:1/Fs:0.5;
% 
% wgn = randn(length(t),2)/2;
% 
% sigOrig = sin(2*pi*[f0;f1]*t)'+wgn  ;



% ecg_tTick=ecgprodata_bystage.S(5).sec.ecg_tTick(1:1000);
% ecg_data=ecgprodata_bystage.S(5).sec.ecgSignal(1:1000);
% plot(ecg_tTick,ecg_data)
% plomb(ecg_data,ecg_tTick)
% axisLim = axis;
% axis(axisLim)
% title('Lomb-Scargle')


%正弦曲线
xr=pi*linspace(-1,1,100);
yr=sin(xr);
%1自然边界条件
x = pi*linspace(-1,1,5);%设置5个控制点
y = sin(x);
cs = spline(x,y);%样条函数
xx = linspace(x(1),x(end),100);%插值点
yy=ppval(cs,xx);%插值
figure(1)
plot(x,y,'bo',xr,yr,'b--',xx,yy,'r-');%绘图

