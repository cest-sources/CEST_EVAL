function M0_stack=fitM0(M_nosat_stack,P)

%function M0_stack=fitM0(M_nosat_stack,P)
mysize=size(M_nosat_stack);
M0_stack=zeros(mysize(1),mysize(2),mysize(3),numel(P.SEQ.w));

M_nosat_stack(:,:,:,mysize(4)+1)=M_nosat_stack(:,:,:,mysize(4)); %% the M0 stack is extended by 1 to make sure that the last point is not crazily extrapolated
P.SEQ.index_M0= [P.SEQ.index_M0; max([P.SEQ.index_no_M0(end) P.SEQ.index_M0(end)])+1 ]; %% the index M0 is also extended by the last measured offset index +1

for ii=1:mysize(1)
    for jj=1:mysize(2)
        for kk=1:mysize(3)
            M0_stack(ii,jj,kk,:)  = interp1(P.SEQ.index_M0,squeeze(M_nosat_stack(ii,jj,kk,:)),P.SEQ.index_no_M0,'linear','extrap');
        end
        
    end
    
end

% referencing is done on indizes not on Offsets to correct for the signal
% drift over time. Non-uniform offset spacing falsifies that.