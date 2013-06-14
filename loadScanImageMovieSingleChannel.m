function [image header]=loadScanImageMovieSingleChannel(filename,directory,channel)

%Fast opener for one channel only of Scan Image files
%If 2 channels are present ut load only the specified cahnned and modifies the header to account fo the removed channel.
%Leopoldo 2009

%%
if nargin==1
    [filename directory]=uigetfile('*.tif');
    cd(directory)
else
    currentFile=filename;
    currentDirectory=directory;
end


image=uint16([]);



%store file data on figure

currentFile=filename;
currentDirectory=directory;


imStackInfo=imfinfo(filename);
info=imStackInfo;
frames = length(imStackInfo); %LTP
width=unique(imStackInfo(:,1).Width);%LTP
height= unique(imStackInfo(:,1).Height);%LTP
header = info(1).ImageDescription;
evalc(header);
%%


%%% 2 channels, remove one
if state.acq.savingChannel1==1 & state.acq.savingChannel2==1
    % modify header to remove a channel
    %hard coded for removing only red for now!!!

    acqHeader=findstr(header,'.acq.acquiringChannel2=1');
    savingHeader=findstr(header,'.acq.savingChannel2=1');
    header(acqHeader:acqHeader+length('.acq.acquiringChannel2=1')-1)='.acq.acquiringChannel2=0';
    header(savingHeader:savingHeader+length('.acq.savingChannel2=1')-1)='.acq.savingChannel2=0';


    image=uint16(zeros(height, width, frames/2)); % allocate memory

    h=waitbar(0,'Loading Frame...', 'Position', 1000* [1.0598    0.3690    0.2700    0.0563]);
    for i=1:frames/2
        image(:,:,i)=imread(filename,i*2-(2-channel));
        waitbar(i/(frames/2),h,['Loading Frame...'  num2str(i)] )
    end
    close(h);
%%
% 1 channels, don't change anything
else
    image=uint16(zeros(height, width, frames)); % allocate memory

    h=waitbar(0,'Loading Frame...', 'Position', 1000* [1.0598    0.3690    0.2700    0.0563]);
    for i=1:frames
        image(:,:,i)=imread(filename,i);
        waitbar(i/(frames),h,['Loading Frame...'  num2str(i)] )
    end
    close(h);
end
