%
%  This is a script for testing image registration methods - dirty, for a reason.
%    Also, not a function s.t. you can keep stuff in memory easily
%

% load im ; normalize in some way
%F = 25;
F = 100;
if (1 == 1)
	clear im1;
	clear im2;

	for i=1:F ; 
	    % 10/30 20093 trial 12 is a good motion trial
%			 im1(:,:,i) = double(imread('/Users/speron/data/mouse_gcamp_learn/an20093/2009_10_30/scanimage//an20093_10_30_main012.tif', i)) ; 
			im1(:,:,i) = double(imread('~/data/test_imreg_data/NXJF36705_0719_tuftA_25x_suf_beh__008.tif',i));
%			im1(:,:,i) = double(imread('~/data/test_imreg_data/TK_091030_JF24076_beh_005_Green.tif',i));
      % 10/22 1 + 10/13 1 is good rotation
%			im1(:,:,i) = double(imread('/Users/speron/data/mouse_gcamp_learn/an20093/2009_10_22/scanimage//an20093_10_22_post_001.tif', i)) ; 
  end
	for i=1:min(25,F) ; 
%			im2(:,:,i) = double(imread('/Users/speron/data/mouse_gcamp_learn/an20093/2009_10_22/scanimage//an20093_10_22_post_001.tif', i)) ; 
			%im2(:,:,i) = double(imread('/Users/speron/data/mouse_gcamp_learn/an20093/2009_10_14/scanimage//an20093_10_13_post_001.tif', i)) ; 
			im2(:,:,i) = double(imread('/Users/speron/data/mouse_gcamp_learn/an20093/2009_10_14/scanimage//an20093_10_13_main_013.tif', i)) ; 
	end
	M1 = max(max(max(im1)));
	M2 = max(max(max(im2)));

  M1 = mean(mean(mean(im1)));
  M2 = mean(mean(mean(im2)));

	im1 = im1/M1;
	im2 = im2/M2;

%    for i=1:F ; imshow(im1(:,:,i));pause; end
end
% compute local minima

% -----------------
% plot side by side
if ( 1 == 0)
	S = size(im1);
	im1_rgb = zeros(S(1),S(2), 3);
	im2_rgb = zeros(S(1),S(2), 3);
	im1_rgb(:,:,1) = mean(im1,3);
	f = figure ; 
	for f=1:50;
		for i=2:28
		%	subplot(2,2,1);  imshow(im1_rgb) ; axis square;
		%	subplot(2,2,2);  imshow(im2_rgb) ; axis square;
		%	subplot(2,2,3);
			lim = double(imread(sprintf('/Users/speron/data/mouse_gcamp_learn/an22707/2009_10_14/scanimage//an22707_10_14_main_%.3d.tif', f), i)) ; 
			lim = lim/max(max(lim));
			im2_rgb(:,:,2) = lim;
			imshow(im1_rgb+im2_rgb) ; axis square;
			disp('dibs');
			pause(.1);
		end
	end
end

% easy test of imreg
if ( 0 == 1)

   % ims should shift RIGHT
	ims = zeros(20,50) ; 
	ims(1:20,5) = 1; 
	imt = zeros(20,50) ; 
	imt(1:20,10) = 1; 
	figure ; 
	subplot(2,2,1) ; 
	imshow(ims) ; 
	title('ims') ; 
	subplot(2,2,2) ; 
	imshow(imt) ; 
	title('imt') ;
	subplot(2,2,3);
  im_c = imreg_fft(ims, imt, '');

  % ims should shift LEFT
	ims = zeros(20,50) ; 
	ims(1:20,10) = 1; 
	imt = zeros(20,50) ; 
	imt(1:20,5) = 1; 
	figure ; 
	subplot(2,2,1) ; 
	imshow(ims) ; 
	title('ims') ; 
	subplot(2,2,2) ; 
	imshow(imt) ; 
	title('imt') ;
	subplot(2,2,3);
  im_c = imreg_fft(ims, imt, '');

  % ims should shift DOWN
	ims = zeros(20,50) ; 
	ims(5, 1:50) = 1; 
	imt = zeros(20,50) ; 
	imt(10, 1:50) = 1; 
	figure ; 
	subplot(2,2,1) ; 
	imshow(ims) ; 
	title('ims') ; 
	subplot(2,2,2) ; 
	imshow(imt) ; 
	title('imt') ;
	subplot(2,2,3);
  im_c = imreg_fft(ims, imt, '');
