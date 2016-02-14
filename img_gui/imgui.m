function varargout = imgui(varargin)
% IMGUI M-file for imgui.fig
%      IMGUI, by itself, creates a new IMGUI or raises the existing
%      singleton*.
%
%      H = IMGUI returns the handle to a new IMGUI or the handle to
%      the existing singleton*.
%
%      IMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMGUI.M with the given input arguments.
%
%      IMGUI('Property','Value',...) creates a new IMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imgui

% Last Modified by GUIDE v2.5 10-Feb-2016 13:27:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imgui_OpeningFcn, ...
    'gui_OutputFcn',  @imgui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if (nargin~=0 && ischar(varargin{1}))
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before imgui is made visible.
function imgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imgui (see VARARGIN)

% Choose default command line output for imgui
handles.output = hObject;

handles.shift=0;

handles.P = evalin('base','P');

 set(gcf,'OuterPosition', [-20 -20 740 540]);

try
    handles.P.FIT.modelnum
catch
    handles.P.FIT.modelnum=0;
end

% Segment
try
	handles.Segment = evalin('base','Segment');
catch
	handles.Segment = ones(handles.P.SEQ.stack_dim(1),handles.P.SEQ.stack_dim(2));
end

% Z_corrExt
try
    handles.Z_corrExt= evalin('base','Z_corrExt');
catch
    try
        handles.Z_corrExt= evalin('base','Z_uncorr');
    catch
        handles.Z_corrExt= evalin('base','Mz_stack');
    end
end

handles.mysize=size(handles.Z_corrExt);
try
    handles.Zlab = evalin('base','Zlab');
    handles.Zref=evalin('base','Zref');
    set(handles.Zlabstatus,'String','Zlab/ref created');
catch
    handles.Zlab=handles.Z_corrExt;
    handles.Zref.Amide=ones(handles.mysize);
    handles.Zref.NOE=ones(handles.mysize);
    handles.Zref.Amine=ones(handles.mysize);
    handles.Zref.MT=ones(handles.mysize);
    handles.Zref.Background=ones(handles.mysize);
    set(handles.Zlabstatus,'String','not loaded');
end
handles.Zlab_used=handles.Zlab;
handles.Zref_used=handles.Zref.Amide;


try
    handles.popt = evalin('base','popt');
catch
%     [handles.popt handles.P] = FIT_3D(handles.Z_corrExt,handles.Segment,handles.P,handles.Segment);
      handles.popt=ones(size(handles.Z_corrExt,1),size(handles.Z_corrExt,2),size(handles.Z_corrExt,3),17);
      handles.P.FIT.modelnum=0;
end

% dB0_stack
try 
    handles.dB0_stack = evalin('base','dB0_stack_ext');
catch
    try 
        handles.dB0_stack = evalin('base','dB0_stack_int');
    catch
        handles.dB0_stack = ones(handles.P.SEQ.stack_dim(1),handles.P.SEQ.stack_dim(2),handles.P.SEQ.stack_dim(3));
    end
end

% M0_stack
try
    handles.M0_stack = evalin('base','M0_stack');
catch
    handles.M0_stack = ones(handles.P.SEQ.stack_dim(1),handles.P.SEQ.stack_dim(2),handles.P.SEQ.stack_dim(3));
end

% T1map
try
    handles.T1map = evalin('base','T1map');
    handles.T1map = handles.T1map/1000;
catch
    handles.T1map = ones(size(handles.Z_corrExt,1),size(handles.Z_corrExt,2),size(handles.Z_corrExt,3));
end

% B1map
try
    handles.B1map = evalin('base','B1map');
catch
    handles.B1map=ones(handles.P.SEQ.stack_dim(1),handles.P.SEQ.stack_dim(2));
end

% extContrast
try
    handles.extContrast=evalin('base','extContrast');
    handles.extContrastflag=1;
catch
    handles.extContrast=ones(handles.P.SEQ.stack_dim(1),handles.P.SEQ.stack_dim(2));
    handles.extContrastflag=0;
end

handles.x_Zspec_ppm = handles.P.SEQ.w;

handles.Amidepos=find_nearest(handles.x_Zspec_ppm,3.5);
handles.Aminepos=find_nearest(handles.x_Zspec_ppm,2.2);
handles.NOEpos=find_nearest(handles.x_Zspec_ppm,-3.5);
handles.MTpos=find_nearest(handles.x_Zspec_ppm,-2);

handles.mysize=size(handles.Z_corrExt);

% Set default limits for plot of spectrum

