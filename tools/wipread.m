function [P]=wipread(string,maxIns,CTRL)


%building cell strings for the string parameter
pulse_shape={'Gauss' 'Sinc' 'Rect' 'Spinlock' 'Adia Fullpass' 'Adia Spinlock' 'AdiaInvRec' 'Fermi'};
spoiling={'none' 'constant' 'alternating' 'varying'};
sampling={'regular' 'alternating' 'List' 'SingleOffset'};

try
%reading file as a string of cells
FID=fopen(string,'r');
A=textscan(FID,'%s','BufSize', 500000);
fclose(FID);

%searching for the parameter. Value of parameter is always two lines after declaration 
for ii=1:numel(A{1})
    if strcmp(A{1}{ii},'lAverages') 
        P.SEQ.averages= str2double(A{1}{ii+2});
    end
    
    if strcmp(A{1}{ii},'sProtConsistencyInfo.flNominalB0') 
        P.SEQ.nominalB0= str2double(A{1}{ii+2});
        try
        P.SEQ.FREQ=P.SEQ.nominalB0*gamma_;
        P.SEQ.FS= round(P.SEQ.nominalB0);
        catch
        fprintf('nominal B0 could not be read \n');
        end
    end   
    
    if strcmp(A{1}{ii},'lRepetitions') 
        P.SEQ.measurements= str2double(A{1}{ii+2})+1;
    end
    if strcmp(A{1}{ii},'adFlipAngleDegree[0]')
        P.SEQ.imageflipangle= str2double(A{1}{ii+2});
    end
    
    if  strcmp(A{1}{ii},'alTR[0]')
        P.SEQ.TR= str2double(A{1}{ii+2});
    end
    
    if strcmp(A{1}{ii},'alTE[0]')
        P.SEQ.TE= str2double(A{1}{ii+2});
    end
    % searching of WIP parameters
    for jj=1:15 %PS: changed from 10 to 11 2014/09/30
        if  strcmp(A{1}{ii},sprintf('sWiPMemBlock.alFree[%i]',jj)) 
            WIPparamlong(jj)=str2double(A{1}{ii+2});
        end;
        if strcmp(A{1}{ii},sprintf('sWiPMemBlock.adFree[%i]',jj))
            WIPparamdouble(jj)=str2double(A{1}{ii+2});
        end
    end
end;
catch
    fprintf('Files could not be accessed')
end;

% WIP parameters are written into P

    %first long
    try
        P.SEQ.MTon= WIPparamlong(1);
        P.SEQ.pulseshape= pulse_shape{WIPparamlong(2)};
        P.SEQ.n= WIPparamlong(8);
        P.SEQ.tp= WIPparamlong(10);
        P.SEQ.DC= WIPparamlong(11);
        P.SEQ.spoiling= spoiling{WIPparamlong(6)};
    catch
        fprintf('General sequence parameters could not be read \n');
    end
    
    try
        P.SEQ.Binomlength= WIPparamlong(4);
    catch
        fprintf('Binom length could not be read \n')
        P.SEQ.Binomlength = 0;
    end
	
	try
        P.SEQ.BinomDist= WIPparamlong(5);
    catch
        fprintf('Binom Distance could not be read \n')
        P.SEQ.BinomDist = 0;
    end
	
	try
        P.SEQ.BinomNumber= WIPparamlong(6);
    catch
        P.SEQ.BinomNumber = 0;
    end
    
    try
        P.SEQ.BinomNumberinTrec= WIPparamlong(7);
    catch
        P.SEQ.BinomNumberinTrec = 0;
    end
    
     try
        P.SEQ.NLock_SL= WIPparamlong(8);
    catch
        fprintf('Number of Locking Pulses could not be read \n')
        P.SEQ.NSat_AdiaSL = 0;
    end
    
    try 
        P.SEQ.sampling= sampling{WIPparamlong(13)};
    catch
        fprintf('Sampling could not be read \n')
        P.SEQ.sampling= sampling{1};
    end
    
    try
        P.SEQ.recovertime= WIPparamlong(14);
    catch
        fprintf('Recover time could not be read \n')    
        P.SEQ.recovertime= 0;
    end
    
    try
        P.SEQ.recovertimeM0= WIPparamlong(15);
    catch
        fprintf('M0 recover time could not be read \n')
        P.SEQ.recovertimeM0= 0;
    end
    
    %then doubles
    try
        P.SEQ.adiabaticmu= WIPparamdouble(1);
    catch
        fprintf('Adiabatic mu could not be read \n')
        P.SEQ.adiabaticmu= 0;
    end
    
	try
        P.SEQ.adiabaticBW= WIPparamdouble(2);
    catch
        fprintf('Adiabatic BW could not be read \n')
        P.SEQ.adiabaticBW = 0;
    end
	
	try
        P.SEQ.adiabaticLength= WIPparamdouble(3);
    catch
        fprintf('Adiabatic Length could not be read \n')
        P.SEQ.adiabaticLength = 0;
    end
	
    
    try
        P.SEQ.adiabatic_B1= WIPparamdouble(4);
    catch
        fprintf('Adiabatic B1 could not be read \n')
        P.SEQ.n_adiabatic = 0;
    end
    

    try
        P.SEQ.B1= WIPparamdouble(5);
    catch
        fprintf('B1 could not be read \n')
        P.SEQ.B1= 0;
    end
	
    try
        P.SEQ.Offset= WIPparamdouble(6);
    catch
        fprintf('Offset could not be read \n')
        P.SEQ.Offset= 0;
    end
    
    try
        P.SEQ.Fermislope= WIPparamdouble(7);
    catch
        fprintf('Fermislope could not be read \n')
        P.SEQ.Fermislope= 0;
    end
    
    try
        P.SEQ.FermiFWHM= WIPparamdouble(8);
    catch
        fprintf('FermiFWHM could not be read \n')
        P.SEQ.FermiFWHM= 0;
    end
    
	
    %let them be controlled by the user
