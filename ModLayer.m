% ModLayer(raw3Dstack)
% Imad Hanhan and Michael D. Sangid. August, 2019. Purdue University.
% ModLayer: A MATLAB GUI Drawing Segmentation Tool for Visualizing and Classifying 3D Data
%
% ModLayer is a tool that allows for slice-by-slice Visualization of two 3D
% datasets. A global variable called data_modify must be instantiated in
% the workspace and must have the same size as raw3Dstack.
% For example: 
%               raw3Dstack=imagestackofinterest;
%               global data_modify;
%               data_modify=processed3Dstacked;
%               ModLayer(raw3Dstack)
% If you use this tool and your work results in a publication, please cite as:
% I. Hanhan, M.D. Sangid, ModLayer: A Matlab GUI Drawing Segmentation Tool for 
% Classifying and Processing 3D Data, Submitt. under Rev. (2019).

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

set(handles.togglebutton1,'string','Modify OFF','ForegroundColor','red'); %initialize toggle button to be off to start with

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

handles.size1=size(data1); %the size of the data
handles.size2=size(data_modify); %the size of data_modify, which should match and was warned above

handles.data1=data1; %store data1

%temp store sizes
s1=handles.size1; 
s2=handles.size2;

set(handles.slider1, 'min',1); %set the min left slider to 1
set(handles.slider1, 'max',s1(3)); %set the max left slider to the max of the number of layers
set(handles.slider1, 'Value', 1); %set slider value set to 1
set(handles.slider1, 'SliderStep', [1/(s1(3)-1) , 1/(s1(3)-1) ]); %set the slider step
set(handles.text2, 'String', num2str(s1(3))) %the text box for the max layer
set(handles.text3, 'String', num2str(1)) %the text box for the min layer

%repeat for data_modify
set(handles.slider2, 'min',1);%set the min left slider to 1
set(handles.slider2, 'max',s2(3));%set the max left slider to the max of the number of layers
set(handles.slider2, 'Value', 1);%set slider value set to 1
set(handles.slider2, 'SliderStep', [1/(s2(3)-1) , 1/(s2(3)-1) ]);%set the slider step
set(handles.text9, 'String', num2str(s2(3)))%the text box for the max layer
set(handles.text10, 'String', num2str(1))%the text box for the min layer


%Colormapr options
set(handles.popupmenu1, 'Value', 10) %set the colormap option to 10, gray
set(handles.popupmenu2, 'Value', 18) %set the colormap option to 18, JetWhite

set(handles.pushbutton3,'Enable','off'); %undo button disabled
% set(handles.pushbutton3, 'ForegroundColor','white'); %undo is not ready to go

% Update handles structure
guidata(hObject, handles);

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
imagesc(handles.axes1, data1(:,:,floor(z1))); %plot the desired slice
caxis(  handles.axes1, [handles.data1min handles.data1max]);
set(handles.edit2, 'String', num2str(floor(z1))); %set the slider text box to the slice
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
    set(handles.edit3, 'String', num2str(floor(z1))); %srt left slider text to match layer
    imagesc(handles.axes2, data_modify(:,:,floor(z1))); %display the image
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
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %set the data_modify image to the new layer
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap choice
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if jetwhite colormap choice
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
    end
    set(handles.edit3, 'String', num2str(floor(z2)));
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1;%get data1
    z2=get(handles.slider2,'Value'); %get the z location of the right slider
    imagesc(handles.axes1, data1(:,:,floor(z2)));
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18
        colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
    elseif popmv1==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set jetwhite as colormap
    end
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %display the selected slice of data_modify
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if standard matlab colormap 
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if jetwhite is selected
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
    end
    set(handles.edit2, 'String', num2str(floor(z2))); %set the left scroll text box to the slice
    set(handles.edit3, 'String', num2str(floor(z2))); %set the right scroll text box to the slice
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

imagesc(handles.axes2, data_modify(:,:,floor(z1))); %plot data_modify at matching slice on right image
caxis(  handles.axes2, [handles.data2min handles.data2max]);
if popmv2<18 %if standard matlab colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jetwhite
end
    
set(handles.slider2, 'Value', z1); % set the right slider to match the left slider
set(handles.edit3, 'String', num2str(floor(z1))); %set the right text box of slice # to match

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

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)

global data_modify %bring in and update data_modify