if (min(handles.x_Zspec_ppm) < -8 && max(handles.x_Zspec_ppm) > 8)
    handles.xlim_axes_spec_2=[-8 8];  
else
    handles.xlim_axes_spec_2=[min(handles.x_Zspec_ppm) max(handles.x_Zspec_ppm)];
end
handles.ylim_axes_spec_2=[0 1.1];
set(handles.x_left,'String',num2str(handles.xlim_axes_spec_2(2)))
set(handles.x_right,'String',num2str(handles.xlim_axes_spec_2(1)))
set(handles.y_bottom,'String',num2str(handles.ylim_axes_spec_2(1)))
set(handles.y_top,'String',num2str(handles.ylim_axes_spec_2(2)))

% Set default limits for slice and offset

handles.freq_pos=1;
handles.slice=1;
set(handles.popupmenu1,'Value',1);
xlim=get(handles.axes1,'XLim');
ylim=get(handles.axes1,'YLim');
xx=xlim(2)-xlim(1);
yy=ylim(2)-ylim(1);

handles.clims=[-0.1 0.1];
set(handles.slider6,'Max',numel(handles.x_Zspec_ppm))
set(handles.slider6,'SliderStep',[1/(numel(handles.x_Zspec_ppm)-1) 1/(numel(handles.x_Zspec_ppm)-1)]);
set(handles.slider6,'Value',1);

u=handles.P.EVAL.upperlim_slices;
l=handles.P.EVAL.lowerlim_slices;
if l>=u u=l+1; end;
set(handles.slider9,'Max',u-l+1);
set(handles.slider9,'Min',1);
set(handles.slider9,'Value',1);
set(handles.slider9,'SliderStep',[ 1/(u-l) 1/(u-l) ]);
% Update handles structure
%if control was pressed
handles.ctrl =1;
handles.shift =0;

handles.ppp_old=1;
axes(handles.axes1);
handles.Stack = handles.Z_corrExt;  % initial stack is Z-spectrum
handles.clims=set_clims(handles.Stack(:,:,handles.slice,handles.freq_pos));
imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims);



guidata(hObject, handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% IMAGE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Zspec', 'Zspec_uncorr', 'T1map [s]','B1map', 'dB0map [ppm]','M0_stack','extContrast'});


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% select input to see in axes1: Z-stack, T1map, B1map....
axes(handles.axes1);
cla;
colorbar;
clear handles.Stack
popup_sel_index = get(hObject, 'Value');
handles.slice=get(handles.slider9, 'Value');

switch popup_sel_index
    case 1 % Stack=Z_corrExt
        handles.Z_corrExt= evalin('base','Z_corrExt');
        handles.Stack = handles.Z_corrExt;
    case 2 % Stack=Z_uncorr
        handles.Z_corrExt= evalin('base','Z_uncorr');
        handles.Stack = handles.Z_corrExt;
    case 3
        handles.Stack=double(handles.T1map);
        set(handles.slider6,'Value',1);
        set(handles.slider9,'Value',1);
        handles.slice=1;
        handles.freq_pos=1;
    case 4
        handles.Stack=double(handles.B1map);
        set(handles.slider6,'Value',1);
        set(handles.slider9,'Value',1);
        handles.slice=1;
        handles.freq_pos=1;
    case 5
        handles.Stack=double(handles.dB0_stack);
        set(handles.slider6,'Value',1);
        handles.freq_pos=1;
    case 6
        handles.Stack=double(handles.M0_stack);
        set(handles.slider6,'Value',1);
        set(handles.slider9,'Value',1);
        handles.freq_pos=1;
    case 7
        if (handles.extContrastflag==1)
            if (ndims(handles.extContrast)==2)
                handles.Stack(:,:,1,1)=double(handles.extContrast);
                set(handles.slider9,'Value',1);
            elseif (ndims(handles.extContrast)==3)
                handles.Stack(:,:,:,1)=double(handles.extContrast);
            elseif (ndims(handles.extContrast)==4)
                % Interpolate Zspec for Asymmetry analysis
                ext_size=size(handles.Z_corrExt);
                for k=1:ext_size(3)
                    for i=1:ext_size(1)
                        for j=1:ext_size(2)
                            if (isnan(handles.Segment(i,j)) == 0)
                                handles.extContrast_interp(i,j,k,:)= interp1(handles.P.SEQ.w,squeeze(handles.extContrast(i,j,k,:)),handles.x_Zspec_ppm,'linear');
                            else
                                handles.extContrast_interp(i,j,k,:)=NaN(numel(handles.x_Zspec_ppm),1);
                            end
                        end
                    end
                end
                handles.Stack=handles.extContrast_interp;
            end
        end
        set(handles.slider6,'Value',1);
        %         handles.Stack= handles.Stack/max(max(max( handles.Stack)));
end
handles.clims=set_clims(handles.Stack(:,:,handles.slice,handles.freq_pos));
imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims);
colorbar;
colormap jet;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% slider to change Offset in Z-spectrum
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% slider to change Offset in Z-spectrum
axes(handles.axes1);
j=round(get(hObject,'Value'));
handles.freq_pos=j;
set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.freq_pos)));
if handles.freq_pos<=size(handles.Stack,4) % if popt parameters are selected
    imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims);
