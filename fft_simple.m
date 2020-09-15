function [f,y] =fft_simple(x,srate,fl,fh)
%功能：函数，做短时傅里叶变化，计算频谱
%输入：一位数据x；采样频率srate。频率下限f1，频率上限fh
%输出：频率上下限之间的频率序列及所对应频谱序列
if fl<0
    error('MATLAB:fft_simple:频率下限不能小于零')
end
if fh>srate/2
    error('MATLAB:fft_simple:频率上限不能大于采样频率的一半')
end
N=length(x);  %%求输入数据的长度
z=abs(fft(x,N))*2/N;  %%短时傅里叶变换；
p_s=0:1:N/2;  %%频率序列对应的点序列
df=srate/N; %%频率梯度，连续两点的频率差值
f_s=p_s*df;  %%产生频率序列
f=f_s(fl/df+1:1:fh/df+1); %%由fl和fh产生频率序列
y=z(fl/df+1:1:fh/df+1);
end

