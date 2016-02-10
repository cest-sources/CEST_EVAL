function Z=NORM_ZSTACK(Mz_stack,M0_stack,P,Segment,type)


if nargin<5
    type='M0'
end;

if ismatrix(Segment)
    for ii=1:P.SEQ.stack_dim(3)
        Segment_3D(:,:,ii)=Segment;
    end;
else
    Segment_3D=Segment;
end

ind_zeros=find(M0_stack==0);
M0_stack(ind_zeros)=0.001;
sizeMz=size(Mz_stack);

M0_stack_4D=ones(sizeMz);

switch type
    case 'M0'
        
        for ii=1:P.SEQ.stack_dim(4)
            if (ndims(M0_stack)<4)
                M0_stack_4D(:,:,:,ii)=M0_stack.*Segment_3D;
            else
                M0_stack_4D(:,:,:,ii)=M0_stack(:,:,:,ii).*Segment_3D;
            end
        end;
        
    case 'baseline'

        for ii=1:sizeMz(1)
            for jj=1:sizeMz(2)
                if Segment(ii,jj)==1
                    M0_stack_4D(ii,jj,1,:)=interp1q([P.SEQ.w(1); P.SEQ.w(end)],[mean(Mz_stack(ii,jj,1,1:2),4) ; mean(Mz_stack(ii,jj,1,end-1:end),4)],P.SEQ.w);
                end
            end
        end
end;
        
        Z=Mz_stack./M0_stack_4D;