end

% test imreg_ methods
if ( 0 ==  1 )
	im_t = mean(im2,3); % target image
	ims = im1;
  im_c = imreg_fft(ims, im_t, '');
  %im_c = imreg_corr(ims, im_t, '');

	% play as movie ...
	figure;
	S = size(im_t);
	im1_rgb = zeros(S(1),S(2), 3);
	im2_rgb = zeros(S(1),S(2), 3);
	im1_rgb(:,:,1) = im_t;
	for f=1:F
		subplot(1,2,1);
		im2_rgb(:,:,2) = im_c(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;
		subplot(1,2,2);
		im2_rgb(:,:,2) = ims(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;
		pause
	end
end

% -----------------
% Landmark selector
if ( 1 == 0 )
	im_c = zeros(size(im_s)); % corrected film
  for f=1:F
	  im_tmp = im_s (:,:,f);
		M = median(reshape(im_tmp,1,[]));
		val = find(im_tmp < 1.1*M & im_tmp > 0.9*M);
		im_tmp = zeros(size(im_tmp));
		im_tmp(val) = 1;
		im_tmp = im2bw(im_tmp, .5);
		im_tmp = imdilate(im_tmp,strel('disk', 10));
		im_tmp = imerode(im_tmp,strel('disk', 10));
%		imshow(im_tmp);

%    L = watershed(im_tmp);
%    imshow(label2rgb(L));
    cc = bwconncomp(im_tmp,4);
		labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled);
    imshow(RGB_label);


		axis square;
		pause;
	end
end

% -------------------
% my own 'gradient descent' method
if ( 1 == 1)
%  im_s = im1;
%  im_s = im1(:,:,1);
  im_s = im1;
%  im_s = im1(:,:,40:60);
	im_t = mean(im1(:,:,1:5),3);

  im_s_o = im_s;
  im_t_o = im_t;

%	im_t = im_t/median(reshape(im_t,[],1));
%	im_s = im_s/median(reshape(im_s,[],1));
im_s = im_s/max(reshape(im_s,[],1));
im_t = im_t/max(reshape(im_t,[],1));

  % height x width x n ; scanning is along WIDTH
	height = size(im_s,1);
	width = size(im_s,2);
	nframes = size(im_s,3);
	nlinesperblock = 1; % number of lines per block
  max_n_steps = 50;
	corrs = zeros(1,max_n_steps);
	dxs = zeros(1,max_n_steps);
	dys = zeros(1,max_n_steps);
%	corrthresh = .95; 

			dx = 0; % right > 0
			dy = 0; % down > 0
			maxdx = 50;
			maxdy = 25;

% returns
  lE_r = zeros(nframes, height/nlinesperblock); % line-by-line error
  dx_r = zeros(nframes, height/nlinesperblock);
  dy_r = zeros(nframes, height/nlinesperblock);

  % GAUSSIAN convolve
if ( 1 == 1 )
	g_r = 5;
	gauss = customgauss([2*g_r+1 2*g_r+1], 2.5 , 2.5, 0, 0, 1, [1 1]*(g_r+1)/2);
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
	for f=1:nframes
tic
	  for l=1:(height/nlinesperblock)
		  corrs = 0*corrs;
%	  for l=150:155
%	  for l=40
		  s_l = ((l-1)*nlinesperblock)+1;
		  e_l = s_l + nlinesperblock-1;
if (1 == 1)
			t_line = reshape(im_t(s_l:e_l,:,1),[],1); % line from target image -- what you want to match to
			s_line = reshape(im_s(s_l:e_l,:,f),[],1); % line from target image -- what you want to match to

			% --- original displacement
			R = corrcoef(t_line,s_line);
		  Rvec = R(1,2);
end

% IMPROVE:
% 1) memory for positions already tested (matrix?)
% 2) handle line BLOCKS *** FFT
% 3) score correlations -- and give more weight to high ones in a final pass
% 4) border issues -- e.g., dy < 0 probably means you will lose your top next - how to deal w/ this?
% 5) see the error space -- loop dx, dy
% 6) try fft, correlation on a local scale
% uncomment and there is no inter-step memory
%      if (abs(dx) > maxdx/2 | abs(dy) > maxdy/2 | dy < 0)
			  dx = 0; % right > 0
				dy = 0; % down > 0
