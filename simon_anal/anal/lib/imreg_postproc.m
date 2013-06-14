% 
% S Peron Dec. 2009
%
% [dx dy dtheta] = imreg_postproc (dx, dy, dtheta, err, opt)
%
% Given a dx, dy, dtheta, err, it will apply post-processing (median filter and
%  adaptive correction based on error) to registration data, giving new displacement
%  vectors.  No images are handled here, and the displacement vectors must be the
%  same size as error vector.
% 
% opt.mfs1: -1 no median filtering at step 1 ; > 0 yes with size mfs1
% opt.corr: -1 for no correlation based correction at step 2; otherwise [alpha, beta
%              gbs] where err < alpha*median(err) means bad (this is correlation)
%              and err > beta*median(err) means good (this is correlation).  gbs is
%              minimal streak size -- if you find a bad value, you give it the value
%              of next good with block size gbs.
% opt.mfs2: -1 no median filtering at step 3 ; > 0 yes with size mfs2
% opt.debug: 0 - nothing 1 - show waitbars
% opt.mat_out_path: filename of .mat file you want to save dx/dy for all steps - if blank
%            no saving
%
function [dx_r dy_r dtheta_r] = imreg_postproc(dx, dy, dtheta, err, opt)
  % init variables
	dx_o = dx;
	dy_o = dy;
	dx_c = 0;
	dy_c = 0;
	dx_mf1 = 0;
	dy_mf1 = 0;
	dx_mf2 = 0;
	dy_mf2 = 0;

  % --- opt check:
  if (length(opt) == 0) % defaults
	  opt.debug = 0;
	  opt.mfs1 = -1;
	  opt.corr = -1;
	  opt.mfs2 = -1;
	  opt.mat_out_path = '';
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'debug') == 0)
		  opt.debug = 0;
		end
	  if (isfield(opt,'mfs1') == 0)
		  opt.mfs1= -1;
		end
	  if (isfield(opt,'corr') == 0)
		  opt.corr = -1;
		end
	  if (isfield(opt,'mfs2') == 0)
		  opt.mfs2 = -1;
		end
	  if (isfield(opt,'mat_out_path') == 0)
		  opt.mat_out_path = -1;
		end
	end

  % prelims:
  sdx = size(dx);
	if (length(sdx) == 1) ; sdx = [1 sdx]; end
	if (length(sdx) > 1) 
	  nframes = sdx(1);
	else
	  nframes = 1;
	end

	% is this rigid or piecewise?
	piecewise = 1; % 0: rigid ; 1: piecewise
	if ((sdx(2) == 1 & nframes > 1) | (sdx(2) == 1 & nframes == 1))
	  piecewise = 0;
	end

  % waitbar
	if (opt.debug  >= 1) ; wb = waitbar(0, 'imreg-postprocess starting ...'); end

  % 1) --- first median filter
	if (opt.mfs1 > 0)
		if (opt.debug  >= 1) ; waitbar(0.25, wb, 'imreg-postprocess::median filter 1'); end
		mfs = opt.mfs1;
		dxt = medfilt1(reshape(dx',[],1),mfs);
		dyt = medfilt1(reshape(dy',[],1),mfs);
		
		% median filtered dx for posterity
		dx_mf1 = zeros(sdx(1), sdx(2));
		dy_mf1 = zeros(sdx(1), sdx(2));

    % reshape
		for f=1:nframes
			si = (f-1)*sdx(2) + 1;
			ei = si + sdx(2) -1;
			dx_mf1(f,:) = dxt(si:ei);
			dy_mf1(f,:) = dyt(si:ei);
		end

    % assign
		dx = dx_mf1;
		dy = dy_mf1;
	end

  % 2) --- adaptive correction -- iff piecewise
	if (piecewise & length(opt.corr) == 3)
    % preliminary variable calculation
		if (opt.debug  >= 1) ;  waitbar(0.5, wb,'imreg-wrapup::adaptive correction'); end
		% again, assign first as dx_c so that you can save all dx's separately
		[dx_c dy_c] = correct_displacement_vectors(dx, dy, err, opt.corr(1), opt.corr(2), opt.corr(3), opt.debug);

		dx = dx_c;
		dy = dy_c;
	end

	% 3) --- post-correction median filter
	if (opt.mfs2 > 0)
		if (opt.debug  >= 1) ; waitbar(0.75, wb, 'imreg-postprocess::median filter 2'); end
		mfs = opt.mfs2;
		dxt = medfilt1(reshape(dx',[],1),mfs);
		dyt = medfilt1(reshape(dy',[],1),mfs);
		
		% median filtered dx for posterity
		dx_mf2 = zeros(sdx(1), sdx(2));
		dy_mf2 = zeros(sdx(1), sdx(2));

    % reshape
		for f=1:nframes
			si = (f-1)*sdx(2) + 1;
			ei = si + sdx(2) -1;
			dx_mf2(f,:) = dxt(si:ei);
			dy_mf2(f,:) = dyt(si:ei);
		end

    % assign
		dx = dx_mf2;
		dy = dy_mf2;
	end

  % 4) --- wrap it up
	dx_r = dx;
	dy_r = dy;
	dtheta_r = [];
	disp('imreg-postproc::not doing dtheta now.');
  if (opt.debug >= 1) ; delete(wb) ; end
  if (length(opt.mat_out_path) > 0)
	  save(opt.mat_out_path, 'err', 'dx_o', 'dx_mf1', 'dx_mf2', 'dx_c', 'dx_r', 'dy_o', 'dy_mf1', 'dy_mf2', 'dy_c', 'dy_r', '-mat');
	end
	

%
% This performs adaptive correction on a dx/dy series given an error
%  Returns corrected dx and dy displacement vectors. lE is line-by-line
%  error vector.  The following parameters are important:
%    alpha: lE (errors -- correlations actually) below median(lE)*alpha are "bad"
%    beta: medial(lE)*beta is good
%    gbs: good block size (see below)
%  If you are "bad", you are replaced by the mean value of the first gbs good points
%    and the preceding good gbs points.  
%  debug: if 1, waitbar
%
function [dx_r dy_r] = correct_displacement_vectors(dx, dy, lE, alpha, beta, gbs, debug)
  nframes = size(dx,1);
	nlines = size(dx,2);

	lE = reshape(lE',[],1); % error throughout, line-by-line
	dx_c = reshape(dx',[],1); % dx and dy -- Corrected
	dy_c = reshape(dy',[],1);
	mE = median(lE);
%mE
%gbs
	% go line-by-line
	lE_good = find(lE >= mE*beta);
	Lg = length(lE_good);
	lE_bad = find(lE < mE*alpha);
	Lb = length(lE_bad);
	last_nxt = [];
	if (debug >= 1) ; wb = waitbar(0,'Applying adaptive correction ...'); end
	for b=1:length(lE_bad)
		if (debug >= 1) ; wb = waitbar(b/length(lE_bad), wb, 'Applying adaptive correction ...'); end
	  
		% for all bad points, find good points before and after
		prev = max(find(lE_good < lE_bad(b)));
		nxt = min(find(lE_good > lE_bad(b)));

		% blockiness
		if (gbs > 1)
			found = 0;	  
			% next block:
			while(found == 0 & length(nxt) > 0)
				if (nxt + gbs > Lg) 
					found = -1;
				else
					desired = lE_good(nxt)+(0:gbs-1);
					if (length(intersect(desired,lE_good)) == length(desired))
						found = 1;

%fidx = 1+floor(lE_good(nxt)/(nlines));
%lidx = lE_good(nxt)-((fidx-1)*(nlines));
%lidxb = lE_bad(b)-((fidx-1)*(nlines));
%disp(['f: ' num2str(fidx) ' from l: ' num2str(lidxb) ' to : ' num2str(lidx)]);

						nxt = nxt:nxt+gbs-1;
						% the current next will be the prev on the following run
						if (length(last_nxt) > 0) 
							prev = last_nxt;
						end
						last_nxt = nxt;
					else
						nxt = nxt+1;
					end
				end
			end
		end

		% make sure they exist -- at end and beginning you only have 1 
		Sdx = []; % sum of 2 good pts
		Sdy = []; % sum of 2 good pts
		if (length(prev) > 0)
			Sdx = [Sdx  dx_c(lE_good(prev))'];
			Sdy = [Sdy  dy_c(lE_good(prev))'];
		end
		if (length(nxt) > 0)
			Sdx = [Sdx  dx_c(lE_good(nxt))'];
			Sdy = [Sdy  dy_c(lE_good(nxt))'];
		end

		% and correct . . . 
		dx_c(lE_bad(b)) = mean(Sdx);
		dy_c(lE_bad(b)) = mean(Sdy);
	end
			
  if (debug >= 1) ; delete(wb) ; end

	% and construct reshaped vector
	dx_r = zeros(nframes,nlines);
	dy_r = zeros(nframes,nlines);
	
	for f=1:nframes
		si = (f-1)*nlines + 1;
		ei = si + nlines -1;
		dx_r(f,:) = dx_c(si:ei);
		dy_r(f,:) = dy_c(si:ei);
	end
