function C = colouriseOris(im)
% takes an input "im" that is orientations between -pi and pi and converts
% it to LAB coloursspace. C is an imSize x imSize x 3 rgb image.

imSize = size(im);

% convert to colour
L = ones(imSize)*70;
[a,b] = pol2cart(im,L(1));
C = lab2rgb_array(L,a,b)/255;