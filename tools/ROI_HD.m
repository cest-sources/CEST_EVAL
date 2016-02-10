function [ROI_def]= ROI_HD (APT_Stack,noROIs,mysize,clims,shape)
% gives ROIdef as an array and not as a struct
warning('works. but try to use ROItool. MZ');
if nargin<4
    clims=[0 0.1];
end;

if nargin<5
    shape='free';
end;

ROI_def=zeros(mysize(1),mysize(2),noROIs);

[S]=ROItool(APT_Stack,noROIs,shape,clims);

for ii=1:noROIs
ROI_def(:,:,ii)=S{ii}.ROI_def;
end


