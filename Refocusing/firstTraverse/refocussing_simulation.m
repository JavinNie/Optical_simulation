%%20210804 23:34

%part1: diffuse_simulation
%part2: iterate to focusing

clc
clearvars

% % % %48�߳�
% c = parcluster('local');
% c.NumWorkers = 48;
% parpool(c, c.NumWorkers);

%������������
wavelength = 450e-9;
k = 2*pi/wavelength;

sampling_size = 12e-6;
len_SLM=1e-3;
[xin, yin] = meshgrid(-len_SLM/2:sampling_size:len_SLM/2, -len_SLM/2:sampling_size:len_SLM/2);

%������任
[theta,r]=cart2pol(xin,yin);
r2=r.^2;

n=20;%segment number
%SLM���� tag
x=round((xin+len_SLM/2)/(len_SLM/(n-1+0.1)));
y=round((yin+len_SLM/2)/(len_SLM/(n-1+0.1)));
tag=y*n+x+1;
clear x y

tic
% % % %%%%�����������
% % % M=numel(xin);
% % % mu=[0,0];%��ѧ����
% % % sigma=[1 0;0,1];%Э�������
% % % %���ʷ��棬����ɢ���ⳡ
% % % T=mvnrnd(mu,sigma,M*M);%����n*n������
% % % T=T(:,1)+1i*T(:,2);
% % % T=reshape(T,M,M);
% % % % % ����ֵ�ֽ⣬�����غ�
% % % [~,s,~]=svd(T);
% % % T=T/max(max(s));
% % % clear s
% % % save 'T.mat' T
%
% % % % % ���ش������
load('T.mat');
toc

tic

%n*n����������λ��
ind=zeros(1,n*n);%��ʼ��SLM��������λ����ȫΪ��
ini_flag=1;%��һ�α����ı�־
aim_value=[];%Ŀ������Ĺ�ǿ
phase_level=15;%SLMÿ����������λ����Ŀ
for j=[(1:n*n) (1:n*n)]
    for h=1:phase_level
% % %�������������������λ��        
ind(j)=(h-1)/phase_level*2*pi;
% initial beam profile
%����slm��������λ
phase=tag;
for i=n*n:-1:1
    phase(tag==i)=ind(i);
end
m_phase = angle(exp(1i*phase));
w_slm = 200e-6;
m_beam_amp = (exp( - r2/w_slm^2));  
E_slm=m_beam_amp.*exp(1i*m_phase);

%slm-100nm-Len(f=250)-------medium----observe plane(250mm)
%����·����������
z1=100e-3;
ft=250e-3;
z3=ft/4;
z2=ft-z3;

%ft���棬��slm������ǰ��һ��
fft_sample = 2^11;
[E_out1, Xout1, Yout1] = mFraFFT2D(m_phase, m_beam_amp, ft, z1 , z2, xin, yin, wavelength, fft_sample);
E_out1= interp2 (Xout1,Yout1,E_out1,xin,yin);

[l,c]=size(E_out1);
M=numel(E_out1);
%��Ϊ���������ھ�������
E1_reshaped=reshape(E_out1,M , 1);

if ini_flag==1
    %������ɢ������棬��˹��
    E_dis=E1_reshaped;
    %���ⳡ��Ϊ����
    E_dis=reshape(E_dis,c,l);
    %���������������Ͼ۽�
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

%��ɢ�������
E_dis=T*E1_reshaped;
%����ɢ�ⳡ��Ϊ����
E_dis=reshape(E_dis,c,l);

%���������������Ͼ۽�
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

%���������Ż�������
save 'ind.mat' ind

%%��������
figure
plot(aim_value)
xlabel('��������')
ylabel('Ŀ�������ǿ��')
%%%%����ͼ��
Iout_dB=10*log10(Iout/ref_I);
figure
imagesc(xin(1,:), yin(:,1),Iout_dB,CLIM);
title('difusse final state')
axis square
colormap jet
%%%%���ĵ���ԲȦ
hold on
Iout(aim_index)=1e20;
[r,c]=find(Iout==Iout(aim_index));
plot(xin(1,c),yin(r,1),'go');
axis square
hold off