end
colorbar;
guidata(hObject, handles);


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% slider to change slice
j=get(hObject,'Value');
set(handles.uipanel4,'Title',sprintf('slice: %f',j));
handles.slice=fix(j);
guidata(hObject, handles);
axes(handles.axes1);
if numel(size(handles.Stack))>3
    imagesc(squeeze(handles.Stack(:,:,handles.slice,handles.freq_pos)),handles.clims);
else
    imagesc(squeeze(handles.Stack(:,:,handles.slice)),handles.clims);
end;

colorbar;

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% slider to change slice
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popuppools.
function popuppools_Callback(hObject, eventdata, handles)

axes(handles.axes1);
popup=get(hObject,'Value');
handles.pool = popup;
switch popup
    case 1 %Amide
        handles.Zlab_used=handles.Zlab;
        handles.Zref_used=handles.Zref.Amide;
        set(handles.slider6,'Value',handles.Amidepos);
        set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.Amidepos)));
    case 2 %Amine
        handles.Zlab_used=handles.Zlab;
        handles.Zref_used=handles.Zref.Amine;
        set(handles.slider6,'Value',handles.Aminepos);
        set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.Aminepos)));
    case 3 %NOE
        handles.Zlab_used=handles.Zlab;
        handles.Zref_used=handles.Zref.NOE;
        set(handles.slider6,'Value',handles.NOEpos);
        set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.NOEpos)));
    case 4 %MT
        handles.Zlab_used=handles.Zlab;
        handles.Zref_used=handles.Zref.MT;
        set(handles.slider6,'Value',handles.MTpos);
        set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.MTpos)));
    case 5 %Raw
        try
            handles.Z_flipped; % does Z_flipped already exist
        catch
            [handles.Z_flipped] = calc_Z_flipped(handles.P,handles.Z_corrExt); %create it if not
        end
        handles.Zlab_used=handles.Z_corrExt;
        handles.Zref_used=handles.Z_flipped;
        set(handles.slider6,'Value',handles.Amidepos);
        set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.Amidepos)));
    case 6 %LDiff
         handles.Zlab_used=handles.Z_corrExt;
         handles.Zref_used=handles.Zref.Background;
         set(handles.slider6,'Value',handles.Amidepos);
         set(handles.uipanel3,'Title',sprintf('Offset= %f',handles.x_Zspec_ppm(handles.Amidepos)));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popuppools_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupcontrast.
function popupcontrast_Callback(hObject, eventdata, handles)

axes(handles.axes1);
popup=get(hObject,'Value');
handles.contrast = popup;
switch popup
    case 1 %MTR_LD
        handles.Stack=handles.Zref_used-handles.Zlab_used;
    case 2 %MTR_Rex
        handles.Stack=1./handles.Zlab_used-1./handles.Zref_used;
    case 3 %AREX
       for jj=1:numel(handles.x_Zspec_ppm)
            handles.Stack(:,:,handles.slice,jj)=(1./handles.Zlab_used(:,:,handles.slice,jj)-1./handles.Zref_used(:,:,handles.slice,jj))./handles.T1map(:,:,handles.slice);
       end
end
handles.freq_pos=round(get(handles.slider6,'Value'));
handles.clims=set_clims(handles.Stack(:,:,handles.slice,handles.freq_pos));
imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims);
colorbar;
colormap jet;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupcontrast_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Zlabbutton.
function Zlabbutton_Callback(hObject, ~, handles)
% load Zlab/Zref if they were not already in the workspace
clear handles.Zlab handles.Zref
[handles.Zlab, handles.Zref] = get_FIT_LABREF(handles.popt,handles.P,handles.Segment,handles.x_Zspec_ppm);
handles.Zref_used=handles.Zref.Background;
handles.Zlab_used=handles.Zlab;

set(handles.Zlabstatus,'String','Zlab/ref created');

axes(handles.axes1);
try
    imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims);
catch
    handles.Stack = handles.Z_corrExt;
end

colorbar

