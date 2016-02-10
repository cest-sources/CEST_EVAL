
% function [S]=ROItool(img,numberROIS,shape, clims)
% shape of ROI can be {('free'),'rect','ellipse', ROIstruct}
% if its a ROIstruct S the old ROIdef is used instead of drawing new rois
% clims colorbar limits: e.g. [0 0.2]
% returns struct S with fields mean, std, ROI_def

%Author Moritz Zaiss E020 moritz.zaiss@web.de
%Date: 10.3.2011

function [S]=ROItool(img,noROIS,shape,clims)

if nargin<3 
    shape='free';
else
    if ~ischar(shape)
        noROIS=numel(shape);
%         x=shape{1}.x;
    end
end;
if nargin<2 
    noROIS=1;
end

if nargin<4
    clims=[0 2*mean(img(img>0))];
end;

for jj=1:noROIS
   
    %S{1}.IM=squeeze(img(:,:,1));
    if ischar(shape)
        figure('Name','Choose ROI','NumberTitle','off'),
        ROI_def=ROItool_1(img,shape,clims);     
     else
         ROI_def=shape{jj}.ROI_def;
     end;
    
    S{jj}.mean=mean(double(img(ROI_def)));
    S{jj}.std=std(double((img(ROI_def))));
    S{jj}.img=img;
    S{jj}.ROI_def=ROI_def;
    
end