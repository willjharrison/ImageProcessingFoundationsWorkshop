clear
close all
clc

imSize = 512;
allSDs = 2.^(0:5);
nOris = 32;
allOris = linspace(0,2*pi - 2*pi/nOris, nOris);

allFFT = zeros(imSize);
figure;

for sdLoop = 1:length(allSDs)

    for oriLoop = 1:length(allOris)

        thisSteeredFilt = ...
            steeredFilter(imSize, allOris(oriLoop), ...
            allSDs(sdLoop), imSize/2);

        filtMag = abs(fftshift(fft2(thisSteeredFilt)));
        allFFT = allFFT + filtMag/(allSDs(sdLoop)^2);
        allFFT_out = allFFT - min(allFFT(:));
        allFFT_out = allFFT_out / max(allFFT_out(:));
        
        filtMag = filtMag - min(filtMag(:));
        filtMag = filtMag / max(filtMag(:));

        thisSteeredFilt = thisSteeredFilt - min(thisSteeredFilt(:));
        thisSteeredFilt = thisSteeredFilt / max(thisSteeredFilt(:));
        
        subplot(1,3,1)
        imshow(thisSteeredFilt)
        title('Steered filter')
        
        subplot(1,3,2)
        imshow(filtMag)
        title('Filter spectrum')

        subplot(1,3,3)
        imshow(allFFT_out)
        title('Summed spectrum')
         
        pause(.1)

    end
end
