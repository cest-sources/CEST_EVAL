function [ output_args ] = montage1t(AA,cl,smooth)
%MONTAGE1 Summary of this function goes here
%   Detailed explanation goes here
AA(isnan(AA))=0;
if nargin>1
    cl=cl;
else
    cl=[0 2.5*mean(AA(AA>0))];
end;
if nargin>2
for ii=1:size(AA,3)
AA(:,:,ii) = imgaussfilt(squeeze(AA(:,:,ii)),smooth);
end;
end;

montage1(permute(AA(:,end:-1:1,:),[2 1 3]),cl);

end

