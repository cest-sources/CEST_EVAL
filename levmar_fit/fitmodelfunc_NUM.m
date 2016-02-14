function [P] = fitmodelfunc_NUM(M,P)
% function [P] = fitmodelfunc_NUM(M,P)
% fitmodelnumber:
% digits 1,2:   use of function ( 01 Zspectrum, 02 WASABI, 03 T1, 04 T1rho , 05 T2 ,....)
% digit    3:   number of pools/function
% digit  4,5:   number of model
% digits   6:   choice of startparameters/boundaries
% example:
% 015011
% Zspectrum fit, 5 pools, model 01, choice 1
% 01101x: 'lorentzfit1pool'
% 01102x: 'lorentzfit1pool_BW'
% 01201x: 'lorentzfit2pool'
% 01202x: 'lorentzfit2pool_BW'
% 01203x: 'lorentzfit_REX2pool'
% 01301x: 'lorentzfit3pool'
% 01302x: 'lorentzfit3pool_BW'
% 01303x: 'lorentzdoublefit3pool'
% 01401x: 'lorentzfit4pool'
% 01402x: 'lorentzfit4pool_BW'
% 01501x: 'lorentzfit5pool'
% 01502x: 'lorentzfit5pool_BW'
% 01601x: 'lorentzfit6pool'
% 01602x: 'lorentzfit6pool_BW'
% 02101x: 'WASABIFIT'
% 02102x: 'WASABIFIT_2'
% 03101x: 'T1_recovery'
% 04101x: 'T1RHOFIT';
% 04102x: 'T1RHOFITsimple';
% 05101x: 'T2_multiecho'


w_axe = P.SEQ.w;

bl = w_axe(1); 
br = w_axe(length(w_axe));

[min_y,min_x]=min(M);
[max_y,max_x]=max(M);

scandist=(w_axe(numel(w_axe))-w_axe(1))/(numel(w_axe)-1);

% old stuff from Moritz for Doepfert...
%schmaler pool
if min_x==1 
    min_x = 2; 
end;
stepp=min_x-5;
if stepp <=0
    stepp=stepp+10; % make sure that not a negative index
end;
%dMs=( w_axe(min_x)-w_axe(stepp) )  / (M(stepp)-M(min_x));


if P.FIT.modelnum == 011011 %2  % corrected 5.9.2013
%% 1pool

%       Zi       A0    G0[ppm]  dw0   
lb = [ max_y   0.00     15     -4.0    ];
ub = [ max_y   0.04     50      0.0    ];
p0 = [ max_y   0.02     25     -2.0    ];
fitfunc = 'lorentzfit1pool';

elseif P.FIT.modelnum == 011021 %2  % corrected 5.9.2013
%% 1pool

%       Zi       A0    G0[ppm]  dw0   BW
lb = [ max_y   0.00     15     -4.0    0.1 ];
ub = [ max_y   0.04     50      0.0    1.0 ];
p0 = [ max_y   0.02     25     -2.0    0.5 ];
fitfunc = 'lorentzfit1pool_BW';

elseif P.FIT.modelnum == 011031 %2  % corrected 5.9.2013
%% 1pool

%       Zi       A0    G0[ppm]  dw0  
lb = [ max_y   0.00     15     -4.0   ];
ub = [ max_y   0.04     50      0.0   ];
p0 = [ max_y   0.02     25     -2.0   ];
fitfunc = 'gaussfit1pool';

elseif P.FIT.modelnum == 012011 || P.FIT.modelnum == 2 %2  % corrected 5.9.2013
%% 2pool

   %   Zi        A0     G0[ppm]      dw0           A1           G1[ppm]     dw1                                                             
lb = [ 0        0.1     0.5         -0.001         0           15          -4];
ub = [ 1        1       6           +0.001         0.4         100          0];
%startwert der parameter 2 pool
p0 = [ 0.7      0.8      2            0            0.1         50          -2];
fitfunc = 'lorentzfit2pool';

elseif P.FIT.modelnum == 012021 
%% 2pool

   %   Zi        A0     G0[ppm]      dw0           A1           G1[ppm]     dw1    BW                                                         
lb = [ 0        0.1     0.5         -0.001         0           15          -4      0.01 ];
ub = [ 1        1       6           +0.001         0.4         100          0      1.00 ];
%startwert der parameter 2 pool
p0 = [ 0.7      0.8      2            0            0.1         50          -2      0.50 ];
fitfunc = 'lorentzfit2pool_BW';


