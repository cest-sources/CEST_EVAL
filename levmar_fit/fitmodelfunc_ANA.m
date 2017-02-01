function [f, fZi, f1, f2, f3, f4, f5, f6, g, g2, g3, g4, g5]= fitmodelfunc_ANA(A,P)
% function [f, fZi, f1, f2, f3, f4, f5, f6, g, g2, g3, g4, g5]= fitmodelfunc_ANA(A,P)
% f: full fit
% fZi: Initial Z value
% f1: Water Lorentz fit
% f2: Amide Lorentz fit
% f3: NOE Lorentz fit
% f4: MT Lorentz fit
% f5: Amine Lorentz fit
% f6: Additional Lorentz fit not yet defined
% g: Fit Water+MT (Reference - all CEST+NOE)
% g2: Fit WATER+NOE+MT+Amine (Reference - Amide)
% g3: Fit WATER+Amide+MT+Amine (Reference - NOE)
% g4: Fit WATER+Amide+NOE+Amine (Reference - MT)
% g5: Fit WATER+Amide+NOE+MT (Reference - Amine)

try
    modelname=P.FIT.fitfunc;
catch
    fprintf('\n better define P.FIT.fitfunc \n');
    P = fitmodelfunc_NUM(zeros(numel(P.SEQ.w),1),P);
    modelname=P.FIT.fitfunc;
end

