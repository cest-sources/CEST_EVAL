function [P]=perform_lookup(LOOKUP,Z,P)
%[P]=perform_WASABI_lookup(LOOKUP,Z,P)


WASABI_bib=LOOKUP{1};
bib_entries=LOOKUP{2};

mysize=size(WASABI_bib);

lb = P.FIT.lower_limit_fit;
ub = P.FIT.upper_limit_fit;
p0 = P.FIT.start_fit;
% find minimum between current WASABI spectrum and lookuptable


for ii=1:numel(P.SEQ.w)
    data_stack(:,:,:,:,ii)=Z(ii)*ones(mysize(1),mysize(2),mysize(3),mysize(4));
end


absDiff=sum(abs(WASABI_bib-data_stack),5);

% get index of minimum and the corresponding start parameters

[MIN,INDEX]=min(absDiff(:));
MIN=MIN/numel(P.SEQ.w);
BEST_START=bib_entries(INDEX);
BEST_START=BEST_START{1,1};  % this has to be done because BEST_START is a struct

if ((MIN<0.5) && (isnan(MIN)==0))
    
    % overwrite startparameter from fitmodelfunc_NUM only if more
    % than one value of this startparameter was tried in the lookuptable
    
    %B1
    if ((mysize(1)>1) && (MIN<0.1))
        p0(1)=BEST_START(1);
    end
    
    %dB0
    if ((mysize(2)>1) && (MIN<0.1))
        p0(2)=BEST_START(2);
        
    end
    
    %c
    if ((mysize(3)>1) && (MIN<0.1))
        p0(3)=BEST_START(3);
        
    end
    
    %af
    if ((mysize(4)>1) && (MIN<0.1) && (P.FIT.modelnum == 111))
        p0(4)=BEST_START(4);
        
    end
end

% do this always 
lb=p0-0.5;
ub=p0+0.5;
lb(1)=p0(1)*0.5; % overwrite B1
ub(1)=p0(1)*1.5; % overwrite B1


P.FIT.lower_limit_fit = lb;
P.FIT.upper_limit_fit = ub;
P.FIT.start_fit = p0;