elseif P.FIT.modelnum == 012031 %99  % changed 7.7.2013 to Doepfert solution
%% 2pool dopefert

   %    c           A0                  G0[ppm]          dw0            A1          G1[ppm] 1µT=0.3ppm@3T       dw1
lb = [ 0            0.02                scandist        bl              0.00        scandist                    1  ];
ub = [ 1.5          max_y               15              br              max_y       1                           br  ];
%startwert der parameter 2 pool
p0 = [ max_y+0.1    (max_y-min_y)/2     dMs             w_axe(min_x)    0.02        0.4                         w_axe(min_x)+2.2  ];
fitfunc = 'lorentzfit_REX2pool';

elseif P.FIT.modelnum == 013011 || P.FIT.modelnum == 3%3   %  % corrected 5.9.2013
%% 3pool

   %   Zi       A0      G0[ppm]  dw0     A1      G1[ppm]   dw1      A2      G2      dw2
lb = [ 0.5      0     0.1       -0.01    0.0       2      -0.01     0.0     15       -4 ];
ub = [ 1        1     2.0       +0.01	 1.0       8       0.01     0.4    100       -0 ];
%startwert der parameter 5 pool
p0 = [ 1        0.8   1.0        0.00    0.4       3       0.00     0.1     50       -2 ];
fitfunc = 'lorentzfit3pool';

elseif P.FIT.modelnum == 013021 
%% 3pool mit splitted_water_lorentz

   %   Zi       A0      G0[ppm]  dw0     A1      G1[ppm]   dw1      A2      G2      dw2    BW   
lb = [ 0.5      0     0.1       -0.01    0.0       2      -0.01     0.0     15       -4    0.1 ];
ub = [ 1        1     2.0       +0.01	 1.0       8       0.01     0.4    100       -0    1.0 ];
%startwert der parameter 5 pool
p0 = [ 1        0.8   1.0        0.00    0.4       3       0.00     0.1     50       -2    0.5 ];
fitfunc = 'lorentzfit3pool_BW';

elseif P.FIT.modelnum == 013031 %33   %  % corrected 5.9.2013
%% 3pool 

   %   Zi       A0      G0[ppm]     A1      G1     A2      G2      dw2
lb = [ 0.5      0.1     0.5         0        2     0.001	20       -4 ];
ub = [ 1        1       2           0.8      8      0.4     100       0 ];
%startwert der parameter 5 pool
p0 = [ 1        0.8     1           0.5      3      0.1     50       -2 ];
fitfunc = 'lorentzdoublefit3pool';

elseif P.FIT.modelnum == 014011 || P.FIT.modelnum == 4%4   %  % installed 4.9.2013 corrected 9.9.2013
%% 4pool

%       1    2           3      4       5           6       7 
%      Zi    A0          G0     dw0     A1          G1     dw1     A2     G2      dw2       A3       G3     dw3                                                                    
lb = [ 0.5   0.02       0.3      -1    0.0         0.4     3.0     0.0    2      -5.0       0.00     1      1.0  ];
ub = [ 1.0   1.00      10.0      +1    0.3         6.0     5.0     0.2    7      -2.0       0.20     4      2.5  ];
%startwert der parameter 5 pool
p0 = [ 1.0   0.90       0.8       0    0.1         2.0     3.5     0.1    4      -3.5       0.01     2      2.2  ]; 
fitfunc = 'lorentzfit4pool';

elseif P.FIT.modelnum == 014021 
%% 4pool mit splitted_water_lorentz

%       1    2           3      4       5           6       7 
%      Zi    A0          G0     dw0     A1          G1     dw1     A2     G2      dw2       A3       G3     dw3     BW                                                                   
lb = [ 0.5   0.02       0.3      -1    0.0         0.4     3.0     0.0    2      -5.0       0.00     1      1.0    0.1 ];
ub = [ 1.0   1.00      10.0      +1    0.3         6.0     5.0     0.2    7      -2.0       0.20     4      2.5    1.0 ];
%startwert der parameter 5 pool
p0 = [ 1.0   0.90       0.8       0    0.1         2.0     3.5     0.1    4      -3.5       0.01     2      2.2    0.5 ];
fitfunc = 'lorentzfit4pool_BW';

