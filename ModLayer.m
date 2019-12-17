% ModLayer Visualizes a 3D reference image and an adjustable 3D image,
% allowing the user to simultaneously scroll, zoom, pan, and modify regions
% through interactive drawing on the image stacks.
%
%-----------------------------------------------------------------------------
%
%   Imad Hanhan and Michael D. Sangid, Purdue University, 2019.
%
%-----------------------------------------------------------------------------
%
%   ModLayer(reference_3D_image) opens the ModLayer gui with the stacks of
%   images in reference_3D_image visualized on the left, and the stacks of
%   the global variable 'data_modify' visualized on the right. Global
%   variable 'data_modify' must be defined prior to running ModLayer.
%
%       For example:
%           global data_modify
%           data_modify=adjustable_3D_data;
%           ModLayer(reference_3D_image)
%
%	ModLayer keyboard shortcuts:
%	Note: When zoom/pan/cursor are active, ModLayer's keyboard shortcuts
%	are not. You must unclick zoom/pan/cursor to allow ModLayer's keyboard 
%	shortcuts to work. Otherwise, MATLAb will assubme keyboard shortcuts
%	for it's built-in zoom/pan/cursor functions.
%
%   	Plus Sign         +     zoom in
%   	Hyphen            -     zoom out
%   	Page Up         pagup   scroll to next slice
%   	Page Down      pagdown  scroll to previous slice
%   	Left Arrow              pan left
%   	Right Arrow             pan right
%   	Up Arrow                pan up
%   	Down Arrow              pan down
%   	Backslash         \     modify
%
%-----------------------------------------------------------------------------
% 
% If you use this tool and your work results in a publication, please cite as:
%
% Hanhan, Imad, and Michael D. Sangid. "ModLayer: A MATLAB GUI Drawing
%      Segmentation Tool for Visualizing and Classifying 3D Data." Integrating
%      Materials and Manufacturing Innovation (2019): 1-8.
%
%-----------------------------------------------------------------------------


