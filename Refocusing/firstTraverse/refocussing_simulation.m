%%20210804 23:34

%part1: diffuse_simulation
%part2: iterate to focusing

clc
clearvars

% % % %48线程
% c = parcluster('local');
% c.NumWorkers = 48;
% parpool(c, c.NumWorkers);

%基础参数设置
wavelength = 450e-9;
k = 2*pi/wavelength;

sampling_size = 12e-6;
len_SLM=1e-3;
[xin, yin] = meshgrid(-len_SLM/2:sampling_size:len_SLM/2, -len_SLM/2:sampling_size:len_SLM/2);

%极坐标变换
[theta,r]=cart2pol(xin,yin);
r2=r.^2;

n=20;%segment number
%SLM分区 tag
x=round((xin+len_SLM/2)/(len_SLM/(n-1+0.1)));
y=round((yin+len_SLM/2)/(len_SLM/(n-1+0.1)));
tag=y*n+x+1;
clear x y

tic
% % % %%%%随机矩阵生成
% % % M=numel(xin);
% % % mu=[0,0];%数学期望
% % % sigma=[1 0;0,1];%协方差矩阵
% % % %介质仿真，生成散射后光场
% % % T=mvnrnd(mu,sigma,M*M);%生成n*n个样本
% % % T=T(:,1)+1i*T(:,2);
% % % T=reshape(T,M,M);
% % % % % 奇异值分解，能量守恒
% % % [~,s,~]=svd(T);
% % % T=T/max(max(s));
% % % clear s
% % % save 'T.mat' T
%
% % % % % 加载传输矩阵：
load('T.mat');
toc

tic

%n*n个分区的相位级
ind=zeros(1,n*n);%初始化SLM分区的相位级，全为零
ini_flag=1;%第一次遍历的标志
aim_value=[];%目标区域的光强
phase_level=15;%SLM每个分区的相位级数目
for j=[(1:n*n) (1:n*n)]
    for h=1:phase_level
% % %逐个遍历各个分区的相位级        
ind(j)=(h-1)/phase_level*2*pi;
% initial beam profile
%更新slm分区的相位
phase=tag;
for i=n*n:-1:1
    phase(tag==i)=ind(i);
end
m_phase = angle(exp(1i*phase));
w_slm = 200e-6;
m_beam_amp = (exp( - r2/w_slm^2));  
E_slm=m_beam_amp.*exp(1i*m_phase);

%slm-100nm-Len(f=250)-------medium----observe plane(250mm)
%传播路径距离设置
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
    
    Iout_dB=10*log10(Iout/ref_I);
    figure
    CLIM = [-30 0];
    imagesc(xin(1,:), yin(:,1),Iout_dB,CLIM);
    title('Gaussian')
    axis square
    colormap jet
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

if ini_flag==1 
    Iout_dB=10*log10(Iout/ref_I);
    figure
    imagesc(xin(1,:), yin(:,1),Iout_dB,CLIM);
    title('difusse initial state')
    axis square
    colormap jet
    ini_flag=0;
end

aim_index=(l+1)/2*l;
aim_intensity(h)=Iout(aim_index);
    end
    ind(j)=(find(aim_intensity==max(aim_intensity))-1)/phase_level*2*pi;
    aim_value=[aim_value max(aim_intensity)];
end
toc

%保存最终优化的曲线
save 'ind.mat' ind

%%迭代曲线
figure
plot(aim_value)
xlabel('迭代次数')
ylabel('目标点能量强度')
%%%%最终图像
Iout_dB=10*log10(Iout/ref_I);
figure
imagesc(xin(1,:), yin(:,1),Iout_dB,CLIM);
title('difusse final state')
axis square
colormap jet
%%%%中心点标记圆圈
hold on
Iout(aim_index)=1e20;
[r,c]=find(Iout==Iout(aim_index));
plot(xin(1,c),yin(r,1),'go');
axis square
hold off

