% ecg_tTick=ecgprodata_bystage.S(5).sec.ecg_tTick(1:1000);
% ecg_data=ecgprodata_bystage.S(5).sec.ecgSignal(1:1000);
% 
% S=lomb(ecg_tTick,ecg_data,0.1,40,0.001)


% %%
% fs=128; %%����Ƶ��
% ecg_N=1024;
% ecg_n=0:ecg_N-1;
% %%FFT
% ecg_fft=fft(ecg_data,ecg_N);
% ecg_mag=abs(ecg_fft);
% ecg_f=(0:length(ecg_fft)-1)'*fs/length(ecg_fft);
% figure
% plot(ecg_f,ecg_mag)
% axis([ecg_f(1) ecg_f(end)/2 min(ecg_mag) max(ecg_mag)])
% title('Ƶ��ͼ')
% xlabel('Ƶ��')
% ylabel('��ֵ')
% set(gcf,'unit','centimeters','position',[1 3 30 15]);
% set(gca,'Position',[.1 .2 .8 .6]);
% 
% %������
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
% % xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('�ĵ��źŵĹ�����');
% % set(gcf,'unit','centimeters','position',[1 3 30 15]);
% % set(gca,'Position',[.1 .2 .8 .6]);
% 
% 
% 
% % ecg_P=10*log10(abs(fft(ecg_data).^2)/ecg_N);
% % f=0:length(ecg_P)-1;
% % figure
% % plot(f,ecg_P);grid
% % xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('�ĵ��źŵĹ�����');
% % set(gcf,'unit','centimeters','position',[1 3 30 15]);
% % set(gca,'Position',[.1 .2 .8 .6]);
% 
% % plot(ecg_f,ecg_p);
% % xlabel('Ƶ�ʣ�Hz)');
% % ylabel('������');
% % title('�ĵ��źŹ�����')
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
% % Fs=128;                        %����Ƶ��  
% % fp=20;fs=30;                    %ͨ����ֹƵ�ʣ������ֹƵ��  
% % rp=1.4;rs=1.6;                    %ͨ�������˥��  
% % wp=2*pi*fp;ws=2*pi*fs;     
% % [n,wn]=buttord(wp,ws,rp,rs,'s');     %��s����ȷ��������˹ģ���˲����״κ�3dB  
% %                                
% % [z,P,k]=buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����  
% % [bp,ap]=zp2tf(z,P,k)  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��  
% % [bs,as]=lp2lp(bp,ap,wp) %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��  
% %   
% % [hs,ws]=freqs(bs,as);         %ģ���˲����ķ�Ƶ��Ӧ  
% % [bz,az]=bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任  
% % [h1,w1]=freqz(bz,az);         %�����˲����ķ�Ƶ��Ӧ  
% % m=filter(bz,az,y(:,1));  
% %         
% % figure
% % subplot(211)
% % plot(x,m);  
% % xlabel('t(s');ylabel('mv');title('��ͨ�˲����ʱ��ͼ��');
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


%��������
xr=pi*linspace(-1,1,100);
yr=sin(xr);
%1��Ȼ�߽�����
x = pi*linspace(-1,1,5);%����5�����Ƶ�
y = sin(x);
cs = spline(x,y);%��������
xx = linspace(x(1),x(end),100);%��ֵ��
yy=ppval(cs,xx);%��ֵ
figure(1)
plot(x,y,'bo',xr,yr,'b--',xx,yy,'r-');%��ͼ

