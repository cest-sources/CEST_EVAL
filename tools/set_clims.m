function [clims]=set_clims(img)

imgsize=size(img);
k=0;
values(1)=0;
values(2)=0.2;
for ii=1:imgsize(1)
    for jj=1:imgsize(2)
        if (~isnan(img(ii,jj)) && img(ii,jj)~=0 && ~isinf(img(ii,jj)))
            k=k+1;
            values(k)=img(ii,jj);
        end
    end
end

MEAN=mean(values);
STD=std(values);

clims(1)=MEAN-STD;
clims(2)=MEAN+STD;
if (isnan(clims(1)) || isnan(clims(2)))
    clims = [-0.1 0.1];
elseif(clims(1) == clims(2))
    clims = [-0.1 0.1];
end