%			end
% FFT based
if ( 1 == 0)
step = 0;
      tgt_sl = max(1, s_l-maxdy);
      tgt_el = min(height, e_l+maxdy);

			% get slice of target
			tgt_slice = im_t(tgt_sl:tgt_el,:,1);
     
		  % get slice of source
			src_slice = zeros(size(tgt_slice));
			if (l < maxdy) 
			  sli = l;
			elseif ((height - l) < maxdy)
			  sli = maxdy - (height-l);
			else
			  sli = maxdy+1;
			end
			disp(['l: ' num2str(l) ' sli: ' num2str(sli)]);
			src_slice(sli,:) = im_s(l,:,f);

     Ss = size(src_slice);

		  % 2d cross correlation
%      R = xcorr2(src_slice, tgt_slice);
%      [irr idx] = max(reshape(R, [], 1));

%			dy = floor(idx/size(R,2));
%			dx = Ss(2) - (((idx/size(R,2))-dy)*size(R,2));

			% compute fft 2d - use padded matrices
			fim_s = zeros(Ss(1)*2,Ss(2)*2);
  		fim_s((1/4)*2*Ss(1):(3/4)*2*Ss(1)-1,(1/4)*2*Ss(2):(3/4)*2*Ss(2)-1) = src_slice;
			fim_t = zeros(Ss(1)*2,Ss(2)*2);
			fim_t((1/4)*2*Ss(1):(3/4)*2*Ss(1)-1,(1/4)*2*Ss(2):(3/4)*2*Ss(2)-1) = tgt_slice;
			R = real(ifft2(fft2(rot90(rot90(fim_s))).*fft2(fim_t)));

			[irr idx] = max(reshape(R,4*Ss(1)*Ss(2),1));


			% derive the x, y displacements
			dx = floor(idx/(2*Ss(1)));
			dy = round(((idx/(2*Ss(1)))-dx) * 2*Ss(1));
			if (dx > Ss(2)) ; dx = -1*(2*Ss(2) - dx); end
			if (dy > Ss(1)) ; dy = -1*(2*Ss(1) - dy); end
      dy = -1*dy;
			% dx, dy from fft
         
end

% gradient descent discrete numerical
if ( 1 == 1 ) 
      for step=1:max_n_steps
%	corrz = zeros(61,121);
%		for dx=-60:60
%		for dy=-30:30
				% -- compute cross corr in 4 displacement directions, move, rinse, repeat
				h_r = [max(1,1-dx) min(width,width-dx)]; % horizontal range IN SRC
				v_r = [max(1,s_l+dy) min(height, e_l+dy)] ; % vertical range
				H = h_r(1):h_r(2);
				V = v_r(1):v_r(2);
				% down
				if (v_r(2)+1 < height)
					s_line = reshape(im_s(V+1,H,f),[],1); % line from target image -- what you want to match to
%					if (dy == 0) ; disp(['dy 0 ; h_r: ' num2str(h_r)]); end
%disp(['f: ' num2str(f) ' dx: ' num2str(dx) ' dy: ' num2str(dy)]);
					R = corrcoef(t_line(max(1,1+dx):min(width,width+dx)),s_line);
