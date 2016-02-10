function [Zlab, Zref] = get_FIT_LABREF(popt,P,Segment,x_inter)
%[Zlab, Zref] = get_FIT_LABREF(popt,P,Segment,x_inter)
% please always check pool numbers!!
if nargin < 4
    x_inter=P.SEQ.w;
end

sizes=size(popt);
Zlab=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.Background=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.Amide=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.NOE=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.MT=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.Amine=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));
Zref.onlyWater=zeros(sizes(1),sizes(2),sizes(3),numel(x_inter));

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
                 Zlab(ii,jj,kk,:)=f(x_inter);
                 Zref.Background(ii,jj,kk,:)=g(x_inter);
                 Zref.Amide(ii,jj,kk,:)=g2(x_inter);
                 Zref.NOE(ii,jj,kk,:)=g3(x_inter);
                 Zref.MT(ii,jj,kk,:)=g4(x_inter);
                 Zref.Amine(ii,jj,kk,:)=g5(x_inter);
                 Zref.onlyWater(ii,jj,kk,:)=fZi(x_inter)-f1(x_inter);
             else
                 Zlab(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.Background(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.Amide(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.NOE(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.MT(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.Amine(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 Zref.onlyWater(ii,jj,kk,:)=NaN(numel(x_inter),1);
                 
             end;
             
         end;
     end;     
 end;
close(h);
