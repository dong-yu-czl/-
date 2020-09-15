
CollectedData=load('D:\��ѧ��ҵ\���ӿγ����2\subjectcode\n7_ECG_SegbySleepstage_of_iBlk2.mat');


x=ecgprodata_bystage.S(3).sec(1).ecg_tTick(1:1000);
y=ecgprodata_bystage.S(3).sec(1).ecgSignal(1:1000);
figure;
plot(x,y);


%����������������������ͨ�˲����˳������źš�������������������  
Fs=128;                        %����Ƶ��  
fp=80;fs=100;                    %ͨ����ֹƵ�ʣ������ֹƵ��  
rp=1.4;rs=1.6;                    %ͨ�������˥��  
wp=2*pi*fp;ws=2*pi*fs;     
[n,wn]=buttord(wp,ws,rp,rs,'s');     %��s����ȷ��������˹ģ���˲����״κ�3dB  
                               
[z,P,k]=buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����  
[bp,ap]=zp2tf(z,P,k)  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��  
[bs,as]=lp2lp(bp,ap,wp) %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��  
  
[hs,ws]=freqs(bs,as);         %ģ���˲����ķ�Ƶ��Ӧ  
[bz,az]=bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任  
[h1,w1]=freqz(bz,az);         %�����˲����ķ�Ƶ��Ӧ  
m=filter(bz,az,y(:,1));  
  
figure  
freqz(bz,az);title('������˹��ͨ�˲�����Ƶ��');  
        
figure  
subplot(2,1,1);  
plot(x,y(:,1));  
xlabel('t(s)');ylabel('mv');title('ԭʼ�ĵ��źŲ���');grid;  
  
subplot(2,1,2);  
plot(x,m);  
xlabel('t(s');ylabel('mv');title('��ͨ�˲����ʱ��ͼ��');grid; 



%�����������C�����˲������ƹ�Ƶ���š�����������-  
%50Hz�ݲ�������һ����ͨ�˲�������һ����ͨ�˲������  
%����ͨ�˲�����һ��ȫͨ�˲�����ȥһ����ͨ�˲�������  
Me=100;               %�˲�������  
L=100;                %���ڳ���  
beta=100;             %˥��ϵ��  
Fs=1500;  
wc1=49/Fs*pi;     %wc1Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ51Hz  
wc2=51/Fs*pi     ;%wc2Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ49Hz  
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me); %hΪ�ݲ���  
                                                              
w=kaiser(L,beta);  
Y=h.*rot90(w);         %yΪ50Hz�ݲ��������Ӧ����  
m2=filter(Y,1,m);  
  
figure  
subplot(2,1,1);plot(abs(h));axis([0 100 0 0.2]);  
xlabel('Ƶ��(Hz)');ylabel('����(mv');title('�ݲ�������');grid;  
N=512;  
P=10*log10(abs(fft(Y).^2)/N);  
f=(0:length(P)-1);  
subplot(2,1,2);plot(f,P);  
xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('�ݲ���������');grid;  
     
figure  
subplot (2,1,1); plot(x,m);  
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�');grid;  
subplot(2,1,2);plot(x,m2);  
xlabel('t(s)');ylabel('��ֵ');title('�����˲����ź�');grid;  


%������������IIR�����������˲�����������Ư�ơ�����������-  
Wp=1.4*2/Fs;     %ͨ����ֹƵ��   
Ws=0.6*2/Fs;     %�����ֹƵ��   
devel=0.005;    %ͨ���Ʋ�   
Rp=20*log10((1+devel)/(1-devel));   %ͨ���Ʋ�ϵ��    
Rs=20;                          %���˥��   
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %����Բ�˲����Ľ״�   
[b a]=ellip(N,Rp,Rs,Wn,'high');       %����Բ�˲�����ϵ��   
[hw,w]=freqz(b,a,512);     
result =filter(b,a,m2);   
  
figure  
freqz(b,a);  
figure  
subplot(211); plot(x,m2);   
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�');grid  
subplot(212); plot(x,result);   
xlabel('t(s)');ylabel('��ֵ');title('�����˲����ź�');grid  
    
