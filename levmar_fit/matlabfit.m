
function [ret, popt, info, covar] = matlabfit(fitfunc, p0, M, nIter, options,boundaries, lb, ub, w, P)
% P.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-4, 1E-06];

%MATLAB fitting toolbox: This doesnt work yet, as the parameter vector has
%to be split up in seperate variables, that is a bit stupid to programm to
%be general working, i implement it for the optimization toolbox firt.
%
% Algorithm — Algorithm used for the fitting procedure:
% Trust-Region — This is the default algorithm and must be used if you specify Lower or Upper coefficient constraints.
% Levenberg-Marquardt — If the trust-region algorithm does not produce a reasonable fit, and you do not have coefficient constraints, try the Levenberg-Marquardt algorithm.
% Finite Differencing Parameters
% 
% DiffMinChange — Minimum change in coefficients for finite difference Jacobians. The default value is 10-8.
% DiffMaxChange — Maximum change in coefficients for finite difference Jacobians. The default value is 0.1.
% Note that DiffMinChange and DiffMaxChange apply to:
% 
% Any nonlinear custom equation, that is, a nonlinear equation that you write
% Some of the nonlinear equations provided with Curve Fitting Toolbox software
% However, DiffMinChange and DiffMaxChange do not apply to any linear equations.
% 
% Fit Convergence Criteria
% 
% MaxFunEvals — Maximum number of function (model) evaluations allowed. The default value is 600.
% MaxIter — Maximum number of fit iterations allowed. The default value is 400.
% TolFun — Termination tolerance used on stopping conditions involving the function (model) value. The default value is 10-6.
% TolX — Termination tolerance used on stopping conditions involving the coefficients. The default value is 10-6.
% Coefficient Parameters
% 
% Unknowns — Symbols for the unknown coefficients to be fitted.
% StartPoint — The coefficient starting values. The default values depend on the model. For rational, Weibull, and custom models, default values are randomly selected within the range [0,1]. For all other nonlinear library models, the starting values depend on the data set and are calculated heuristically. See optimized starting points below.
% Lower — Lower bounds on the fitted coefficients. The tool only uses the bounds with the trust region fitting algorithm. The default lower bounds for most library models are -Inf, which indicates that the coefficients are unconstrained. However, a few models have finite default lower bounds. For example, Gaussians have the width parameter constrained so that it cannot be less than 0. See default constraints below.
% Upper — Upper bounds on the fitted coefficients. The tool only uses the bounds with the trust region fitting algorithm. The default upper bounds for all library models are Inf, which indicates that the coefficients are unconstrained.
% For more information about these fit options, see the lsqcurvefit function in the Optimization Toolbox™ documentation.


%  fitable_func =@(x,w,Z) feval(fitfunc,x, w, P);
% 
% ft = fittype('fitable_func(x,w,Z)');
% 
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Algorithm='Levenberg-Marquardt';
% opts.Display = 'Off';
% opts.Lower = lb;
% opts.StartPoint = p0;
% opts.Upper = ub;
% opts.MaxIter= nIter;
% opts.DiffMinChange= options(2);
% opts.DiffMaxChange= 0.1000;
% opts.MaxFunEvals= 600;
% opts.TolFun= options(4);
% opts.TolX= options(3);

% [fitresult, gof] = fit( xData, yData, ft, opts, 'problem', {P.R1A P.tp} );
% 
% ci = confint(fitresult);
% ci = ci(2,:)-coeffvalues(fitresult);


%LEVMAR (if mexfile is properly compiled)
%      opts(1) scale factor for the initial damping factor
%      opts(2) stopping threshold for ||J^T e||_inf
%      opts(3) stopping threshold for ||Dp||_2
%      opts(4) stopping threshold for ||e||_2
%      opts(5) step used in finite difference approximation to the Jacobian.

%MATLAB optimization toolbox


[w, M] = prepareCurveData(w, M );

fitable_func =@(x,w,Z) feval(fitfunc,x, w, P)';

% fit-options
matlab_options = optimset('TolFun',options(4),'TolX',options(3), 'MaxIter',nIter,'Display','off');

try
[popt resnorm RES,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(fitable_func,p0,w,M,lb,ub,matlab_options);

[ci, varb, corrb, varinf] = nlparci(popt,RES,JACOBIAN,0.95);
ci(:,1) = ci(:,1)-popt';
ci(:,2) = ci(:,2)-popt';
ret=EXITFLAG;
info=OUTPUT;
covar=corrb;

catch
    ret=-1;
    info=0;
    covar=0;
    popt=0;

end;





