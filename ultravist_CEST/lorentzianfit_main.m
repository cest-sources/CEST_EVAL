function [Zlab, Zref, Pnew, popt] = lorentzianfit_main(Z_corrExt, P, Segment, mode)
% ** function [Zlab, Zref, Pnew, popt] = lorentzianfit_main(Z_corrExt, P, Segment, mode)
% 'mode' can be:
%   'invivo' (default) uses standard 5-pool Lorentzian model (water, amide,
%       NOE, MT, amine).
%   'ultravist' uses 3 pools corresponding to Ultravist z-spectrum peaks
%       (water, @4.2ppm, @5.6ppm).
%
% CT 20170111

if nargin<4
    mode='invivo';
end

Pnew = P;
Pnew.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-04, 1E-06];
Pnew.FIT.nIter     = 50;
Pnew.FIT.extopt    = 1; % change parameters explicitly

switch mode
    case 'invivo'
        Pnew.FIT.modelnum  = 5;     % number of Lorentzian pools (possible 1-5)
        %Lorentzian line LI defined by amplitude Ai, width Gi [ppm] and offset dwi[ppm]: Li=Ai.*Gi^2/4./ (Gi^2/4+(dw-dwi).^2) ;
        %1=water; 2=amide; 3=NOE; 4=MT; 5=amine
        %const.Zi   A1    G1    dw1     A2     G2    dw2     A3    G3   dw3     A4    G4   dw4    A5    G5   dw5
        lb = [ 0.5  0.02  0.3  -1       0.0    0.4   +3     0.0    1    -4.5    0.0   10   -4     0.0   1    1   ];
        ub = [ 1    1     10   +1       0.2    3     +4     0.4    5    -2        1   100  -1     0.2   3.5  2.5 ];
        p0 = [ 1    0.9   1.4   0       0.025  0.5   3.5    0.02   3    -3.5    0.1   25   -1     0.01  1.5  2.2 ];
    case 'ultravist'
        Pnew.FIT.modelnum  = 3;
        %Lorentzian line LI defined by amplitude Ai, width Gi [ppm] and offset dwi[ppm]: Li=Ai.*Gi^2/4./ (Gi^2/4+(dw-dwi).^2) ;
        %1=water; 2=@4.2ppm; 3=@5.6ppm
        %const.Zi   A1    G1    dw1     A2     G2    dw2     A3    G3   dw3
        lb = [ 0.5  0.02  0.3  -1       0.0    1     3.8     0.0    1    5   ];
        ub = [ 1    1     10   +1       0.6    5     4.8     0.6    5    6   ];
        p0 = [ 1    0.9   1.4   0       0.1    3     4.2     0.1    3    5.6 ];
    otherwise
        error('Input ''mode'' can only be ''invivo'' or ''ultravist''')
end

Pnew.FIT.lower_limit_fit = lb;
Pnew.FIT.upper_limit_fit = ub;
Pnew.FIT.start_fit = p0;

[popt, Pnew] = FIT_3D(Z_corrExt, Pnew, Segment); % perform the fit pixelwise
[Zlab, Zref] = get_FIT_LABREF_modified(popt, Pnew, Segment, mode);  % create Reference values Z_Ref=(Z_lab - Li)