elseif P.FIT.modelnum == 015011 || P.FIT.modelnum == 5%5   %  % installed 6.9.2013 corrected 24.9.2013
%% 5pool

%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT          A3       G3      dw3                                                                     
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +3      0.0    1     -4.5    0.0    10      -4             0.0       0.4     1];
ub = [ 1    1          10           +1          0.2         4       +4      0.4    5     -2        1    100     4              0.2       2.5     2.5];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5     3.5     0.02     7    -3.5    0.1     25      -2            0.01      1      2.2];
fitfunc = 'lorentzfit5pool';

elseif P.FIT.modelnum == 015012 %12345   %  % installed 4.9.2013 corrected 9.9.2013
%% 5pool

%      Zi       A0       G0      dw0      A1    G1      dw1     A2      G2      dw2      AMT      GMT     dwMT     a4         G4     dw4 
lb = [ 0.7      0.1     0.5     -0.4    0.001	2       1.5     0          1     -3      0        10      -4        0          1     -4];
ub = [ 1        1       6       +0.4	0.2     5        3      0.3        3     -1      0.4      60       0        0.3        6     -2];
%startwert der parameter 5 pool
p0 = [ 0.9      0.9     2       0       0.1     3        2      0.025      3     -1.5    0.1      25      -2        0.025        3    -3];
fitfunc = 'lorentzfit5pool';

elseif P.FIT.modelnum == 015013 %5011   %  % installed 6.9.2013 corrected 24.9.2013
%% 5pool

%       1   2           3            4          5           6       7  
%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT          A3       G3      dw3                                                                     
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +3      0.0    1     -4.5    0.0    10      -4             0.0       1       1   ];
ub = [ 1    1          10           +1          0.2         3       +4      0.4    5     -2        1    100     -2              0.2      3.5     2.5 ];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5     3.5     0.02     3    -3.5    0.1     25      -2            0.01      1.5     2.2 ];
fitfunc = 'lorentzfit5pool';

elseif P.FIT.modelnum == 015021  
%% 5pool mit splitted_water_lorentz

%       1   2           3            4          5           6       7  
%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT          A3       G3      dw3   BW                                                                    
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +3      0.0    1     -4.5    0.0    10      -4             0.0       1       1     0.1 ];
ub = [ 1    1          10           +1          0.2         3       +4      0.4    5     -2        1    100     -2              0.2      3.5     2.5   1.0 ];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5     3.5     0.02     3    -3.5    0.1     25      -2            0.01      1.5     2.2   0.5 ];
fitfunc = 'lorentzfit5pool_BW';

elseif P.FIT.modelnum == 016011 || P.FIT.modelnum == 6%6
%% 6pool
                                         
%      1    2           3           4           5           6       7      8       9       10    11      12       13            14       15      1
%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT          A3       G3      dw3                          
lb = [0.5   0.02       0.3          -1          0.0         0.4     +3      0.0    1     -4.5    0.0    10      -4             0.0       0.4     1        0      2    1.5      ];
ub = [1     1          10           +1          0.2         1.5     +4      0.4    5     -2        1    100     -2             0.2       1.5     2.5     0.2     5      5    ];
%startwert der parameter 5 pool
p0 = [1    0.95        0.5          0           0.025       1     3.5      0.02   7     -3.5    0.1    25      -2             0.01       1      2.0       0.01    3      3.5    ];
fitfunc = 'lorentzfit6pool';


elseif P.FIT.modelnum == 016012 %6   % CELLCEST % installed 28.10
%% 6pool 
%breiten aromatic NOE (+2ppm) like pool ( nehme dazu (pool A3))
% schmalen amine pool (nehme dazu A1)

%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT          A3       G3      dw3               NOE2                                                      
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +1.5      0.0    1     -3.7    0.0    20      -4             0.0       2     1.8              0.0       1       -2. ];
ub = [ 1    1          10           +1          0.2         0.8     +2.5      0.4    3     -3.2    1      70        -2           0.2       4     2.3              0.2       2       -1.5 ];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5       2     0.02      2      -3.5    0.1   25       -2            0.01      1      2             0.01      1.5      -1.6];
fitfunc = 'lorentzfit6pool';

elseif P.FIT.modelnum == 016021 %16
%% 6pool mit splitted_water_lorentz