% instring='It is indicated that the offset array is equidistantly spaced,please input the value of the maximal offset in ppm\n';
prompt={'maximal offset [ppm]',...
        'first slice to be examined:',...
        'last slice to be examined (one toggles single slice specified by first slice):',...
        'number of measurements:',...
        'B1 [µT]:',...
        'number of pulses',...
        'duration of pulse [µs]',...
        'duty cycle [%]',...
        'recover time [ms]',...
        'M0 recover time [ms]',...
        'sampling: 1= regular, 2=alternating, 3=List, 4=SingleOffset',...
        'frequency [MHz]'};
name=sprintf('Number of Slices = %i\n', maxIns);
numlines=1;

try 
    P.SEQ.measurements
catch
    P.SEQ.measurements=1; % for SpinLock experiments with just one on-resonant measurement
end

% Try to write values in defaultanswer, if error following values are taken
try
   defaultanswer={num2str(P.SEQ.Offset),'1','1',num2str(P.SEQ.measurements),num2str(P.SEQ.B1),num2str(P.SEQ.n),num2str(P.SEQ.tp),num2str(P.SEQ.DC),num2str(P.SEQ.recovertime),num2str(P.SEQ.recovertimeM0),num2str(strmatch(P.SEQ.sampling,sampling)),num2str(P.SEQ.FREQ)};
catch
   defaultanswer={'1','1','1','1','1','1','1','1','1','1','1',num2str(1*gamma_)};
end;

% Interface window is opened
if strcmp(CTRL,'USER')
    answer=inputdlg(prompt,name,numlines,defaultanswer);
else
    answer=defaultanswer;
end;
% if User changed values they are overwritten here
ANSW=str2double(answer);
P.SEQ.Offset= ANSW(1);
P.EVAL.lowerlim_slices= ANSW(2);
P.EVAL.upperlim_slices= ANSW(3);
P.SEQ.measurements= ANSW(4);
P.EVAL.N_asym=fix((P.SEQ.measurements-1)/2);
P.SEQ.B1= ANSW(5);
P.SEQ.n= ANSW(6);
P.SEQ.tp= ANSW(7);
P.SEQ.DC= ANSW(8);
P.SEQ.recovertime= ANSW(9);
P.SEQ.recovertimeM0= ANSW(10);
P.SEQ.sampling= sampling{ANSW(11)};
P.SEQ.FREQ= ANSW(12);
end
