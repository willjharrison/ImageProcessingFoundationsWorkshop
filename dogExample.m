clear
close all
clc

imageOrFrequency = 0; % 0 for image, 1 for frequency
showImages = 1;
noiseProp = 0; % noise SD is prop of image range

% find and load an image
imFolder = 'exampleImages/dog/';
imFiles = dir([imFolder 'bw*.jpg']); % original colour and greyscale images are included in the folder

% load an arbitrary image
whichIm = 5;
try
    im = rgb2gray(imread([imFolder imFiles(whichIm).name]));
catch
    im = imread([imFolder imFiles(whichIm).name]);
end

im = double(im)/255;
imSize = length(im); % assumes square im
im = im + randn(imSize)*noiseProp; % add noise

if showImages
    figure;
    imshow(im,[])
end
%% DoG filter design
% not to be confused with a derivative-of-Gaussian (or "dog" for short), or
% the appropriate filters to simulate canine vision, this DoG stands for
% difference-of-Gaussian, which is how we produce the "mexican hat"
% isotropic filter for edges

excitatorySD = 4; % px
inhibitorySD = excitatorySD*1.6; % 1.6 by convention, but can be arbitrary
innerGauss = Gaussian2D(excitatorySD, imSize/2, imSize);
innerGauss = innerGauss/sum(innerGauss(:)); 
outterGauss = Gaussian2D(inhibitorySD, imSize/2, imSize);
outterGauss = outterGauss/sum(outterGauss(:));
dogFilter = innerGauss - outterGauss;
dogFilter = dogFilter/sum(abs(dogFilter(:)));

if showImages
    % let's zoom in a bit on the important bit so it's easier to see
    coords = round(imSize/2-inhibitorySD*4):round(imSize/2+inhibitorySD*4);
    zoomDG = dogFilter(coords,coords);
    zoomDG = zoomDG / max([abs(min(zoomDG(:))) max(zoomDG(:))]);
    figure;
    imshow([zoomDG/2 + .5 log(abs(fftshift(fft2(zoomDG))))])
end

%% filtering
if imageOrFrequency == 0 
    Rdog = conv2(im,dogFilter,'same');
else
    Rdog = fftshift(ifft2(fft2(im).*fft2(dogFilter)));
end

Rdog_disp = Rdog - min(Rdog(:));
Rdog_disp = Rdog_disp/max(Rdog_disp(:));

if showImages
    figure;
    imshow([im Rdog_disp])
end

%% What happens if you use a gaussian blur kernel to smooth Rdog?