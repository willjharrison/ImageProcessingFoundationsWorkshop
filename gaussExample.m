clear
close all
clc

imageOrFrequency = 0; % 0 for image, 1 for frequency
noiseProp = .25; % noise SD is prop of image range
showImages = 1;
showFreq = 1; % set this to 1 to also show fourier spectra


% find and load an image
imFolder = 'exampleImages/face/';
imFiles = dir([imFolder 'bw*.jpg']); % original colour and greyscale images are included in the folder

% load an arbitrary image
whichIm = 10;
try
    im = rgb2gray(imread([imFolder imFiles(whichIm).name]));
catch
    im = imread([imFolder imFiles(whichIm).name]);
end

im = double(im)/255;
im = im - min(im(:));
im = im / max(im(:));

imSize = length(im); % assumes square im

im = im + randn(imSize)*noiseProp;

%% Gauss filter design
% A gaussian filter is just a weighted average. The size of the filter
% determines the spatial extent of averaging - bigger kernels mean
% averaging across more pixels -> more blurring

% let's change the SD of the kernel to see how the level of blur changes
allSDs = 2.^(2:2:6);

% define anonymous function so we can easily change the SD in a loop
gaussFilt = @(sd) Gaussian2D(sd, imSize/2, imSize);

Rgauss = zeros(imSize, imSize, length(allSDs));

if showImages
    figure;
    subplot(2,length(allSDs)+1, 1);
    imshow(im,[])
    title('OG im')

    % generate a non-filter just as a place holder to balance the panels
    subplot(2,length(allSDs)+1, 5);
    noFilt = zeros(imSize);
    noFilt(1) = 1;
    noFilt = fftshift(noFilt);

    imshow(noFilt)
    title('Gaussian filter')

end

for sdLoop = 1:length(allSDs)

    thisSD = allSDs(sdLoop);
    thisFilt = gaussFilt(thisSD);

    tic;
    if imageOrFrequency == 1
        thisFiltIm = fftshift(ifft2(fft2(im).*fft2(thisFilt),'symmetric'));
    else
        thisFiltIm = conv2(im,thisFilt,'same');
    end
    thisFiltIm = thisFiltIm - min(thisFiltIm(:));
    thisFiltIm = thisFiltIm / max(thisFiltIm(:));
    Rgauss(:,:,sdLoop) = thisFiltIm;

    if showImages
        subplot(2,length(allSDs)+1, sdLoop+1);
        imshow(thisFiltIm);
        title(sprintf('SD: %d', thisSD))

        subplot(2,length(allSDs)+1, sdLoop + 5);
        imshow(thisFilt,[])
        title('Gaussian filter')

    end

    convTimer = toc;
    fprintf('Time to filter in image domain: %.1f\n', convTimer)

end

%% show the frequency spectrum of each image
if showFreq == 1
    allIms = cat(3,Rgauss,im);
    fftIms = zeros(size(allIms));
    phaseIms = fftIms;
    magIms = fftIms;

    if showImages == 1
        figure;
    end

    for imLoop = 1:size(allIms,3)

        % convert to frequency domain, use fftshift() to centre DC 
        fftIms(:,:,imLoop) = fftshift(fft2(allIms(:,:,imLoop)));
        
        % compute phase
        phaseIms(:,:,imLoop) = angle(fftIms(:,:,imLoop));
        
        % compute magnitude
        magIms(:,:,imLoop) = abs(fftIms(:,:,imLoop));
        
        % log magnitude so it's easier to see in figure.
        mi = log(magIms(:,:,imLoop));

        if showImages == 1
            subplot(1,size(allIms,3), imLoop);
            imshow(mi,[])
            title(sprintf('Mag'))
        end
    end


end