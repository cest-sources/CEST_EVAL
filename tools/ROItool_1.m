
% [ROI_def, AVG , STD]=ROItool_1(img,shape,clims)
% only for a single ROI
% shape of ROI can be {('free'),'rect','ellipse'}

%Author Moritz Zaiss E020 moritz.zaiss@web.de
%Date: 26.10.2014

function [ROI_def, AVG , STD]=ROItool_1(img,shape,clims)

if nargin<2 
    shape='free';
end;

if nargin<3
imagesc(img,[0 2*mean(img(img>0))])
else
imagesc(img,clims)
end;
axis image

colormap jet
% try
%     ROIs_old=evalin('base','ROI_def');
%     hold on;
%     for ii=1:size(ROIs_old,3)
%         contour(ROIs_old(:,:,ii),1,'m-');
%     end
% end


title('1. Choose region of interest - 2. click');

if strcmp(shape,'free')
e=imfreehand(gca);
elseif strcmp(shape,'rect')
    e=imrect(gca);
elseif strcmp(shape,'ellipse')
    e=imellipse(gca);
    elseif strcmp(shape,'poly')
    e=impoly(gca);
end;

h = uicontrol('Position',[20 20 200 40],'String','Continue',...
              'Callback','uiresume(gcbf)');
 uiwait(gcf); 
 
ROI_def=createMask(e); 

close gcf

AVG=mean(double(img(ROI_def)));
STD=std(double((img(ROI_def)))); 

