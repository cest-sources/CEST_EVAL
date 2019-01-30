% 2-stage Fitting code for low-power 3T protein CEST data
%
% As published in:
% "3D gradient echo snapshot CEST MRI with low power saturation for human
% studies at 3T"
% Anagha Deshmane, Moritz Zaiss, Tobias Lindig, Kai Herz, Mark Schuppert,
% Chirayu Gandhi, Benjamin Bender, Ulrike Ernemann, Klaus Scheffler
% Magnetic Resonance in Medicine 2018, https://doi.org/10.1002/mrm.27569
%
% INPUTS (check BIG_BATCH2_cest-sources.m):
%       P           parameter struct
%       Mz_stack    cest images (Nread x Nphase x Nslice x Noffsets)
%       M0_stack    reference images  (Nread x Nphase x Nslice)
%       Z_uncorr    non-B0 corrected Z spectrum  (Nread x Nphase x Nslice x Noffsets)
%       Segment     mask  (Nread x Nphase x Nslice)
%       
% OUTPUTS:
%
% Requires the following MATLAB toolboxes: 
% Symbolic Math Toolbox
% Image Processing Toolbox
% Statistics and Machine Learning Toolbox
% Curve Fitting Toolbox
% Parallel Computing Toolbox
% 
% Contact: 
% Anagha Deshmane, anagha.deshmane@tuebingen.mpg.de 
% Max Planck Institute for Biological Cybernietcs
% Tuebingen, Germany
%
%%
if ~exist('NOE_fitting','dir')
    mkdir NOE_fitting
end
cd NOE_fitting
%% multiselect

[FileName,pathname] = uigetfile('*.*','Select NOE Z UNCORR stack(s)','MultiSelect','on');
if iscell(FileName)==0
    temp=FileName; clear FileName;
    FileName{1}=temp; clear temp;
end

for III=1:numel(FileName)
%% Load Data & Setup
hwait = waitbar((III-0.5)/numel(FileName),'hold on - this will take long per stack');

% single file eval
clearvars -except III FileName pathname; close all; 

filename=FileName{III};

load([pathname filename]);
filename

P.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-04, 1E-06];
P.FIT.nIter     = 100;
P.FIT.extopt=1; % change parameters explicitly

% exclude outtermost slices
Segment(:,:,[1:3 end-2 end-1 end])=0;

%% 2pool fit (DS + MT)
sprintf('First 2pool Background fit...')

P.FIT.modelnum = 012021; 
BW0 = (1/P.SEQ.tp)/P.SEQ.FREQ;
%       Zi      A0      G0      dw0     AMT     GMT     dwMT	BW
lb = [ 0.5      0.02    0.3     -1      0.0     30      -2.5     BW0]; 
ub = [ 1        1       10      +1      0.5     60       0      BW0 ];
p0 = [ 0.95     0.67    1.8     0       0.15    40      -1      BW0 ]; 

P.FIT.lower_limit_fit = lb; P.FIT.upper_limit_fit = ub; P.FIT.start_fit = p0;
P.FIT.exclude=[find_nearest(P.SEQ.w,-8):find_nearest(P.SEQ.w,-1.5)...
        find_nearest(P.SEQ.w,1.5):find_nearest(P.SEQ.w,5.5)...
        find_nearest(P.SEQ.w,6):2:find_nearest(P.SEQ.w,10) ];

[popt0, P] = FIT_3D(Z_uncorr,P,Segment); % perform the fit pixelwise
save(['Fit_' P.EVAL.filename(1:9) P.FIT.fitfunc '.mat'],'popt0','P');

%% B0 correction from 2 pool fit
sprintf('B0 correction...')

% extract B0 map
dB0_stack_ext = squeeze(popt0(:,:,:,4));

% B0 correction
[Mz_CORR] = B0_CORRECTION(Mz_stack,dB0_stack_ext,P,Segment);
[Z_corrExt] = NORM_ZSTACK(Mz_CORR,M0_stack,P,Segment);

save([P.EVAL.filename(1:9) '_Z_B0corr.mat'],'Z_corrExt','dB0_stack_ext','P','Segment');