% precreation of fitfunctions
    f=@(k) 0 ;
    fZi=@(k) 0 ;
    f1=@(k) 0 ;
    f2=@(k) 0 ;
    f3=@(k) 0 ;
    f4=@(k) 0 ;
    f5=@(k) 0 ;
    f6=@(k) 0 ;
    g=@(k) 0;
    g2=@(k) 0;
    g3=@(k) 0;
    g4=@(k) 0;
    g5=@(k) 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(modelname,'lorentzfit1pool')
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    %superposmodel
    %lorentzfit  : x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(10);

    f=@(k)  fZi(k)-f1(k);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(modelname,'lorentzfit1pool_BW')
    fZi=@(k) A(1) ;
    f1=@(k) L0_BW(A(1:4),A(end),k);
    %superposmodel
    %lorentzfit  : x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(10);

    f=@(k)  fZi(k)-f1(k);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(modelname,'gaussfit1pool')
    fZi=@(k) A(1) ;
    f1=@(k) A(2)*exp(-(k-A(4))^2/(2*A(3)^2));
    %superposmodel
    %lorentzfit  : x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(10);

    f=@(k)  fZi(k)-f1(k);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(modelname,'lorentzfit2pool') )
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;

    %superposmodel
    %lorentzfit  : x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(10);

    f=@(k)  fZi(k)-f1(k)-f2(k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(modelname,'lorentzfit2pool_BW')
    fZi=@(k) A(1) ;
    f1=@(k) L0_BW(A(1:4),A(end),k);
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;


    %superposmodel
    %lorentzfit  : x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(10);

    f=@(k)  fZi(k)-f1(k)-f2(k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(modelname,'lorentzfit_REX2pool'))
    f1=@(k) 1-A(1) ;
    f2=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    f3=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    if numel(A)>7
        f4=@(k) A(8).*A(9).^2/4./ (A(9).^2/4.+(k-A(10)).^2);
    else
        f4=@(k)0;
    end;
    %superposmodel
    %x(k)= (1-L0)/((1-L0)+ p(1)*L0+L0*L1)  ;
    f=@(k) sqrt((1-f2(k)))./( 1-f2(k)+A(1).*f2(k)+f2(k).*f3(k)+f2(k).*f4(k) );
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzfit3pool') )
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ; % water
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ; % amine
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ; % MT

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k);
    g=@(k) fZi(k)-f1(k)-f3(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      ;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
elseif ( strcmp(modelname,'lorentzfit3pool_BW') )
    fZi=@(k) A(1) ;
    f1=@(k) L0_BW(A(1:4),A(end),k); % water
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ; % amine
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ; % MT

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k);
    g=@(k) fZi(k)-f1(k)-f3(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      ;
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzdoublefit3pool') )
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k).^2) ; % water
    f2=@(k) A(4).*A(5).^2/4./ (A(5).^2/4+(k).^2) ; % water broad
    f3=@(k) A(6).*A(7).^2/4./ (A(7).^2/4+(k-A(8)).^2) ; % MT    
    %superposmodel
    %lorentzfit: x(k)= p(1) - p(2)*p(3).^2/4./(p(3).^2/4.+(i-p(4))^2) - p(5).*exp(-(k-p(4))^2/(p(6)/(2*sqrt(log(2))))^2) - p(7)*p(8).^2/4./(p(8).^2/4.+(i-p(9))^2);

    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k);
    g=@(k) fZi(k)-f1(k)-f3(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      ;
    
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzfit4pool') )
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);

    f=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k);
    g=@(k) fZi(k)-f1(k)-f3(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k);
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzfit4pool_BW') )
    fZi=@(k) A(1) ;
    f1=@(k) L0_BW(A(1:4),A(end),k); % water
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);

    f=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k);
    g=@(k) fZi(k)-f1(k)-f3(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k);
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzfit5pool') )
    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);
    f5=@(k) A(14).*A(15).^2/4./ (A(15).^2/4+(k-A(16)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)-f5(k);
    g=@(k)  fZi(k)-f1(k)            -f4(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k); 
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k); 
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)      ; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'lorentzfit5pool_BW') )
    fZi=@(k) A(1) ;
    f1=@(k) L0_BW(A(1:4),A(end),k); % water
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);
    f5=@(k) A(14).*A(15).^2/4./ (A(15).^2/4+(k-A(16)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)-f5(k);
    g=@(k)  fZi(k)-f1(k)            -f4(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k); 
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k); 
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)      ; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(modelname,'lorentzfit6pool'))

    fZi=@(k) A(1) ;
    f1=@(k) A(2).*A(3).^2/4./ (A(3).^2/4+(k-A(4)).^2) ;
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);
    f5=@(k) A(14).*A(15).^2/4./ (A(15).^2/4+(k-A(16)).^2);
    f6=@(k) A(17).*A(18).^2/4./ (A(18).^2/4+(k-A(19)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)-f5(k)-f6(k);
    g=@(k)  fZi(k)-f1(k)-f4(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k)-f6(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k)-f6(k);
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k)-f6(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)      -f6(k);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(modelname,'lorentzfit6pool_BW')) % fügt einen Lorentz ein, der ein plateau der breite BW hat
    fZi=@(k) k*0+A(1) ;
    f1=@(k) L0_BW(A(1:4),A(20),k);
    f2=@(k) A(5).*A(6).^2/4./ (A(6).^2/4+(k-A(7)).^2) ;
    f3=@(k) A(8).*A(9).^2/4./ (A(9).^2/4+(k-A(10)).^2) ;
    f4=@(k) A(11).*A(12).^2/4./ (A(12).^2/4+(k-A(13)).^2);
    f5=@(k) A(14).*A(15).^2/4./ (A(15).^2/4+(k-A(16)).^2);
    f6=@(k) A(17).*A(18).^2/4./ (A(18).^2/4+(k-A(19)).^2);

    %superposmodel
    %lorentzfit: x(k)= 1 - p(1)*p(2)/(p(2)+(i-p(3))^2) - p(4)*p(5)/(p(5)+(i-p(6))^2) - p(7)*p(8)/(p(8)+(i-p(9))^2) - p(10)*p(11)/(p(11)+(i-p(12))^2);
    f=@(k)  fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)-f5(k)-f6(k);
    g=@(k)  fZi(k)-f1(k)-f4(k);
    g2=@(k) fZi(k)-f1(k)      -f3(k)-f4(k)-f5(k)-f6(k);
    g3=@(k) fZi(k)-f1(k)-f2(k)      -f4(k)-f5(k)-f6(k);
    g4=@(k) fZi(k)-f1(k)-f2(k)-f3(k)      -f5(k)-f6(k);
    g5=@(k) fZi(k)-f1(k)-f2(k)-f3(k)-f4(k)      -f6(k);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ( strcmp(modelname,'WASABIFIT') )
    
    freq=P.SEQ.FREQ;
    t_p=P.SEQ.tp/(1E6);
    B1=A(1);
    offset=A(2);
    c=A(3);
    
    f=@(xx) c.*abs(1-2.*sin(atan((B1./((freq./gamma_)))./(xx-offset))).^2.*sin(sqrt((B1./((freq./gamma_))).^2+(xx-offset).^2).*freq.*(2.*pi).*t_p/2).^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
elseif  ( strcmp(modelname,'WASABIFIT_2') )
      
    freq=P.SEQ.FREQ;
    t_p=P.SEQ.tp/(1E6);
    B1=A(1);
    offset=A(2);
    c=A(3);
    af=A(4);
    
    f=@(xx) abs(c-af*sin(atan((B1./((freq./gamma_)))./(xx-offset))).^2.*sin(sqrt((B1./((freq./gamma_))).^2+(xx-offset).^2).*freq.*(2.*pi).*t_p/2).^2);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(modelname,'T1recovery') )
    f=@(k) abs((A(2)-A(3)).*exp(-1./A(1).*k)+A(3)) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(modelname,'T1recovery_biex')
    f=@(k) A(3)*abs((A(2)).*exp(-1./A(1).*k)+(A(5)).*exp(-1./A(4).*k)+1) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
elseif (strcmp(modelname,'T1RHOFIT') )
    f=@(xx) (A(1)*exp(-A(2)*xx)+A(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
       
elseif (strcmp(modelname,'T1RHOFITsimple') )
    f=@(xx) (A(1)*exp(-A(2)*xx));
    
elseif (strcmp(modelname,'T2_multiecho') )
    f=@(xx) (A(2)*exp(-1/A(1)*xx)+A(3));
    
end; % if

end % function

function L0=L0_BW(p,BW,k)

for jj=1:numel(k)
    i=k(jj);
        if i > p(4)+BW/2 

            L0(jj)= p(2)*p(3).^2/4./(p(3).^2/4.+(i-(p(4)+BW/2)).^2);

        elseif i < p(4)-BW/2

            L0(jj)= p(2)*p(3).^2/4./(p(3).^2/4.+(i-(p(4)-BW/2)).^2);

        else
            L0(jj)= p(2);
        end;
end;
if iscolumn(k)&&isrow(L0) || iscolumn(L0)&&isrow(k)
L0=L0';
end;

end