guidata(hObject, handles);


% --- Executes on selection change in popparameter.
function popparameter_Callback(hObject, eventdata, handles)
% shows images of popt-parameters in axes1
i=get(hObject,'Value');
axes(handles.axes1);
handles.Stack=squeeze(handles.popt(:,:,:,i));
img=handles.Stack(:,:,handles.slice);
handles.freq_pos=1;
handles.clims(1)=mean(mean(img(~isnan(img))))-mean(std(img(~isnan(img))));
handles.clims(2)=mean(mean(img(~isnan(img))))+mean(std(img(~isnan(img))));
imagesc(handles.Stack(:,:,handles.slice),handles.clims);
colorbar;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popparameter_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Modifier,'control')
    handles.ctrl=1;   
end;
if strcmp(eventdata.Modifier,'shift')
    if handles.shift==0
        handles.shift=1;
    else
        handles.shift=0;
    end;    
end;

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Change Colorbar of Image  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --- Executes on button press in radioref.
function radioref_Callback(hObject, eventdata, handles)

if get(hObject,'Value');
    clear handles.Stack
end;

axes(handles.axes1);
imagesc(R2,handles.clims);
guidata(hObject, handles);

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%axes1_ButtonDownFcn(hObject, eventdata, handles);
if handles.shift
axes(handles.axes1);    
    p=get(handles.axes1,'CurrentPoint');
    
    xlim=get(handles.axes1,'XLim');
    ylim=get(handles.axes1,'YLim');
    xx=xlim(2)-xlim(1);
    yy=ylim(2)-ylim(1);
    
    handles.ppp_old=handles.ppp_old-0.5*[xx yy];
    p=p(1,1:2);
    
    y=(4*(xx-p(1))/yy)^2;
    x=(p(2)-xx/2)/xx/10;
    handles.clims=[x*30*abs(y)-abs(y) x*30*abs(y)+abs(y)];

    if ndims(handles.Stack)==2
        imagesc(handles.Stack,handles.clims);
    elseif ndims(handles.Stack)==4
        imagesc(squeeze(handles.Stack(:,:,handles.slice,handles.freq_pos)),handles.clims);
    elseif ndims(handles.Stack)==3
        imagesc(squeeze(handles.Stack(:,:,handles.slice)),handles.clims);
    end;
    colorbar;
    colormap jet;
end;
guidata(hObject, handles);


function c=climsfunc(handles,A)
popup_sel_index = get(handles.popclims, 'Value');
CL=[-1 1;-0.2 0.2;0 15;0 1;-0.02 0.1;0 0.1;-0.1 0.1];

c=CL(popup_sel_index,:);

% --- Executes on selection change in popclims.
function popclims_Callback(hObject, eventdata, handles)

handles.clims=climsfunc(handles,handles.Stack);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popclims_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'-1 1', '-0.2 0.2','0 15','0 1','-0.02 0.1','0 0.1','-0.1 0.1',});


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
if (handles.ctrl==1)
    axes1_ButtonDownFcn(hObject, eventdata, handles);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% SPECTRUM  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% 'STR' is pressed inside the image (axis1)
% show spectrum of that pixel in axes2
if (handles.ctrl==1)
    p=get(handles.axes1,'CurrentPoint');
    asize=size(handles.Stack);
    y=uint16(p(1));
    x=uint16(p(3));
    if ((x>0) &&  (y>0) && (x<asize(1)) && (y<asize(2)))
        handles.x=x;
        handles.y=y;
        fprintf('Position: %g,%g \n',x,y);
        plot_Spectrum(handles);
    end
    
end
guidata(hObject, handles);



function plot_Spectrum(handles)
%plot spectrum in axes2 and broad spectrum in axes_broad
x=handles.x;
y=handles.y;

