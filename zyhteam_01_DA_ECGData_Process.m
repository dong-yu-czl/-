
CollectedData=load('D:\大学作业\电子课程设计2\subjectcode\n7_ECG_SegbySleepstage_of_iBlk2.mat');


x=ecgprodata_bystage.S(3).sec(1).ecg_tTick(1:1000);
y=ecgprodata_bystage.S(3).sec(1).ecgSignal(1:1000);
figure;
plot(x,y);


%——————————低通滤波器滤除肌电信号——————————  
Fs=128;                        %采样频率  
fp=80;fs=100;                    %通带截止频率，阻带截止频率  
rp=1.4;rs=1.6;                    %通带、阻带衰减  
wp=2*pi*fp;ws=2*pi*fs;     
[n,wn]=buttord(wp,ws,rp,rs,'s');     %’s’是确定巴特沃斯模拟滤波器阶次和3dB  
                               
[z,P,k]=buttap(n);   %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益  
[bp,ap]=zp2tf(z,P,k)  %转换为Ha(p),bp为分子系数，ap为分母系数  
[bs,as]=lp2lp(bp,ap,wp) %Ha(p)转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数  
  
[hs,ws]=freqs(bs,as);         %模拟滤波器的幅频响应  
[bz,az]=bilinear(bs,as,Fs);     %对模拟滤波器双线性变换  
[h1,w1]=freqz(bz,az);         %数字滤波器的幅频响应  
m=filter(bz,az,y(:,1));  
  
figure  
freqz(bz,az);title('巴特沃斯低通滤波器幅频曲');  
        
figure  
subplot(2,1,1);  
plot(x,y(:,1));  
xlabel('t(s)');ylabel('mv');title('原始心电信号波形');grid;  
  
subplot(2,1,2);  
plot(x,m);  
xlabel('t(s');ylabel('mv');title('低通滤波后的时域图形');grid; 



%—————–带陷滤波器抑制工频干扰——————-  
%50Hz陷波器：由一个低通滤波器加上一个高通滤波器组成  
%而高通滤波器由一个全通滤波器减去一个低通滤波器构成  
Me=100;               %滤波器阶数  
L=100;                %窗口长度  
beta=100;             %衰减系数  
Fs=1500;  
wc1=49/Fs*pi;     %wc1为高通滤波器截止频率，对应51Hz  
wc2=51/Fs*pi     ;%wc2为低通滤波器截止频率，对应49Hz  
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me); %h为陷波器  
                                                              
w=kaiser(L,beta);  
Y=h.*rot90(w);         %y为50Hz陷波器冲击响应序列  
m2=filter(Y,1,m);  
  
figure  
subplot(2,1,1);plot(abs(h));axis([0 100 0 0.2]);  
xlabel('频率(Hz)');ylabel('幅度(mv');title('陷波器幅度');grid;  
N=512;  
P=10*log10(abs(fft(Y).^2)/N);  
f=(0:length(P)-1);  
subplot(2,1,2);plot(f,P);  
xlabel('频率(Hz)');ylabel('功率(dB)');title('陷波器功率谱');grid;  
     
figure  
subplot (2,1,1); plot(x,m);  
xlabel('t(s)');ylabel('幅值');title('原始信号');grid;  
subplot(2,1,2);plot(x,m2);  
xlabel('t(s)');ylabel('幅值');title('带阻滤波后信号');grid;  


%——————IIR零相移数字滤波器纠正基线漂移——————-  
Wp=1.4*2/Fs;     %通带截止频率   
Ws=0.6*2/Fs;     %阻带截止频率   
devel=0.005;    %通带纹波   
Rp=20*log10((1+devel)/(1-devel));   %通带纹波系数    
Rs=20;                          %阻带衰减   
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %求椭圆滤波器的阶次   
[b a]=ellip(N,Rp,Rs,Wn,'high');       %求椭圆滤波器的系数   
[hw,w]=freqz(b,a,512);     
result =filter(b,a,m2);   
  
figure  
freqz(b,a);  
figure  
subplot(211); plot(x,m2);   
xlabel('t(s)');ylabel('幅值');title('原始信号');grid  
subplot(212); plot(x,result);   
xlabel('t(s)');ylabel('幅值');title('线性滤波后信号');grid  
    
