function [angDist,radDist] = polarDistFunAccMid(imSize)
% [angDist,radDist] = polarDistFunAccMid(imSize)
% 
% Calculates the radial and angular distances from the centre of a square
% image with size specified by imSize. angDist is in degrees, not radians. 
% 
% Updated to AccMid to ensure that the actual midpoint is the midpoint of
% the output.

[X,Y]=meshgrid(-imSize/2+.5:imSize/2+.5-1,-imSize/2+.5:imSize/2+.5-1); % 2D matrix of radial distances from centre
% [X,Y]=meshgrid(-imSize/2+1:imSize/2,-imSize/2+1:imSize/2); % 2D matrix of radial distances from centre
radDist=(X.^2+Y.^2).^0.5; % radial distance from centre
angDist=rad2deg(atan2(-Y, X)); % orientation around image
