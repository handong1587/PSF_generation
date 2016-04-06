function [Raw,V]= createBlurredRawColor(y, psf, lambda, sigma_gauss, init)
%
% Creates a Blurred and noisy image simulating raw measurements under motion blur. The image formation model
% is the one used in [Boracchi and Foi 2011] and [Boracchi and Foi 2012], where
% both the blur due to camera motion and the sensor noise are defined as functions of the exposure time. 
% Two noise terms affect the observation:
%	- a time dependent (and signal dependent) component, inherent to photon-acquisition process, which follows a Poissonian distribution.
%   - a time independent (and signal independent) component, which accounts for electronic and thermal noise, following a Gaussian distribution.
% This model provides a unified description of both long-exposure and short-exposure images
% thus for describing very general acquisition paradigms including the recently proposed approaches 
% based on blurred/noisy image pairs such as [Tico and Vehvilainen 2006] and [Yuan et al 2007] 
%
%  [Raw,V]= CreateBlurredRaw(y, psf, lambda, sigma_gauss, init)
%
% output description
% Raw           noisy blurred observation
% V             Fourier Transform of PSF (sized as Raw)
% 
% input description
% y                original image
% psf              psf in space domain
% lambda           Poisson noise parameter
% sigma_gauss      Gaussian noise parameter
% init             (optional) initialization parameter for Poissonian and Gaussian noise
%
%
% References
% [Boracchi and Foi 2012] Giacomo Boracchi and Alessandro Foi, "Modeling the Performance of Image Restoration from Motion Blur"
%  Image Processing, IEEE Transactions on. vol.21, no.8, pp. 3502 - 3517, Aug. 2012, doi:10.1109/TIP.2012.2192126 
% Preprint Available at http://home.dei.polimi.it/boracchi/publications.html
%
% [Boracchi and Foi 2011] Giacomo Boracchi and Alessandro Foi, "Uniform motion blur in Poissonian noise: blur/noise trade-off"
%  Image Processing, IEEE Transactions on. vol. 20, no. 2, pp. 592-598, Feb. 2011 doi: 10.1109/TIP.2010.2062196 
% Preprint Available at http://home.dei.polimi.it/boracchi/publications.html
%
% [Tico and Vehvilainen 2006] M. Tico and M. Vehvilainen, ?Estimation of motion blur point spread function from differently exposed image frames,? 
% in Proc. EUSIPCO 2006, 2006.
%
% [Yuan et al 2007] L. Yuan, J. Sun, L. Quan, and H.-Y. Shum, ?Image deblurring with blurred/noisy image pairs,? 
%  ACM Trans. Graph., vol. 26, no. 3, p. 1, 2007
% 
% Revision History
% March 2009         - beta release (not available online)
% December 2012  - first official release
%
% Giacomo Boracchi*, Alessandro Foi**
% giacomo.boracchi@polimi.it
% alessandro.foi@tut.fi
% * Politecnico di Milano
% **Tampere University of Technology


if nargin<4
    sigma_gauss=0;
end

if nargin==5
    % noise initialization
    randn('seed', init);
    rand('seed', init);  %%% FIX SEED FOR RANDOM PROCESSES  (OPTIONAL)
end

%% rescale the original image image
y = y * lambda;

[yN,xN,channel]=size(y);
[ghy,ghx,channel]=size(psf);

%% Generate Blurred Observation

% pad PSF with zeros to whole image domain, and centers it.
big_v=zeros(yN,xN,channel);
big_v(1:ghy,1:ghx,:)=psf;
big_v=circshift(big_v,-round([(ghy-1)/2 (ghx-1)/2]));

% Frequency response of the PSF
V=fft2(big_v);
% performs blurring (convolution is obtained by product in frequency domain)
y_blur=real(ifft2(V.*fft2(y)));

%% Add noise terms

% Poisson Noise (signal and time dependent)
Raw=poissrnd(y_blur.*(y_blur>0));   %%  Poissonian process having expectation y_blur

% Gaussian Noise (signal and image independent)
Raw=Raw + sigma_gauss*randn(size(Raw));
