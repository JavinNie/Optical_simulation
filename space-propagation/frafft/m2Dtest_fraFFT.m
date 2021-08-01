clc
clearvars
% close all
% load phase_screen.mat
wavelength = 450e-9;
k = 2*pi/wavelength;

sampling_size = 4e-6;
[xin, yin] = meshgrid(-400e-6:sampling_size:400e-6, -400e-6:sampling_size:400e-6);

xin2 = xin;
yin2 = yin;

[m_size] = size(xin);


for i = 1:m_size(1)
    for j = 1:m_size(2)
        [xin2(i,j), yin2(i,j)] = mCoordinate(xin(i,j), yin(i,j), 45, 64);
    end
end


xin = (xin);
yin = (yin);
xin2 = (xin2);
yin2 = (yin2);

r2 = xin2.^2 + yin2.^2;
r3 = xin2.^3 + yin2.^3;



w_slm = 200e-6;
a = [3.5e4].^-1;
b = 1/w_slm^2*3/a;

b=0;
m_phase = (angle(exp(1i*b*r3))+pi);
% m_phase2 = (angle(exp(1i*(b*r3+xxx*10*pi)))+pi);

m_beam_amp = (exp( - r2/w_slm^2));  % beam profile on the LCOS

% fT = 0.25; 
% n = 4;
fT = inf; 

fft_sample = 4096;

z1 = 0.5;
z2= 0.05;
E_out1 = (zeros(fft_sample, fft_sample, length(z2)));
% E_out2 = E_out1;
E_out_ref = E_out1;
% E_out2 = E_out1;
% E_out_refx = E_out1;
for i = 1:length(z2)  
    [E_out1(:,:,i), ~, ~] = mFraFFT2D_sp(m_phase, m_beam_amp, fT,z1 , z2, xin, yin, wavelength, fft_sample);
    [E_out_ref(:,:,i), ~, ~] = mFraFFT2D_sp(m_phase*0, m_beam_amp, fT, z1 , z2, xin, yin, wavelength, fft_sample);
    
    
end

[~, Xout, Yout] = mFraFFT2D_sp(0, m_beam_amp,fT,z1 , z2, xin, yin, wavelength, fft_sample);


I_out_ref = abs(E_out_ref).^2;
m_ref = max(max(max(I_out_ref)));
I_out_ref = I_out_ref/m_ref;
I_out_ref_dB = 10*log10(I_out_ref);


I_out1 =  abs(E_out1).^2;
I_out1 = I_out1/m_ref;
I_out_dB1 = 10*log10(I_out1);


CLIM = [-40 -10];
figure
imagesc(Xout(1,:), Yout(:,1), I_out_dB1, CLIM);
axis square

scale=5e-3;
axis([-1 1 -1 1]*scale)

% figure
% imagesc(Xout(1,:), Yout(:,1), I_out_ref_dB, CLIM);
% axis square
