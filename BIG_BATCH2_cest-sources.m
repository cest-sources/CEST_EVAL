%% CEST EVAL
%   Date: 2016/02/10 
%   Version for CEST-sources.de
%   Authors: Moritz Zaiss  - m.zaiss@dkfz.de , Johannes Windschuh 
%   Divison of Medical Physics in Radiology
%   German Cancer Research Center (DKFZ), Heidelberg Germany, http://www.dkfz.de/en/index.html
%   CEST sources - Copyright (C) 2016  Moritz Zaiss
%   **********************************
%   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or(at your option) any later version.
%    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   **********************************
%
%   --SHORT  DOC--

%% add current folder and subfolders to path
addpath(genpath(cd('.')))

%%
clear all; close all; clc

%% LOAD CEST-DATA
[M0_stack, Mz_stack, P] = LOAD('USER');
% dimensions: M0_stack(x,y,z) or M0_stack(x,y,z,w) ;  Mz_stack(x,y,z,w) ;
% make sure they are double; offets (deltaomega in ppm) are stored in P.SEQ.w
%% DEFINE 2D Segment of ones and NaNs

% this creates the mask Segment, with values between [0 0.05] and within the defined free shaped ROI
Segment= make_Segment(M0_stack, 'free', mean(M0_stack(M0_stack>0)).*[0.3]); 

%% WASSR1 EVAL
[dB0_stack_ext yS] = MINFIND_SPLINE_3D(Mz_stack,Segment,P);
P.EVAL.w_fit = min(P.SEQ.w):0.01:max(P.SEQ.w);

%% calculate internal dB0 map
[dB0_stack_int yS] = MINFIND_SPLINE_3D(Mz_stack,Segment,P);

%% correct data for dB0 with external B0-map from WASSR or WASAB1
[Mz_CORR ] = B0_CORRECTION(Mz_stack,dB0_stack_ext,P,Segment);

%% correct data for dB0 with internal B0-map from the measurement
[Mz_CORR ] = B0_CORRECTION(Mz_stack,dB0_stack_int,P,Segment);

%% Normalize uncorrected data and B0 corrected data
[Z_uncorr] = NORM_ZSTACK(Mz_stack,M0_stack,P,Segment);

[Z_corrExt] = NORM_ZSTACK(Mz_CORR,M0_stack,P,Segment);


%% save
save matlab.mat ;

%% start imgui
close(imgui); imgui

%% Multi-Lorentzian fitting

P.FIT.options   = [1E-04, 1E-15, 1E-10, 1E-04, 1E-06];
P.FIT.nIter     = 50;
P.FIT.modelnum  = 5;     %% number of Lorentzian pools (possible 1-5)

P.FIT.extopt=1; % change parameters explicitly
%Lorentzian line LI defined by amplitude Ai, width Gi [ppm] and offset dwi[ppm]: Li=Ai.*Gi^2/4./ (Gi^2/4+(dw-dwi).^2) ;
%1=water; 2=amide; 3=NOE; 4=MT; 5=amine
%const.Zi   A1    G1    dw1     A2     G2    dw2     A3    G3   dw3     A4    G4   dw4    A3    G3   dw3
lb = [ 0.5  0.02  0.3  -1       0.0    0.4   +3     0.0    1    -4.5    0.0   10   -4     0.0   1    1   ];
ub = [ 1    1     10   +1       0.2    3     +4     0.4    5    -2        1   100  -1     0.2   3.5  2.5 ];
p0 = [ 1    0.9   1.4   0       0.025  0.5   3.5     0.02   3    -3.5    0.1   25   -1     0.01  1.5  2.2 ];
P.FIT.lower_limit_fit = lb; P.FIT.upper_limit_fit = ub; P.FIT.start_fit = p0;

Segment= make_Segment(M0_stack, 'free', mean(M0_stack(M0_stack>0)).*[0.3]); % choose smalle ROI for testing
close all

tic
[popt, P] = FIT_3D(Z_corrExt,P,Segment); % perform the fit pixelwise
toc

[Zlab, Zref] = get_FIT_LABREF(popt,P,Segment);  % create Reference values Z_Ref=(Z_lab - Li)

imgui

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

%% B1 correction
%you need to copy the files form https://github.com/cest-sources/B1_correction to your path

n=1;
%% B1 correction step1: create 5D Z_stack
% dimensions of Z_Stack : x,y,z,w,B1
Z_stack(:,:,:,:,n)=Z_corrExt; %% do this for all B1 measurements
n=n+1;

%% B1 correction step2: run correction -rqures relative B1_map
tic % etwa 100s
B1_input=[0.3 0.6 0.8]; % give the nominal B1 values set at the scanner
B1_output=[0.3 0.4 0.6 0.7 0.8]; % choose which values you want to reconstruct, e.g. B1_output=[ 1 2 ], or B1_output=B1_input
[Z_stack_corr] = Z_B1_correction(Z_stack,B1map,B1_input,B1_output,Segment,'linear');
% [Z_stack_corr] = Z_B1_correction(Z_stack,B1_map,B1_input,B1_output,Segment);
toc

Z_corrExt=Z_stack_corr(:,:,:,:,2); % pick second reconstructed value (e.g. 2 for B1_output(2)=0.4µT) 

imgui


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




