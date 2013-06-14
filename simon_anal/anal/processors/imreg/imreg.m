% 
% S Peron Sept. 2009
%
% This is a processor IMREG; make a directory, edit get_processors.m, and put
%  your new processor, based on this, in there.  Create a xxx_control as gui, if
%  you wish.
%
% "func" is the *string* name of the function you wish to call below, with 
%        params always getting passed thereto.
%
% "params" is a structure, with params.value carrying content.  This allows us 
%          type independence obviating need for a huge number of variables. 
% 
% I would love to use MATLAB objects, but this allows us backwards compatability ...
%
function retparams = imreg(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize imreg processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('imreg processor init start ...');

	% --- start the gui
  [winhan handles_struct] = imreg_control();

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	glovars.processor_step(params(1).value).gui_handle = handles_struct;

	disp('imreg processor init end ...');

%
% Closes the imreg processor -- basically destructor.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = shutdown(params)
  retparams = [];

%
% The core of the processor -- this guy is *not* allowed to talk to glovars.
%
%  params:
%    1: path of image file to process 
%    2: output path 
%    3: method to use: 1: Piecewise 2: 'Greeberg et al.', 3: 'FFT', 4: 'Rigid', 5: '3D Affine', 6:'Disable step'
% 	 4: how to preprocess target img: 1 - raw ; 2 - mean ; 3 - median ; 4 - max projection
%    5: target img path set to 'auto' if mode is auto (3)
%    6: img frame#; set to -1 implies "use whole stack"
%    7: stillest consec frames: -1: ignore ; > 0 : select this many stillest consecuttive frames as target
%    8: source pre-processing : 1 - as is ; 2 - mean ; 3 - frame range (NOT SUPPORTED)
%    9: number of channels for source image
%   10: channel used for source image
%   11: 1: gui-based 2: parallel/standalone mode
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image path if this is an outputting processor
%
function retparams = process(params)
  global glovars;
  retparams = [];

  % assign meaningful names to params
  src_path = params(1).value;
	out_path = params(2).value;
	imreg_meth = params(3).value;
	tgt_preproc_meth = params(4).value;
	tgt_path = params(5).value;
	tgt_frm = params(6).value;
	tgt_still_nfrm = params(7).value;
  src_preproc_meth = params(8).value;
  nchan = params(9).value;
  usedchan = params(10).value;
  exec_mode = params(11).value;

	srcim_opt.numchannels = nchan;
	srcim_opt.channel = usedchan;
  
  disp(['Starting processor imreg on source file ' src_path ' and output file ' out_path]);

  % --- sanity checks

  % --- preparation
  
	% read, process src images
	[im_s, im_descr] = load_image(src_path, -1, srcim_opt);
	if (size(im_s,3) > 1 & src_preproc_meth == 2) % multiframe source AND you requested mean
	  im_s_o = im_s; % save it -- you need to post-process use this
	  im_s = mean(im_s,3);
	end

  % auto determine target image?  
	if(strcmp(tgt_path, 'auto') == 1)
	  % parse source image path to get path
		sepidx = find(src_path == filesep);
		mat_path = [src_path(1:sepidx(length(sepidx)-1)) filesep 'imreg_err_file.mat'];
		lock_path = [src_path(1:sepidx(length(sepidx)-1)) filesep 'lock.m'];

    % check if a lock file exists, which means another process is doing error analysis and you wait ...
		while(exist(lock_path, 'file') == 2)
			disp(['Lock ' lock_path ' exists -- waiting 1 s']);
			pause(1);
		end

		% if the MAT file does not exist, then you must create it -- lock down dir and go
		if (exist(mat_path,'file') == 0)
			fid = fopen(lock_path, 'w');
			fclose(fid);
   
	    % run and save
			tif_path = [src_path(1:sepidx(length(sepidx)-1)) filesep '*.tif'];
			determine_trial_with_least_motion(tif_path, mat_path, []);

			delete(lock_path);
		end

		% and now load it ...
	  load(mat_path); % the file has the variable tgt_path defined; loading changes it
	end

	% read, process target
	tinf = imfinfo(tgt_path);
	tgtim_opt.numchannels = 1; % for now 1 chan only allowd in target
	tgtim_opt.channel = 1; % for now 1 chan only allowd in target
	if (tgt_frm == -1 | length(tgt_frm) == 2) % use whole stack or a few frames
    if (tgt_frm == -1) 
		  tgt_frm = [1 length(tinf)];
		end
		im_t = load_image(tgt_path, tgt_frm, tgtim_opt);

    % autoselect stillest if called for (And sensical...)
	  if (tgt_still_nfrm > 0) 

		  if (tgt_still_nfrm > size(im_t,3))
			  disp('Cannnot exceed number of frames in movie for autoselect.');
				tgt_still_nfrm = size(im_t,3)-1;
			end

		  % determine interframe difference
			fd_tmp = abs(diff(im_t,[],3));
			for fi=1:size(fd_tmp,3)
			  fd(fi) = sum(sum(fd_tmp(:,:,fi)));
			end

			% determine mean difference for streaks starting at each frame
		  for fi=1:size(im_t,3)-tgt_still_nfrm
			  frame_d(fi) = sum(fd(fi:fi+tgt_still_nfrm-1));
			end

			% and the min please
			[irr sidx] = min(frame_d);
			% baboom
			im_t = im_t(:,:,sidx:sidx+tgt_still_nfrm-1);
	  end

		% at this point, post-processing makes sense - mean, median, or raw
		if (tgt_preproc_meth == 2) % mean
		  im_t = mean(im_t,3);
		elseif (tgt_preproc_meth == 3) % median
		  im_t = median(im_t,3);
		elseif (tgt_preproc_meth == 4) % max projection
		  im_t = max(im_t,[], 3);
		elseif (tgt_preproc_meth == 5) % 20% moving average
		  ntf = ceil(length(tgt_frm)/5);
			matf = zeros(size(im_t, 1), size(im_t,2), length(tgt_frm)-ntf);
			for i=1:length(tgt_frm)-ntf;
        matf(:,:,i) = mean(im_t(:,:,i:ntf+i),3);
			end
		  im_t = max(matf,[], 3);
		else % if 1, raw  ; leave alone
		  disp('WARNING: you should specify frame number if using raw img ; stack passm makes no sense.');
		end
	elseif (length(tgt_frm) == 1) % use single frame
		im_t = load_image(tgt_path, tgt_frm, tgtim_opt);
		% at this point, post-processing makes NO sense since you have one frame so mean/median silly
	end

  % --- apply the registration 
	%    method to use: 1: Piecewise 2: 'Greeberg et al.', 3: 'FFT', 4: 'Rigid', 5: '3D Affine', 6:'Disable step'
	dx_r = 0; 
	dy_r = 0;
	dtheta_r = 0;
	E = []; % error
	lE = []; % line-by-line error for piecwise
  switch imreg_meth
	  case 1 % piecewise, correlation based error space
		  piecewise_opt = [];
		  if(exec_mode == 1) ;  piecewise_opt.debug = 1; end
		  [im_o dx_r dy_r E lE] = imreg_piecewise(im_s, im_t, piecewise_opt);
    case 2 % greenberg et al
      [im_o dx_r dy_r E] = imreg_greenberg(im_s, im_t, []);
    case 3 % fft
      [im_o dx_r dy_r E] = imreg_fft(im_s, im_t, []);
    case 4 % rigid with rotation -- my own with rotation ; iter. conv. for now
      [im_o dx_r dy_r dtheta_r E] = imreg_rigid(im_s, im_t, []);
    case 5 % 3d affine -- basically rigid in 3d
      disp('imreg: this method not yet implemented');
		case 6 % HMM based on Dombeck et al.
      [im_o dx_r dy_r E] = imreg_dombeck_hmm(im_s, im_t, []);
	end

	% --- if the source stack was not "as is", you must correct for this
	if (src_preproc_meth == 2) % mean of source was used 
	  disp('Warning - mean-of-source registration only works for rigid registration methods');
	  nfrm = size(im_s_o, 3);
		dx_r = dx_r*ones(nfrm,1);
		dy_r = dy_r*ones(nfrm,1);
		dtheta_r = dtheta_r*ones(nfrm,1);
		
		% reapply imreg_wrapup
    [im_o E] = imreg_wrapup (im_s_o, im_t, dx_r, dy_r, dtheta_r, []);
	end

	% --- output tif
	imwrite(uint16(im_o(:,:,1)), out_path, 'tif', 'Compression', 'none', 'Description',im_descr, 'WriteMode', 'overwrite');
  for f=2:size(im_o,3)
	  imwrite(uint16(im_o(:,:,f)), out_path, 'tif', 'Compression', 'none', 'WriteMode', 'append');
	end
	retparams(1).value = out_path;

	% --- output .imreg_out with dx, dy, E lE
	save(strrep(out_path,'tif', 'imreg_out'), 'dx_r', 'dy_r', 'dtheta_r', 'E' ,'lE', 'src_path', '-mat');

%
% Processor wrapper for single instance mode ; should setup params and make a 
%  single process() call.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    2: path of image file to process 
%    3: output file path (if not an outputting processor, will be ignored)
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image path if this is an outputting processor
%
%  glovars used:
%
function retparams = process_single(params)
  global glovars;
  retparams = [];

	% 1) get gui-defined parameters (1-8)
	pr_params = construct_params_from_gui(params);
	pr_params(11).value = 1; % gui based execution -- waitbars and the whole shebang

	% 2) call process()
  retparams = process(pr_params);


