function ret  = GetNormMatrix(x,y,mean,std)
ret = normrnd(mean,std,[x y]);
end