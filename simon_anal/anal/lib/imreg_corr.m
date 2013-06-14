%
% [im_c dx dy E] = imreg_corr(im_s, im_t, opt)
%
% Given two images, finds optimal x/y offset by computing the cross-correlation;
%  returns the corrected image -- im_s is source image, im_t is 
%  target image (i.e., shifts source so it fits with target). Also returns
%  displacement in x (dx) and y (dy) that needs to be applied to source image
%  to match target.  dx > 0 and dy > 0 imply right and down movement, resp.
%  E is the error for each frame, measured as the absolute value of im_s-im-c.
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.
%       opt.pct_cut - ignore diagonals shorter than this % of principal diag 
%                     length to avoid low-sampled extremal regions
%       opt.max_corr_cutoff - correlation must have at least this [0,1] value
%                             otherwise it is discarded; 0 makes this irrel.
%       opt.smax - correlation computation is proportional to the square of 
%                  max(height,width) ; downsample to below this height/width 
%                  to improve speed
%
function [im_c dx_v dy_v E] = imreg_corr(im_s, im_t, opt)
  
	im_c = [];
	dx_v = [];
	dy_v = [];
	E = [];

	% --- variable defaults ; passable in opt eventually?
	pct_cut = 10;
	max_corr_cutoff = 0.4; % at least this much to count a line -- mean must be > this
	smax = 200;
	if (isstruct(opt))
		if (isfield(opt,'pct_cut'))
		  pct_cut = opt.pct_cut;
		end
		if (isfield(opt,'max_corr_cutoff'))
		  max_corr_cutoff = opt.max_corr_cutoff;
		end
  	if (isfield(opt,'smax'))
		  smax = opt.smax;
		end
  end

	% --- size check - must be same
	s1 = size(im_s);
	s2 = size(im_t);
	if ((s1(1) == s2(1)) + (s1(2) == s2(2)) ~= 2 ) ; disp('Only identical image sizes supported at this point .');; return ; end

	% --- more setup . . .
	S = size(im_s);
	if (length(S) == 3) ; F = S(3) ; else F = 1; end

	% --- preprocess the target image -- this only need be done once
	if (s1(1) > s1(2)) 
		disp('Squaring images - ONLY WORKS WITH 2:1 1:2 aspect ratio');
		im_t = downsample(im_t,2);
	elseif (s1(2) > s1(1))
		disp('Squaring images - ONLY WORKS WITH 2:1 1:2 aspect ratio');
		im_t = downsample(im_t',2)';
	end
	dim_t = im_t;
	while(size(dim_t,1) > smax | size(dim_t,2) > smax)
		dim_t = downsample(downsample(dim_t,2)',2)';
	end
 
  % --- MAIN LOOP
	im_c = zeros(size(im_s)); % corrected image
	for f=1:F
		% --- square images if not square
	  im1 = im_s(:,:,f);
		sq_dx = 1;
		sq_dy = 1;
		if (s1(1) > s1(2)) 
			disp('Squaring images');
			im1 = downsample(im1,2);
			sq_dy = sq_dy*2;
		elseif (s1(2) > s1(1))
			disp('Squaring images');
			im1 = downsample(im1',2)';
			sq_dx = sq_dx*2;
		end

		% --- downsample (?)
		downsam = 1; % store downsample factor
		dim1 = im1;
		while(size(dim1,1) > smax | size(dim1,2) > smax)
			dim1 = downsample(downsample(dim1,2)',2)';
			downsam = downsam * 2;
		end
		cutsize = round(length(dim1)*(pct_cut/100));

		% --- correlate
		cm_x = corr(double(dim1),double(dim_t));
		cm_y = corr(double(dim1'),double(dim_t'));
		disp(['Corr with size: ' num2str(size(dim1,1)) ' by ' num2str(size(dim1,2))]);

		% --- look at diags . . . 
		sc1 = size(cm_x,1);
		sc2 = size(cm_x,2);

		dmul_x = zeros(size(cm_x,1),1);
		dmur_x = zeros(size(cm_x,1),1);
		for x=1:sc1
			dsuml = 0;
			dsumr = 0;
			for y=1:sc1-x+1
				dsumr = dsumr + cm_x(y,x+y-1); % toplef to botright, right side 
				dsuml = dsuml + cm_x(x+y-1,y); % toplef to botright, left side 
			end
			if ( y > cutsize) % skip low sample areas 
				dmul_x(x) = dsuml/y;
				dmur_x(x) = dsumr/y;
			end
		end

		dmul_y = zeros(size(cm_y,1),1);
		dmur_y = zeros(size(cm_y,1),1);
		for x=1:sc1
			dsuml = 0;
			dsumr = 0;
			for y=1:sc1-x+1
				dsumr = dsumr + cm_y(y,x+y-1); % toplef to botright, right side 
				dsuml = dsuml + cm_y(x+y-1,y); % toplef to botright, left side 
			end
			if (y > cutsize) % skip low sample areas
				dmul_y(x) = dsuml/y;
				dmur_y(x) = dsumr/y;
			end
		end

		% --- extract offsets based on peak of mean sum of diagonals of correlation matrix
		[max_corr_l x_off_l] = max(dmul_x);
		[max_corr_r x_off_r] = max(dmur_x);
		if (max_corr_l > max_corr_r)
			max_corr = max_corr_l;
			x_off_f = x_off_l;
		else
			max_corr = max_corr_r;
			x_off_f = -1*x_off_r;
		end

		% --- REJECT if correlaton too low 
		% (i.e., displacement is 0 -- you will always have a max, it may be very weak and tehrefore improper)
		if (max_corr >= max_corr_cutoff)  
			x_off = x_off_f*downsam*sq_dx;
		end

		% --- repeat for y direction
		[max_corr_l y_off_l] = max(dmul_y);
		[max_corr_r y_off_r] = max(dmur_y);
		if (max_corr_l > max_corr_r)
			max_corr = max_corr_l;
			y_off_f = y_off_l;
		else
			max_corr = max_corr_r;
			y_off_f = -1*y_off_r;
		end
		% --- REJECT if correlaton too low 
		% (i.e., displacement is 0 -- you will always have a max, it may be very weak and tehrefore improper)
		if (max_corr >= max_corr_cutoff)  
			y_off = y_off_f*downsam*sq_dy;
		end

		% ============ plotting for debug -- correlation matrix and peak of diagonal mean
		if ( 1 == 0) 
			figure;
			subplot(2,3,1);
			imshow(cm_x);
			axis square;
			colormap hsv;
			colorbar;
			subplot(2,3,2);
			plot(downsam:downsam:length(dmul_x)*downsam,dmul_x);
			subplot(2,3,3);
			plot(downsam:downsam:length(dmur_x)*downsam,dmur_x);

			subplot(2,3,4);
			imshow(cm_y);
			axis square;
			colormap hsv;
			colorbar;
			subplot(2,3,5);
			plot(downsam:downsam:length(dmul_y)*downsam,dmul_y);
			subplot(2,3,6);
			plot(downsam:downsam:length(dmur_y)*downsam,dmur_y);
			pause;
		end
		% ============ 

		% --- construct output image, and compute dx, dy 
		dx = -1*x_off;
		dy = -1*y_off;
		dx_v(f) = dx;
		dy_v(f) = dy;
		disp(['f: ' num2str(f) ' dx: ' num2str(dx) ' dy: ' num2str(dy)]);

		% construct the new image -- dx > 0 to right ; dy > 0 DOWN
		if (dy > 0)
			y1_s = 1;
			y2_s = S(1)-dy;
			y1_c = dy+1;
			y2_c = S(1);
		else
			y1_s = -1*dy + 1;
			y2_s = S(1);
			y1_c = 1;
			y2_c = S(1)+dy;
		end
		if (dx > 0)
			x1_s = 1;
			x2_s = S(2)-dx;
			x1_c = dx+1;
			x2_c = S(2);
		else
			x1_s = -1*dx + 1;
			x2_s = S(2);
			x1_c = 1;
			x2_c = S(2)+dx;
		end
		im_c(y1_c:y2_c,x1_c:x2_c,f) = im_s(y1_s:y2_s,x1_s:x2_s,f);
		E(f) = sum(sum(abs(im_c-im_s)));
  end