popmv2=get(handles.popupmenu2,'Value'); %pop menu colormap value selection on right image
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ...
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'}; %colormap options
z2=floor(get(handles.slider2,'Value')); %get slice number of data_modify
xlim = get(handles.axes1, 'XLim'); %get x-axes of left image
ylim = get(handles.axes1, 'YLim'); %get y-axes of left image

handles.undoslicenumber=z2; %the slice number for undoing
handles.undoslice=data_modify(:,:,z2); %the slice for undoing

set(hObject,'string','Modify ON','ForegroundColor','green'); %Make Modify OFf -> Modify ON in green

axes_number=get(handles.popupmenu3,'Value'); %pop menu value for drawing on the left ir right image

if axes_number==2
    hFH = imfreehand(handles.axes1); %tasks user to free hand on axes1
elseif axes_number==1
    hFH = imfreehand(handles.axes2); %tasks user to free hand on axes2
end

% At this point the user will draw on the image and the program will wait

% Once drawing is done (click is released)
mask = hFH.createMask(); %create a mask from the drawing

% Get value to impose on mask from user input:
image=data_modify(:,:,z2); %save the image for imposing mask
string_value_to_impose=get(handles.edit1,'String'); %the segmentation value to impose on the image
image(mask)=str2double(string_value_to_impose); %Update segmentation value on image

% % DO NOT CHANGE: Get value to impose on mask from left image:
% data1=handles.data1;%get data1
% image_left=data1(:,:,z2); %store left image data1
% image=data_modify(:,:,z2); %store the image for imposing mask (right)
% string_value_to_impose=image_left(find(mask==1)); %get intensity from left image at draw region
% image(find(mask==1))=string_value_to_impose; %Update segmentation value on right image

data_modify(:,:,z2)=image; %update slice with the modifief image

imagesc(handles.axes2, data_modify(:,:,floor(z2))); %display the updated image on data_modify
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
set(hObject,'string','Modify OFF','ForegroundColor','red'); %set text from Modify ON -> Modify OFF in red
set(handles.pushbutton3,'Enable','on'); %undo button enabled
% set(handles.pushbutton3, 'ForegroundColor', 'black'); %Make the button usable

% end

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
set(handles.slider1, 'Value', floor(z1)); %set the slider value to match user text choice

xlim = get(handles.axes1, 'XLim'); %get the x-axes of left image
ylim = get(handles.axes1, 'YLim'); %get the y-axes of left image

%get data1
data1=handles.data1; %bring in data1

%plot image1
imagesc(handles.axes1, data1(:,:,floor(z1)));
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
    set(handles.edit3, 'String', num2str(floor(z1))); %set the right text box to match
    imagesc(handles.axes2, data_modify(:,:,floor(z1))); %show the right image at the matching slice
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
set(handles.slider2, 'Value', floor(z2)); %set slide to the desired slice   

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %update right image to the new slice
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
    imagesc(handles.axes1, data1(:,:,floor(z2))); %show left data at matching slice
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18 %if default colormaps
        colormap(handles.axes1, options{popmv1}); %set the colormap
    elseif popmv1==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set colormap to jetwhite
    end
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %show right image at matching slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white
    end
    set(handles.edit2, 'String', num2str(floor(z2))); %set the left text box slice number
    set(handles.edit3, 'String', num2str(floor(z2))); %set the righ text box slice number
    set(handles.slider1, 'Value', floor(z2)); %set left slider value
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

set(handles.slider2, 'Value', floor(z2)); %set slide to the desired slice   

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %update right image to the new slice
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
    imagesc(handles.axes1, data1(:,:,floor(z2))); %show left data at matching slice
    caxis(  handles.axes1, [handles.data1min handles.data1max]);
    if popmv1<18 %if default colormaps
        colormap(handles.axes1, options{popmv1}); %set the colormap
    elseif popmv1==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap); %set colormap to jetwhite
    end
    imagesc(handles.axes2, data_modify(:,:,floor(z2))); %show right image at matching slice
    caxis(  handles.axes2, [handles.data2min handles.data2max]);
    if popmv2<18 %if default colormap
        colormap(handles.axes2, options{popmv2}); %set the colormap
    elseif popmv2==18 %if custom colormap
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap); %set jet-white
    end
    set(handles.edit2, 'String', num2str(floor(z2))); %set the left text box slice number
    set(handles.edit3, 'String', num2str(floor(z2))); %set the righ text box slice number
    set(handles.slider1, 'Value', floor(z2)); %set left slider value
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

