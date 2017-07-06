%Input: f_scanOffset(no. slices, frames per slice, size of slice/step)
%Add scanning offset to DHPSF output used with scanning script on Agave.
%ARC 21/3/16

%Required Parameters: Frames per burst, Step size, number of steps
%Input localisation in format ouput by easyDHPSF

function [loclist] = f_scanOffset(createfile,scatt)

%----------Parameters------------%
%slices=3;       %number of slices taken
%burst=100;      %number of frames recordered at each slice
%scanstep=3500;     %size of scan step in nm
%--------------------------------%

%if no arguments use default values
%if no arguments then create file = yes
if nargin < 2
  scatt =0;
end
if nargin < 1
  createfile =1;
end


%User choses .csv file containing easydhpsf ouput
[fileName,pathName] = uigetfile('*.csv','Choose easydhpsf output file');
openpath=strcat(pathName,fileName);

%User enters variables
prompt={'Number of slices:','Frames per burst:','z step size (nm):'};
title='Scan Offset';

def(1)= {'3'};
def(2)= {'100'};
def(3)= {'3500'};

answer=inputdlg(prompt,title,1,def);

if isempty(answer)
    error('User cancelled the program')
end

slices = str2num(answer{1});
burst = str2num(answer{2});
scanstep = str2num(answer{3});


%open chosen file
tempimport=importdata(openpath, ',', NaN);
%fitdata=tempimport;
loclist=tempimport.data;
clear tempimport;

%reverse z direction as its upsidedown by default (i think)
loclist(:,5)=-loclist(:,5);

%Use modulo to add on correct offset
for i=1:size(loclist,1)

    framemod=floor(loclist(i,1)/burst);

    loclist(i,5)=loclist(i,5)+mod(framemod,slices)*scanstep;
    %disp(mod(framemod,slices)*scanstep)
end

if createfile==1
    savepath=strcat(pathName,'ScanSorted',fileName);
    csvwrite(savepath,loclist);
end

if scatt==1
     figure
     scatter3(loclist(:,3),loclist(:,4),loclist(:,5),'.');
     xlabel('x (nm)');
     ylabel('y (nm)')
     zlabel('z (nm)')
     axis vis3d
     axis equal
end
