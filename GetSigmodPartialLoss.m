function ret = GetSigmodPartialLoss(x)

temp = 1 / (1 + exp(-x));
ret = temp * (1 - temp);

end