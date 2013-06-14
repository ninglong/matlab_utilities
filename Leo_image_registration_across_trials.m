function Leo_image_registration_across_trials

%Registers a a series of movies against an specified image 
% The list of files to register and teh target image are specified by uis. 
% Leopoldo Petreanu 2009
[f p] = uigetfile('*.tif','Click any file.');
cd(p)
[pathstr, name, ext, versn] = fileparts([p f]);
d = dir(fullfile(pathstr, ['/*' ext]));

str = {d.name};
str = sortrows({d.name}');
[s,v] = listdlg('PromptString','Select files to analyze:', 'OKString', 'OK',...
	'SelectionMode','multiple',...
	'ListString', str, 'Name', 'Select a File');
names = str(s);
numTraces = size(names, 1);

[targetfilename p]=uigetFile('*.tif*', 'Select Image Target File.');
target=imread(targetfilename);
h=waitbar(0,'Processing Trial...','Position',1000*[ 1.0568    0.5400    0.2700    0.0563]);
tic;
 for i=1:numTraces
        waitbar(i/numTraces,h,['Processing Trial...'  names{i}] );
        fullsourcefilename = fullfile(pathstr, names{i});
        Leo_image_registration_single_trial(targetfilename, fullsourcefilename);
        
 end
 toc
 close(h)