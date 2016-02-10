function [nosatStack,satStack,P] = load_3D(CTRL,folder)

%% loading of images and checking Dicom-header
% no normalization yet
% CTRL controls by 'B1guess' for a B1mapload or  '' for CEST load


if nargin < 2
    cd(uigetdir)
end

function result = filterWithRegexpi(listOfFiles, expression)
    result = listOfFiles(arrayfun(@(x) ~isempty(regexpi(x.name, expression, 'once')), listOfFiles, 'UniformOutput', true));
end

listoffiles = filterWithRegexpi(dir(), '\.ima');

if numel(listoffiles) == 0
    listoffiles = filterWithRegexpi(dir(), '\.dcm');
end

numfiles=size(listoffiles,1);
info = struct('Instance', zeros(numfiles,1), 'Acquisition',zeros(numfiles,1));
for k=1:numfiles
    filect=listoffiles(k).name;
    dicom_info=dicominfo(filect);
    info.Instance(k,1)=dicom_info.InstanceNumber;
    info.Acquisition(k,1)=dicom_info.AcquisitionNumber;
end

% for case of evaluation of 2D-data that wasnt acquired in one sequence
% changes info.Acquisition only in this case

if max(info.Instance)==1
    info.Acquisition=[1:numfiles];
end
    

clear tmp k
tmp=dicomread(filect);
mysize=size(tmp);
maxIns=max(info.Instance);
clear filect tmp
if strcmp(CTRL,'B1guess')
    
else
    P=wipread( num2str(listoffiles(1).name),maxIns,CTRL);
end;
maxAcq=max(info.Acquisition); % number of Offsets in z-spec (including M0's)

% if 3D has failed     % maxAcq=14;
% info.Acquisition(243:264,1)=12;
% info.Acquisition(265:286,1)=13;
% info.Acquisition(287:308,1)=14;

if (strcmp (P.SEQ.sampling,'List'))
    try
        oldfolder=pwd;
        cd ..
        Offsetlist(:,1)=load('Offsetlist.txt');
        cd (oldfolder);
        
    catch
        [Filename, Pathname]=uigetfile('.txt','Pick an Offsetlist');
        Offsetlist(:,1)=load(strcat(Pathname,Filename));
        cd (oldfolder);
    end
end


if (strcmp(P.SEQ.sampling,'List'))
  
        
%% pick unsaturated images from all images    
    %ask for cutoff offset
    prompt = {'Enter cuttoff offset (absolute value):','Is first M0 image in List: 1 (yes) 0 (no) 2 (no M0image at all)'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'300','1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);    
    cutoff_offset=abs(str2num(answer{1}));
    M0LIST=str2num(answer{2});
    
    Msat_array=(abs(Offsetlist)<cutoff_offset);
    
    if M0LIST==1
        tempOffset=Offsetlist(2);
    else
        tempOffset=Offsetlist(1);
    end
    %gehe Msat druch 
    %merke ir aktuellen werte
    %sobald ne 0 kommt schreibe aktuellen wert da rein.
        
    Offset_for_this_M0=[];
    for ii=1:numel(Offsetlist)
        if Msat_array(ii)==1
          tempOffset=Offsetlist(ii);
        else %Msat_array(ii)==0
            Offset_for_this_M0(ii)=tempOffset + ii*0.0000001;  %% (dirty) this is to avoid same offsets
        end;
            
    end;
    
    P.SEQ.value_nextM0=Offset_for_this_M0(~Msat_array);
    
    if M0LIST==1 % all M0 values are in Offsetlist (including first)
        P.SEQ.index_M0=find(abs(Offsetlist)>=cutoff_offset);
        P.SEQ.index_no_M0=find(abs(Offsetlist)<cutoff_offset);
        P.SEQ.w=Offsetlist(P.SEQ.index_no_M0);
        clearvars Offsetlist;
        P.SEQ.value_nextM0=[P.SEQ.value_nextM0]; %% we add the intrinsic M0 value here explicitly being -300
    
    elseif M0LIST==0 % the first M0 value is not in Offsetlist
        P.SEQ.index_M0=[1; find(abs(Offsetlist)>=cutoff_offset)+1];  %% find all unsat images index ( add the intrinsic M0 image and shift by 1)
        P.SEQ.index_no_M0=find(abs(Offsetlist)<cutoff_offset)+1; %% find all sat images index ( due to the intrinsic M0 image shift by 1)
        P.SEQ.w=Offsetlist(P.SEQ.index_no_M0-1); %% find all sat images offset (-1 to shift back the intrinsic M0)
        clearvars Offsetlist;

        P.SEQ.value_nextM0=[-300 P.SEQ.value_nextM0]; %% we add the intrinsic M0 value here explicitly being -300
    elseif M0LIST==2 % there are no M0 images at all
        P.SEQ.index_M0=[];  %% find all unsat images index ( add the intrinsic M0 image and shift by 1)
        P.SEQ.index_no_M0=[1:numel(Offsetlist)]; %% find all sat images index ( due to the intrinsic M0 image shift by 1)
        P.SEQ.w=Offsetlist(P.SEQ.index_no_M0); %% find all sat images offset (-1 to shift back the intrinsic M0)
        clearvars Offsetlist;

        P.SEQ.value_nextM0=[]; %% we add the intrinsic M0 value here explicitly being -300
    
    end

    %% end of picking unsaturated images

else  %% no Offsetlist
     M0LIST=0;
     P.SEQ.index_M0=1;
     P.SEQ.index_no_M0=[2:maxAcq];
     P.SEQ.value_nextM0=[-300]; %% we add the intrinsic M0 value here explicitly being -300
     'M0 image offset is assumed to be -300'

    
end;
    
%% in any case DO:

Stack=zeros(mysize(1),mysize(2),P.EVAL.upperlim_slices-P.EVAL.lowerlim_slices+1,maxAcq);

%create Stack of Z-spectra with chosen number of slices
for ii=1:numfiles
    if(P.EVAL.lowerlim_slices <= info.Instance(ii)) && (info.Instance(ii) <=  P.EVAL.upperlim_slices)
        Stack(:,:,info.Instance(ii)-P.EVAL.lowerlim_slices+1,info.Acquisition(ii))=dicomread(listoffiles(ii).name);
    end
end

%% separate saturated from unsaturated images using P.SEQ.index_M0 and  P.SEQ.index_no_M0
%initialize
if M0LIST<2 % M0 images exist

    nosatStack=zeros(size(Stack,1),size(Stack,2),size(Stack,3),numel(P.SEQ.index_M0));
    satStack=zeros(size(Stack,1),size(Stack,2),size(Stack,3),size(Stack,4)-numel(P.SEQ.index_M0));

    nosatStack=Stack(:,:,:,P.SEQ.index_M0);   %% reads all the unsaturated images 
    satStack=Stack(:,:,:,P.SEQ.index_no_M0);

else % there are no M0 images (adiabatic pulse test,... etc)
    nosatStack=ones(size(Stack,1),size(Stack,2));
    satStack=zeros(size(Stack,1),size(Stack,2),size(Stack,3),size(Stack,4)-numel(P.SEQ.index_M0));

    satStack=Stack(:,:,:,P.SEQ.index_no_M0);
end

%% ouputs for P struct
P.SEQ.stack_dim=size(satStack);
P.SEQ.maxIns=maxIns;
P.SEQ.maxAcq=maxAcq;
P.SEQ.dicom_info=dicom_info;

end
