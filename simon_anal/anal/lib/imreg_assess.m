%
% function imreg_assess(src_path_pre, src_path_post, tgt_mode, tgt, f2)
%
% S Peron Dec. 2009
%
% This evaluates the quality of image registration on several metrics.  
%   src_path_pre: the source image stack original
%   src_path_post: the source image stack following processing 
%   tgt_mode: 0: you will specify a file as tgt
%             1: you will specify a stack as tgt
%             2 element vector: mean of frame range specified (ORIGINAL source file; 
%               if both are 0, will use entire stack)
%   tgt: depending on tgt_mode ...
%   f2: if passed, 'hold on' for figure 2
%
% Returns handle to figure with frame-by-frame corr.
%
function f2 =  imreg_assess(src_path_pre, src_path_post, tgt_mode, tgt, f2, col)

  % --- load the stacks
	im_s_pre = load_image(src_path_pre, -1, []); % load all frames, chans
	im_s_post = load_image(src_path_post, -1, []); % load all frames, chans

	% --- target image construction -- based on tgt_mode, tgt
	if (tgt_mode == 1) 
    im_t = tgt;
	elseif(tgt_mode == 0)
	  im_t = load_image(tgt, -1, []); % load all frames, chans
	elseif(length(tgt_mode) == 2)
	  if (sum(tgt_mode) == 0)
		  im_t = mean(im_s_pre,3);
		else
		  im_t = mean(im_s_pre(:,:,tgt_mode(1):tgt_mode(2)),3);
		end
	end

	% --- figure?
	if (~exist('f2','var'))
	  f2 = -1
	end

	% --- show before and after mean and max projections
	pre_maxproj = max(im_s_pre,[],3);
	post_maxproj = max(im_s_post,[], 3);

	pre_meanproj = mean(im_s_pre,3);
	post_meanproj = mean(im_s_post,3);

	f1 = figure;
	% Max projection
  M =max( max(max(pre_maxproj)),max(max(post_maxproj)));
	subplot(2,2,1);
	imshow(pre_maxproj, [0 M]);
	title('Pre-processing maximal projection');
	axis square;

	subplot(2,2,2);
	imshow(post_maxproj, [0 M]);
	title('Post-processing maximal projection');
	axis square;

	% Mean projection
  M =max( max(max(pre_maxproj)),max(max(post_maxproj)));
	subplot(2,2,3);
	imshow(pre_meanproj, [0 M]);
	title('Pre-processing mean projection');
	axis square;

	subplot(2,2,4);
	imshow(post_meanproj, [0 M]);
	title('Post-processing mean projection');
	axis square;

  % --- Measure 'motion' - mean difference across all pixels
	mu_pre = mean(reshape(im_s_pre,[],1));
	mu_post = mean(reshape(im_s_pre,[],1));
	for f=2:size(im_s_pre,3) % assume same n frames ; this is complicated because you need to ignore 0'd pixels

	  % turn both frames into vectors
    pre_1 = reshape(im_s_pre(:,:,f-1),[],1);
    pre_2 = reshape(im_s_pre(:,:,f),[],1);

		% determine pixels not equal to 0, -1
		val = find(pre_1 > 0 & pre_2 > 0);

		% compute diff -- normalize to n_pix, mean intensity
		d_pre(f-1) = sum(abs(pre_2(val)-pre_1(val)))/length(val)/mu_pre;

    % repeat
    post_1 = reshape(im_s_post(:,:,f-1),[],1);
    post_2 = reshape(im_s_post(:,:,f),[],1);
		val = find(post_1 > 0 & post_2 > 0);
		d_post(f-1) = sum(abs(post_2(val)-post_1(val)))/length(val)/mu_post;
	end

  if ( f2 == - 1) 
    f2 = figure;
	else 
	  figure(f2);
	end
	subplot(2,1,1);
	hold on;
	plot (1:length(d_pre), d_pre, 'r-', 1:length(d_post), d_post,[col '-']);
	xlabel('Frame');
	ylabel({'Interframe Difference', 'Normalized to mean intensity, number of pixels (A.U.)'});
	set(gca, 'TickDir','out');
	legend('Raw data', 'Registered data');

  % --- measure correlation with source, frame-by-frame
	vt = reshape(im_t,1,[]);
	for f=1:size(im_s_pre,3);
		vpre = reshape(im_s_pre(:,:,f),1,[]);
		vpost = reshape(im_s_post(:,:,f),1,[]);
		valpre = find(vpre > 0);
		valpost = find(vpost > 0);

		R = corrcoef(vt(valpre), vpre(valpre));
		e_pre(f) = R(1,2);
		R = corrcoef(vt(valpost), vpost(valpost));
		e_post(f) = R(1,2);
	end

	subplot(2,1,2);
	hold on;
	plot (1:length(e_pre), e_pre, 'r-', 1:length(e_post), e_post, [col '-']);
	xlabel('Frame');
	ylabel('Correlation between source and target image');
	set(gca, 'TickDir','out');
	legend('Raw data', 'Registered data');

	% --- summary data
%	disp(['proc: ' src_path_post ' mean norm. int. pre: ' num2str(mean(d_pre)) ' post: ' num2str(mean(d_post))]);
%	disp(['proc: ' src_path_post ' sd norm. int. pre: ' num2str(std(d_pre)) ' post: ' num2str(std(d_post))]);
%	disp(['proc: ' src_path_post ' cv norm. int. pre: ' num2str(std(d_pre)/mean(d_pre)) ' post: ' num2str(std(d_post)/mean(d_post))]);
	d_pre_z = d_pre - min(d_pre);
	d_post_z = d_post- min(d_post);
	disp(['proc: ' src_path_post ' mean norm. int. second der. pre, 0d: ' num2str(mean(abs(diff(d_pre_z)))) ' post: ' num2str(mean(abs(diff(d_post_z))))]);
%	disp(['proc: ' src_path_post ' cv zerod norm int. pre.: ' num2str(std(d_pre_z)/mean(d_pre_z)) ' post: ' num2str(std(d_post_z)/mean(d_post_z))]);
	disp(['proc: ' src_path_post ' mean corr pre: ' num2str(mean(e_pre)) ' post: ' num2str(mean(e_post))]);
  