asize=size(handles.Stack);


    
    
    W(1,:)=handles.P.SEQ.w ; %für Stacksingle
    w(:,1)=x_for_plot(handles.P.SEQ.w);
    
    if (get(handles.popupmenu1, 'Value') == 5)
    
        Z=squeeze(handles.M0_stack(x,y,handles.slice,:));
        popt=squeeze(handles.popt(x,y,handles.slice,:));
    
    else 
        Z=squeeze(handles.Z_corrExt(x,y,handles.slice,:));
        popt=squeeze(handles.popt(x,y,handles.slice,:));
    end
    
    if (handles.P.FIT.modelnum > 1 && not(get(handles.popupmenu1, 'Value') == 5)) %value 5 is M0 stack 
        
        [f, fZi, f1, f2, f3, f4, f5, f6, g, g2, g3, g4, g5] = fitmodelfunc_ANA(popt,handles.P);
        
        axes(handles.axes_spec_2);
        cla;
       
        plot(handles.axes_spec_2,W,Z,'mo'); % plot datapoints
        hold on
                plot(handles.axes_spec_2,w,f(w),'-k'); % plot complete fit
        
        if(get(handles.button_fZi,'Value'))   % plot 1st Lorentzian (water)
            plot(handles.axes_spec_2,w,fZi(w),':m');
        end
        
        if (get(handles.peak_position,'Value')) % plot normal Lorentzians
            
            if(get(handles.button_pool1,'Value'))   % plot 1st Lorentzian (water)
                plot(handles.axes_spec_2,w,f1(w),':c');
            end
            
            if(get(handles.button_pool2,'Value'))
                plot(handles.axes_spec_2,w,f2(w),':b'); % plot 2nd Lorentzian (amide)
            end
            
            if(get(handles.button_pool3,'Value'))
                plot(handles.axes_spec_2,w,f3(w),':k'); % plot 3rd Lorentzian (NOE)
            end
            
            if(get(handles.button_pool4,'Value'))
                plot(handles.axes_spec_2,w,f4(w),':g'); % plot 4th Lorentzian (MT)
            end
            
            if(get(handles.button_pool5,'Value'))
                plot(handles.axes_spec_2,w,f5(w),':r'); % plot 5th Lorentzian (amine)
            end
            
            if(get(handles.button_pool6,'Value'))
                plot(handles.axes_spec_2,w,f6(w),':b'); % plot 6th Lorentzian
            end
            
        else % plot upside down Lorentzians
            
            
            if(get(handles.button_pool1,'Value'))   % plot 1st Lorentzian (water)
                plot(handles.axes_spec_2,w,fZi(w)-f1(w),':c');
            end
            
            if(get(handles.button_pool2,'Value'))
                plot(handles.axes_spec_2,w,fZi(w)-f2(w),':b'); % plot 2nd Lorentzian (amide)
            end
            
            if(get(handles.button_pool3,'Value'))
                plot(handles.axes_spec_2,w,fZi(w)-f3(w),':k'); % plot 3rd Lorentzian (NOE)
            end
            
            if(get(handles.button_pool4,'Value'))
                plot(handles.axes_spec_2,w,fZi(w)-f4(w),':g'); % plot 4th Lorentzian (MT)
            end
            
            if(get(handles.button_pool5,'Value'))
                plot(handles.axes_spec_2,w,fZi(w)-f5(w),':r'); % plot 5th Lorentzian (amine)
            end
            
            if(get(handles.button_pool6,'Value'))
                plot(handles.axes_spec_2,w,fZi(w)-f6(w),':b'); % plot 6th Lorentzian
            end
            
        end
        
        hold off
        
        % full Z-spectrum
        plot (handles.axes_spec_broad,W,Z,'mo',w,f(w),'-k',w,fZi(w),':m',w,f1(w),':c',w,f2(w),':b',w,f3(w),':k',w,f4(w),':g',w,f5(w),':r');
        
    else % no fit exists
        
        axes(handles.axes_spec_2);
        cla;
       
        plot(handles.axes_spec_2,W,Z,'ko-');  
        hold on
        % plot datapoints
        %plot(handles.axes_spec_2,W,Z,'k'); % plot datapoints
        hold off
        
        % full Z-spectrum
       % axes(handles.axes_spec_broad);
        plot (handles.axes_spec_broad,W,Z,'k');
        
    end
    
    % plot settings
    
    if (get(handles.reverseAx2,'Value'))
        set(handles.axes_spec_2,'XDir','reverse');
    else
        set(handles.axes_spec_2,'XDir','normal');
    end
    
    if (get(handles.reverseAx2,'Value'))
        set(handles.axes_spec_broad,'XDir','reverse');
    else
        set(handles.axes_spec_broad,'XDir','normal');
    end
    
    set(handles.axes_spec_2,'YLim',handles.ylim_axes_spec_2);
    set(handles.axes_spec_2,'XLim',handles.xlim_axes_spec_2);
    
    set(handles.axes_spec_broad,'YLim',[min(Z)-0.05,max(Z)+0.05]);
    set(handles.axes_spec_broad,'XLim',[min(handles.P.SEQ.w),max(handles.P.SEQ.w)]);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% SPECTRUM PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_left_Callback(hObject, eventdata, handles)
% changes lower/upper limit for x-axis of Z-spectrum (depends if reverse or
% not)
x_left_str=get(hObject,'String');
x_left=str2double(x_left_str);
if (get(handles.reverseAx2,'Value'))
    handles.xlim_axes_spec_2=[handles.xlim_axes_spec_2(1) x_left];