%
% Processor wrapper for batch mode ; should generate .mat files containing params
%  for process that a parallel agent can then call. Handle any glovars/gui communication 
%  and setup a glovars/gui independent params structure for process() itself.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    2: path(s) of source images -- cell array
%    3: output path 
%    4: .mat file path -- filename for mat file that parallel processor will use
%    5: .mat dependency file(s) -- filename(s) that must be executed before this one
%                                  can include standard 'ls' wildcards
%
%  retparams: 
%    1: cell ARRAY with path(s) of .mat file(s) generated
%
function retparams = process_batch (params)
  global glovars;
  retparams = [];

	% 1) get gui-defined parameters (1-8)
	pr_params = construct_params_from_gui(params);
	pr_params(11).value = 2; % non-gui based execution -- quiet!

	% 2) call process()
  retparams(1).value = par_generate('imreg','process',pr_params, params(4).value, params(5).value);


%
% Return values for saving in case gui is saved
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = get_saveable_settings(params)
  global glovars;
  retparams = [];

%
% Pass saved values for assigning to gui in case gui was saved
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = set_saveable_settings(params)
  global glovars;
  retparams = [];

% =============================================================================
% --- Processor-specific functions
% =============================================================================

%
% constructs a params structure that can be passed to process based on GUI 
% assigned properties
%
function pr_params = construct_params_from_gui(params)
  global glovars;

	si = params(1).value;
	step = glovars.processor_step(si);
	last_step = glovars.processor_step(si-1);
	han = step.gui_handle;

  % source pre-processing issues: 1 - as is ; 2 - mean ; 3 - frame range (NOT SUPPORTED)
	spmv = 1; 
	if (get(han.source_mean_radio, 'Value') == 1) ; spmv = 2; end
	if (get(han.source_mean_of_frames_radio, 'Value') == 1) ; spmv = 2; disp('Mean of frames not supported; defaulting to mean'); end

  % tpmv - how to preprocess target img: 1 - raw ; 2 - mean ; 3 - median ; 4 - max
	tpmv = get(han.target_process_menu,'Value');
  % which radio button is checked - which tells us what target image to use
	%  t_img_mode: 1 - current trial ; 2 - specific file ; 3 - autoselect based on PREVIOUS imreg analysis
	%  t_img_path: target img; set to 'auto' if mode is auto (3)

  % current trial mode - assign target path to current trial stack - i.e., source file (use
	%  this because it assures you will use the last step, which makes sense)
	if (get(han.target_current_trial_stack_radio,'Value') == 1)
		t_img_path = params(2).value;
	% target file specified -assign it
	elseif (get(han.target_specific_file_radio,'Value') == 1)
		% get from gui 
		t_img_path = get(han.target_stackpath_edit, 'String');
	% auto select target file - therefore, do this and assign path 
	elseif (get(han.target_auto_radio,'Value') == 1)
