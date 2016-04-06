%
%
% this script illustrates the generation of random motion PSFs and of motion blurred pictures by setting the exposure
% time. The image formation model and the description of PSF generation is reported in [Boracchi Foi and 2011] and [Boracchi and Foi 2012]
%
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
% December 2012
%
% Giacomo Boracchi*, Alessandro Foi**
% giacomo.boracchi@polimi.it
% alessandro.foi@tut.fi
% * Politecnico di Milano
% **Tampere University of Technology

close all
clear
clc

do_show = 1;
% gray or color image
process_color = 1;

% trajectory curve parameters
PSFsize = 64;
anxiety = 0.005;
numT = 2000;
MaxTotalLength = 64;

% PSF parameters
T = [0.0625 , 0.25 , 0.5, 1]; % exposure Times
do_centerAndScale = 0;

% noise paramters
lambda = 2048;
sigmaGauss = 0.05;

% load original image
y = im2double(imread('imgs/000215_gray.jpg'));
img = im2double(imread('imgs/000215.jpg'));

%% Generate Random Motion Trajectory
TrajCurve = createTrajectory(PSFsize, anxiety, numT, MaxTotalLength, do_show);

%% Sample TrajCurve and Generate Motion Blur PSF
PSFs = createPSFs(TrajCurve, PSFsize,  T , do_show , do_centerAndScale);

%% Generate the sequence of motion blurred observations
zeroCol = [];%zeros(size(y,1) , 5);
paddedImage = [zeroCol];

if process_color == 1
    for ii = 1 : numel(PSFs)
        PSF_3 = cat(3, PSFs{ii}, PSFs{ii}, PSFs{ii});
        z{ii} = createBlurredRawColor(img, PSF_3, lambda, sigmaGauss);
        figure(), 
        imshow(z{ii}, []),title(['image having exposure time ', num2str(T(ii))]);
        imTemp = z{ii}./max(z{ii}(:));
        imTemp(1 : size(PSF_3, 1), 1 : size(PSF_3 , 2), 1 : size(PSF_3 , 3)) = PSF_3./max(PSF_3(:));
        paddedImage=[paddedImage, imTemp, zeroCol];
    end
else
    for ii = 1 : numel(PSFs)
        z{ii} = createBlurredRaw(y, PSFs{ii}, lambda, sigmaGauss);
        figure(), 
        imshow(z{ii}, []),title(['image having exposure time ', num2str(T(ii))]);
        imTemp = z{ii}./max(z{ii}(:));
        imTemp(1 : size(PSFs{ii}, 1), 1 : size(PSFs{ii} , 2)) = PSFs{ii}./max(PSFs{ii}(:));
        paddedImage=[paddedImage, imTemp, zeroCol];
    end
end

figure(), imshow(paddedImage,[]),title('Sequence of observations, PSFs is shown in the upper left corner');
imwrite(paddedImage, 'pdimage.jpg', 'jpg');