%% for APTw Siemens 
%This file assumes that you have converted all dicoms before to 4D nii files.

[FileName,PathName] = uigetfile('*.nii', 'Get CEST nii');  % load the APTw data
CESTfile= [FileName];

[FileName,PathName] = uigetfile('*.nii', 'Get B0 nii'); % load the generated B0 map of the CEST sequence
B0file= [FileName];

% CESTfile = CEST_MOCO(CESTfile,CESTfile,1,[],'spm','bfc'); % MOCO       % not available here on cest_sources
% [ret] = Reslice(B0file,CESTfile, 1,pwd ); % Reslice of B0 map to CEST  % not available here on cest_sources

Stack  = niftiread(fullfile(PathName,CESTfile));
Stack = double(Stack);
M0_stack=Stack(:,:,:,1);  
Mz_stack=Stack(:,:,:,2:end);  % needs to be adjusted to P.SEQ.w
Segment = M0_stack>mean(M0_stack(:));
%% offsets from dcm
[offsets,FREQ]=offsets_from_dcm();
M0_offset=offsets(1);
P.SEQ.w=offsets(2:end);
%% offsets from ini
offsets=offsets_from_ini();
M0_offset=offsets(1);
P.SEQ.w=offsets(2:end)';
%% offsets defined manually
P.SEQ.w = [-4.5 -4 -3.50 -3 -2.5 -2 -1.5 -1 1 1.5 2 2.5 3 3.5 4 4.5]';

%% 4.2. B0 correction: splinesmoothing parameter
P.EVAL.B0_int_meth = 'linear';
P.EVAL.splinesmoothing=0.95;  % strong smoothing for 2µT, use 0.999 fro lower B1
[B0raw] = niftiread(fullfile(PathName,B0file));

B0raw  = B0raw(end:-1:1,:,:); % for some reason, the first dim is flipped in the B0 image of Siemens

dB0_stack_ext= double(B0raw-2048)/(123.2561); %TODO: exact value available by dcm [offsets,FREQ]=offsets_from_dcm();
[~, Mz_CORR] = MINFIND_SPLINE_AND_CORRECT_3D_withExt(Mz_stack,Segment,P,dB0_stack_ext,1); % Find minimum of Z-spectrum for estimation
     
% normalization
[Z_corrExt] = NORM_ZSTACK(Mz_CORR,M0_stack,P,Segment); %Normalization of Z-spectrum; 2 point normalization

Zref = Z_corrExt(:,:,:,end:-1:1);
MTRasym = Zref-Z_corrExt;

save(['Z_816c_' CESTfile(1:7)],...
                         'M0_stack','Mz_stack', 'Mz_CORR','dB0_stack_ext', 'P', 'Z_corrExt','MTRasym', 'Segment','-v7.3');
                 
%% plot MTRasym
indx=find_nearest(P.SEQ.w,3.5);
% MTRasym=permute(MTRasym(:,end:-1:1,:,:),[3 2 1 4]);
MTRasym35=squeeze(MTRasym(:,:,:,indx));
P.SEQ.w(indx)
load('013_Rainbow.mat');
figure,
subplot(1,2,1),montage1t(MTRasym35,[-0.05 0.05]);
colormap(gca,RAINBOW)
subplot(1,2,2), montage1t(MTRasym35,[-0.03 0.05]);
colormap(gca,RAINBOW)

figure, plot(P.SEQ.w, squeeze(Z_corrExt(end/2,end/2,end/2,:)),'x'); title('Z-spectrum of the central voxel');
