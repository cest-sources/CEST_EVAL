function [popt, ret, covar, info]=levmar_fit(M,P)

lb = P.FIT.lower_limit_fit;
ub = P.FIT.upper_limit_fit;
p0 = P.FIT.start_fit;

if exist('levmar')==3
[ret, popt, info, covar] = levmar(P.FIT.fitfunc, p0, M, P.FIT.nIter, P.FIT.options, 'bc', lb, ub, P.SEQ.w, P);
else
    [ret, popt, info, covar] = matlabfit(P.FIT.fitfunc, p0, M, P.FIT.nIter, P.FIT.options, 'bc', lb, ub, P.SEQ.w, P);
end;
    
if ret==-1
    
    popt=p0*0;
end;










