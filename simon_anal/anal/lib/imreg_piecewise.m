%
% [im_c dx_r dy_r E] = imreg_piecewise(im_s, im_t, opt)
%
% Given two images, finds optimal x/y offset using a gradient descent (or
%  ascent more correctly) over a correlation-based error space.  It does
%  this in a piecewise fashion, using each line as a piece.
%
% im_s is your source and im_t is your target image.  It returns im_c, 
%  which is your corrected image.  dx_r and dy_r correspond to the 
%  *line-by-line* displacements, with dx_r(f,l) being the displacement in
%  x for line l, frame f.  dx_r > 0: right ; dy_r > 0 : down.  
%
% E is the *frame-by-frame* normalized correlation after processing.
%
% lE_r is the *line-by-line* correlation to target of best fit
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.  
%
%       debug: 0: none (default)
%              1: waitbars
%
function [im_c dx_r dy_r E lE_r] = imreg_piecewise(im_s, im_t, opt)

	nlinesperblock = 1; % number of lines per block
	if (nlinesperblock ~= 1) ; disp('WARNING: not sure if you can have anything but 1 line per block ... things may break'); end % don't do that!
  max_n_steps = 50; % maximal number of iterations
	maxdx = 50; % maximal x displacement
	maxdy = 25; % maximal y displacement
	g_r = 5; % size of gaussian preconvolving matrix is 2*g_r + 1
	g_s = 1.5; % the size of the gaussian itself (sigma) 2.5 works

  % --- opt check:
  if (length(opt) == 0) % defaults
	  opt.debug= 0;
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'debug') == 0)
		  opt.debug = 0;
		end
	end

  % --- prelims
  im_s_o = im_s; % store for passage to imreg_wrapup
  im_t_o = im_t;

	im_s = im_s/max(reshape(im_s,[],1));
	im_t = im_t/max(reshape(im_t,[],1));

  % height x width x n ; scanning is along WIDTH
	height = size(im_s,1);
	width = size(im_s,2);
	nframes = size(im_s,3);

	dx = 0; % right > 0
	dy = 0; % down > 0

	% returned variables
  lE_r = zeros(nframes, height/nlinesperblock); % line-by-line error
  dx_r = zeros(nframes, height/nlinesperblock);
  dy_r = zeros(nframes, height/nlinesperblock);

  % --- pre-convolve with Gaussian
	if ( 1 == 1 )
		gauss = customgauss([2*g_r+1 2*g_r+1], g_s , g_s, 0, 0, 1, [1 1]*(g_r+1)/2);
		im_sconv = zeros(size(im_s)); % convolved
		for f=1:nframes
			% gaussian convolve, resize
			im_tmp = im_s(:,:,f);
			im_tmp = conv2(im_tmp,gauss);
			im_sconv(:,:,f) = im_tmp(g_r+1:height+g_r, g_r+1:width+g_r);
			im_sconv(:,:,f) = im_sconv(:,:,f)/max(max(im_sconv(:,:,f)));
		end
		im_s = im_sconv;

		% gaussian convolve target, resize
		im_tmp = im_t;
		im_tmp = conv2(im_tmp,gauss);
		im_tconv(:,:,f) = im_tmp(g_r+1:height+g_r, g_r+1:width+g_r);
		im_t = im_tconv(:,:,f)/max(max(im_tconv(:,:,f)));
	end

  % --- The main loop -- frame by frame
	if (opt.debug >= 1) ; wb = waitbar(0, 'Processing piecewise ...'); end
	dx_guess = 0;
	dy_guess = 0;
	for f=1:nframes
		if (opt.debug >= 1) ; wb = waitbar(f/nframes, wb, ['Piecewise processing frame ' num2str(f)]); end

    % get the 'guess dx' from fft
		fft_opt.wb_on = 0;
		if ( 0 == 1 ) % debug this!
			[irr dx_guess dy_guess irr2] = imreg_fft(im_s(:,:,f), im_t, fft_opt);
			if (abs(dx_guess) > maxdx) ; dx_guess = 0; end
			if (abs(dy_guess) > maxdy) ; dy_guess = 0; end
    end
 
    % line-by-line
	  for l=1:(height/nlinesperblock)
		  % setup this line
		  s_l = ((l-1)*nlinesperblock)+1;
		  e_l = s_l + nlinesperblock-1;
			t_line = reshape(im_t(s_l:e_l,:,1),[],1); % line from target image -- what you want to match to
			s_line = reshape(im_s(s_l:e_l,:,f),[],1); % line from soure image -- what you want to match 

			% original displacement
			R = corrcoef(t_line,s_line);
		  Rvec = R(1,2);

      % erase memory -- this should eventually be changed -- for now we use fft guess
			dx = dx_guess; % right > 0
			if (l+dy_guess > 0) 
				dy = dy_guess; % down > 0
			else
			  dy = 0;
			end

			% go for as many steps as you are allowed (break if you find min).  For each step,
			%  compute cross corr in 4 displacement directions, move, rinse, repeat.
      for step=1:max_n_steps
				h_r = [max(1,1-dx) min(width,width-dx)]; % horizontal range IN SRC
				v_r = [max(1,s_l+dy) min(height, e_l+dy)] ; % vertical range
				H = h_r(1):h_r(2);
				V = v_r(1):v_r(2);

				% down
				if (v_r(2)+1 < height)
					s_line = reshape(im_s(V+1,H,f),[],1); % line from source image
					R = corrcoef(t_line(max(1,1+dx):min(width,width+dx)),s_line);
					Rvec(2) = R(1,2);
				else
					Rvec(2) = 0;
				end

				% up
				if (v_r(1)-1 > 0) 
					s_line = reshape(im_s(V-1,H,f),[],1); % line from source image 
					R = corrcoef(t_line(max(1,1+dx):min(width,width+dx)),s_line);
					Rvec(3) = R(1,2);
				else
					Rvec(3) = 0;
				end

				% right
				if (dx+1 < width)
				  DX = dx + 1;
					n_h_r = [max(1,1-DX) min(width,width-DX)]; % horizontal range
					s_line = reshape(im_s(V,n_h_r(1):n_h_r(2),f),[],1); % line from source image
					R = corrcoef(t_line(max(1,1+DX):min(width,width+DX)),s_line);
					Rvec(4) = R(1,2);
				else
					Rvec(4) = 0;
				end

				% left
				if (width+dx-1 > 1)
				  DX = dx-1;
					n_h_r = [max(1,1-DX) min(width,width-DX)]; % horizontal range
					s_line = reshape(im_s(V,n_h_r(1):n_h_r(2),f),[],1); % line from source image
					R = corrcoef(t_line(max(1,1+DX):min(width,width+DX)),s_line);
					Rvec(5) = R(1,2);
				else
					Rvec(5) = 0;
				end

				% determine best correlation ; go that way!
				[lastbest Ridx] = max(Rvec);
				if (Ridx == 1 )%& lastbest > corrthresh) 
				%if (Ridx == 1)
				  break;  % best is where you are -- we are done
				elseif (Ridx == 2) 
				  dy = min(dy+1,maxdy);
					Rvec(1) = Rvec(2);
				elseif (Ridx == 3) 
				  dy = max(dy-1,-1*maxdy);
					Rvec(1) = Rvec(3);
				elseif (Ridx == 4) 
				  dx = min(dx+1,maxdx);
					Rvec(1) = Rvec(4);
				elseif (Ridx == 5)
				  dx = max(dx-1,-1*maxdx);
					Rvec(1) = Rvec(5);
			  end

				% Sanity check to prevent explosions due to line exceeding what exists
				if (dy <= -1*l) ; dy = -1*l +1 ; end
				if (dy+l > height) ; dy = height-l ; end