else
    handles.xlim_axes_spec_2=[x_left handles.xlim_axes_spec_2(2)];
end
set(handles.axes_spec_2,'XLim',handles.xlim_axes_spec_2);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function x_left_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_right_Callback(hObject, eventdata, handles)
% changes lower/upper limit for x-axis of Z-spectrum (depends if reverse or
% not)
x_right_str=get(hObject,'String');
x_right=str2double(x_right_str);

if (get(handles.reverseAx2,'Value'))
    handles.xlim_axes_spec_2=[x_right handles.xlim_axes_spec_2(2)];
else
    handles.xlim_axes_spec_2=[handles.xlim_axes_spec_2(1) x_right];
end
set(handles.axes_spec_2,'XLim',handles.xlim_axes_spec_2);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function x_right_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_bottom_Callback(hObject, eventdata, handles)
% edit lower limit of Z-spectrum
y_bottom_str=get(hObject,'String');
y_bottom=str2double(y_bottom_str);
handles.ylim_axes_spec_2=[y_bottom handles.ylim_axes_spec_2(2)]; 
set(handles.axes_spec_2,'YLim',handles.ylim_axes_spec_2);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function y_bottom_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function y_top_Callback(hObject, eventdata, handles)
% edit upper limit of Z-spectrum
y_top_str=get(hObject,'String');
y_top=str2double(y_top_str);
handles.ylim_axes_spec_2=[handles.ylim_axes_spec_2(1) y_top]; 
set(handles.axes_spec_2,'YLim',handles.ylim_axes_spec_2);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function y_top_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reverseAx2.
function reverseAx2_Callback(hObject, eventdata, handles)
%switch values of the Offset limits and plot then
offset1_str=get(handles.x_left,'String');
offset1=str2double(offset1_str);
offset2_str=get(handles.x_right,'String');
offset2=str2double(offset2_str);
set(handles.x_left,'String',offset2_str);
set(handles.x_right,'String',offset1_str);
plot_Spectrum(handles);
guidata(hObject, handles);

% --- Executes on button press in button_fZi.
function button_fZi_Callback(hObject, eventdata, handles)
% toggle visibilty of Zbase
plot_Spectrum(handles);


% --- Executes on button press in button_pool1.
function button_pool1_Callback(hObject, eventdata, handles)
% toggle visibilty of pool1 (water)
plot_Spectrum(handles);


% --- Executes on button press in button_pool2.
function button_pool2_Callback(hObject, eventdata, handles)
% toggle visibilty of pool2 (amide)
plot_Spectrum(handles);


% --- Executes on button press in button_pool3.
function button_pool3_Callback(hObject, eventdata, handles)
% toggle visibilty of pool3 (NOE)
plot_Spectrum(handles);


% --- Executes on button press in button_pool4.
function button_pool4_Callback(hObject, eventdata, handles)
% toggle visibilty of pool4 (MT)
plot_Spectrum(handles);


% --- Executes on button press in button_pool5.
function button_pool5_Callback(hObject, eventdata, handles)
% toggle visibilty of pool5 (Amine)
plot_Spectrum(handles);


% --- Executes on button press in button_pool6.
function button_pool6_Callback(hObject, eventdata, handles)
% toggle visibilty of pool6
plot_Spectrum(handles);


% --- Executes on button press in peak_position.
function peak_position_Callback(hObject, eventdata, handles)
% toggle Lorentzian Peaks from bottom or Top
plot_Spectrum(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% SAVE/LOAD....ANYTHING ELSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Outputs from this function are returned to the command line.
function varargout = imgui_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on button press in full_butt.
function full_butt_Callback(hObject, eventdata, handles)
% enlarge and save image in axes1 (buttonname: Fullscreen)
if ndims(handles.Stack)==2
    figure, imagesc(handles.Stack,handles.clims);
    axis image
elseif ndims(handles.Stack)==4
    figure,imagesc(squeeze(handles.Stack(:,:,handles.slice,handles.freq_pos)),handles.clims);
    axis image
elseif ndims(handles.Stack)==3
    figure,imagesc(squeeze(handles.Stack(:,:,handles.slice)),handles.clims);
    axis image
else fprintf('dimdim');
end;
set(gca,'XTickLabel',{});
set(gca,'YTickLabel',{});
colorbar;
colormap jet;

%Save image as .png and .fig
pool = handles.pool;
contrast = handles.contrast;
contraststring={'MTR_LD' 'MTR_Rex' 'AREX' 'ASYM'};
poolstring={'Amide' 'Amine' 'NOE' 'MT'};
completestring=strcat(poolstring{pool},contraststring{contrast});
saveas(gcf,completestring,'png')
saveas(gcf,completestring,'fig')

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% slider to change slice
[file,path]= uiputfile('*.mat','Save Workspace As');

evalin('base', sprintf('save([%s %s])',file,path) );


% --------------------------------------------------------------------
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]= uigetfile('*.mat','Load Workspace');
evalin('base', sprintf('load(%s)',file) );


