%%
addpath(genpath(cd('.')))
%%
clear all; close all; clc

%% LOAD Siemens CEST-DATA
[M0_stack, Mz_stack, P] = LOAD('USER'); % thats quite automized, good luck


%% LOAD philips CEST-DATA (rec par)

clear Z Mz_stack M0_stack Mz_CORR
[imagesOut, ParsOut] = read_rec_file('filename.REC'); % cd to recpar folder and adjust filename
size(imagesOut)
for ii=1:size(imagesOut,3)
S(:,:,1,ii)=squeeze(imagesOut(1,1,ii,1,1,:,:)); % adjust dimensions if needed, here its x,y,z,w
end;

M0_stack=S(:,:,1,1);        % first image is unsaturated M0 image, adjust if necessary
Mz_stack=S(:,:,1,2:end-1);  % all the others are the saturated images
P.SEQ.w=linspace(-5,5,18)'; % give offsets manually

% some parameters the routines need later
P.EVAL.w_fit=(-10:0.01:10)';
P.EVAL.w_interp=P.SEQ.w;
P.SEQ.stack_dim=size(Mz_stack);
P.EVAL.lowerlim_slices=1;
P.EVAL.upperlim_slices=size(M0_stack,3);
clearvars -except  P Mz_stack M0_stack image_z x X ROI_def Segment dB0_stack_ext dB0_stack_int
 