%			disp(['   steps: ' num2str(step) ' corr: ' num2str(lastbest) ' dx: ' num2str(dx) ' dy: ' num2str(dy) ' f: ' num2str(f) ' l: ' num2str(l)]);
      end
			dx_r(f,l) = dx;
			dy_r(f,l) = -1*dy;
			lE_r(f,l) = Rvec(1);
%			disp(['steps: ' num2str(step) ' dx: ' num2str(dx) ' dy: ' num2str(dy) ' f: ' num2str(f) ' l: ' num2str(l)]);
		end
%		mfsf = 10; % usualyl 10
%		dx_r(f,:) = medfilt1(dx_r(f,:),round(l/mfsf));
%		dy_r(f,:) = medfilt1(dy_r(f,:),round(l/mfsf));
	end
	if (opt.debug >= 1) ; delete(wb) ; end

	% call imreg_wrapup and get your final image
	wrap_opt.err_meth = 3; % correlation based
	wrap_opt.debug = 0;  % uncomment if you want to debug with movie
	if (opt.debug >= 1) 
	  wrap_opt.debug = 1;
	end
	wrap_opt.post_proc = [1 1 1 0];
	wrap_opt.post_proc = [0 0 0 0];
	wrap_opt.lE = lE_r;
  [im_c E] = imreg_wrapup (im_s_o, im_t_o, dx_r, dy_r, [], wrap_opt);

