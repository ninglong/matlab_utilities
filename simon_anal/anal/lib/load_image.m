%
% im = load_image(fullpath, frames, opt)
%
% S Peron Nov 2009
%
% This is basically a wrapper for imread that allows you to do more fancy things
%  as necessity arises.  Returns im, which is either a stack or a single frame.
%  
% fullpath - location of the image stack file
% frames - [a b] or a ; if [a b], read inclusively frame range a to b ; if a, only a.
%          If the file is multichannel, frame a does *not* correspond to frame a in
%          the file, but rather frame a in the specified channel.  Set to -1 to load all.
% opt - a generic structure for parameters:
%       numchannels - how many imaging channels?  if > 1, assume frames are in 
%                     1_c1,1_c2,2_c1,2_c2 ... where 1_c1 is frame 1, channel 1
%       channel - if above is > 1, you must select a channel!
%
% 
function [im im_descr] = load_image(fullpath, frames, opt)

  % --- opt check:
  if (length(opt) == 0) % defaults
	  opt.numchannels = 1;
	  opt.channel = 1;
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'numchannels') == 0)
		  opt.numchannels = 1;
		end
	  if (isfield(opt,'channel') == 0)
		  opt.channel= 1;
		end
	end

	% --- load - first, get info and construct im, then fill it
	if (length(frames) == 1) ; frames(2) = frames(1) ; end
	imf = imfinfo(fullpath);
	if (frames(1) == -1) % load all frame mode
	  frames(1) = 1;
		frames(2) = length(imf)/opt.numchannels;
	end
	im = zeros(imf(1).Height, imf(1).Width, length(frames(1):frames(2)));
	for f=frames(1):frames(2)
	  infile_idx = opt.numchannels*(f-1) + opt.channel;
		% skip inappropriately sized frames
		if (imf(infile_idx).Width == imf(1).Width & imf(infile_idx).Height == imf(1).Height)
		  im(:,:,f) = imread(fullpath, infile_idx);
		else
		  disp(['load_image::not allowed to have files with disparate frame sizes -- skipping frame ' num2str(f) ' in ' fullpath]);
		end
	end
    if isfield(imf(1),'ImageDescription')
        im_descr = imf(1).ImageDescription; % to be put back to the header
    else
        im_descr = '';
    end
