function Leo_image_registration_single_trial(targetfilename, fullsourcefilename)

% Image subpixel registration implamentation for Scan Image File
% Registers one channel only for now. 
% Based on dftregistration.m 
%Registered files are saved on the sane directory with prefix "reg_chan_1..."
% % Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup, 
% "Efficient subpixel image registration algorithms," Opt. Lett. 33, 156-158 (2008).
% Leopoldo Petreanu 2009

% difine the subpixel resoluton ( e.g. =10, subpixel rsolution =1/10)
subpixelFraction=1; %<---- Config
channel=1;          %<---- Config 

[pathstr, name, ext, versn] = fileparts(fullsourcefilename);
cd(pathstr)
target=imread(targetfilename);
% [G_Stack  header]=loadScanImageMovieSingleChannel(fullsourcefilename,pathstr,channel);
G_Stack =imread_multi(fullsourcefilename,'g');
im_info = imfinfo(fullsourcefilename);
if isfield(im_info(1),'ImageDescription')
    header = im_info(1).ImageDescription;
else
    header = '';
end

[ r c z]=size(G_Stack);
Greg=zeros(r, c, z);

h=waitbar(0,'Processing Frame...', 'Position', 1000* [1.0598    0.4545    0.2700    0.0563]);

for i=1:z;
    waitbar(i/z,h,['Processing Frame...'  num2str(i)] );
    [output(:,:,i) Greg(:,:,i)] = dftregistration(fft2(double(target)),fft2(double(G_Stack(:,:,i))),subpixelFraction);
    regIm=abs(ifft2(Greg(:,:,i)));
    imwrite(uint16(regIm),[pathstr filesep 'reg_chan1_' name '.tif'],'tif','Compression','none','Description',header,'WriteMode','append');
end
close(h)