function varargout = ModLayer(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ModLayer_OpeningFcn, ...
                   'gui_OutputFcn',  @ModLayer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ModLayer is made visible.
function ModLayer_OpeningFcn(hObject, eventdata, handles, varargin)

global data_modify %brings in global data_modify from the workspace

if isempty(data_modify)==1 %check if data_modify exists in workspace
    error('Global variable data_modify not instantiated in workspace.')
end

data1=varargin{1}; %bring data1 from user input

if size(data1)~=size(data_modify) %check that the sizes match
    warning('Size of 3D Stacked images does not match data_modify.') %warn the user
end

set(handles.pushmodify,'string','MODIFY','ForegroundColor', [0.6350 0.0780 0.1840], 'TooltipString', 'Press `/` to modify'); %initialize toggle button to be off to start with
set(handles.uipanel1,'ForegroundColor', [0.6350 0.0780 0.1840], 'ShadowColor',[0.6350 0.0780 0.1840] ); %change panel colors to red

z=1; %intializes as slice = first slice for visualizaing both datasets

handles.data1min=min(data1(:));
handles.data2min=min(data_modify(:));
handles.data1max=max(data1(:));
handles.data2max=max(data_modify(:));
handles.undoslicenumber=1;
handles.undoslice=data_modify(:,:,1);

imagesc(handles.axes1, data1(:,:,z)); %visualize data1
caxis(  handles.axes1, [handles.data1min handles.data1max]);
colormap(handles.axes1, 'gray') %set the colormap for data1 as gray

% Custom Jet White colormap:
myColorMap = jet(256); %colormap used for indexing, where 0 is white
myColorMap(1,:) = 1; %set first value as white

imagesc(handles.axes2, data_modify(:,:,z)); %asigns the second window data2
colormap(handles.axes2, myColorMap) %sets the default colormap as jetwhite
caxis(  handles.axes2, [handles.data2min handles.data2max]);

% Set output objects
handles.output = hObject;

handles.data1=data1; %store data1

s1=size(data1); %the size of the data
s2=size(data_modify); %the size of data_modify, which should match and was warned above

if size(s1)<3 %if it's a 2D image
    s1(3)=1; %set the third dimension to 1
    slider_step1=0; %set the slider step to 0, will make slider bar not do anything
else
    slider_step1=1/(s1(3)-1); %otherwise, set the slider bar to a correct stepsize
end

if size(s2)<3 %if data_modify is a 2D image
    s2(3)=1; %set the third dimension to 1
    slider_step2=0;%set the slider step to 0, will make slider bar not do anything
else
    slider_step2=1/(s2(3)-1);%otherwise, set the slider bar to a correct stepsize
end

%store sizes
handles.size1=s1; %store the size of the reference image
handles.size2=s2; %store the size of data_modify

set(handles.slider1, 'min',1); %set the min left slider to 1
set(handles.slider1, 'max',s1(3)); %set the max left slider to the max of the number of layers
set(handles.slider1, 'Value', 1); %set slider value set to 1
set(handles.slider1, 'SliderStep', [slider_step1 , slider_step1 ]); %set the slider step
set(handles.text2, 'String', num2str(s1(3))) %the text box for the max layer
set(handles.text3, 'String', num2str(1)) %the text box for the min layer

%repeat for data_modify
set(handles.slider2, 'min',1);%set the min left slider to 1
set(handles.slider2, 'max',s2(3));%set the max left slider to the max of the number of layers
set(handles.slider2, 'Value', 1);%set slider value set to 1
set(handles.slider2, 'SliderStep', [slider_step2 , slider_step2 ]);%set the slider step
set(handles.text9, 'String', num2str(s2(3)))%the text box for the max layer
set(handles.text10, 'String', num2str(1))%the text box for the min layer


%Colormapr options
set(handles.popupmenu1, 'Value', 10) %set the colormap option to 10, gray
set(handles.popupmenu2, 'Value', 18) %set the colormap option to 18, JetWhite

set(handles.pushbutton3,'Enable','off'); %undo button disabled

guidata(hObject, handles);% Update handles structure

% --- Outputs from this function are returned to the command line.
function varargout = ModLayer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider 1 movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data_modify %bring in and update data_modify

popmv1=get(handles.popupmenu1,'Value'); %get the user's selected colormap choice, left
popmv2=get(handles.popupmenu2,'Value'); %get the user's selected colormap choice, right
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %list out the colormap options

z1=get(handles.slider1,'Value'); %get left slider value of data1

xlim = get(handles.axes1, 'XLim'); %get the X axes location (in case the user has zoomed or panned)
ylim = get(handles.axes1, 'YLim'); %get the Y axes location (in case the user has zoomed or panned)

%get data1
data1=handles.data1;

%plot image1 for data1
imagesc(handles.axes1, data1(:,:,uint32(z1))); %plot the desired slice
caxis(  handles.axes1, [handles.data1min handles.data1max]);
set(handles.edit2, 'String', num2str(uint32(z1))); %set the slider text box to the slice
if popmv1<18 %if using a default colormap
    colormap(handles.axes1, options{popmv1}); %set the colormap
elseif popmv1==18 %is uing the custom colormap
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1; %set white
    colormap(handles.axes1,myColorMap); %set jetwhite
end

%plot image 2
if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    %do nothing, user is only changing the left image
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    set(handles.slider2, 'Value', z1); %srt the right slider to match left slider
    set(handles.edit3, 'String', num2str(uint32(z1))); %srt left slider text to match layer
    imagesc(handles.axes2, data_modify(:,:,uint32(z1))); %display the image
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if user selected a default colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %is the user selected the custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set colormap as JetWhite
    end
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim); %zoom/pan data1 to match user selection
    set(handles.axes1, 'YLim', ylim); %zoom/pan data1 to match user selection
    set(handles.axes2, 'XLim', xlim); %zoom/pan data_modify to match user selection
    set(handles.axes2, 'YLim', ylim); %zoom/pan data_modify to match user selection
    linkaxes([handles.axes1,handles.axes2],'xy') %link axes
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);

