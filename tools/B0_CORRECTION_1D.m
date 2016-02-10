function [Mz_corr]=B0_CORRECTION_1D(Z,dB0,P)
%interpolation (set if needed other than linear(default))
int_meth='linear'; % i.e. spline,cubic,pchip
xfit=P.EVAL.w_fit;
w_interp=P.EVAL.w_interp;
x_Zspec_ppm=P.SEQ.w;

if dB0>0 %frage ab: aktuelle B0 verschiebung
    ind=find(xfit > dB0);
else
    ind=find(xfit >= dB0);
end;
if numel(ind)>0
    minind=ind(1);
else
    minind=fix((numel(xfit)/2));
   %    'DANGER in B0 correction - dB0 larger than sampling range'
end;

% find offset of the fitted minimum
% interpolate zspec to higher number of points
try
    yint=interp1(x_Zspec_ppm,Z,xfit,int_meth);%
catch
    'fault'
end

xxx=xfit-xfit(minind);

Mz_corr = interp1(xxx,yint,w_interp,'linear','extrap');

