function ret = GetLNSigmodPartialLoss(x)

temp = exp(-x);
ret = temp / (1 + temp);

end