end

% --- Executes on slider 2 movement.
function slider2_Callback(hObject, eventdata, handles)

global data_modify %bring in/update data_modify

popmv1=get(handles.popupmenu1,'Value'); %get colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %import colormap options

xlim = get(handles.axes1, 'XLim'); %get the xlim from data1
ylim = get(handles.axes1, 'YLim'); %get the ylim from data1

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    z2=get(handles.slider2,'Value'); %get the right slider value
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %set the data_modify image to the new layer
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap choice
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if jetwhite colormap choice
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
    end
    set(handles.edit3, 'String', num2str(uint32(z2)));
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1;%get data1
    z2=get(handles.slider2,'Value'); %get the z location of the right slider
    imagesc(handles.axes1, data1(:,:,uint32(z2)));
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18
        colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
    elseif popmv1==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set jetwhite as colormap
    end
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %display the selected slice of data_modify
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if standard matlab colormap 
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if jetwhite is selected
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
    end
    set(handles.edit2, 'String', num2str(uint32(z2))); %set the left scroll text box to the slice
    set(handles.edit3, 'String', num2str(uint32(z2))); %set the right scroll text box to the slice
    set(handles.slider1, 'Value', z2); %set the scroll bar value - btw hope you're having a good day!
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off') %turn of linking axes
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim); %adjust x-axes on left on new slice
    set(handles.axes1, 'YLim', ylim); %adjust y-axes on left on new slice
    set(handles.axes2, 'XLim', xlim); %adjust x-axes on right on new slice
    set(handles.axes2, 'YLim', ylim); %adjust y-axes on right on new slice
    linkaxes([handles.axes1,handles.axes2],'xy') %link the axes
end


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in checkbox1 Link XY
function checkbox1_Callback(hObject, eventdata, handles)
%gets the current xlim and ylim of left image
if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off') %unlink axes
elseif get(handles.checkbox1, 'Value') == 1 %if linking xy axes
    xlim = get(handles.axes1, 'XLim'); %get the x-axes of left image
    ylim = get(handles.axes1, 'YLim'); %get the y-axes of left image

    set(handles.axes1, 'XLim', xlim); %set the x-axes of left image
    set(handles.axes1, 'YLim', ylim); %set the y-axes of left imags
    set(handles.axes2, 'XLim', xlim); %set the x-axes of right image
    set(handles.axes2, 'YLim', ylim); %set the y-axes of right image
    linkaxes([handles.axes1,handles.axes2],'xy') %link the axes
end

% --- Executes on button press in checkbox2 Link Z
function checkbox2_Callback(hObject, eventdata, handles)

global data_modify %bring/update in data_modify
z1=get(handles.slider1,'Value'); %get slice number of left image

popmv2=get(handles.popupmenu2,'Value'); %get colormap selection
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options

imagesc(handles.axes2, data_modify(:,:,uint32(z1))); %plot data_modify at matching slice on right image
caxis(  handles.axes2, [handles.data2min handles.data2max]);
if popmv2<18 %if standard matlab colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
end
    
set(handles.slider2, 'Value', z1); % set the right slider to match the left slider
set(handles.edit3, 'String', num2str(uint32(z1))); %set the right text box of slice # to match

% --- Executes on selection change in popupmenu for colormap on left image.
function popupmenu1_Callback(hObject, eventdata, handles)

popmv=get(hObject,'Value'); %pop menu value of colormap
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options
if popmv<18 %if standard colormap
    colormap(handles.axes1, options{popmv}); %set the colormap
elseif popmv==18 %if custom colormap
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes1,myColorMap); %set jetwhite
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu colormap on right image.
function popupmenu2_Callback(hObject, eventdata, handles)

popmv=get(hObject,'Value'); %pop menu value of colormap
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options
if popmv<18 %if standard colormap
    colormap(handles.axes2, options{popmv}); %set the colormap
