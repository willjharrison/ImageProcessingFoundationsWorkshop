clear
close all
clc

imageOrFrequency = 1; % 0 for image, 1 for frequency
showImages = 1;
noiseProp = .025; % noise SD is prop of image range
sd = 8; % SD of the gaussian from which the derivate is computed

% find and load an image
imFolder = 'exampleImages/dog/';
imFiles = dir([imFolder 'bw*.jpg']); % original colour and greyscale images are included in the folder

% load an arbitrary image
whichIm = 10;
try
    im = rgb2gray(imread([imFolder imFiles(whichIm).name]));
catch
    im = imread([imFolder imFiles(whichIm).name]);
end

im = double(im)/255;
imSize = length(im); % assumes square im
pos = ceil(imSize/2); % centre of gaussian filter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% When building orientation sensitive models, I always find it useful to
% have various sanity checks where you know the ground truth of the
% filtering result. e.g.:
% im = zeros(imSize); 
% im(imSize/2-4:imSize/2+4,:) = 1; % creates a horizontal (0°) line
% im = imrotate(im,0,'crop'); % rotate by some amount - this should be recovered by the algo below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add noise
im = im + randn(imSize)*noiseProp;

if showImages
    figure;
    imshow(im,[]);
    title('OG image')
end

%% BASIS FILTERS 
% derivative of gaussian functions as per Freeman '95
Gx = gaussDerZero(imSize,sd,pos);
Gy = gaussDerNinety(imSize,sd,pos);

if showImages
    figure;
    imshow([Gx Gy]/2 + .5)
    title('Basis filters')
end

Gx = Gx/sum(abs(Gx(:)));
Gy = Gy/sum(abs(Gy(:)));

%% Image filtering 

if imageOrFrequency == 0 % image domain
    % filter image with basis filters using "conv2"
    tic;
    Rx = conv2(im,Gx,'same');
    Ry = conv2(im,Gy,'same');
    convTimer = toc;
    fprintf('Time to filter in image domain: %.1f\n', convTimer)

else % frequency domain
    tic;
    Rx = fftshift(ifft2(fft2(Gx).*fft2(im)));
    Ry = fftshift(ifft2(fft2(Gy).*fft2(im)));
    convTimer = toc;
    fprintf('Time to filter in frequency domain: %.1f\n', convTimer)
end


if showImages
    figure;
    imshow([Rx Ry],[])
    title('Filter responses: sin (left), cos (right)')

end


%% RECOVER DOMINANT ORIENTATION 
% find dominant orientation at every pixel location
thetaHat = atan2(Ry,Rx);

% gradient magnitude
mag = sqrt(Rx.^2 + Ry.^2);

% circular stats for orientation
thetaMu = circ_mean(wrapTo2Pi(thetaHat(:)*2),mag(:))/2;

fprintf('Mean orientation: %.1f°\n', rad2deg(thetaMu))

if showImages 
    
    % create a colourwheel
    colWheelSize = round(imSize/5);
    colWheel = createColourWheel_v04(colWheelSize,0,0);
    
    % colourise the recovered orientations
    colThetas = colouriseOris(thetaHat);
    
    % make magnitude image combatible with coloured image for visualising
    magOut = repmat(mag,1,1,3);
    magOut = magOut - min(mag(:));
    magOut = magOut / max(magOut(:));

    % make an image that combines both colour (i.e. orientation) AND
    % magnitude and combine colourwheel
    colMagThetas = colouriseOris_withAmp(thetaHat, mag, 70);
    % rotIm = imrotate(colMagThetas,-rad2deg(thetaMu),'crop');
    % figure;
    % imshow([colMagThetas rotIm])

    colMagThetas(1:colWheelSize,1:colWheelSize,:) = colWheel;
    
    figure;
    imshow([colThetas magOut colMagThetas]);

    
end

%% how to be a baller
% Loop through N image locations and draw a steered filter matching the
% dominant structure in the original image
canvas = zeros(imSize);

% create a mask to prevent finding strong edge detectors at the border of
% the image, rather than in the internal structure (this is usually taken
% care of by the edge artefact section below)
[~,radDist] = polarDistFunAccMid(imSize);
edgePadding = 20; % px
mask = createLowPassFilter(radDist, imSize/2-edgePadding, edgePadding);
magIm = magOut(:,:,1).*mask;

% so we don't keep finding the same image location each draw, we will
% remove each chosen location after we draw it, by placing an inverse
% Gaussian at the chosen location.
gaussLoc = @(pos) 1 - Gaussian2D(sd, pos, imSize);

nFilts = 500;

% loop through the filters and draw them additively - this is why I get
% paid the big bucks (btw lmk if someone wants to pay me big bucks)
for filtLoop = 1:nFilts

    % find the strongest edge signals:
    [m,idx] = max(magIm(:));

    % find the dominant orientation 
    filtOri = thetaHat(idx);

    % find the x/y coords
    [filtPos(1), filtPos(2)] = ind2sub(size(canvas),idx);
    
    % steer a filter
    canvas = canvas + steeredFilter(imSize, filtOri, sd, filtPos);

    % reduce magnitude at filter location to prevent the same location
    % being returned again.
    magIm = magIm.*gaussLoc(filtPos);
    

end

if showImages == 1
    figure;
    imshow(canvas,[])
end

% %% Edge artefacts ruin everything everywhere all at once!
% % One simple way to remove edges is to apply two extra image processing
% % steps:
% 
% % 1. use a circular aperture to mask the corners of the image
% % create aperture
% [~,radDist] = polarDistFunAccMid(imSize);
% edgePadding = 20; % px
% mask = createLowPassFilter(radDist, imSize/2-edgePadding, edgePadding);
% apertureIm = im.*mask;
% 
% if showImages == 1
%     figure;
%     subplot(1,2,1)
%     imshow([im mask apertureIm])
% end
% 
% % 2. now add padding around the entire image so circular wrapping ain't no
% % thang
% paddedIm = addPadding(apertureIm,2,0,0);
% 
% if showImages == 1
%     subplot(1,2,2)
%     imshow(paddedIm)
% end
% 
% % 3. now repeat the filtering, but with the newly sized padded image.
% % Because the image is double the dimensions (as per addpadding()), the
% % filters will also need to be built from scratch.