%	imshow([s_line' ; t_line((max(1,1+dx):min(width,width+dx)))']); colormap(jet) ; title([num2str(dx) ' dy ' num2str(dy)]);pause;
					Rvec(2) = R(1,2);
				else
					Rvec(2) = 0;
				end
				% up
				if (v_r(1)-1 > 0) 
					s_line = reshape(im_s(V-1,H,f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+dx):min(width,width+dx)),s_line);
					Rvec(3) = R(1,2);
				else
					Rvec(3) = 0;
				end
				% right
				if (dx+1 < width)
				  DX = dx + 1;
					n_h_r = [max(1,1-DX) min(width,width-DX)]; % horizontal range
					s_line = reshape(im_s(V,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+DX):min(width,width+DX)),s_line);
					Rvec(4) = R(1,2);
				else
					Rvec(4) = 0;
				end
				% left
				if (width+dx-1 > 1)
				  DX = dx-1;
					n_h_r = [max(1,1-DX) min(width,width-DX)]; % horizontal range
					s_line = reshape(im_s(V,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+DX):min(width,width+DX)),s_line);
					Rvec(5) = R(1,2);
				else
					Rvec(5) = 0;
				end
			if ( 1 == 0 ) % diagnl?
				% down, right
				if (v_r(2)+1 < height & h_r(1)+1 < width)
					n_h_r = [max(1,1+dx+1) min(width,width+dx+1)]; % horizontal range
					s_line = reshape(im_s(V+1,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+dx+1):min(width,width+dx+1)),s_line);
					Rvec(6) = R(1,2);
				else
					Rvec(6) = 0;
				end
				% down, left
				if (v_r(2)+1 < height & h_r(2)-1 > 1)
					n_h_r = [max(1,1+dx-1) min(width,width+dx-1)]; % horizontal range
					s_line = reshape(im_s(V+1,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+dx-1):min(width,width+dx-1)),s_line);
					Rvec(7) = R(1,2);
				else
					Rvec(7) = 0;
				end
				% up, right
				if (v_r(1)-1 > 0 & h_r(1)+1 < width)
					n_h_r = [max(1,1+dx+1) min(width,width+dx+1)]; % horizontal range
					s_line = reshape(im_s(V-1,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+dx+1):min(width,width+dx+1)),s_line);
					Rvec(8) = R(1,2);
				else
					Rvec(8) = 0;
				end
				% up, left
				if (v_r(1)-1 > 0 & h_r(2)-1 > 1)
					n_h_r = [max(1,1+dx-1) min(width,width+dx-1)]; % horizontal range
					s_line = reshape(im_s(V-1,n_h_r(1):n_h_r(2),f),[],1); % line from target image -- what you want to match to
					R = corrcoef(t_line(max(1,1+dx-1):min(width,width+dx-1)),s_line);
					Rvec(9) = R(1,2);
				else
					Rvec(9) = 0;
				end
     end

				% compute best direction based on derivatives . . . 
				%dRdx = ((Rvec(1)-Rvec(5))+(Rvec(4)-Rvec(1))/2; % positive means rightward; neg left
				%dRdy = ((Rvec(1)-Rvec(2))+(Rvec(3)-Rvec(1))/2; % positive means down; neg up
				%if (dRdx > 0) ; dx = dx + 1; else ; dx = dx - 1; end
				%if (dRdx > 0) ; dx = dx + 1; else ; dx = dx - 1; end
%				disp(['rv2: ' num2str(Rvec(2))]);
%corrz(dy+31,dx+61) = Rvec(2);
%end ; end ; pause
%Rvec
%if (step == 1) ; disp (['init: ' num2str(Rvec(1))]); end
%if ( l == 151 ) ; pause ; end
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
				elseif (Ridx == 6)
				  dx = min(dx+1,maxdx);
				  dy = min(dy+1,maxdy);
					Rvec(1) = Rvec(6);
				elseif (Ridx == 7)
				  dx = max(dx-1,-1*maxdx);
				  dy = min(dy+1,maxdy);
					Rvec(1) = Rvec(7);
				elseif (Ridx == 8)
				  dx = max(dx-1,-1*maxdx);
				  dy = max(dy-1,-1*maxdy);
					Rvec(1) = Rvec(8);
				elseif (Ridx == 9)
				  dx = min(dx+1,maxdx);
				  dy = max(dy-1,-1*maxdy);
					Rvec(1) = Rvec(9);
				elseif(Ridx == 1)
				break; % disallow jumps
				  dx = round((rand(1)-0.5)*(maxdx/4));
				  dy = round((rand(1)-0.5)*(maxdy/4));
			  end
				if (dy <= -1*l) ; dy = -1*l +1 ; end
				if (dy+l > height) ; dy = height-l ; end
%			disp(['   steps: ' num2str(step) ' corr: ' num2str(lastbest) ' dx: ' num2str(dx) ' dy: ' num2str(dy) ' f: ' num2str(f) ' l: ' num2str(l)]);
	end
      end
			dx_r(f,l) = dx;
			dy_r(f,l) = -1*dy;
			lE_r(f,l) = Rvec(1);
%			disp(['steps: ' num2str(step) ' dx: ' num2str(dx) ' dy: ' num2str(dy) ' f: ' num2str(f) ' l: ' num2str(l)]);
		end
		mfsf = 10; % usualyl 10
		dx_r(f,:) = medfilt1(dx_r(f,:),round(l/mfsf));
		dy_r(f,:) = medfilt1(dy_r(f,:),round(l/mfsf));
toc
	end

  % ----- the all-important post-processing
  % Go thru and clean up dx/dy based on error of individual lines -- if the corr 
	%  of a given line, based on correlation of best fit, is below alpha*median corr,
	%  then set the value to the mean of the displacements of the line before and after
	%  this line that have a correlation gte to beta*median corr and occur in blocks of
	%  size gbs (good block size)
if ( 1 == 0 )
  % convenient vectors
  lE = reshape(lE_r',[],1); % error throughout, line-by-line
	dx_c = reshape(dx_r',[],1); % dx and dy -- Corrected
	dy_c = reshape(dy_r',[],1);
	mE = median(lE);

  alpha = .8;
	beta = 1;
	gbs = 10; % 10 in a row exceeding beta

  % go line-by-line
	lE_good = find(lE >= mE*beta);
	Lg = length(lE_good);
	lE_bad = find(lE < mE*alpha);
	Lb = length(lE_bad);
	last_nxt = [];
  for b=1:length(lE_bad)
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
			fidx = 1+floor(lE_good(nxt)/(height/nlinesperblock));
			lidx = lE_good(nxt)-((fidx-1)*(height/nlinesperblock));
			lidxb = lE_bad(b)-((fidx-1)*(height/nlinesperblock));
      disp(['f: ' num2str(fidx) ' from l: ' num2str(lidxb) ' to : ' num2str(lidx)]);
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

  % ---- correction at top, bottom

	% ---- apply median filter
  sL = height/nlinesperblock;
	mfsf = 5; % usualyl 10
	dx_c = medfilt1(dx_c,round(sL/mfsf));
	dy_c = medfilt1(dy_c,round(sL/mfsf));

	
	% *corrected* return displacement matrices
  dx_cr = zeros(nframes, height/nlinesperblock);
  dy_cr = zeros(nframes, height/nlinesperblock);
  
  sL = height/nlinesperblock;
  for f=1:nframes
	  si = (f-1)*sL + 1;
		ei = si + sL -1;
	  dx_cr(f,:) = dx_c(si:ei);
	  dy_cr(f,:) = dy_c(si:ei);
  end
end
	% call imreg_wrapup and get your final image
	wrap_opt.err_meth = 3; % correlation based
	wrap_opt.debug = 2;  % uncomment if you want to debug with movie
	wrap_opt.post_proc = [1 1 1 1];
	wrap_opt.lE = lE_r;
  [im_c E] = imreg_wrapup (im_s_o, im_t_o, dx_r, dy_r, [], wrap_opt);
end

% -----------------
% imreg_rigid -- rotatOr
if ( 0 == 1)
  im_s = im1;
	im_t = mean(im1(:,:,1:5),3);
  [im_c dx_r dy_r E] = imreg_dombeck_hmm(im_s, im_t, []);
end
if ( 0 == 1 )
  sim = size(im_s);
	nframes = sim(3);
	figure;
	im1_rgb = zeros(sim(1),sim(2), 3);
	im2_rgb = zeros(sim(1),sim(2), 3);
	vim_s = im_s/max(max(max(im_s)));
	vim_t = im_t/max(max(max(im_t)));
	dim_c = im_c/max(max(max(im_c)));
	im1_rgb(:,:,1) = vim_t;

	for f=1:nframes
		% plot
		subplot(2,2,1);
		im2_rgb(:,:,2) = dim_c(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;

		subplot(2,2,2);
		im2_rgb(:,:,2) = vim_s(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;

		if (exist('dx','var') && size(dx,1) >= f)
			subplot(2,2,3) ;
			plot(dx(f,:), 'b');
			title('dx');
			subplot(2,2,4) ;
			plot(dy(f,:));
			title('dy');
		end 

		pause
	end
end

% -----------------
% Greenberg et al.
if ( 0 == 1)
	im_t = mean(im2,3); % target image
	im_t = mean(im1,3); % target image
%	im_t = im1(:,:,12) ; % target
%	im_t = im_t/max(max(im_t));

	im_s = im1;
%im_s = mean(im1,3);
	im_c = zeros(size(im_s)); % corrected film
	% run the algo
	settings.move_thresh = 0.06; % .075 % .06 paper
	settings.corr_thresh = 0.9; % .75 % .85 paper ... .9 works 4 me
  settings.max_iter = 50; % 120 paper too
	settings.scanlinesperparameter = 0.25; % 2 
	settings.pregauss = .75 ; %0.75
	settings.haltcorr = 0.99;% .95 ; .99 paper
	settings.dampcorr = 0.8; % .8 paper as well
 % [p, iter_used, corr, failed, settings, xpixelposition, ypixelposition] = ...
 %  extern_greenberg_motioncorrect(im_s,im_t,[],settings,[]);


	% construct the corrected image -- p consists of [dx dy] -- based on size of p 
	im_c = zeros(size(im_s));
	S_im_c = size(im_c);
	nc_p = size(p,2);

  p2im_c = S_im_c(1)/((nc_p/2)-1); % how many img columns does each p entry span
	if (p2im_c < 1) ; dpsl = round(1/p2im_c) ; else ; dpsl =1 ; end % how many divisions per single scan line?
%	p2im_c = round(p2im_c);
	if (p2im_c == 0) ; p2im_c = 1; end

  for f=1:25
	  if (failed(f)) ; continue ; end
	  disp(['f: ' num2str(f)]);
	  dx = p(f,2:nc_p/2); % drop first term -- alternative would be to average
		                   % since you have n+1 pts for n (image) rows
		dy = p(f, (nc_p/2)+2:nc_p); % again drop the first of n+1 to get n entries
     
		% post processing -- discontinuities not allowed
    % fix by setting all dy to median
%	  dy = mean(dy)*ones(size(dy)); 
%	  dy = median(dy)*ones(size(dy)); 
	  % fix by fitting to linear
 % 	dy_pol = polyfit(1:length(dy),dy,1) ;
	%	dy = dy_pol(2) + dy_pol(1)*(1:length(dy));
		% median filter dx
%		mfl = 5;
%		dx = medfilt1(dx,round(length(dx)/mfl));

    % GOOD:
		fs = round(length(dx)/10); % filter size
		sdx = zeros(1,length(dx) + 2*fs);
		sdx = [dx(5)*ones(1,fs) dx dx(length(dx)-5)*ones(1,fs)]; % dont take edge values bc those are often strange
		sdx = medfilt1(sdx,fs); 
		dx = sdx(fs+1:length(sdx)-fs);

		fs = round(length(dy)/10); % filter size
		sdy = zeros(1,length(dy) + 2*fs);
		sdy = [dy(5)*ones(1,fs) dy dy(length(dy)-5)*ones(1,fs)]; % dont take edge values bc those are often strange
		sdy = medfilt1(sdy,fs); 
		dy = sdy(fs+1:length(sdy)-fs);

%		dx = medfilt1(dx,round(length(dx)/10));
%		dy = medfilt1(dy,round(length(dy)/10));


		% edge effects
 %   dx(1:round(length(dx)/mfl/2)) = dx(round(length(dx)/mfl));
 %   dx(round(length(dx)*(1-(1/mfl/2))):length(dx)) = dx(round(1-(1/mfl)));

%		fs = 3;
%	  dy = conv(dy,ones(1,fs)/fs);
 %   dy = dy(fs/2:length(dy)-fs/2);

    % determine bounds for each p
		x_i = 1;
		for i=1:(nc_p/2)-1

		  % The rows -- or y coordinates
			if (dpsl == 1)
				y_s = (i-1)*p2im_c+1:i*p2im_c;
			else
				y_s = ceil(i/dpsl);
			end
      y_c = round(y_s + dy(i));

			y_bad = find (y_c < 1 | y_c > S_im_c(1));
			y_good = setdiff(1:length(y_s),y_bad);
			y_s = y_s(y_good);
			y_c = y_c(y_good);

		  % The columns -- or x coordinates -- ASSUME integral number of lines
      x_s = (x_i-1)*(S_im_c(2)/dpsl)+1:(x_i)*(S_im_c(2)/dpsl);
      x_c = round(x_s + dx(i));

			x_i = x_i + 1; 
			if (x_i > dpsl) ; x_i = 1; end

			x_bad = find (x_c < 1 | x_c > S_im_c(2));
			x_good = setdiff(1:length(x_s),x_bad);
			x_s = x_s(x_good);
			x_c = x_c(x_good);

      
      % build image subsection if there is something there -- at edges, may have nothing to do
			if (length(y_s) > 0 & length(x_s) > 0)
				im_c(y_c,x_c,f) = im_s(y_s,x_s,f);
			end
		end
		DX(f,:) = dx;
		DY(f,:) = dy;
	end

	% play as movie ...
	figure;
	S = size(im1);
	im1_rgb = zeros(S(1),S(2), 3);
	im2_rgb = zeros(S(1),S(2), 3);
	im_s = im_s/max(max(max(im_s)));
	im_t = im_t/max(max(max(im_t)));
	im_c = im_c/max(max(max(im_c)));
	im1_rgb(:,:,1) = im_t;
	for f=1:F
		% compute diffs
		imsl = reshape(im_s(:,:,f),1,[]);
		imcl = reshape(im_c(:,:,f),1,[]);
		imtl = reshape(im_t,1,[]);
		val = find(imcl ~= 0);
		d_uncorr = sum(abs(imsl(val)-imtl(val)));
		d_corr = sum(abs(imcl(val)-imtl(val)));
d1(f) = d_corr
		% plot
		subplot(2,2,1);
		im2_rgb(:,:,2) = im_c(:,:,f);
		imshow(im1_rgb + im2_rgb);
		title(['diff: ' num2str(round(d_corr))]);
		axis square;

		subplot(2,2,2);
		im2_rgb(:,:,2) = im_s(:,:,f);
		imshow(im1_rgb + im2_rgb);
		title(['diff: ' num2str(round(d_uncorr))]);
		axis square;

		subplot(2,2,3) ;
		plot(DX(f,:), 'b');
		title('dx');
		subplot(2,2,4) ;
		plot(DY(f,:));
		title('dy');

		pause
	end
	

end

% -----------------
% fft based translation (no rot.)
if ( 0 == 1)
	g_r = 7; % MUST BE ODD
	gauss = customgauss([2*g_r+1 2*g_r+1], 1.5 , 1.5, 0, 0, 1, [1 1]*(g_r+1)/2);
	im_t = mean(im2,3); % target image
	im_t = mean(im1,3); % target image
	im_t = im_t/max(max(im_t));
	im_c = zeros(size(im1)); % corrected film
% INVERT
%im_t = (-1*im_t) + 1;
	im_sconv = zeros(size(im1)); % convolved
	S = size(im_t);
	for f=1:F
		% gaussian convolve, resize
		im_s = im1(:,:,f);
		im_s = conv2(im_s,gauss);
		im_sconv(:,:,f) = im_s(g_r+1:S(1)+g_r, g_r+1:S(2)+g_r);
		im_sconv(:,:,f) = im_sconv(:,:,f)/max(max(im_sconv(:,:,f)));
		im_s = im_s(g_r+1:S(1)+g_r, g_r+1:S(2)+g_r); 
		im_s = im_s/max(max(im_s));

%im_s = (-1*im_s) + 1;

	%imshow(im_s); pause;
		% compute fft 2d
    fim_s = zeros(S(1)*2,S(2)*2);
    fim_s((1/4)*2*S(1):(3/4)*2*S(1)-1,(1/4)*2*S(2):(3/4)*2*S(2)-1) = im_s;
    fim_t = zeros(S(1)*2,S(2)*2);
    fim_t((1/4)*2*S(1):(3/4)*2*S(1)-1,(1/4)*2*S(2):(3/4)*2*S(2)-1) = im_t;
		R = real(ifft2(fft2(rot90(rot90(fim_s))).*fft2(fim_t)));
%    R = R(1:S(1),1:S(2));
	%imshow(R, [min(min(R)) max(max(R))]); pause;
		[irr idx] = max(reshape(R,4*S(1)*S(2),1));
idx
		% derive the x, y displacements
		dy = floor(idx/(2*S(1)));
		dx = round(((idx/(2*S(1)))-dy) * 2 * S(2));
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
		im_c(y1_c:y2_c,x1_c:x2_c,f) = im_s(y1_s:y2_s,x1_s:x2_s);
	end
	im_c = im_c/max(max(max(im_c)));

	% play as movie ...
	figure;
	im1_rgb = zeros(S(1),S(2), 3);
	im2_rgb = zeros(S(1),S(2), 3);
	im1_rgb(:,:,1) = im_t;
	im_sconv = im_sconv/max(max(max(im_sconv)));
	for f=1:F
		subplot(1,2,1);
		im2_rgb(:,:,2) = im_c(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;
		subplot(1,2,2);
		im2_rgb(:,:,2) = im_sconv(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;
		pause
	end
end

% -----------------
% corr based
if (1 == 0)
% ??? how to normalize -- presumably to maximum in STACK
	g_r = 5;
	gauss = customgauss([2*g_r+1 2*g_r+1], .65 , .65, 0, 0, 1, [3 3]);
	im_t = mean(im2,3); % target image
	im_t = im_t/max(max(im_t));
	im_c = zeros(size(im1)); % corrected film
	im_sconv = zeros(size(im1)); % convolved
	S = size(im_t);
sim_t = im_t(1+S(1)/4:3*S(1)/4,1+S(2)/4:3*S(2)/4);
%sim_t = im_t(1+S(1)/8:5*S(1)/8,1+S(2)/8:5*S(2)/8);
	for f=1:F
		% gaussian convolve, resize
		im_s = im1(:,:,f);
		im_s = conv2(im_s,gauss);
		im_sconv(:,:,f) = im_s(g_r+1:S(1)+g_r, g_r+1:S(2)+g_r);
		im_sconv(:,:,f) = im_sconv(:,:,f)/max(max(im_sconv(:,:,f)));
		im_s = im_s(g_r+1:S(1)+g_r, g_r+1:S(2)+g_r); 
		im_s = im_s/max(max(im_s));

sim_s = im_s(1+S(1)/4:3*S(1)/4,1+S(2)/4:3*S(2)/4);
%sim_s = im_s(1+S(1)/8:5*S(1)/8,1+S(2)/8:5*S(2)/8);


    [dx dy] = find_optimal_offset(sim_s,sim_t,'',1);
%    [dx dy] = find_optimal_offset(im_s,im_t,'',2);
 dx = -1*dx; 
 dy = -1*dy; 
% dy = -1*dy; 
%dx = 0;
%dy = 0;
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
		im_c(y1_c:y2_c,x1_c:x2_c,f) = im_s(y1_s:y2_s,x1_s:x2_s);
	end
	im_c = im_c/max(max(max(im_c)));

	% play as movie ...
	figure;
	im1_rgb = zeros(S(1),S(2), 3);
	im2_rgb = zeros(S(1),S(2), 3);
	im1_rgb(:,:,1) = im_t;
	im_sconv = im_sconv/max(max(max(im_sconv)));
	for f=1:F
		subplot(1,2,1);
		im2_rgb(:,:,2) = im_c(:,:,f);
		imshow(im1_rgb + im2_rgb);
		title('TARGET in red');
		axis square;
		subplot(1,2,2);
		im2_rgb(:,:,2) = im_sconv(:,:,f);
		imshow(im1_rgb + im2_rgb);
		axis square;
		pause
	end
end

% -----------------
% corr based
if ( 1 == 0)
	R = 1;
	corrim = zeros(size(im,1),size(im,2));
	for x=1+R:size(im,1)-1-R ; 
			for y=1+R:size(im,2)-1-R ;
					for r1=-1*R:R
							for r2=-1*R:R
								cc = corrcoef(reshape(im(x,y,:),S,1),reshape(im(x+r1,y+r2,:),S,1)) ;
								corrim(x,y) = corrim(x,y)+cc(2,1);
							end
					end
			end ; 
			disp(['x: ' num2str(x)]); 
	end
end
