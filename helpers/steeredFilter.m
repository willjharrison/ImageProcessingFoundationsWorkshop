function filt = steeredFilter(imSize,theta,sd,pos)
% first derivative of gaussian

filt = cos(theta)*gaussDerZero(imSize,sd,pos) +...
    sin(theta)*gaussDerNinety(imSize,sd,pos);