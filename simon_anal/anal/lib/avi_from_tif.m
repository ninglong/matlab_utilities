%
% function avi_from_tif(src_path, fps, frames, tgt_frames)
%
% S Peron 2009 Dec
%
% Generates an AVI movie from a tiff stack, saving it in same place but with
%  avi path instead.
%
%  src_path: the tif stack; pass cell array of 2 to do green/red (first is green)
%  fps: frames per second; default is 10.
%  frames: vector specifying which frames to use; default uses all movie; -1 = all
%  tgt_frames: if specified, for *second* (red) movie, it will use these frames' 
%    avg as target in RED ALWAYS; -1 disables
%
function avi_from_tif(src_path, fps, frames, tgt_frames)

  % defaults
  if (~ exist('fps', 'var'))
	  fps = 10;
	end
  if (~ exist('frames', 'var'))
	  frames = -1;
	end
	if (~ exist('tgt_frames', 'var'))
	  tgt_frames = -1;
	end

  % multiples?
	twofer = 0;
	if (iscell(src_path))
	  src_path2 = src_path{2};
		src_path = src_path{1};
		twofer = 1;
	end

  % out path
	out_path = strrep(src_path,'.tiff','_t2a.avi');
	out_path = strrep(src_path,'.tif','_t2a.avi');
	if (strcmp(out_path,src_path))
	  disp('avi_from_tif::same in and out path -- must have tif in name -- appending.');
		out_path = [out_path '_t2a.avi'];
	end

	% load the file
  im = double(load_image(src_path, frames,[]));
	if (twofer) ; im2 = double(load_image(src_path2, frames, [])); end

	% and make the movie ...
	h = figure;
	avi_file = avifile(out_path, 'fps', fps);
	M = max(max(max(im)));
	im = im/M;
	if (twofer) ; M2 = max(max(max(im2))); im2 = im2/M2; end
	SM = max(size(im,1), size(im,2));
	if (twofer) % initialize the rgb matrices
	  im1_rgb = zeros(size(im,1),size(im,2),3);
	  im2_rgb = zeros(size(im,1),size(im,2),3); 

		if (tgt_frames ~= -1)
		  im2_rgb(:,:,1) = mean(im2(:,:,tgt_frames),3);
		end
	end
	for f=1:size(im,3)
	  % red and green superimpose
	  if (twofer)
		  im1_rgb = 0*im1_rgb; % erase last slide
		  im1_rgb(:,:,2) = im(:,:,f); % green channel (2) first im
			if (tgt_frames == -1 ) % if you are matching moveies, do so
				im2_rgb = 0*im2_rgb; % erase last slide
				im2_rgb(:,:,1) = im2(:,:,f); % red channel (1) secondi m
			end
			% add green and red channels to produce final
			imshow(im1_rgb + im2_rgb, 'Border', 'tight');
		% monochrome
		else
			imshow(im(:,:,f), 'Border', 'tight');
%			text(20,20,num2str(f*(1/3.91)), 'Color', [1 1 1], 'FontWeight', 'bold', 'FontSize', 30); % this should be a passed param
		end
		set(h, 'Position', [0 0 SM SM]);
		axis square; % aspect ENFORCER

		% avi write
		avi_file = addframe(avi_file, h);
	end
	avi_file = close(avi_file);