% --------------------------------------------------------------------
function axes1_context_Callback(hObject, eventdata, handles)
% hObject    handle to axes1_context (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiolorentz.


% --- Executes on button press in savepic_butt.
function savepic_butt_Callback(hObject, eventdata, handles)
% hObject    handle to savepic_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg('Name the current stack!','save current stack',1,{'Stack_gui'});

assignin('base',answer{1},handles.Stack);

handles.clims=get(handles.axes1,'CLim');
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% ROI ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function ROI_asym_Callback(hObject, eventdata, handles)
% ROI tool showing mean Spectrum w/o errorbars and the asymmetry in the
% selected ROIs

deffi=get(get(handles.axes1,'Children'),'CData');
choice = questdlg('New or saved ROI', ...
    'Roi', ...
    'New','Saved','Saved');
% Handle response
switch choice
    case 'Saved'
        try
            ROI_def= evalin('base','ROI_def');
            noROIs=size(ROI_def,3);
        end;
    case 'New'
        prompt={'Number of ROIs','shape ((free),rect, ellipse, poly): '};
        dlg_title='Enter number of ROIs:';
        defaultans={'2','free'};
        num_lines=1;
%         answer = inputdlg('Enter number of ROIs:','Number of ROIs',1,{'2'},'shape','free',{'free'});
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        noROIs=str2double(answer{1});
        shape=answer{2};
        [ROI_def]= ROI_HD (deffi,noROIs,handles.mysize,handles.clims,shape);
        assignin('base','ROI_def',ROI_def);
end;

for ii=1:noROIs
     
    % for z-spec
    for jj=1:numel(handles.P.SEQ.w)

        Zhelp=handles.Z_corrExt(:,:,handles.slice,jj);     
        ROI_data{ii}.Zmean(jj)=mean(Zhelp(ROI_def(:,:,ii)>0));
        ROI_data{ii}.Zstd(jj)=std(Zhelp(ROI_def(:,:,ii)>0));
        ROI_data{ii}.ROI_def=ROI_def(:,:,ii);

    end;
    ROI_data{ii}.ASYMmean = calc_Z_flipped_1D(handles.P,ROI_data{ii}.Zmean) - ROI_data{ii}.Zmean;
    
    ROI_data{ii}.x=handles.P.SEQ.w;
    % for asymetry
    ROI_data{ii}.xasym=handles.P.SEQ.w(handles.P.SEQ.w>=0);
    
end

figure,
%% Plot location of ROIs in selected image
subplot(2,2,4)
imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims), axis image;
hold on;
for ii=1:numel(ROI_data)
    contour(ROI_data{ii}.ROI_def,1,'m-','LineWidth',2);
    [yy xx]=find(ROI_data{ii}.ROI_def);
    t_h=text(fix(max(xx)),fix(min(yy)),'# ');
    set(t_h,'String',sprintf('ROI # %d',ii),'BackgroundColor',[1 1 1])
    leg{ii}=sprintf('# ROI %d',ii);
end
set(gca,'xtick',[],'ytick',[]);
clear yy xx

%% select restriction points for errorbarplot (else errorbars look terrible)

if get(handles.reverseAx2,'Value')
    lower_offset_str=get(handles.x_right,'String');
    lower_offset=str2double(lower_offset_str);
    higher_offset_str=get(handles.x_left,'String');
    higher_offset=str2double(higher_offset_str);
else
    lower_offset_str=get(handles.x_left,'String');
    lower_offset=str2double(lower_offset_str);
    higher_offset_str=get(handles.x_right,'String');
    higher_offset=str2double(higher_offset_str);
end

x_start=find_nearest(handles.P.SEQ.w,lower_offset);
x_stop=find_nearest(handles.P.SEQ.w,higher_offset);
%% Plot Z-spectra with errorbars

subplot(2,2,1)
for ii=1:numel(ROI_data)
    errorbar(handles.P.SEQ.w(x_start:x_stop),ROI_data{ii}.Zmean(x_start:x_stop),ROI_data{ii}.Zstd(x_start:x_stop),'Color',cl(ii,numel(ROI_data)));
    hold on
