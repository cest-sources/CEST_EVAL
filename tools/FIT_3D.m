function [popt, P]= FIT_3D(Z_stack,P,Segment,StartValues)
%[popt, P]= FIT_3D(Z_stack,P,Segment,StartValues)


mysize=size(Z_stack);

% if no Segment is given to function
if nargin < 3
    Segment = ones(mysize(1),mysize(2),mysize(3));
end

% make Segment 3D if Z_stack is 3D
if (ndims(Segment)==2 && mysize(3)>1)
    for ii=1:mysize(3)
        Segment(:,:,ii)=Segment(:,:,1);
    end
end

% case of no explicit startvalues in function is dealt with in voxel loop
% further down


% allocation
mysize=size(Z_stack);
N_offsets=mysize(4); % number of points in the z-spec

Stack_single=double(Z_stack);

% this is only for initializing popt and getting the fitfunction
tmpzspec=zeros(N_offsets,1);
[P] = fitmodelfunc_NUM(tmpzspec,P);
popt=NaN(mysize(1),mysize(2),mysize(3),P.FIT.nparams);

if ( nargin == 4 && ~(islogical(StartValues)) )
        P.FIT.start_fit = StartValues;
end

% create lookuptable for WASABI fit here
if (strcmp(P.FIT.fitfunc,'WASABIFIT') || strcmp(P.FIT.fitfunc,'WASABIFIT_2') )
    [WASABI_bib, bib_entries] = lookuptable_WASABI(P);
    LOOKUP{1}=WASABI_bib;
    LOOKUP{2}=bib_entries;
end

if ( exist('Composite')>0 && strcmp(P.FIT.fitfunc,'T1recovery_biex') )
    
 
    % Spread Matritzes on labs
    Stack_c = Composite();  % One element per lab in the pool
    tmpzspec_c=Composite();
    popt_c = Composite();
    Segment_c = Composite();
    P_c = Composite();
    
    npools=size(Stack_c,2); %% number matlabpools
    np=mysize(2)/npools;
    %InterVals
    IV = @(i) 1+fix(np*(i-1)):fix(np*(i)); 
    
    for ii = 1:length(Stack_c)
        
        Stack_c{ii} = Stack_single(:,IV(ii),:,:);
        
        Segment_c{ii}=Segment(:,IV(ii),:);
        tmpzspec_c{ii}=zeros(mysize(4),1);
        P_c{ii}=P;
        popt_c{ii} = NaN(mysize(1),numel(IV(ii)),mysize(3),P.FIT.nparams);
  
    end
    
    % iteration on partial matritzes
    
    spmd
        for k=1:mysize(3) %slice
            for i=1:mysize(1)
                %tic
%                 fprintf('Labindex: %d,slice %d,  Zeile: %d von %d , Spalten: %d\n',labindex,k,i,mysize(1),numel(IV(labindex)));
               
                for j=1:numel(IV(labindex))
                                     
                    if (Segment_c(i,j,k)==1)
                        tmpzspec_c(:,1)=squeeze(Stack_c(i,j,k,:));
%                         in case data dependent startvalues/boundaries are chosen
                        [P_c] = fitmodelfunc_NUM(tmpzspec,P_c);
                        if ( nargin == 4 && ~(islogical(StartValues)) )
                                P_c.FIT.start_fit = StartValues;    
                        end
                        
                        % perform lookup in lookuptable, here startvalues and
                        % bounds are overwritten in P
                        if (strcmp(P.FIT.fitfunc,'WASABIFIT') || strcmp(P.FIT.fitfunc,'WASABIFIT_2') )
                            [P_c]=perform_lookup(LOOKUP,tmpzspec_c,P_c);
                        end
                        
                        [popt_c(i,j,k,:)]= levmar_fit(tmpzspec_c,P_c);

                    end;
                    
                end; % end y-axis loop (j)
                
                
            end % end x-axis loop (i)

        end  % end for slice loop (k)
    
    end % end spmd
    
    
    % reallocation labs to local
    
    Stack_single = cat(2, Stack_c{:});
           
    popt = cat(2,popt_c{:});
        
else  %not parallel
%     
%     % create lookuptable for WASABI fit here
%     if (strcmp(P.FIT.fitfunc,'WASSRFIT') || strcmp(P.FIT.fitfunc,'WASSRFIT_2') )
%         [WASABI_bib, bib_entries] = lookuptable_WASABI(P);
%         LOOKUP{1}=WASABI_bib;
%         LOOKUP{2}=bib_entries;
%     end
    
    pixeltofit = numel(Segment(Segment==1));
    pixelcounter = 1;
    hh = waitbar(0);
    for k=1:mysize(3)
        
        str = sprintf('Fitting slice number %d out of %d', k, mysize(3));
        
        for i=1:mysize(1)
            
            for j=1:mysize(2)
                                
                if Segment(i,j,k) == 1
                    
                    waitbar(pixelcounter/pixeltofit,hh,str);
                    pixelcounter = pixelcounter + 1;
                    
                    % 1 D data
                    tmpzspec(:,1) = squeeze(Stack_single(i,j,k,:));
                    
                    % get startvalues and bounds (important that this is here
                    % since startvalues depend on values in data (tmpzspec)
                    % sometimes
                    
                    [P] = fitmodelfunc_NUM(tmpzspec,P);
            
                    if ( nargin == 4 && ~(islogical(StartValues)) )
                        % case of normal startvalue vector
                        if ndims(StartValues)==1 
                            P.FIT.start_fit = StartValues;
                         % case of B1map guess (if ever necesairy again)
                        elseif ndims(StartValues)==2
                            P.FIT.start_fit = StartValues(i,j);
                        end 
                    end
                    
                    % perform lookup in lookuptable, here startvalues and
                    % bounds are overwritten in P
                    if (strcmp(P.FIT.fitfunc,'WASABIFIT') || strcmp(P.FIT.fitfunc,'WASABIFIT_2') )
                        [P]=perform_lookup(LOOKUP,tmpzspec,P);
                    end
                    
                    if (strcmp(P.FIT.fitfunc,'T1recovery_biex') && ~(islogical(StartValues)) )
                        P.FIT.lower_limit_fit(1:3) = StartValues(i,j,k,:);
                        P.FIT.upper_limit_fit(1:3) = StartValues(i,j,k,:);
                        P.FIT.start_fit=p0;
                        P.FIT.start_fit(1:3) = StartValues(i,j,k,:);
                    end
                    
                    % all information about startvalues/bounds is saved in
                    % P struct
                    [popt(i,j,k,:)]  = levmar_fit(tmpzspec,P);
                                         
                end
                
            end
            
        end
           
    end
    
    close(hh);
    
end


