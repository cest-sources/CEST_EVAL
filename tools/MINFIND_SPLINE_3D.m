function [dB0 yS yfit]= MINFIND_SPLINE_3D(Mz_stack,Segment,P)

[P]=change_w_fit(P);

xfit(:,1)=P.EVAL.w_fit;

x_Zspec_ppm=P.SEQ.w;

fittoolboxflag=1;  %% ist die fitting toolbox da oder nicht

splineflag=1; % 1 for smoothingspline 0 for smoothing with 0.97


% allocation
mysize=size(Mz_stack);
N_offsets=mysize(4); % number of points in the z-spec

Stack_single=double(Mz_stack);

dB0=zeros(mysize(1),mysize(2),mysize(3));

yS=zeros(mysize(1),mysize(2),mysize(3),mysize(4));

tmpzspec=zeros(N_offsets,1);

if ndims(Segment)==2
    for ii=1:mysize(3)
        Segment(:,:,ii)=Segment(:,:,1);
    end
end

if 0%(exist('Composite')>0)
    
    %% Zerlege Matritzen auf labs
    Stack_c = Composite();  % One element per lab in the pool
    
    yS_c = Composite();
    yfit_c = Composite();
    
    dB0 = Composite();
    Segment_c= Composite();
    
    npools=size(Stack_c,2); %% wieviele matlabpools
    np=mysize(2)/npools;
    %teilintervalle
    IV = @(i) 1+fix(np*(i-1)):fix(np*(i)); %InterVals
    
    for ii = 1:length(Stack_c)
        
        Stack_c{ii} = Stack_single(:,IV(ii),:,:);
        
        Segment_c{ii}=Segment(:,IV(ii),:);
        
        yS_c{ii} = zeros(mysize(1),numel(IV(ii)),mysize(3),mysize(4));
        yfit_c{ii} = zeros(mysize(1),numel(IV(ii)),mysize(3),numel(xfit) );
        
        dB0{ii}=zeros(mysize(1),numel(IV(ii)),mysize(3));
        
    end
    
    %% iteration auf teilmatritzen
    
    spmd
        
        %fit with smoothing spline using default spline factor
        %fo_ = fitoptions('method','SmoothingSpline','Normalize','on','SmoothingParam',0.999);
        
        if splineflag
            fo_ = fitoptions('method','SmoothingSpline');
            ft_ = fittype('SmoothingSpline');
        else % disable in case of in vivo
            fo_ = fitoptions('method','SmoothingSpline','SmoothingParam',0.97);
            ft_ = fittype('SmoothingSpline');
        end
        
        for k=mysize(3)
            
            for i=1:mysize(1)
                %tic
                %fprintf('Labindex: %d,  Zeile: %d von %d , Spalten: %d\n',labindex,i,mysize(1),numel(IV(labindex)));
                for j=1:numel(IV(labindex))
                    
                    
                    if Segment_c(i,j,k) > 0
                        tmpzspec(:,1)=squeeze(Stack_c(i,j,k,:));
                        
                        %fit for in vivo
                        cf_ = fit(x_Zspec_ppm,tmpzspec,ft_,fo_);
                        yS_c(i,j,k,:)= cf_(x_Zspec_ppm);
                        yfit_c(i,j,k,:)=cf_(xfit);
                        
                        [minval,minind]=min(yfit_c(i,j,k,:));
                        
                        dB0_c(i,j,k)=xfit(minind,1);
                    else
                        dB0_c(i,j,k)=NaN;
                    end;
                    
                end;
                
                
            end
            
            %toc;
        end  % end for slice loop
        
    end
    
    
    %% reallocation labs to local
    
    Stack_single = cat(2, Stack_c{:});
    
    yS = cat(2, yS_c{:});
    yfit = cat(2, yfit_c{:});
    
    dB0 = cat(2, dB0_c{:});
    
    
else  %not parallel
    
    
    %fit with smoothing spline using default spline factor
    %fo_ = fitoptions('method','SmoothingSpline','Normalize','on','SmoothingParam',0.999);
    
    
    if splineflag
        fo_ = fitoptions('method','SmoothingSpline');
        ft_ = fittype('SmoothingSpline');
    else % disable in case of in vivo
        fo_ = fitoptions('method','SmoothingSpline','SmoothingParam',0.97);
        ft_ = fittype('SmoothingSpline');
    end
    
    
    
    for k=1:mysize(3)
        
        for i=1:mysize(1)
            h = waitbar(i/mysize(1));
            %             tic
            %             fprintf('Zeile: %d von %d , Spalten: %d\n',i,mysize(1),mysize(2));
            for j=1:mysize(2)
                if Segment(i,j,k) > 0
                    tmpzspec(:,1)=squeeze(Stack_single(i,j,k,:));
                    
                    if fittoolboxflag
                        cf_ = fit(x_Zspec_ppm,tmpzspec,ft_,fo_);
                        %yS(i,j,k,:)= cf_(x_Zspec_ppm);
                        yS(i,j,k,:)= cf_(P.SEQ.w);
                        yfit(i,j,k,:)=cf_(xfit);
                    else
                        
                        %                         yS(i,k,:) = interp1(x_Zspec_ppm,fastsmooth(tmpzspec,2,1,1),x_Zspec_ppm,'spline');
                        %                         yfit =interp1(x_Zspec_ppm,fastsmooth(tmpzspec,2,1,1),xfit,'spline');
                        yS(i,j,k,:) = interp1(x_Zspec_ppm,bfilt(tmpzspec)',x_Zspec_ppm,'spline');
                        yfit(i,j,k,:) =interp1(x_Zspec_ppm,bfilt(tmpzspec)',xfit,'spline');
                        %                         windowSize=3;
                        %                         yS(i,k,:) = interp1(x_Zspec_ppm,filter(ones(1,windowSize)/windowSize,1,tmpzspec),x_Zspec_ppm,'spline');
                        %                         yfit(i,j,k,:) =interp1(x_Zspec_ppm,filter(ones(1,windowSize)/windowSize,1,tmpzspec),xfit,'spline');
                        %                         yS(i,k,:) = interp1(x_Zspec_ppm,tmpzspec,x_Zspec_ppm,'spline');
                        %                         yfit(i,j,k,:) =interp1(x_Zspec_ppm,tmpzspec,xfit,'spline');
                        
                    end;
                    
                    [minval,minind]=min(yfit(i,j,k,:));
                    dB0(i,j,k)=xfit(minind,1);
                    
                else
                    dB0(i,j,k)=NaN;
                end;
                
            end;
            
        end
        close(h)
    end
    
end

end
