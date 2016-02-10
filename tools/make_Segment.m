function [Segment] = make_Segment(image, shape, range)
%function [Segment] = make_Segment(image, shape, range)
% image:        image to draw/define Segment on (2D or 3D)
% shape:        defines shape when string
%               defines range when vector e.g. [200 800]             
% range:        defines range when shape is given as string e.g. [0 200] 
% 
% when range has only 1 element: e.g. [200] then this value is lower cutoff
% meaning range=[200 99999999999]

mysize = size(image);

if numel(mysize)==2
    mysize(3)=1;
end
    
if nargin < 3
    range_flag = 0;
else
    range_flag = 1;
end



for ii=1:mysize(3)
    
    image_2D=squeeze(image(:,:,ii));
   
    % only drawn ROI
    if (ischar(shape) && range_flag == 0)
        figure('Name','Draw Segment','NumberTitle','off'); 
        ROI_def = ROItool_1(image_2D,shape);
        temp=double(ROI_def);
        temp(temp==0)=NaN;
        Segment(:,:,ii)=temp;
        
        figure
        subplot(1,2,1)
        imagesc(Segment(:,:,ii)); axis image
        subplot(1,2,2)
        imagesc(image_2D); axis image
        hold on
        temp(isnan(temp))=0;
        contour(temp,1,'m-','LineWidth',2);
    
    % only segmented by value
    elseif (~ischar(shape) && range_flag == 0)        
        range = shape;
        if numel(range)<2
            range(2)=999999999999;
        end
        temp = zeros(mysize(1),mysize(2));
        temp(image_2D > range(2)) = 0;
        temp(image_2D <= range(2)) = 1;
        temp(image_2D < range(1)) = 0;
%         temp = imfill(temp);
        Segment_draw = temp;
        temp(temp == 0) = NaN;
        Segment(:,:,ii)=temp;
        figure
        subplot(1,2,1)
        imagesc(Segment(:,:,ii)); axis image
        subplot(1,2,2)
        imagesc(image_2D); axis image
        hold on
        contour(Segment_draw,1,'m-','LineWidth',2);
    
    % both segmented by value and drawn
    elseif (ischar(shape) && range_flag == 1)
        if numel(range)<2
            range(2)=999999999999;
        end
        % drawn
        figure('Name','Draw Segment','NumberTitle','off'); 
        ROI_def = ROItool_1(image_2D,shape);
        temp_1=logical(ROI_def);
        % segmented
        temp_2 = zeros(mysize(1),mysize(2));
        temp_2(image_2D > range(2)) = 0;
        temp_2(image_2D <= range(2)) = 1;
        temp_2(image_2D < range(1)) = 0;
        %temp_2 = imfill(temp_2);
        temp_2 = logical(temp_2);
        % together
        temp = temp_1 + temp_2;
        temp = double(temp);
        Segment_draw = temp;
        temp(temp < 2) = NaN;
        temp(temp == 2) = 1;
        Segment_draw(Segment_draw < 2) = 0;
        Segment_draw(Segment_draw == 2) = 1;
        Segment(:,:,ii)=temp;
        figure
        subplot(1,2,1)
        imagesc(Segment(:,:,ii)); axis image
        subplot(1,2,2)
        imagesc(image_2D); axis image
        hold on
        contour(Segment_draw,1,'m-','LineWidth',2);

    end

end

