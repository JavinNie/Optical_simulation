%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fT = 175e-3; 
% wavelength = 1550e-9; 
% N_pixels = 25;
% pixel_size = 6.4e-6;
% sampling_size = 0.1e-6;
% m_period = 7.5; 
% sampling_size = 6.4e-6;
% xin = -3200e-6:sampling_size:3200e-6;
% fT = 10000;
% z1 = 0.0;
% z2 = 100;
% wavelength = 450e-9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%自由空间传播的仿真算法，对f1和f2做了极限处理
function [E_out, Xout, Yout] = mFraFFT2D_sp(m_phase, m_beam_amp,fT, z1, z2, xin,yin, wavelength, fft_sample)
if fT~=inf
    error('NOT FREESPACE')
end
E_in=m_beam_amp.*exp(1i*(m_phase));

sampling_size = abs(yin(1) - yin(2));

fH = z1 + z2 - z1*z2/fT; 
f2 = (z1+z2);
f1 = (z1+z2);

% f2 = (z1*z2 - (z1+z2)*fT)/(fT-z1);
% f1 = (z1*z2 - (z1+z2)*fT)/(fT-z2);

m_tan = max(max(xin))/fH;
step2 = wavelength*fH/fft_sample/sampling_size;

[Xout,Yout] = meshgrid((-((fft_sample-1)/2)*step2):step2:((fft_sample-1)/2*step2),(-((fft_sample-1)/2)*step2):step2:((fft_sample-1)/2*step2));

k = 2*pi/wavelength;
m_phase_f1 =  -k*(xin.^2 + yin.^2)/2/f1;
m_phase_f2 = -k*(Xout.^2+Yout.^2)/2/f2;

E_in = E_in.*exp(1i*m_phase_f1);
E_out = fftshift(fft2(E_in, fft_sample, fft_sample)).*exp(1i*(((Xout+Yout)*m_tan/wavelength)*2*pi+m_phase_f2));
end

