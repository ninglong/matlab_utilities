%
% [im_c dx_r dy_r E] = imreg_dombeck_hmm(im_s, im_t, opt)
%
% Given two images, finds optimal x/y offset using the HMM algorithm from
%  Dombeck et al. 2007:
%   Imaging large-scale neural activity with cellular resolution in awake, mobile mice.
%   Dombeck DA, Khabbaz AN, Collman F, Adelman TL, Tank DW.
%   Neuron. 2007 Oct 4;56(1):43-57.
%  That algorithm is implemented in extern_dombeck.m; see
%  it for details.  This is basically a wrapper that returns im_c,
%  the corrected image -- im_s is source image, im_t is 
%  target image (i.e., shifts source so it fits with target). Also returns
%  displacement in x (dx_r) and y (dy_r) that needs to be applied to source image
%  to match target.  dx_r > 0 and dy_r > 0 imply right and down movement, resp.
%  E is the error for each frame, measured as correlation.
%
%  Since this is a line-by-line correction algorithm, dx_r will be n x t where n
%  is the number of lines, t is the number of trials.  Same for dy.
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.  
%       opt.maxdx: maximal x displacement (in pixels; 20 default)
%       opt.maxdy: maximal y displacement (in pixels; 10 default)
%       opt.debug_flag: 0: no messages 1: waitbars (default) 2: misc. plots too
%
function [im_c dx_r dy_r E] = imreg_dombeck_hmm(im_s, im_t, opt)
  %	process opt structure
	maxdx = 10;
	maxdy = 5;
	debug_flag = 1;
	if (isstruct(opt))
		if (isfield(opt,'maxdx'))
		  maxdx = opt.maxdx;
		end
    if (isfield(opt,'maxdy'))
		  maxdy= opt.maxdy;
		end
    if (isfield(opt,'debug_flag'))
		  debug_flag= opt.debug_flag;
		end
  end


	% run the algorithm
  offsets = extern_dombeck(im_s, im_t, maxdx, maxdy, debug_flag);
	% construct the corrected image -- offsets consists of [dy dx] -- based on size of offets
	S_im_c = size(im_s);


  % nframes, nlines
	nlines  = S_im_c(1);
  if (length(S_im_c) == 2) 
	  nframes = 1;
	else
	  nframes = S_im_c(3);
	end
  
	% loop over all lines and determine dx, dy
	nlines_b = nlines-2*maxdy; % actual number of lines with the buffer 
	dx_last = offsets(2,1);
	dy_last = offsets(1,1);
  for f=1:nframes
	  dx = zeros(1,nlines);
	  dy = zeros(1,nlines);
	  dx(maxdy+1:nlines_b+maxdy) = offsets(2,(f-1)*nlines_b+1:f*nlines_b);
	  dy(maxdy+1:nlines_b+maxdy) = offsets(1,(f-1)*nlines_b+1:f*nlines_b);

    % 'interpolate' dx and dy for missing lines -- top, bottom
		if (f < nframes) ; dx_next = offsets(2,f*nlines_b+1); else ; dx_next = offsets(2,f*nlines_b); end
		if (f < nframes) ; dy_next = offsets(1,f*nlines_b+1); else ; dy_next = offsets(1,f*nlines_b); end
	
		dx(1:maxdy) = mean([dx_last dx(maxdy+1)]);
		dx(maxdy+nlines_b+1:nlines) = mean([dx_next dx(nlines_b+maxdy)]);
		dy(1:maxdy) = mean([dy_last dy(maxdy+1)]);
		dy(maxdy+nlines_b+1:nlines) = mean([dy_next dy(nlines_b+maxdy)]);

    % return value assing
		dx_r(f,:) = dx;
		dy_r(f,:) = dy;
  end

	% call imreg_wrapup and get your final image
	wrap_opt.err_meth = 3; % correlation based
	wrap_opt.debug = 0;
  [im_c E] = imreg_wrapup (im_s, im_t, dx_r, dy_r, [], wrap_opt);

