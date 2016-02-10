function [M0_stack, Mz_stack, P] = LOAD(CTRL)
%function [M0_stack, Mz_stack, P] = LOAD(CTRL)


[M_nosat_stack,Mz_stack,P] = load_3D(CTRL);
   
%  calculate Offset-Arrays

[unsorted_x_Zspec_ppm,unsorted_x_M0_ppm]=calcOffset(P,size(Mz_stack));

% For 'alternating' and 'reverse' sampling this puts the values of x_Zspec
% and Mz_stack in the right order
[P.SEQ.w,IX]=sort(unsorted_x_Zspec_ppm);
Mz_stack=double(Mz_stack(:,:,:,IX));
% make w_fit vector for fit plotting or dB0 correction
P.EVAL.w_fit=min(P.SEQ.w):0.01:max(P.SEQ.w);
    
% P.EVAL.w_interp=min(P.SEQ.w):0.02:max(P.SEQ.w);     % statt = P.SEQ.w; rerich geändert für imgui
P.EVAL.w_interp=P.SEQ.w;

% for more sophisticated M0 change here, now first image is used
if (ndims(M_nosat_stack)==4)
    M0_stack=fitM0(double(M_nosat_stack),P);
else
    M0_stack=double(M_nosat_stack);
end