elseif popmv==18 %if custom colormap
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes2,myColorMap); %set the colormap to jetwhite
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushmodify.
function pushmodify_Callback(hObject, eventdata, handles)

global data_modify %bring in and update data_modify

set(hObject,'Interruptible', 'on');

popmv2=get(handles.popupmenu2,'Value'); %pop menu colormap value selection on right image
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ...
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options
z1=uint32(get(handles.slider1,'Value')); %get slice number of data1
z2=uint32(get(handles.slider2,'Value')); %get slice number of data_modify
xlim = get(handles.axes1, 'XLim'); %get x-axes of left image
ylim = get(handles.axes1, 'YLim'); %get y-axes of left image

%The user will not be able to do anything else, so all controls
%need to be disbabled:
allhandleArray = [handles.popupmenu3, handles.popupmenu4, handles.edit1,handles.pushmodify];
% Set them all disabled.
set(allhandleArray, 'Enable', 'off');
set(handles.uipanel1,'ForegroundColor', [0, 0.5, 0], 'ShadowColor',[0, 0.5, 0] ); %change panel colors to green

axes_number=get(handles.popupmenu3,'Value'); %pop menu value for drawing on the left ir right image

popmv4=get(handles.popupmenu4,'Value'); %pop menu for continuous or single

value_to_impose=str2double(get(handles.edit1,'String')); %the segmentation value to impose on the image

if value_to_impose > handles.data2max
    handles.data2max=value_to_impose; %update max data_modify in case user has changed max value
    guidata(hObject,handles); %Update handles
elseif value_to_impose < handles.data2min
    handles.data2min=value_to_impose; %update min data_modify in case user has changed min value
    guidata(hObject,handles); %Update handles
end
        
if popmv4 == 1 %user is in single mode
    
    handles.undoslicenumber=z2; %the slice number for undoing
    handles.undoslice=data_modify(:,:,z2); %the slice for undoing
    
    if axes_number==2
        %bring text box with instructions
        set(handles.text17, 'Visible', 'on','String', ['Draw on the left image to impose a multi-class segmentation value of ', get(handles.edit1,'String'), ' on the right image. To cancel, press Esc.']);
        hFH = imfreehand(handles.axes1); %tasks user to free hand on axes1
    elseif axes_number==1
        %bring text box with instructions
        set(handles.text17, 'Visible', 'on','String', ['Draw on the right image to impose a multi-class segmentation value of ', get(handles.edit1,'String'), ' on the right image. To cancel, press Esc.']);
        hFH = imfreehand(handles.axes2); %tasks user to free hand on axes2
    end

    % At this point the user will draw on the image and the program will wait
    xlim = get(handles.axes1, 'XLim'); %get x-axes of left image, in case user zoomed or panned
    ylim = get(handles.axes1, 'YLim'); %get y-axes of left image, in case user zoomed or panned
    % Once drawing is done (click is released), or the user has pressed ESC
    if isempty(hFH)
        % User pushed escape button and didn't make a modification
