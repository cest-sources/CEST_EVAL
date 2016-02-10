function [Z_flipped_1D] = calc_Z_flipped_1D(P,Zspec)

x_zspec=P.SEQ.w;

% new x vector
int1    = x_zspec(2:end);
int2    = x_zspec(1:end-1);
step    = abs(min(int1-int2));
offset  = max([abs(min(x_zspec)) abs(max(x_zspec))]);
x_zspec_int = -offset:step:offset;

% interpolate zspec data
y_zspec_int = spline(x_zspec,Zspec,x_zspec_int);

% reverse the Datapoints
y_zspec_int_flipped=y_zspec_int(end:-1:1);

%calculate mirrored zspectrum
if isrow(Zspec)
    Z_flipped_1D(1,:)=interp1(x_zspec_int,y_zspec_int_flipped,x_zspec);
else 
    Z_flipped_1D(:,1)=interp1(x_zspec_int,y_zspec_int_flipped,x_zspec);
end
