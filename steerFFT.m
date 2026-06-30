clear
close all
clc
% this demo uses steered filters to compare image vs fourier domain. Three
% images will animate: 1) a steered filter of a given bandwidth and
% orientation, 2) the steered filter's fourier spectrum, 3) the cumulative
% sum of all filters' spectra.

% some basic filter settings - all can be modified
imSize = 512;
allSDs = 2.^(0:5);
nOris = 16;
allOris = linspace(0,2*pi - 2*pi/nOris, nOris);

% animation delay
pDelay = 0.25; % seconds

allFFT = zeros(imSize);
figure;
for sdLoop = 1:length(allSDs) % run through filter SDs

    for oriLoop = 1:length(allOris) % run through filter orientations

        % create the steered filter
        thisSteeredFilt = ...
            steeredFilter(imSize, allOris(oriLoop), ...
            allSDs(sdLoop), imSize/2);

        % compute and normalise spectrum
        filtMag = abs(fftshift(fft2(thisSteeredFilt)));
        allFFT = allFFT + filtMag/(allSDs(sdLoop)^2);
        allFFT_out = allFFT - min(allFFT(:));
        allFFT_out = allFFT_out / max(allFFT_out(:));
        
        filtMag = filtMag - min(filtMag(:));
        filtMag = filtMag / max(filtMag(:));

        thisSteeredFilt = thisSteeredFilt - min(thisSteeredFilt(:));
        thisSteeredFilt = thisSteeredFilt / max(thisSteeredFilt(:));
        
        % show it all
        subplot(1,3,1)
        imshow(thisSteeredFilt)
        title('Steered filter')
        
        subplot(1,3,2)
        imshow(filtMag)
        title('Filter spectrum')

        subplot(1,3,3)
        imshow(allFFT_out)
        title('Summed spectrum')
         
        pause(pDelay)

    end
end