%% 2pool fit (DS + MT)
sprintf('Second 2pool Background fit...')
    
P.FIT.modelnum = 012021; 
BW0 = (1/P.SEQ.tp)/P.SEQ.FREQ;
%       Zi      A0      G0      dw0     AMT     GMT     dwMT	BW
lb = [ 0.5      0.02    0.3     -1      0.0     30      -2.5     BW0]; 
ub = [ 1        1       10      +1      0.5     60       0      BW0 ];
p0 = [ 0.95     0.67    1.8     0       0.15    40      -1      BW0 ]; 

P.FIT.lower_limit_fit = lb; P.FIT.upper_limit_fit = ub; P.FIT.start_fit = p0;

P.FIT.exclude=[find_nearest(P.SEQ.w,-8):find_nearest(P.SEQ.w,-1.5)...
        find_nearest(P.SEQ.w,1.5):find_nearest(P.SEQ.w,6)...
        find_nearest(P.SEQ.w,6):2:find_nearest(P.SEQ.w,10) ];

[popt1, P] = FIT_3D(Z_corrExt,P,Segment); % perform the fit pixelwise

[ZlabBG, ZrefBG] = get_FIT_LABREF(popt1,P,Segment,P.SEQ.w);  % create Reference values Z_Ref=(Z_lab - Li)
MTR_LD = ZlabBG - Z_corrExt;

save(['FitB0corr_' P.EVAL.filename(1:9) P.FIT.fitfunc '.mat'],'popt1','P','Z_corrExt','ZlabBG','ZrefBG','MTR_LD');

h0=figure;
subplot(1,3,1); montage1t(popt1(:,:,:,2)); colorbar; caxis([0.7 0.9]); title('A_{DS}')
subplot(1,3,2); montage1t(popt1(:,:,:,5)); colorbar; caxis([0 0.2]); title('A_{MT}')
subplot(1,3,3); montage1t(popt1(:,:,:,8)); colorbar; caxis([0.5*BW0 1.5*BW0]); title('BW')
saveas(h0,['FitB0corr_' P.EVAL.filename(1:9) P.FIT.fitfunc '.fig']);

%% 3pool fit on MTRLD
sprintf('3pool Lorentzian on MTRLD...')

P3 = P;

P3.FIT.modelnum = 013041; 
%                   L0 is amide,          L1 is amine (2ppm)        L2 is NOE.
%          c       A0    G0[ppm]  dw0     A1      G1[ppm]    dw1     A2      G2      dw2       
lb = [ 0        0     0.4     3.2      0.0       0.4     1.8     0.0     1        -4    ];
ub = [ 0.2      0.2   6       3.8	   0.1       6       2.2     0.2     6        -3    ];
p0 = [ 0        0.05   4.5    3.5      0.05      1       2.0     0.1     4.5      -3.5  ];

P3.FIT.lower_limit_fit = lb; P3.FIT.upper_limit_fit = ub; P3.FIT.start_fit = p0;
P3.FIT.exclude = setdiff([1:length(P.SEQ.w)],P.FIT.exclude) ;

[popt3, P3] = FIT_3D(MTR_LD,P3,Segment); % perform the fit pixelwise
[ZlabCEST, ZrefCEST] = get_FIT_LABREF(popt3,P3,Segment,P.SEQ.w);  % create Reference values Z_Ref=(Z_lab - Li)

save(['FitLD_B0corr_' P.EVAL.filename(1:9) P3.FIT.fitfunc '.mat'],'popt3','P3','MTR_LD','Segment','ZlabCEST','ZrefCEST');

h1=figure;
subplot(1,3,1); montage1t(popt3(:,:,:,2)); colorbar; caxis([0 0.04]); title('A_{+3.5 ppm}')
subplot(1,3,2); montage1t(popt3(:,:,:,5)); colorbar; caxis([0 0.03]); title('A_{+2.0 ppm}')
subplot(1,3,3); montage1t(popt3(:,:,:,8)); colorbar; caxis([0 0.08]); title('A_{-3.5 ppm}')
saveas(h1,['FitLD_B0corr_' P.EVAL.filename(1:9) P3.FIT.fitfunc '.fig']);


end % end of multifileselect