end

set(gca,'XLIM',[lower_offset higher_offset]);
set(gca,'YLIM',handles.ylim_axes_spec_2);

if get(handles.reverseAx2,'Value')
    set(gca,'XDir','reverse');
end
title('Mean Z-spectrum with std in ROI');

%% Plot Z-spectra without errorbars

subplot(2,2,2)
for ii=1:numel(ROI_data)
    plot(handles.P.SEQ.w,ROI_data{ii}.Zmean,'Color',cl(ii,numel(ROI_data)),'Marker','+');
    hold on;
end
legend(leg, 'Location', 'Southeast');

set(gca,'XLIM',[lower_offset higher_offset]);
set(gca,'YLIM',handles.ylim_axes_spec_2);

if get(handles.reverseAx2,'Value')
    set(gca,'XDir','reverse');
end

title('Mean Z-spectrum in ROI');
%% Plot asymmetry analysis of ROIs

subplot(2,2,3)
for ii=1:numel(ROI_data)
    plot(ROI_data{ii}.x,ROI_data{ii}.ASYMmean,'Color',cl(ii,numel(ROI_data)));
    hold on
end

set(gca,'XLIM',[0 higher_offset]);

legend(leg, 'Location', 'Northeast');
title('Asymmetry in ROI');

assignin('base','ROI_data',ROI_data);

guidata(hObject, handles);

% --------------------------------------------------------------------
function ROI_data_Callback(hObject, eventdata, handles)
% gives out histogram, mean and std of the values in the ROI(s) of the current
% image

deffi=get(get(handles.axes1,'Children'),'CData');
choice = questdlg('New or saved ROI', ...
    'Roi', ...
    'New','Saved','Saved');
% Handle response
switch choice
    case 'Saved'
        try
            ROI_def= evalin('base','ROI_def');
            noROIs=size(ROI_def,3);
        end
    case 'New'
        answer = inputdlg('Enter number of ROIs:','Number of ROIs',1,{'2'});
        noROIs=str2double(answer);
        [ROI_def]= ROI_HD (deffi,noROIs,handles.mysize,handles.clims);
        assignin('base','ROI_def',ROI_def);
end;

for ii=1:noROIs
    ROI_data{ii}.ROI_def(:,:)=ROI_def(:,:,ii);
    if (ndims(handles.Stack)==4)
        temp_img=handles.Stack(:,:,handles.slice,handles.freq_pos);
    elseif (ndims(handles.Stack)==3)
        temp_img=handles.Stack(:,:,handles.slice);
    elseif(ndims(handles.Stack)==2)
        temp_img=handles.Stack(:,:);
    end
    ROI_data{ii}.mean=mean(temp_img(ROI_def(:,:,ii)>0));
    ROI_data{ii}.std=std(temp_img(ROI_def(:,:,ii)>0));
end
figure
subplot(1,2,2),
imagesc(handles.Stack(:,:,handles.slice,handles.freq_pos),handles.clims), hold on;
for ii=1:numel(ROI_data)
    contour(ROI_data{ii}.ROI_def,1,'m-');
    [y x]=find(ROI_data{ii}.ROI_def);
    t_h=text(fix(max(x)),fix(min(y)),'# ');
    set(t_h,'String',sprintf('ROI # %d',ii),'BackgroundColor',[1 1 1])
    leg{ii}=sprintf('# ROI %d',ii);
    allmeans(ii)=ROI_data{ii}.mean;
    allSTDs(ii)=ROI_data{ii}.std;
end;
subplot(1,2,1),
errorbar(allmeans, allSTDs, 's');
set(gca, 'XTick', 1:numel(ROI_data), 'XTickLabel', leg);

% Histogram Data
figure,
for jj=1:noROIs
    temp_img=handles.Stack(:,:,handles.slice,handles.freq_pos);
    histo_data{jj}=reshape(temp_img(ROI_def(:,:,jj)>0),1,sum(sum(ROI_def(:,:,jj))));
    if noROIs==3
        subplot(3,1,jj);
    else
        subplot(floor(sqrt(noROIs)),ceil(sqrt(noROIs)),jj);
    end
    hist(histo_data{jj},20);
    title(leg{jj});
end

assignin('base','ROI_data',ROI_data);


% --- Executes on button press in ROIspec_button.
function ROIspec_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROIspec_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_asym_Callback(hObject, eventdata, handles)


% --- Executes on button press in ROIimg_button.
function ROIimg_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROIimg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_data_Callback(hObject, eventdata, handles)
