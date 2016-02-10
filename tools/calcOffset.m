function [x_Zspec_ppm, unsorted_x_M0]=calcOffset(P,sizes)

unsorted_x_M0=1; %%%%%%%%%%%%%check!
% define which values are M0

if (strcmp (P.SEQ.sampling,'List'))
   x_Zspec_ppm=P.SEQ.w;
    
elseif(strcmp(P.SEQ.sampling,'OneSide'))
    step=P.MeasInt/(sizes(4)-1);
    for ii=1:sizes(4)
        x_Zspec_ppm(ii,1)=P.SEQ.Offset-P.SEQ.MeasInt/2+(ii-1)*step;
    end
    
elseif(strcmp(P.SEQ.sampling,'OOI'))
    step = P.SEQ.MeasInt/((sizes(4)-1)/2-1);
    for ii=1:(sizes(4)-1)/2 
            x_Zspec_ppm(2*ii-1,1)= -P.SEQ.Offset-P.SEQ.MeasInt/2+(ii-1)*step;
            x_Zspec_ppm(2*ii,1)= -(-P.SEQ.Offset-P.SEQ.MeasInt/2+(ii-1)*step);
    end
    
    x_Zspec_ppm(sizes(4),1)=0;
    
else
    Offset=P.SEQ.Offset;
    APTfreq=(sizes(4)-1)/2;
    
    
    xAsym_ppm(:,1)=0:Offset/APTfreq:Offset;
    tempxZspec(:,1)=-Offset:Offset/APTfreq:Offset;
    
    
    if strcmp(P.SEQ.sampling,'regular')
        x_Zspec_ppm=tempxZspec;
    elseif strcmp(P.SEQ.sampling,'reverse')
        x_Zspec_ppm=flipud(tempxZspec);
    elseif strcmp(P.SEQ.sampling,'alternating')
        tempxZspec=abs(tempxZspec);
        tempxZspec=sort(tempxZspec);
        tempxZspec=flipud(tempxZspec);
        for ii=1:max(size(tempxZspec))
            tempxZspec(ii,1)=(-1)^(ii)*tempxZspec(ii,1);
        end
        x_Zspec_ppm=tempxZspec;
    end
end
if isrow(x_Zspec_ppm)
    x_Zspec_ppm=x_Zspec_ppm';
end;

    
    
