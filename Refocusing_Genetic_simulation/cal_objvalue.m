%���㺯��Ŀ��ֵ
%�����������������ֵ
%���������Ŀ�꺯��ֵ
function [objvalue] = cal_objvalue(pop,T)
% x = binary2decimal(pop);
% %ת����������Ϊx�����ı仯��Χ����ֵ
% objvalue=10*sin(5*x)+7*abs(x-5)+10;

wavelength = 450e-9;
k = 2*pi/wavelength;

sampling_size = 12e-6;
len_SLM=1e-3;
[xin, yin] = meshgrid(-len_SLM/2:sampling_size:len_SLM/2, -len_SLM/2:sampling_size:len_SLM/2);
[M,~]=size(xin);
%������任
[~,r]=cart2pol(xin,yin);
r2=r.^2;

n=20;%segment number
%SLM���� tag
x=round((xin+len_SLM/2)/(len_SLM/(n-1+0.1)));
y=round((yin+len_SLM/2)/(len_SLM/(n-1+0.1)));
tag=y*n+x+1;
clear x y

[px,~] = size(pop);

%������������
ini_flag=1;%��һ�α����ı�־
aim_value=[];%Ŀ������Ĺ�ǿ
aim_index=(M+1)/2*M;%Ŀ�����������

%��ʼ��������
for count=1:px
    ind=pop(count,:);
    
    %����slm��������λ
    phase=tag;
    for i=n*n:-1:1
    phase(tag==i)=ind(i);
    end
    m_phase = angle(exp(1i*phase));
    w_slm = 200e-6;
    m_beam_amp = (exp( - r2/w_slm^2));  
    E_slm=m_beam_amp.*exp(1i*m_phase);
    
    %����·�������������
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

    %��һ�Σ��������ǿ�ο�ֵ
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
    
    aim_intensity(count,1)=Iout(aim_index); 
end
objvalue=aim_intensity;