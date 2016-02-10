function [Mz_b0corr] = B0_CORRECTION(Mz_stack,dB0_stack,P,Segment)

sizes=size(Mz_stack);
Mz_b0corr=zeros(sizes(1),sizes(2),sizes(3),sizes(4));

[P]=change_w_fit(P);

if ndims(Segment)==2
    for ii=1:sizes(3)
        Segment(:,:,ii)=Segment(:,:,1);
    end
end

 for kk=1:sizes(3)              %z
     for ii=1:sizes(1)          %x
         for jj=1:sizes(2)      %y
             
             if Segment(ii,jj,kk)==1
                 
             tmpzspec=squeeze(Mz_stack(ii,jj,kk,:));
             [Mz_b0corr(ii,jj,kk,:)]=B0_CORRECTION_1D(tmpzspec,dB0_stack(ii,jj,kk),P);
            
             end;
             
         end;
     end;     
 end;