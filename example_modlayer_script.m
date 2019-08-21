clc

disp('Reading in tomography data');
tomo=h5read('sameple_composite_tomo.h5','/intensity'); %read in the tomo images
tomo=mat2gray(tomo); %scales tomo so intensity is from 0 to 1

disp('Segmenting tomography data');
global data_modify %initialize data_modify, the segmented image, as a global variable
data_modify=zeros(size(tomo)); %set it as all zeros with the same size as tomo images
disp('     Segmenting large pores');
porosity=find(tomo<0.33); %find the large pore pixels
pores=zeros(size(tomo)); %create a temporary porosity matrix
pores(porosity)=1; %set the porosity pixels to 1, binary image
disp('         Dilating pixels of interest');
pores=imdilate(pores, strel('sphere', 4)); %dilate
disp('         Filling holes');
pores=imfill(pores, 'holes'); %fill holes
disp('         Eroding pixels of interest');
pores=imerode(pores, strel('sphere', 5)); %erode
disp('         Removing small fragments');
pores=bwareaopen(pores, 1e4); %remove small pieces
disp('         Finald dilation');
pores=imdilate(pores, strel('sphere', 4)); %dilate
porosity=find(pores==1); %find improved large pores
data_modify(porosity)=2;%set the large pores as 2 in the segmented image
disp('     Segmenting small pores');
smallpores=find(tomo<0.25); %find small pores
data_modify(smallpores)=2; %segment small pores as 2
disp('     Segmenting fibers');
fibers=find(tomo>0.65); %find fibers
data_modify(fibers)=1; %segment fibers as 1

ModLayer(tomo) %initialize ModLayer