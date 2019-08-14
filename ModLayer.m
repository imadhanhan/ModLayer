% ModLayer(raw3Dstack)
% ModLayer is a tool that allows for slice-by-slice Visualization of two 3D
% datasets. A global variable called data_modify must be instantiated in
% the workspace and must have the same size as raw3Dstack.
% For example: 
%               raw3Dstack=imagestackofinterest;
%               global data_modify;
%               data_modify=processed3Dstacked;
%               ModLayer(raw3Dstack)

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

if isempty(data_modify)==1 %check if it exists in workspace
    error('Global variable data_modify not instantiated in workspace.')
end

data1=varargin{1}; %bring data1 from user input

if size(data1)~=size(data_modify) %check that the sizes match
    warning('Size of 3D Stacked images does not match data_modify.')
end

set(handles.togglebutton1,'string','Modify OFF','ForegroundColor','red'); %toggle button should be off to start with

z=1; %intializes as slice = first slice

imagesc(handles.axes1, data1(:,:,z)); %visualize data1
colormap(handles.axes1, 'gray') %set the colormap for data1 as gray

% Jet White colormap:
myColorMap = jet(256); %colormap used for indexing, where 0 is white
myColorMap(1,:) = 1;

imagesc(handles.axes2, data_modify(:,:,z)); %asigns the second window data2
colormap(handles.axes2, myColorMap) %set the colormap as gray

% Set output objects
handles.output = hObject;

handles.size1=size(data1);
handles.size2=size(data_modify);

handles.data1=data1;

s1=handles.size1;
s2=handles.size2;

set(handles.slider1, 'min',1);
set(handles.slider1, 'max',s1(3));
set(handles.slider1, 'Value', 1);
set(handles.slider1, 'SliderStep', [1/(s1(3)-1) , 1/(s1(3)-1) ]);
set(handles.text2, 'String', num2str(s1(3)))
set(handles.text3, 'String', num2str(1))

set(handles.slider2, 'min',1);
set(handles.slider2, 'max',s2(3));
set(handles.slider2, 'Value', 1);
set(handles.slider2, 'SliderStep', [1/(s2(3)-1) , 1/(s2(3)-1) ]);
set(handles.text9, 'String', num2str(s2(3)))
set(handles.text10, 'String', num2str(1))


%Colormapr options
set(handles.popupmenu1, 'Value', 10)
set(handles.popupmenu2, 'Value', 18)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ModLayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data_modify

popmv1=get(handles.popupmenu1,'Value'); %get colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};

z1=get(handles.slider1,'Value'); %get z value of data1

xlim = get(handles.axes1, 'XLim');
ylim = get(handles.axes1, 'YLim');

%get data1
data1=handles.data1;

%plot image1
imagesc(handles.axes1, data1(:,:,floor(z1)));
set(handles.edit2, 'String', num2str(floor(z1)));
if popmv1<18
    colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
elseif popmv1==18
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes1,myColorMap);
end

%plot image 2
if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    %do nothing
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    set(handles.slider2, 'Value', z1);
    set(handles.edit3, 'String', num2str(floor(z1)));
    imagesc(handles.axes2, data_modify(:,:,floor(z1)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
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
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%plot image 2
global data_modify

popmv1=get(handles.popupmenu1,'Value'); %get colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};

xlim = get(handles.axes1, 'XLim');
ylim = get(handles.axes1, 'YLim');

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    z2=get(handles.slider2,'Value');
    imagesc(handles.axes2, data_modify(:,:,floor(z2)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
    set(handles.edit3, 'String', num2str(floor(z2)));
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1;
    z2=get(handles.slider2,'Value');
    imagesc(handles.axes1, data1(:,:,floor(z2)));
    if popmv1<18
        colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
    elseif popmv1==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap);
    end
    imagesc(handles.axes2, data_modify(:,:,floor(z2)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
    set(handles.edit2, 'String', num2str(floor(z2)));
    set(handles.edit3, 'String', num2str(floor(z2)));
    set(handles.slider1, 'Value', z2);
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
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
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%gets the xlim and ylim of image 1
if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if linking xy axes
    xlim = get(handles.axes1, 'XLim');
    ylim = get(handles.axes1, 'YLim');
    %links the axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
end


% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2 Link Z
function checkbox2_Callback(hObject, eventdata, handles)
global data_modify
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z1=get(handles.slider1,'Value');

popmv2=get(handles.popupmenu2,'Value'); %pop menu value popmv
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};

imagesc(handles.axes2, data_modify(:,:,floor(z1)));
if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
end
    
set(handles.slider2, 'Value', z1);
set(handles.edit3, 'String', num2str(floor(z1)));
    


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
popmv=get(hObject,'Value'); %pop menu value popmv
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};
if popmv<18
    colormap(handles.axes1, options{popmv}); %set the colormap for tomography
elseif popmv==18
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes1,myColorMap);
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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popmv=get(hObject,'Value'); %pop menu value popmv
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};
if popmv<18
    colormap(handles.axes2, options{popmv}); %set the colormap for tomography
