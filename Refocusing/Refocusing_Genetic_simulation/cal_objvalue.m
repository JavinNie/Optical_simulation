%计算函数目标值
%输入变量：二进制数值
%输出变量：目标函数值
function [objvalue] = cal_objvalue(pop,T)
% x = binary2decimal(pop);
% %转化二进制数为x变量的变化域范围的数值
% objvalue=10*sin(5*x)+7*abs(x-5)+10;

wavelength = 450e-9;
k = 2*pi/wavelength;

sampling_size = 12e-6;
len_SLM=1e-3;
[xin, yin] = meshgrid(-len_SLM/2:sampling_size:len_SLM/2, -len_SLM/2:sampling_size:len_SLM/2);
[M,~]=size(xin);
%极坐标变换
[~,r]=cart2pol(xin,yin);
r2=r.^2;

n=20;%segment number
%SLM分区 tag
x=round((xin+len_SLM/2)/(len_SLM/(n-1+0.1)));
y=round((yin+len_SLM/2)/(len_SLM/(n-1+0.1)));
tag=y*n+x+1;
clear x y

[px,~] = size(pop);

%基本参数设置
ini_flag=1;%第一次遍历的标志
aim_value=[];%目标区域的光强
aim_index=(M+1)/2*M;%目标区域的索引

%开始遍历仿真
for count=1:px
    ind=pop(count,:);
    
    %更新slm分区的相位
    phase=tag;
    for i=n*n:-1:1
    phase(tag==i)=ind(i);
    end
    m_phase = angle(exp(1i*phase));
    w_slm = 200e-6;
    m_beam_amp = (exp( - r2/w_slm^2));  
    E_slm=m_beam_amp.*exp(1i*m_phase);
    
    %传播路径距离参数设置
    z1=100e-3;
    ft=250e-3;
    z3=ft/4;
    z2=ft-z3;
    
    %ft仿真，从slm到介质前的一面
    fft_sample = 2^11;
    [E_out1, Xout1, Yout1] = mFraFFT2D(m_phase, m_beam_amp, ft, z1 , z2, xin, yin, wavelength, fft_sample);
    E_out1= interp2 (Xout1,Yout1,E_out1,xin,yin);
    
    [l,c]=size(E_out1);
    M=numel(E_out1);
    %化为向量，便于矩阵运算
    E1_reshaped=reshape(E_out1,M , 1);

    %第一次，计算出光强参考值
    if ini_flag==1
        %不加杂散矩阵仿真，高斯光
        E_dis=E1_reshaped;
        %将光场化为矩阵
        E_dis=reshape(E_dis,c,l);
        %继续传播到焦面上聚焦
        ft=inf;
        [E_out2, Xout2, Yout2] = mFraFFT2D(angle(E_dis), abs(E_dis), ft, z3/2 , z3/2, xin, yin, wavelength, fft_sample);
        E_out2= interp2 (Xout2,Yout2,E_out2,xin,yin);
        Iout=abs(E_out2).^2;

        ref_I=max(max(Iout));
    end
    
    %杂散矩阵仿真
    E_dis=T*E1_reshaped;
    %将杂散光场化为矩阵
    E_dis=reshape(E_dis,c,l);

    %继续传播到焦面上聚焦
    ft=inf;
    [E_out2, Xout2, Yout2] = mFraFFT2D(angle(E_dis), abs(E_dis), ft, z3/2 , z3/2, xin, yin, wavelength, fft_sample);
    E_out2= interp2 (Xout2,Yout2,E_out2,xin,yin);
    Iout=abs(E_out2).^2;
    
    aim_intensity(count,1)=Iout(aim_index); 
end
objvalue=aim_intensity;