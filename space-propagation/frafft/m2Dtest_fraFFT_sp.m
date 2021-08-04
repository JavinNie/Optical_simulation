clc
clearvars

wavelength = 450e-9;
k = 2*pi/wavelength;
sampling_size = 4e-6;
[xin, yin] = meshgrid(-400e-6:sampling_size:400e-6, -400e-6:sampling_size:400e-6);

m_size = size(xin);


for i = 1:m_size(1)
    for j = 1:m_size(2)
        [xin2(i,j), yin2(i,j)] = mCoordinate(xin(i,j), yin(i,j), 45, 64);
    end
end
r2 = xin2.^2 + yin2.^2;
r3 = xin2.^3 + yin2.^3;



% beam profile on the LCOS
w_slm = 200e-6;
a = [3.5e4].^-1;
b = 1/w_slm^2*3/a;

b=0; %高斯光
m_phase = (angle(exp(1i*b*r3))+pi);
m_beam_amp = (exp( - r2/w_slm^2));  


fft_sample = 4096;

%传播计算，透镜焦距+∞；传播距离Z=Z1+Z2
fT = inf; 
z1 = 0.5;
z2= 0.05;

[E_out1, ~, ~] = mFraFFT2D(m_phase, m_beam_amp, fT,z1 , z2, xin, yin, wavelength, fft_sample);
[E_out_ref, ~, ~] = mFraFFT2D(m_phase*0, m_beam_amp, fT, z1 , z2, xin, yin, wavelength, fft_sample);

[~, Xout, Yout] = mFraFFT2D(0, m_beam_amp,fT,z1 , z2, xin, yin, wavelength, fft_sample);

%强度计算及归一化
I_out_ref = abs(E_out_ref).^2;
m_ref = max(max(max(I_out_ref)));
I_out_ref = I_out_ref/m_ref;
I_out_ref_dB = 10*log10(I_out_ref);

I_out1 =  abs(E_out1).^2;
I_out1 = I_out1/m_ref;
I_out_dB1 = 10*log10(I_out1);

%绘图
scale=5e-3;

CLIM = [-40 -10];
figure
imagesc(Xout(1,:), Yout(:,1), I_out_dB1, CLIM);
axis square
axis([-1 1 -1 1]*scale)

% figure
% imagesc(Xout(1,:), Yout(:,1), I_out_ref_dB, CLIM);
% axis square
