"""
Created on Wed Mar 18 20:25:19 2020

@author: Fuwei
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import (AutoMinorLocator, MultipleLocator)
pi = np.pi
ln2 = np.log(2)
lambda_0 = 830e-9 # center wavelength of source
d_lambda = 20e-9 # FWHM wavelength bandwidth of source
ns=1.38 # refractive index of sample
l_s1 = 100e-6 # location of backscatterer 1
l_s2 = 150e-6 # location of backscatterer 2
r_s1 = 0.5 # reflectivity of backscatterer 1
r_s2 = 0.25 # reflectivity of backscatterer 2
k_0=2*pi/lambda_0 # center propagation constant
delta_k=2*pi*d_lambda/lambda_0**2 # FWHM bandwidth of k
sigma_k = delta_k/np.sqrt(2*ln2) # standard deviation of k
N=2**10 # number of sampling points
nsigma = 5 # number of standard deviations to plot on each side of kO

plt.figure(1)
plt.suptitle("FD-OCT Simulation",fontsize=25,fontweight=800)
plt.subplot(4,1,1) # Generate the interferogram
k = k_0 + sigma_k*np.linspace(-nsigma,nsigma, N) # array for k
S_k = np.exp(-(1/2)*((k-k_0)**2)/(sigma_k**2)) # Gaussian source PSD
E_s1 = r_s1*np.exp(2j*k*ns*l_s1) # sample electric field from scatter 1
E_s2 = r_s2*np.exp(2j*k*ns*l_s2) # sample electric field from scatter 2
I_k1 = S_k * np.abs(1 + E_s1 + E_s2)**2 # interferogram (r_R = 1)
plt.plot(k/k_0,I_k1/I_k1.max(), 'k')
plt.title('(a)Interferogram')
plt.xlabel(r'Propagation constant $\mathregular{k/k_0}$')
plt.ylabel('Normalized intensity')
plt.axis([0.9,1.1,0,1.1])

plt.subplot(4,1,2) # Inverse Fourier transform (IFT) of the interferogram
spec1 =np.abs(np.fft.fftshift(np.fft.ifft(I_k1)))/np.sqrt(N)
d_ls_prime = 1/(2*nsigma*sigma_k/(2*pi)) # bin = 1/sampling range
ls_prime = d_ls_prime*np.arange(-N/2,N/2)# frequency array
plt.plot(ls_prime/(2*ns),spec1/spec1.max(), 'k') # scale the frequency
plt.title('(b)IFT of the interferogram')
plt.xlabel(r"Depth $\mathregular{I_s}$ (m)")
plt.ylabel('Relative reflectivity')
plt.gca().xaxis.get_major_formatter().set_powerlimits((0,1))
plt.axis([-2*l_s2,2*l_s2,0,1.1])

plt.subplot(4,1,3); # IFT of the deconvolved interferogram
spec1_norm =np.abs(np.fft.fftshift(np.fft.ifft(I_k1/S_k)) )/np.sqrt(N)
d_ls_prime = 1/(2*nsigma*sigma_k/(2*pi)) # bin size = 1/sampling range
ls_prime = d_ls_prime*np.arange(-N/2,N/2) # frequency array
plt.plot(ls_prime/(2*ns),spec1_norm/spec1_norm.max(), 'k')
plt.title('IFT of the deconvolved interferogram')
plt.xlabel(r'Depth $\mathregular{I_s}$ (m)')
plt.ylabel('Relative reflectivity')
plt.axis([-2*l_s2,2*l_s2,0,1.1])
plt.gca().xaxis.get_major_formatter().set_powerlimits((0,1))

plt.subplot(4,1,4) # IFT of the deconvolved differential interferogram
I_k2 = S_k * np.abs(-1 + E_s1 + E_s2)**2 # interferogram
delta_I_k = I_k1 - I_k2
spec2=np.abs(np.fft.fftshift(np.fft.ifft(delta_I_k/S_k)))/np.sqrt(N)
plt.plot(ls_prime/(2*ns),spec2/spec2.max(), 'k')
plt.title('IFT of the deconvolved differential interferogram')
plt.xlabel("Depth $\mathregular{I_s}$ (m)")
plt.ylabel('Relative reflectivity')
plt.axis([-2*l_s2,2*l_s2,0,1.1])
plt.gca().xaxis.get_major_formatter().set_powerlimits((0,1))
plt.subplots_adjust(hspace=0.6)
plt.show()