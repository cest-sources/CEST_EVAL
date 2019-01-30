function [popt, ret, covar, info]=levmar_fit(M,P)

lb = P.FIT.lower_limit_fit;
ub = P.FIT.upper_limit_fit;
p0 = P.FIT.start_fit;

if isfield(P.FIT,'exclude')
    P.SEQ.w(P.FIT.exclude)=[];
    M(P.FIT.exclude)=[];
end;
    
if exist('levmar','file')==3
    [ret, popt, info, covar] = levmar(P.FIT.fitfunc, p0, M, P.FIT.nIter, P.FIT.options, 'bc', lb, ub, P.SEQ.w, P);

elseif license('test', 'optimization_toolbox')
    [ret, popt, info, covar] = matlabfit(P.FIT.fitfunc, p0, M, P.FIT.nIter, P.FIT.options, 'bc', lb, ub, P.SEQ.w, P);
else
    error('You dont have a mex file or the optimization toolbox');
end;
    
if ret==-1    
    popt=p0*0;
end;










