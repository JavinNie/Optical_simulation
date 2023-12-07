clear
close all

%% 所有长度单位: 米/m

%%仿真参数
sampling_size =2e-6;
fft_sample=2^16;
x_in = -3200e-6:sampling_size:3200e-6;
%% 输入光束属性
wavelength = 450e-9;
k=2*pi/wavelength;
w_f = (50e-6);%半径
E_amp = exp(-x_in.^2/w_f^2);
E_phase = zeros(size(E_amp));
%% 光学系统参数
%% 等焦不是共轭（z1=z2=2ft）
z1=0.5;
fT=0.5;
z2=0.5;

%% colins 
%建立光学系统的ABCD矩阵
syms d1 d2 f
m1=[1 d1;0 1];
m2=[1 0;-1/f,1];
m3=[1,d2;0,1];
m=m3*m2*m1;
%%计算ABCD实际的值
d1=z1;
d2=z2;
f=fT;
z_axis=d1+d2;

ABCD=eval(m);
A=ABCD(1,1);
B=ABCD(1,2);
C=ABCD(2,1);
D=ABCD(2,2);

%% 输入平面的定义
%input plane
%采样间距
dxin=mean(abs(diff(x_in)));
%输入面坐标
x_in;

%输入场
%无调制
E_in=E_amp.*exp(1j*E_phase);

%闪耀光栅调制
% E_phase_2=angle(exp(1i*0.002*k*x_in));
% E_in=E_amp.*exp(1j*(E_phase+E_phase_2));

% %二元光栅调制
E_phase_2=floor((angle(exp(1i*0.005*k*x_in))+pi)/pi)*pi;
E_in=E_amp.*exp(1j*(E_phase+E_phase_2));

% %矩形窗调幅
% E_amp_2=double(abs(x_in)<40e-6);
% E_in=(E_amp.*E_amp_2).*exp(1j*(E_phase));

%%输入场绘图
figure(1)
subplot(2,2,1)
plot(x_in,abs(E_in),'LineWidth',1.5)
title('E-in-Amp')
xlabel('x-in')
subplot(2,2,3)
plot(x_in,angle(E_in),'LineWidth',1.5)
title('E-in-Phase')
xlabel('x-in')

% 共轭面情况
if B==0   %%% 此时为共轭面 %%%%%%%%
    x_out = x_in*A;
    dxout = mean(abs(diff(x_out)));
    E_out = E_in/sqrt(A).*exp(1i*pi*C/wavelength/A*x_out.^2); 
else

    %% 输出平面的定义
    %output plane
    %平面边长
    Lout=wavelength*B/dxin;
    %采样间距
    dxout=Lout/(fft_sample);
    %输出面空间坐标
    x_out=((-fft_sample)/2:1:(fft_sample)/2-1)*dxout;%1/dxin/fft_sample;
    %输出面频域坐标
    fxout=x_out/B/wavelength;%((-fft_sample)/2:1:(fft_sample)/2-1)*1/dxin/fft_sample;
    
    %% 柯林斯公式衍射计算
    
    E_in_temp=E_in.*exp(1j*pi*A/wavelength/B*x_in.^2);
    E_out_temp1=fftshift(fft(E_in_temp,fft_sample))*dxin;%fft计算
    E_out_temp2=E_out_temp1.*exp(-1i*2*pi*fxout*x_in(1));%线性相位补偿
    E_out=E_out_temp2.*exp(1j*k*D/2/B*x_out.^2).*exp(1j*k*z_axis)/sqrt(1j*wavelength*B);

end

%% 输出场绘图
subplot(2,2,2)
plot(x_out,abs(E_out),'LineWidth',1.5)
title('E-out-Amp')
xlabel('x-in')
subplot(2,2,4)
plot(x_out,phase(E_out),'LineWidth',1.5)
title('E-out-Phase')
xlabel('x-in')

%% 能量守恒验证
I_in=E_in*E_in'*dxin;
I_out=E_out*E_out'*dxout;
I_res=I_out-I_in;