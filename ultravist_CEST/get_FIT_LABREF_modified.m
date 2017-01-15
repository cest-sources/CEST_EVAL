function [Zlab, Zref] = get_FIT_LABREF_modified(popt, P, Segment, mode, x_inter)
% function [Zlab, Zref] = get_FIT_LABREF_modified(popt, P, Segment, mode, x_inter)
%
% Version of get_FIT_LABREF modified for Ultravist analysis.
% 
% CT 20170111


if nargin < 5
    x_inter=P.SEQ.w;
end

switch mode
    case 'invivo'
        Zref_fields = {'Background', 'Amide', 'NOE', 'MT', 'Amine', 'onlyWater'};
    case 'ultravist'
        Zref_fields = {'Background', 'ppm4p2', 'ppm5p6', 'onlyWater'};
    otherwise
        error('Input ''mode'' can only be ''invivo'' or ''ultravist''')
end

sizes=size(popt);
Zlab=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
for nfield = 1:length(Zref_fields)
    Zref.(Zref_fields{nfield}) = zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
end

if ndims(Segment) == 2
    for ii=1:sizes(3)
        Segment(:,:,ii)=Segment(:,:,1);
    end
end
clear ii

for kk=1:sizes(3)%z
     for ii=1:sizes(1)          %x
         h=waitbar(ii/sizes(1));
         for jj=1:sizes(2)      %y
             
             if Segment(ii,jj,kk)==1
                 
                 [f, fZi, f1, f2, f3, f4, f5, f6, g, g2, g3, g4, g5]= fitmodelfunc_ANA(popt(ii,jj,kk,:),P);
                 Zlab(ii,jj,kk,:) = f(x_inter);
                 Zref.(Zref_fields{1})(ii,jj,kk,:) = g(x_inter);
                 Zref.(Zref_fields{2})(ii,jj,kk,:) = g2(x_inter);
                 Zref.(Zref_fields{3})(ii,jj,kk,:) = g3(x_inter);
                 if strcmp(mode,'invivo')
                    Zref.(Zref_fields{4})(ii,jj,kk,:) = g4(x_inter);
                    Zref.(Zref_fields{5})(ii,jj,kk,:) = g5(x_inter);
                 end
                 Zref.(Zref_fields{end})(ii,jj,kk,:) = fZi(x_inter)-f1(x_inter);
             else
                 Zlab(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 for nfield = 1:length(Zref_fields)
                     Zref.(Zref_fields{nfield})(ii,jj,kk,:) = NaN(numel(x_inter),1);
                 end
             end;
             
         end;
     end;     
 end;
close(h);
