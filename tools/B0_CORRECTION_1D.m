function [Mz_corr]=B0_CORRECTION_1D(Z,dB0,P)
%interpolation (set if needed other than linear(default))
try
    B0_int_meth=P.EVAL.B0_int_meth;
catch
    B0_int_meth='linspline'; % i.e. linspline, linear, spline,cubic,pchip
end;
w_interp=P.EVAL.w_interp;
x_Zspec_ppm=P.SEQ.w;

try
    if strcmp(B0_int_meth,'linspline')
        Mz_corr = (interp1(x_Zspec_ppm-dB0,Z,w_interp,'linear','extrap')+interp1(x_Zspec_ppm-dB0,Z,w_interp,'spline','extrap'))/2;
    else
        Mz_corr = interp1(x_Zspec_ppm-dB0,Z,w_interp,B0_int_meth,'extrap');
    end
    
catch MS
    warning('B0 correction failed during interpolation');
    rethrow(MS)
end


