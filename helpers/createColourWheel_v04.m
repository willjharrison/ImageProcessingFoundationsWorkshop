function colWheel = createColourWheel_v04(imSize,showFig,bgCol)
% imSize = 64; showFig = 1;
% colWheel = createColourWheel(512,1)
% 
% Create an RGB image of a colour wheel with 360 colours evenly spaced in
% CIElab space.
% 
% v03 updated to use lab2rgb function by Paul Bays.
% 
% v04 updated to make code much faster and cleaner.
% 
% Example:
% imSize = 512;
% showFig = 1;
% colWheel = createColourWheel(imSize,showFig);
% 
% wjh July 2016 - willjharri@gmail.com
% v04 April 2017 wjh
% Nov 2021 - updated to include option for background colour - wjh

if nargin < 3
    bgCol = 0;
end

% set up a meshgrid with angles and radii
[angDist,radDist] = polarDistFunAccMid(imSize);

% make angles go from 0 - 359
angDist(angDist<0) = 360+angDist(angDist<0); 
angDist = floor(angDist);

% calculate the x-y coords of all our colour angles
[a,b]=pol2cart(deg2rad(angDist),70);

% set colourspace centre and L value according to Bays
a = a + 20;
b = b + 38;
L = ones(imSize)*70;

colWheel = lab2rgb_array(L,a,b)/255; 

% trim image to show just a wheel
colWheel(repmat(radDist,1,1,3)>imSize/2 | ...
    repmat(radDist,1,1,3)<imSize/4) = bgCol;

if showFig
    imshow(colWheel,[])
end;

% function [angDist,radDist] = polarDistFun(imSize)
% % [angDist,radDist] = polarDistFun(imSize)
% % 
% % Calculates the radial and angular distances from the centre of a square
% % image with size specified by imSize. angDist is in degrees, not radians.
% 
% [X,Y]=meshgrid(-imSize/2:imSize/2-1,-imSize/2:imSize/2-1); % 2D matrix of radial distances from centre
% radDist=(X.^2+Y.^2).^0.5; % radial distance from centre
% angDist=rad2deg(atan2(-Y, X)); % orientation around image

