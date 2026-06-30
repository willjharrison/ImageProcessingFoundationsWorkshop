function filt = gaussDerZero(imSize,sd,pos)

if length(pos) == 1
    pos(2) = pos(1);
end

[y,x] = meshgrid(1:imSize);
x = (x-pos(1))/sd;
y = (y-pos(2))/sd;

filt = -2*x.*exp(-(x.^2+y.^2));