%         set(hObject,'string','MODIFY','ForegroundColor','red'); %set text from Modify ON -> MODIFY in red
        set(allhandleArray, 'Enable', 'on'); %bring back modify-related tools
        set(handles.text17, 'Visible', 'off'); %remove the text instructions
        set(handles.uipanel1,'ForegroundColor', [0.6350 0.0780 0.1840], 'ShadowColor',[0.6350 0.0780 0.1840] ); %change panel colors back to red
        
    else
        mask = hFH.createMask(); %create a mask from the drawing
        
        % Get value to impose on mask from user input:
        image=data_modify(:,:,z2); %save the image for imposing mask
        image(mask)=(value_to_impose); %Update segmentation value on image
        
        data_modify(:,:,z2)=image; %update slice with the modifief image
        
        imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %display the updated image on data_modify
        caxis(  handles.axes2, [handles.data2min handles.data2max]);
        
        if popmv2<18 %if the colormap
            colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
        elseif popmv2==18
            myColorMap = jet(256); %colormap used for indexing, where 0 is white
            myColorMap(1,:) = 1;
            colormap(handles.axes2,myColorMap); %set the colormap to jetwhite
        end
        
        if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
            linkaxes([handles.axes1,handles.axes2],'off')
        elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
            set(handles.axes1, 'XLim', xlim); %set x-axes left image
            set(handles.axes1, 'YLim', ylim); %set y-axes left image
            set(handles.axes2, 'XLim', xlim); %set x-axes right image
            set(handles.axes2, 'YLim', ylim); %set y-axes right image
            linkaxes([handles.axes1,handles.axes2],'xy') %link the axes
        end
        
        guidata(hObject,handles); %Update handles
        % Set them all enabled.
        set(allhandleArray, 'Enable', 'on'); %bring back modify-related tools
        set(handles.pushbutton3, 'Enable', 'on'); %enable undo button
        set(handles.text17, 'Visible', 'off'); %remove the text instructions
        set(handles.uipanel1,'ForegroundColor', [0.6350 0.0780 0.1840], 'ShadowColor',[0.6350 0.0780 0.1840] ); %change panel colors back to red
  
    end
elseif popmv4 == 2 %user is in continuous mode
    %Bring in data1:
    data1=handles.data1;
    
    handles.undoslicenumber=z2; %the slice number for undoing (if the user exits right away)
    handles.undoslice=data_modify(:,:,z2); %current slice for undoing (if the user exits right away)
    
    if axes_number==2
        %bring text box with instructions
        set(handles.text17, 'Visible', 'on','String', ['Continuous mode: draw on the left image to impose a multi-class segmentation value of ', get(handles.edit1,'String'), ' on the right image. When finished, press Esc.']);
    elseif axes_number==1
        %bring text box with instructions
        set(handles.text17, 'Visible', 'on','String', ['Continuous mode: draw on the right image to impose a multi-class segmentation value of ', get(handles.edit1,'String'), ' on the right image. When finished, press Esc.']);
    end

    while popmv4 == 2 %start continuous mode 
        % Update x and y position in case user has zoomed or panned: 
        
        if axes_number==2
            hFH = imfreehand(handles.axes1); %tasks user to free hand on axes1
        elseif axes_number==1
            hFH = imfreehand(handles.axes2); %tasks user to free hand on axes2
        end
        xlim = get(handles.axes1, 'XLim'); %get x-axes of left image
        ylim = get(handles.axes1, 'YLim'); %get y-axes of left image 
                   
        % At this point the user will draw on the image and the program will wait
        guidata(hObject,handles); %Update handles in case modify mode is exited prematurely
        % Once drawing is done (click is released), or the user has pressed ESC
        if isempty(hFH)
            % User pushed escape button and they are done         
            % Set them all disabled.
            set(allhandleArray, 'Enable', 'on'); %bring back modify related buttons
            set(handles.pushbutton3, 'Enable', 'on'); %bring back undo button
            set(handles.text17, 'Visible', 'off'); %remove the text instructions
            set(handles.uipanel1,'ForegroundColor', [0.6350 0.0780 0.1840], 'ShadowColor',[0.6350 0.0780 0.1840] ); %change panel colors back to red