elseif popmv==18
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes2,myColorMap);
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
global data_modify

popmv2=get(handles.popupmenu2,'Value'); %pop menu value popmv
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ...
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};
z2=floor(get(handles.slider2,'Value'));
xlim = get(handles.axes1, 'XLim');
ylim = get(handles.axes1, 'YLim');


% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % modButt=get(hObject,'Value'); %Modify Button Value

% if modButt==0
%     set(hObject,'string','Modify OFF','ForegroundColor','red');
% elseif modButt==1
%     set(hObject,'string','Modify ON','ForegroundColor','green');
% end

set(hObject,'string','Modify ON','ForegroundColor','green');

% while get(hObject,'Value') == 1
image=data_modify(:,:,z2);
% Determine which image is to be modified:

axes_number=get(handles.popupmenu3,'Value'); %pop menu value popmv

if axes_number==2
    hFH = imfreehand(handles.axes1); %tasks user to free hand on axes1
elseif axes_number==1
    hFH = imfreehand(handles.axes2); %tasks user to free hand on axes2
end
mask = hFH.createMask();

% Get value to impose on mask:
string_value_to_impose=get(handles.edit1,'String');
image(mask)=str2double(string_value_to_impose);

data_modify(:,:,z2)=image;

imagesc(handles.axes2, data_modify(:,:,floor(z2)));
if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
end

if popmv2<18
    colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
elseif popmv2==18
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes2,myColorMap);
end

handles.data2=data_modify;

set(hObject,'string','Modify OFF','ForegroundColor','red');
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_modify

popmv1=get(handles.popupmenu1,'Value'); %get colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};

z1=str2double(get(handles.edit2,'String')); %get z value from text box
set(handles.slider1, 'Value', floor(z1));

xlim = get(handles.axes1, 'XLim');
ylim = get(handles.axes1, 'YLim');

%get data1
data1=handles.data1;

%plot image1
imagesc(handles.axes1, data1(:,:,floor(z1)));
% set(handles.edit2, 'String', num2str(floor(z1)));
if popmv1<18
    colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
elseif popmv1==18
    myColorMap = jet(256); %colormap used for indexing, where 0 is white
    myColorMap(1,:) = 1;
    colormap(handles.axes1,myColorMap);
end

%plot image 2
if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    %do nothing
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    set(handles.slider2, 'Value', z1);
    set(handles.edit3, 'String', num2str(floor(z1)));
    imagesc(handles.axes2, data_modify(:,:,floor(z1)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_modify

popmv1=get(handles.popupmenu1,'Value'); %get colormap choice
popmv2=get(handles.popupmenu2,'Value'); %get colormap choice
options={'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', ... 
    'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'jetwhite'};

xlim = get(handles.axes1, 'XLim');
ylim = get(handles.axes1, 'YLim');

z2=str2double(get(handles.edit3,'String'));
set(handles.slider2, 'Value', floor(z2));   

if get(handles.checkbox2, 'Value') == 0 %if NOT linking z axes
    imagesc(handles.axes2, data_modify(:,:,floor(z2)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
%     set(handles.edit3, 'String', num2str(floor(z2)));
elseif get(handles.checkbox2, 'Value') == 1 %if linking z axes
    data1=handles.data1;
    imagesc(handles.axes1, data1(:,:,floor(z2)));
    if popmv1<18
        colormap(handles.axes1, options{popmv1}); %set the colormap for tomography
    elseif popmv1==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes1,myColorMap);
    end
    imagesc(handles.axes2, data_modify(:,:,floor(z2)));
    if popmv2<18
        colormap(handles.axes2, options{popmv2}); %set the colormap for tomography
    elseif popmv2==18
        myColorMap = jet(256); %colormap used for indexing, where 0 is white
        myColorMap(1,:) = 1;
        colormap(handles.axes2,myColorMap);
    end
    set(handles.edit2, 'String', num2str(floor(z2)));
    set(handles.edit3, 'String', num2str(floor(z2)));
    set(handles.slider1, 'Value', floor(z2));
end

if get(handles.checkbox1, 'Value') == 0 %if NOT linking xy axes
    linkaxes([handles.axes1,handles.axes2],'off')
elseif get(handles.checkbox1, 'Value') == 1 %if  linking xy axes
    set(handles.axes1, 'XLim', xlim);
    set(handles.axes1, 'YLim', ylim);
    set(handles.axes2, 'XLim', xlim);
    set(handles.axes2, 'YLim', ylim);
    linkaxes([handles.axes1,handles.axes2],'xy')
end
