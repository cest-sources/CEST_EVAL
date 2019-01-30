function [ output_args ] = montage1(AA,cl)
%MONTAGE1 Summary of this function goes here
%   Detailed explanation goes here
AA(isnan(AA))=0;
if nargin>1
    cl=cl;
else
    cl=[0 2.5*mean(AA(AA>0))];
end;

siz=size(AA);
BB=reshape(AA,siz(1),siz(2),1,siz(3));
size(BB);
BB(isnan(BB))=0;


montage(BB,'DisplayRange',cl,'size', [ceil(sqrt(siz(3))) ceil(sqrt(siz(3)))]);
colormap(gca,'parula');
colorbar
 

end