%             handles.data2min=min(data_modify(:)); %update min data_modify in case user has changed min value
%             handles.data2max=max(data_modify(:)); %update max data_modify in case user has changed max value
%             guidata(hObject,handles); %Update handles to include updated min and max
            break %exit the while loop
        else
            
            mask = hFH.createMask(); %create a mask from the drawing
            handles.undoslicenumber=z2; %update slice number for undoing
            handles.undoslice=data_modify(:,:,z2); %update the current slice for undoing
            % Get value to impose on mask from user input:
            image=data_modify(:,:,z2); %save the image for imposing mask
            image(mask)=(value_to_impose); %Update segmentation value on image
            
            data_modify(:,:,z2)=image; %update slice with the modifief image
            
            imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %display the updated image on data_modify
            caxis(  handles.axes2, [handles.data2min handles.data2max]);
            
            if axes_number==2
                imagesc(handles.axes1, data1(:,:,uint32(z1))); %display the updated image on data_modify
                caxis(  handles.axes1, [handles.data1min handles.data1max]);
            end
            
            if popmv2<18 %if the colormap
                colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
            elseif popmv2==18
                myColorMap = jet(256); %colormap used for indexing, where 0 is white
                myColorMap(1,:) = 1;
                colormap(handles.axes2,myColorMap); %set the colormap to jetwhite
            end
            
            if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
                linkaxes([handles.axes1,handles.axes2],'off')
            elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
                set(handles.axes1, 'XLim', xlim); %set x-axes left image
                set(handles.axes1, 'YLim', ylim); %set y-axes left image
                set(handles.axes2, 'XLim', xlim); %set x-axes right image
                set(handles.axes2, 'YLim', ylim); %set y-axes right image
                linkaxes([handles.axes1,handles.axes2],'xy') %link the axes
            end
        end
    end
end

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1 left 'GO'
function pushbutton1_Callback(hObject, eventdata, handles)
 
global data_modify %bring in and update data_modify

popmv1=get(handles.popupmenu1,'Value'); %get left colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get right colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options

z1=str2double(get(handles.edit2,'String')); %get z value from left text box
set(handles.slider1, 'Value', uint32(z1)); %set the slider value to match user text choice

xlim = get(handles.axes1, 'XLim'); %get the x-axes of left image
ylim = get(handles.axes1, 'YLim'); %get the y-axes of left image

%get data1
data1=handles.data1; %bring in data1

%plot image1
imagesc(handles.axes1, data1(:,:,uint32(z1)));
caxis(  handles.axes1, [handles.data1min handles.data1max]);

if popmv1<18 %if default colormap
    colormap(handles.axes1, options{popmv1}); %set the colormap
elseif popmv1==18 %if custom colormap
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes1,myColorMap); %set jet-white colormap
end

%plot image 2
if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    %don't change the righ image
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes, need to change the right image too
    set(handles.slider2, 'Value', z1); %set the right slider value to match
    set(handles.edit3, 'String', num2str(uint32(z1))); %set the right text box to match
    imagesc(handles.axes2, data_modify(:,:,uint32(z1))); %show the right image at the matching slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormaps
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
    end
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off') %ensure axes remain unlinked
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim); %set left x-axes
    set(handles.axes1, 'YLim', ylim); %set left y axes
    set(handles.axes2, 'XLim', xlim); %set right x-axes
    set(handles.axes2, 'YLim', ylim); %set right y-axes
    linkaxes([handles.axes1,handles.axes2],'xy') %link axes
end

% --- Executes on button press in pushbutton2, right 'GO'
function pushbutton2_Callback(hObject, eventdata, handles)

global data_modify %bring in and update data_modify

popmv1=get(handles.popupmenu1,'Value'); %get left colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get right colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options

xlim = get(handles.axes1, 'XLim'); %get left xlim
ylim = get(handles.axes1, 'YLim'); %get right xlim

z2=str2double(get(handles.edit3,'String')); %get left user inputted text slice
set(handles.slider2, 'Value', uint32(z2)); %set slide to the desired slice   

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %update right image to the new slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap option
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white colormap
    end

elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1; %bring in data1 left data
    imagesc(handles.axes1, data1(:,:,uint32(z2))); %show left data at matching slice
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18 %if default colormaps
        colormap(handles.axes1, options{popmv1}); %set the colormap
    elseif popmv1==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set colormap to jetwhite
    end
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %show right image at matching slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white
    end
    set(handles.edit2, 'String', num2str(uint32(z2))); %set the left text box slice number
    set(handles.edit3, 'String', num2str(uint32(z2))); %set the righ text box slice number
    set(handles.slider1, 'Value', uint32(z2)); %set left slider value
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off') %ensure linking is turning off
elseif get(handles.checkbox1, 'Value') == 1 %if linking xy axes
    set(handles.axes1, 'XLim', xlim); %set x-axes of left image
    set(handles.axes1, 'YLim', ylim); %set y-axes of right image
    set(handles.axes2, 'XLim', xlim); %set x-axes of left image
    set(handles.axes2, 'YLim', ylim); %set y-axes of right image
    linkaxes([handles.axes1,handles.axes2],'xy') %ensure linking is on
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Undo button
global data_modify
z2=handles.undoslicenumber;
data_modify(:,:,z2)=handles.undoslice;
set(hObject,'Enable','off'); %undo button disabled
% The rest of the script will re-update the image
popmv1=get(handles.popupmenu1,'Value'); %get left colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get right colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options

xlim = get(handles.axes1, 'XLim'); %get left xlim
ylim = get(handles.axes1, 'YLim'); %get right xlim

set(handles.slider2, 'Value', uint32(z2)); %set slide to the desired slice   

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %update right image to the new slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap option
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white colormap
    end

elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1; %bring in data1 left data
    imagesc(handles.axes1, data1(:,:,uint32(z2))); %show left data at matching slice
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18 %if default colormaps
        colormap(handles.axes1, options{popmv1}); %set the colormap
    elseif popmv1==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set colormap to jetwhite
    end
    imagesc(handles.axes2, data_modify(:,:,uint32(z2))); %show right image at matching slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white
    end
    set(handles.edit2, 'String', num2str(uint32(z2))); %set the left text box slice number
    set(handles.edit3, 'String', num2str(uint32(z2))); %set the righ text box slice number
    set(handles.slider1, 'Value', uint32(z2)); %set left slider value
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off') %ensure linking is turning off
elseif get(handles.checkbox1, 'Value') == 1 %if linking xy axes
    set(handles.axes1, 'XLim', xlim); %set x-axes of left image
    set(handles.axes1, 'YLim', ylim); %set y-axes of right image
    set(handles.axes2, 'XLim', xlim); %set x-axes of left image
    set(handles.axes2, 'YLim', ylim); %set y-axes of right image
    linkaxes([handles.axes1,handles.axes2],'xy') %ensure linking is on
end



% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
popmv=get(hObject,'Value'); %pop menu value of single or continuous
if popmv==1 %single acquisition
    % do nothing, this is the default
elseif popmv==2 %use is entering continuous mode
    CreateStruct.Interpreter = 'tex';
    CreateStruct.WindowStyle = 'modal';
    msgbox({'\fontsize{18}Entering Continuous Modification Mode';...
        '\fontsize{14}When you press the MODIFY button, you will be able to make multiplie modifications. Zooming and panning will not disrupt continuous mode, but pressing other buttons will exit continuous mode. \bfWhen you are done modifying the layer, press the ESC key to exit continuous mode.'},...
        'Continuous Modification', 'help',CreateStruct); %Will warn and instruct the user
