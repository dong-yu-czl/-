function [f,y] =fft_simple(x,srate,fl,fh)
%���ܣ�����������ʱ����Ҷ�仯������Ƶ��
%���룺һλ����x������Ƶ��srate��Ƶ������f1��Ƶ������fh
%�����Ƶ��������֮���Ƶ�����м�����ӦƵ������
if fl<0
    error('MATLAB:fft_simple:Ƶ�����޲���С����')
end
if fh>srate/2
    error('MATLAB:fft_simple:Ƶ�����޲��ܴ��ڲ���Ƶ�ʵ�һ��')
end
N=length(x);  %%���������ݵĳ���
z=abs(fft(x,N))*2/N;  %%��ʱ����Ҷ�任��
p_s=0:1:N/2;  %%Ƶ�����ж�Ӧ�ĵ�����
df=srate/N; %%Ƶ���ݶȣ����������Ƶ�ʲ�ֵ
f_s=p_s*df;  %%����Ƶ������
f=f_s(fl/df+1:1:fh/df+1); %%��fl��fh����Ƶ������
y=z(fl/df+1:1:fh/df+1);
end

