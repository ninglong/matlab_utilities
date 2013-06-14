%
% [im_c dx_r dy_r E] = imreg_rigid(im_s, im_t, opt)
%
% Given two images, finds optimal x/y offset by computing the dx/dy via
%  fft, then a simple iterative convergence to otpimal dx/dy/dtheta.
%
%  Returns the corrected image -- im_s is source image, im_t is 
%  target image (i.e., shifts source so it fits with target). Also returns
%  displacement in x (dx_r) and y (dy_r) that needs to be applied to source image
%  to match target.  dx_r > 0 and dy_r > 0 imply right and down movement, resp.
%  E is the error for each frame.  Also returns rotated angle.
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.
%        debug: set to 1 to get messages out the wazoo (default = 0)
%        wb_on: set to 1 to have a waitbar (default = 0)
%
function [im_c dx_r dy_r dtheta_r E] = imreg_rigid(im_s, im_t, opt)

  % opt check:
  if (length(opt) == 0) % defaults
	  opt.debug = 0;
	  opt.wb_on = 0;
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'debug') == 0)
		  opt.debug = 0;
		end
	  if (isfield(opt,'wb_on') == 0)
		  opt.wb_on= 0;
		end
	end

%im_t = imrotate(mean(im_s,3), 20, 'bicubic','crop');  
%[im_t E] = imreg_wrapup (im_t, 20, 20, 20, []); % x y theta -- TEST

	% --- variable defaults ; passable in opt eventually?
	E = [];
	wb_on = opt.wb_on;
  sim = size(im_s);
	if (length(sim) == 3) 
	  nframes = sim(3);
	else 
	  nframes = 1;
	end

  nim_t = im_t/median(reshape(im_t,1,[])); % normalize to median
  nim_t = im_t;

  % --- main loop -- do this frame-by-frame
	fft_opt.wb_on = 0;
	if (wb_on) ; wb = waitbar(0, 'Processing rigid registration...'); end
	for f=1:nframes
    % 0) prenormalize to median
		nim_s = im_s(:,:,f)/median(reshape(im_s(:,:,f),1,[])); % normalize to median

		% 1) frame > 1: use last frame as guess ; this is usually very close (if so, 
		%    skip GO and collect $500)

		% 2) frame == 1 // not good enuf fit

		% determine, apply (initial) translation
%		fft_opt.im_t = nim_t;
		[nim_c dx_f dy_f E] = imreg_fft(nim_s, nim_t, fft_opt);

		% iterate through - always imreg_fft, then rotate
		drtheta = 90; % initial angular range - no more than 45!
		n_pts = 7; % how many points to test per iteration? odd keeps 0
		n_iter = 5;
		rot_theta = 0;

		for n=1:n_iter
			% seeding
			dtheta = (rot_theta-(drtheta/2)):(drtheta/(n_pts-1)):(rot_theta+(drtheta/2));
			err = [];

			% rotation loop 
			if (opt.debug == 1) ; disp(['Iterating with theta change of ' num2str(drtheta/(n_pts-1)) ' center ' num2str(rot_theta)]); end
			for t = 1:length(dtheta)
				imr = imrotate(nim_c,dtheta(t), 'bilinear','crop');
				err(t) = corr_err(nim_t, imr); 
			end
			[best_corr best_idx] = max(err); 

			% new rot_theta
			rot_theta = dtheta(best_idx);
			drtheta = 2*(drtheta/(n_pts-1));

			% determine, apply (secondary) translation
			[tim_s irr] = imreg_wrapup(nim_s, nim_t, dx_f, dy_f, rot_theta, []);
			[im_irr dx_f2 dy_f2 E2] = imreg_fft(tim_s, nim_t, fft_opt);
			% convert the new [dx dy] translation vector from rotated coordinates to normal coordinates and add to dx,dy
			th = rot_theta*pi/180;
			R = [cos(th) -sin(th) ; sin(th) cos(th)];
			D = R*[dx_f2 ; dy_f2];
			dx_f = dx_f + round(D(1));
			dy_f = dy_f + round(D(2));
			% apply to produce novel nim_c
			[nim_c irr] = imreg_wrapup(nim_s, nim_t, dx_f, dy_f, 0, []);
		end

		% assign final variables
		dx_r(f) = dx_f;
		dy_r(f) = dy_f;
		dtheta_r(f) = dtheta(best_idx);
		if (opt.debug == 1) ; disp(['Optimal dtheta: ' num2str(dtheta_r(f)) ' dx: ' num2str(dx_f) ' dy: ' num2str(dy_f)]); end
	  if (wb_on) ; waitbar(f/nframes,wb); end
	end
	if (wb_on) ; delete(wb); end

	% --- send to imreg_wrapup
	wrap_opt.err_meth = 3; % correlation based
  if(opt.debug == 1) ; 	wrap_opt.debug = 1; end
  [im_c E] = imreg_wrapup (im_s, im_t, dx_r, dy_r, dtheta_r, wrap_opt);


%
% This is the error function based on normalized cross-correlation for 2 images
%   NO normalization -- you should do this beforehand
%
function e = corr_err(im1,im2)
	im1l = reshape(im1,1,[]);
	im2l = reshape(im2,1,[]);
%	im1l = im1l/max(im1l);
%	im2l = im2l/max(im2l);
	inval = unique([find(im2l==0) find(im1l == 0)]); % imrotate'd images have 0 in unassigned squares; ignore these
	val = setdiff(1:length(im1l), inval);
	R = corrcoef(im1l(val),im2l(val));
	e = R(1,2);

