function medianProjectionGreenChannelAcrossTrials

% read one channel and  accros different Scan Image movies
% max projection accross trials is averaged and saved
% Used to generate target images for image registration
% Leopoldo Petreanu 2009

channel=1; %<--- Config

[f p] = uigetfile('*.tif*', 'Select any movie.');
cd(p)
[pathstr, name, ext, versn] = fileparts([p f]);
d = dir(fullfile(pathstr, ['/*' ext]));
str = {d.name};
str = sortrows({d.name}');
[s,v] = listdlg('PromptString','Select a file:', 'OKString', 'OK',...
	'SelectionMode','multiple',...
	'ListString', str, 'Name', 'Select a File');
names = str(s);
numTraces = size(names, 1);
h=waitbar(0,'Processing Trial...','Position',1000*[ 1.0568    0.5400    0.2700    0.0563]);

for i=1:numTraces
    waitbar(i/numTraces,h,['Processing Trial...'  names{i}] );
    fullfilename = fullfile(pathstr, names{i});
    [A  header]=loadScanImageMovieSingleChannel(fullfilename,pathstr,channel);
        imAvg(:,:,i)=max(im_mov_avg(A,5),[],3);
end
B=uint16(mean(A,3));
imwrite(B,['movAvgmeanTarget_trials_' sprintf(names{1}(end-6:end-4)) 'to' sprintf(names{numTraces}(end-6:end-4)) '.tif'],'tiff','Compression','none')

close(h)