%      1    2           3           4           5           6       7      8       9       10    11      12       13         14       15      1
%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2   AMT     GMT      dwMT       A3       G3      dw3                                  BW                                                    
lb = [ 0.5  0.02       0.3          -1          0.0       0.4      +3       0.0    1     -4.5    0.0    10      -4            0.0    0.4     1      0.001     0.5      2.5    0.01  ];
ub = [ 1    1          10           +1          0.2         4       +4      0.4    5     -2        1    100     -2            0.2    2.5     2.5     0.2       3.5      2.9   0.5    ];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5      3.5    0.02     7    -3.5    0.3     25     -2            0.01     1     2.2       0.01        1      2.7   0.3       ];
fitfunc = 'lorentzfit6pool_BW';

elseif P.FIT.modelnum == 016022 %61   % CELLCEST % installed 28.10
%% 6pool mit splitted_water_lorentz
%breiten aromatic NOE (+2ppm) like pool ( nehme dazu (pool A3))
% schmalen amine pool (nehme dazu A1)

%      Zi   A0          G0          dw0         A1          G1     dw1     A2      G2      dw2      AMT     GMT      dwMT          A3       G3      dw3               NOE2                                                      
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +2.3    0.0    1     -3.7       0.0     20        -4           0.0       2     1.8              0.0       0.4     -2.0     0.1   ];
ub = [ 1    1          10           +1          0.2         0.8     +3      0.4    3     -3.2       0.2     70        -2           0.2       4     2.3              0.2       2       -1.5     0.7    ];
%startwert der parameter 5 pool
p0 = [ 1    0.9        1.4          0           0.025      0.5      2.7     0.02    2    -3.5      0.1     25        -2           0.01      1      2              0.01      1         -1.8     0.3  ];
fitfunc = 'lorentzfit6pool_BW';

elseif P.FIT.modelnum == 021011 %11
%% simple WASABIFIT

%      B1   dB0   c
lb = [ 2    -1    0.01 ];
ub = [ 7    1     6  ];
%startwert der parameter  B1 B0 c
p0 = [ 4    min_y   max_y  ];
% ACHTUNG!!: B1 wird in levmar_fit overwritten with the B1guess
fitfunc = 'WASABIFIT';

elseif P.FIT.modelnum == 021021 %111
%% WASABIFIT with af

%      B1   dB0   c   af
lb = [ 0    -2    0   0 ];
ub = [ 20    2    1   2 ];
%startwert der parameter  B1 B0 c af
p0 = [ 3.7     0    0.5   1.2 ];
% ACHTUNG!!: B1 wird in levmar_fit overwritten with the B1guess
fitfunc = 'WASABIFIT_2';

elseif P.FIT.modelnum == 031011 %1000
%% T1 recovery fit fittype('abs((a-c)*exp(-1/T1*x)+c)'

%     T1          a      c
lb = [0         -5000   0       ];
ub = [10000      5000   5000    ];
p0 = [1000      -2000   1000    ];
fitfunc = 'T1recovery';



elseif P.FIT.modelnum==041011 %12 
%% T1RHOFIT 

lb = [ 0        0.0001      0];
ub = [ 1        1           1];
p0 = [ 0.90     0.008       0];
fitfunc = 'T1RHOFIT';



elseif P.FIT.modelnum==041021 %13 
%% T1RHOFITsimple 

lb = [ 0        0.0001  ];
ub = [ 1        1       ];
p0 = [ 0.90     0.008   ];
fitfunc = 'T1RHOFITsimple';

elseif P.FIT.modelnum==051011
lb = [ 0        0       0       ];
ub = [ 5000     5000    1000    ];
p0 = [ 1000     1000    0       ];
fitfunc = 'T2_multiecho';    

end; %if

P.FIT.fitfunc = fitfunc;
P.FIT.nparams = numel(p0);


if ~isfield(P.FIT,'extopt') % shall external fitoipions be used or the ones defined above?
   P.FIT.extopt=0;
end;

if P.FIT.extopt==0 % the ones defined above
    
P.FIT.lower_limit_fit = lb;
P.FIT.upper_limit_fit = ub;
P.FIT.start_fit = p0;
else                  % do nothing: external fitotpions are used 
    try
    P.FIT.lower_limit_fit; % test if they are set
    catch
         warning('Please provide external options P.FIT.lower_limit_fit, P.FIT.upper_limit_fit, P.FIT.start_fit, Or remove option P.FIT.extopt=1');
    end;
     
end;