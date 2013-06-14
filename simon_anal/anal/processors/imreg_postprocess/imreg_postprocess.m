% 
% S Peron Sept. 2009
%
% This is a processor IMREG_POSTPROCES.  It will do a pre and post median 
%  filter on dx/dy vectors, as well as correlation-based 'adaptive' 
%  correction.
%
% "func" is the *string* name of the function you wish to call below, with 
%        params always getting passed thereto.
%
% "params" is a structure, with params.value carrying content.  This allows us 
%          type independence obviating need for a huge number of variables. 
% 
function retparams = imreg_postprocess(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize imreg_postprocess processor -- called by fluo_display_control when 
%  added to processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('imreg_postprocess processor init start ...');

	% --- start the gui -- in this case, we tell it what step it belongs to
  [winhan handles_struct] = imreg_postprocess_control(params(1).value);

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	glovars.processor_step(params(1).value).gui_handle = handles_struct;

	disp('imreg_postprocess processor init end ...');

%
% Closes the imreg_postprocess processor -- basically destructor.
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
%    1: path of image file to process - from which .imreg_out name is
%       extracted
%    2: output path - image is corrected and output here
%    3: pre-median filter params - size of filter, -1 for none
%    4: adaptive correction params - [alpha beta gbs] ; -1 for nothing
%    5: post-median filter params - size of filter, -1 for none
%    6: gui based(1) or not (0)
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: output path
%
function retparams = process(params)
  global glovars;
  retparams = [];

  % assign meaningful names to params
  n_src_path = params(1).value;
	disp_vec_path = strrep(n_src_path, '.tif', '.imreg_out');
	out_path = params(2).value;
	pre_mf_params = params(3).value;
	adaptive_correction_params = params(4).value;
	post_mf_params = params(5).value;
	use_gui = params(6).value;
  
  disp(['Starting processor imreg_postprocess on source file ' n_src_path ' and output file ' out_path]);

  % --- sanity checks

  % --- preparation

	% read the displacement vector
	load(disp_vec_path, '-mat');

	% --- call imreg_postprocess, then 
	opt.debug = use_gui;
	opt.mfs1 = pre_mf_params;
	opt.corr = adaptive_correction_params;
	opt.mfs2 = post_mf_params;
	opt.mat_out_path = strrep(out_path,'.tif','.imreg_pproc_out');
  [dx_f dy_f dtheta_f] = imreg_postproc(dx_r, dy_r, dtheta_r, lE, opt);

	% --- read, process src images BEFORE the imreg step 
	if (strcmp(src_path, n_src_path))
	  disp('imreg_postprocess::warning - step before this overwrote its input - problem for correction');
	end
	im_s = load_image(src_path, -1, []);

  % --- finito - imreg wrapup with new vectors ; output
  [im_o E] = imreg_wrapup (im_s, mean(im_s,3), dx_f, dy_f, dtheta_f, []);
  

	% output tif
	imwrite(uint16(im_o(:,:,1)), out_path, 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');
  for f=2:size(im_o,3)
	  imwrite(uint16(im_o(:,:,f)), out_path, 'tif', 'Compression', 'none', 'WriteMode', 'append');
	end
	retparams(1).value = out_path;

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

	% 1) get gui-defined parameters (1-5)
	pr_params = construct_params_from_gui(params);
	pr_params(6).value = 1; % gui based execution -- waitbars and the whole shebang

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
	pr_params(6).value = 0; % non-gui based execution -- quiet!

	% 2) call process()
  retparams(1).value = par_generate('imreg_postprocess','process',pr_params, params(4).value, params(5).value);


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

  % prelims - connection to gui setup
	si = params(1).value;
	step = glovars.processor_step(si);
	last_step = glovars.processor_step(si-1);
	han = step.gui_handle;

  % --- 1) get stuff from gui
	

  % --- 2) construct params for process()
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = params(3).value; % output path
  pr_params(3).value = str2num(get(han.init_mf_size_edit,'String')); % size of median filter (-1 = off)
  pr_params(5).value = str2num(get(han.final_mf_size_edit,'String')); % size of median filter (-1 = off)
	alpha = str2num(get(han.alpha_corr_corr_edit,'String'));
	beta = str2num(get(han.beta_corr_corr_edit,'String'));
	gbs = str2num(get(han.gbs_corr_corr_edit,'String'));
	pr_params(4).value = [alpha beta gbs];

	% checkbox check
  if (get(han.init_mf_checkbox,'Value') == 0) 
	  pr_params(3).value = -1;
	end
  if (get(han.corr_corr_checkbox,'Value') == 0) 
	  pr_params(4).value = -1;
		disp('yoyoyo');
	end
  if (get(han.final_mf_checkbox,'Value') == 0) 
	  pr_params(5).value = -1;
	end