end


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel1 is resized.
function uipanel1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'backslash'
        pushmodify_Callback(handles.pushmodify,[], handles);
    case 'return'
        if get(handles.checkbox2, 'Value') == 1 %if linking z axes
            pushbutton1_Callback(handles.pushbutton1, [], handles);
        end
    case 'pageup'
        if get(handles.checkbox2, 'Value') == 1 %if linking z axes
            z=str2double(get(handles.edit2,'String')); %get left user inputted text slice
            if z+1 <= get(handles.slider1, 'max') %get the max value
                set(handles.edit2, 'String', num2str(z+1))
                pushbutton1_Callback(handles.pushbutton1, [], handles);
            end
        else
            errordlg('Data must be linked in the Z for keyboard shortcut','ModLayer Error')
        end
    case 'pagedown'
        if get(handles.checkbox2, 'Value') == 1 %if linking z axes
            z=str2double(get(handles.edit2,'String')); %get left user inputted text slice
            if z-1 >= get(handles.slider1, 'min') %get the min left slider to 1
                set(handles.edit2, 'String', num2str(z-1))
                pushbutton1_Callback(handles.pushbutton1, [], handles);
            end
        else
            errordlg('Data must be linked in the Z for keyboard shortcut','ModLayer Error')
        end
    case 'equal'
        zoom(1.2);
    case 'hyphen'
        zoom(0.83)
    case 'uparrow'
        if get(handles.checkbox1, 'Value') == 1 %if linking xy axes
            ylim = get(handles.axes1, 'YLim'); %get right xlim
            delta=ceil(abs(0.02*diff(ylim)));
            if ylim(1)-delta<0
                delta=ylim(1)-0.5;
                set(handles.axes1, 'YLim', ylim-delta); %set y-axes of right image
                set(handles.axes2, 'YLim', ylim-delta); %set y-axes of right image
            else
                set(handles.axes1, 'YLim', ylim-delta); %set y-axes of right image
                set(handles.axes2, 'YLim', ylim-delta); %set y-axes of right image
            end
            pushbutton1_Callback(handles.pushbutton1, [], handles);
        else
            errordlg('Data must be linked in the XY for keyboard shortcut','ModLayer Error')
        end
    case 'downarrow'
        if get(handles.checkbox1, 'Value') == 1 %if linking xy axes
            s1=handles.size1; %store the size of the reference image
            s2=handles.size2; %store the size of data_modify
            smax=max(s1, s2);
            ylim = get(handles.axes1, 'YLim'); %get right ylim
            delta=ceil(abs(0.02*diff(ylim)));
            if ylim(2)+delta > smax(1)
                delta=smax(1)-ylim(2)+0.5;
                set(handles.axes1, 'YLim', ylim+delta); %set y-axes of right image
                set(handles.axes2, 'YLim', ylim+delta); %set y-axes of right image
            else
                set(handles.axes1, 'YLim', ylim+delta); %set y-axes of right image
                set(handles.axes2, 'YLim', ylim+delta); %set y-axes of right image
            end
            pushbutton1_Callback(handles.pushbutton1, [], handles);
        else
            errordlg('Data must be linked in the XY for keyboard shortcut','ModLayer Error')
        end
    case 'leftarrow'
        if get(handles.checkbox1, 'Value') == 1 %if linking xy axes
            xlim = get(handles.axes1, 'XLim'); %get left xlim
            delta=ceil(abs(0.02*diff(xlim)));
            if xlim(1)-delta < 0
                delta=xlim(1)-0.5;
                set(handles.axes1, 'XLim', xlim-delta); %set x-axes of left image
                set(handles.axes2, 'XLim', xlim-delta); %set x-axes of left image
            else
                set(handles.axes1, 'XLim', xlim-delta); %set x-axes of left image
                set(handles.axes2, 'XLim', xlim-delta); %set x-axes of left image
                pushbutton1_Callback(handles.pushbutton1, [], handles);
            end
        else
            errordlg('Data must be linked in the XY for keyboard shortcut','ModLayer Error')
        end
    case 'rightarrow'
        if get(handles.checkbox1, 'Value') == 1 %if linking xy axes
            s1=handles.size1; %store the size of the reference image
            s2=handles.size2; %store the size of data_modify
            smax=max(s1, s2);
            xlim = get(handles.axes1, 'XLim'); %get left xlim
            delta=ceil(abs(0.02*diff(xlim)));
            if xlim(2)+delta > smax(2) %if trying to pan further than the right
                delta=smax(2)-xlim(2)+0.5;
                set(handles.axes1, 'XLim', xlim+delta); %set x-axes of left image to max
                set(handles.axes2, 'XLim', xlim+delta); %set x-axes of left image
            else
                set(handles.axes1, 'XLim', xlim+delta); %set x-axes of left image
                set(handles.axes2, 'XLim', xlim+delta); %set x-axes of left image
                pushbutton1_Callback(handles.pushbutton1, [], handles);
            end
        else
            errordlg('Data must be linked in the XY for keyboard shortcut','ModLayer Error')
        end
end

