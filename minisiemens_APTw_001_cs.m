%%% for APTw Siemens 
%This file assumes that you have converted all dicoms before to 4D nii files.

[FileName,PathName] = uigetfile('*.nii', 'Get CEST');  % load the APTw data
CESTfile= [FileName];

[FileName,PathName] = uigetfile('*.nii', 'Get B0 nii'); % load the generated B0 map of teh CEST sequence
B0file= [FileName];

% CESTfile = CEST_MOCO(CESTfile,CESTfile,1,[],'spm','bfc'); % MOCO    % not available here on cest_sources
% [ret] = Reslice(B0file,CESTfile, 1,pwd ); % Reslice of B0 map to CEST % not available here on cest_sources
%%
Stack  = niftiread(fullfile(PathName,CESTfile));
M0_stack=Stack(:,:,:,2); 
Mz_stack=Stack(:,:,:,[3:13 15:25]);   % needs to be adjustes do P.SEQ.w

Segment = M0_stack>mean(M0_stack(:));

%4.2. B0 correction: splinesmoothing parameter

%% offsets from dcm
offsets=offsets_from_dcm();
M0_offset=offsets(1);
P.SEQ.w=offsets(2:end);
%% offsets from ini
offsets=offsets_from_ini();
M0_offset=offsets(1);
P.SEQ.w=offsets(2:end);
%% offsets defined manually
P.SEQ.w = [-4 -3.75 -3.75 -3.75 -3.50 -3.50 -3.50 -3.25 -3.25 -3.25 -2.99 2.99 3.25 3.25 3.25 3.50 3.50 3.50 3.75 3.75 3.75 4]';


P.EVAL.B0_int_meth = 'linear';
P.EVAL.splinesmoothing=0.95;
[B0raw] = niftiread(fullfile(PathName,B0file));
dB0_stack_ext= double(B0raw-2048)/(gamma_*2.89362001419); %TODO: get that from sProtConsistencyInfo.flNominalB0
[~, Mz_CORR] = MINFIND_SPLINE_AND_CORRECT_3D_withExt(Mz_stack,Segment,P,dB0_stack_ext,1); % Find minimum of Z-spectrum for estimation
     
% normalization
[Z_corrExt] = NORM_ZSTACK(Mz_CORR,M0_stack,P,Segment); %Normalization of Z-spectrum; 2 point normalization

Zref = Z_corrExt(:,:,:,end:-1:1);
MTRasym = Zref-Z_corrExt;

save(['Z_816c_' CESTfile(1:7)],...
                         'M0_stack','Mz_stack', 'Mz_CORR','dB0_stack_ext', 'P', 'Z_corrExt','MTRasym', 'Segment','-v7.3');
                 
%%
% MTRasym=permute(MTRasym(:,end:-1:1,:,:),[3 2 1 4]);
MTRasym35=squeeze(MTRasym(:,:,:,17));
P.SEQ.w(17)
load('013_Rainbow.mat');
figure,
subplot(1,2,1),montage1t(MTRasym35,[-0.05 0.05]);
colormap(gca,RAINBOW)
subplot(1,2,2), montage1t(MTRasym35,[-0.03 0.05]);
colormap(gca,RAINBOW)
