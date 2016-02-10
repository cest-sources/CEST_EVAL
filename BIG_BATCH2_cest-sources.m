%% add current folder and subfolders to path
addpath(genpath(cd('.')))

%%
clear all; close all; clc

%% LOAD CEST-DATA
[M0_stack, Mz_stack, P] = LOAD('USER');

%% DEFINE 2D Segment of ones and NaNs

% this creates the mask Segment, with values between [0 0.05] and within the defined free shaped ROI
Segment= make_Segment(M0_stack, 'free', mean(M0_stack(M0_stack>0)).*[0.5]); 

%% WASSR1 EVAL
[dB0_stack_ext yS] = MINFIND_SPLINE_3D(Mz_stack,Segment,P);
P.EVAL.w_fit = min(P.SEQ.w):0.01:max(P.SEQ.w);

%% calculate internal dB0 map
[dB0_stack_int yS] = MINFIND_SPLINE_3D(Mz_stack,Segment,P);

%% correct data for dB0 with external B0-map from WASSR or WASAB1
[Mz_CORR ] = B0_CORRECTION(Mz_stack,dB0_stack_ext,P,Segment);

%% correct data for dB0 with internal B0-map from the measurement
[Mz_CORR ] = B0_CORRECTION(Mz_stack,dB0_stack_int,P,Segment);

%% Normalize uncorrected data
[Z_corrExt] = NORM_ZSTACK(Mz_stack,M0_stack,P,Segment);

%% Normalize B0 corrected data
[Z_corrExt] = NORM_ZSTACK(Mz_CORR,M0_stack,P,Segment);


%% save
save matlab_fitted.mat ;

%% start imgui
imgui

%% Fitting
tic
P.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-04, 1E-06];
P.FIT.nIter     = 50;
P.FIT.modelnum  = 015013;               %% possible: 2 = 2pool, 3 = 3pool, 99 = 4pool, 5 = 5pool, 4 = doepfert, 11 = WASSR

P.FIT.extopt=1; % change parameters explicitly
lb = [ 0.5  0.02       0.3          -1          0.0         0.4     +3      0.0    1     -4.5    0.0    10      -4             0.0       1       1   ];
ub = [ 1    1          10           +1          0.2         3       +4      0.4    5     -2        1    100     -1              0.2      3.5     2.5 ];
p0 = [ 1    0.9        1.4          0           0.025      0.5     3.5     0.02     3    -3.5    0.1     25      -1            0.01      1.5     2.2 ];
P.FIT.lower_limit_fit = lb;
P.FIT.upper_limit_fit = ub;
P.FIT.start_fit = p0;

[popt, P] = FIT_3D(Z_corrExt,P,Segment);
toc


[Zlab, Zref] = get_FIT_LABREF(popt,P,Segment);



%% WASSR2/WASAB1 EVAL
[M0_stack, Mz_stack, P] = LOAD('USER');

%%
Segment= make_Segment(M0_stack, 'free', mean(M0_stack(M0_stack>0)).*[0.20]); 
[Z_uncorr] = NORM_ZSTACK(Mz_stack,M0_stack,P,Segment);

tic
P.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-4, 1E-06];
P.FIT.nIter     = 100;
P.FIT.modelnum  = 021021; % 021011 = WASAB1

[popt P] = FIT_3D(Z_uncorr,P,Segment);
toc

B1map=popt(:,:,1)/P.SEQ.B1;
 dB0_stack_ext=popt(:,:,2);

 figure, subplot(1,2,1), imagesc(dB0_stack_ext(:,:,1),[-0.9 0.9]); title('\DeltaB0 map in ppm');
         subplot(1,2,2), imagesc(B1map,[0.6 1.4]); title('relative B1 map');
%%
save B0_B1.mat ;

%% T1 mapping
TI=[100 200 400 600 800 1000 1300 1600 2000 2500 3000 3500 4000 4500 5000 10000 15000];

% TI=[20:20:100  200 400 600 800 1000 1200 1400 1600 1800 2000 2500 3000 3500 4000 4500 5000 10000 ];

% information about fit
P_T1.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-04, 1E-06];
P_T1.FIT.nIter     = 100;
P_T1.FIT.modelnum  = 031011;
P_T1.SEQ.w = TI;
% number of ROIS, mapflag (should complete T1map be calculated), P_T1 struct, Segment

[T1info T1map popt_T1] = T1eval_levmar(1,2,P_T1);