%	  disp('auto mode not yet supported');
%		retparams = -1;
%		return;
		t_img_path = 'auto';
	end

	% frame ranging issues for target image
	%  t_img_frame: target img frame#; set to -1 if mode is auto (3) (also default -- implies "use whole stack")
	%                2 values implies *inclusive* range 
	t_img_frame = -1;
	%  t_img_stillest_nframe: positive value implies use this many of the stillest consecutive frames
	t_img_stillest_nframe = -1;
	if (length(get(han.target_frame1_edit, 'String')) > 0 &length(get(han.target_frame2_edit, 'String')) > 0 )
	  t_img_frame(1) = str2num(get(han.target_frame1_edit, 'String'));
	  t_img_frame(2) = str2num(get(han.target_frame2_edit, 'String'));
		if (t_img_frame(1) == t_img_frame(2)) ; t_img_frame = t_img_frame(1) ; end
	elseif (length(get(han.target_frame1_edit, 'String')) > 0 )
	  t_img_frame =  str2num(get(han.target_frame1_edit, 'String'));
	elseif (length(get(han.target_frame2_edit, 'String')) > 0 )
	  t_img_frame =  str2num(get(han.target_frame2_edit, 'String'));
	end
  if (get(han.target_autoselect_still_checkbox, 'Value') == 1 & ...
	    length(get(han.target_nstill_frames_edit,'String')) > 0)
		t_img_stillest_nframe = str2num(get(han.target_nstill_frames_edit,'String'));
		if (t_img_frame ~= -1) ; disp(['Cannot specify target frame in auto mode.']); end
		t_img_frame = -1; % this takes precedent
	end
  
	% meth - method to use: 1: Piecewise 2: 'Greeberg et al.', 3: 'FFT', 4: 'Rigid', 5: '3D Affine', 6:'Disable step'
  meth = get(han.method_menu, 'Value');

	% nchans, usedchan - the number of channels and channel used for SOURCE image-- for load_image
	nchan = last_step.im_nchan;
	usedchan = last_step.im_usedchan;

  % 2) construct params for process()
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = params(3).value; % output path
  pr_params(3).value = meth; % meth - method to use:  1: Piecewise 2: 'Greeberg et al.', 3: 'FFT', 4: 'Rigid', 5: '3D Affine', 6:'Disable step'
	pr_params(4).value = tpmv;  % tpmv - how to preprocess target img: 1 - raw ; 2 - mean ; 3 - median ; 4 - max
	pr_params(5).value = t_img_path; %  target img; set to -1 if mode is auto (3)
	pr_params(6).value = t_img_frame; %  img frame#; set to -1 if mode is auto (3) (also default -- implies "use whole stack")
  pr_params(7).value = t_img_stillest_nframe; % -1: ignore ; > 0 : select this many stillest consecuttive frames as target
	pr_params(8).value = spmv; % source pre-processing : 1 - as is ; 2 - mean ; 3 - frame range (NOT SUPPORTED)
	pr_params(9).value = nchan; % # of channels in SOURCE image
	pr_params(10).value = usedchan; % channel in SOURCE image to use


