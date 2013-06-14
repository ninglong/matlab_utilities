% 
% S Peron Sept. 2009
%
% This is a processor TURBOREG; make a directory, edit get_processors.m, and put
%  your new processor, based on this, in there.  Create a xxx_control as gui, if
%  you wish.
%
% This is a wrapper for turboreg from within MATLAB.
%
% "func" is the *string* name of the function you wish to call below, with 
%        params always getting passed thereto.
%
% "params" is a structure, with params.value carrying content.  This allows us 
%          type independence obviating need for a huge number of variables. 
% 
% I would love to use MATLAB objects, but this allows us backwards compatability ...
%
function retparams = turboreg(func, params)
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize turboreg processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('turboreg processor init start ...');

	% --- start the gui
  [winhan handles_struct] = turboreg_control();

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	glovars.processor_step(params(1).value).gui_handle = handles_struct;

	
	disp('turboreg processor init end ...');

%
% Closes the turboreg processor -- basically destructor.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = shutdown(params)
  retparams = [];

%
% The core of the processor -- calls processing functions ; NOT Allowed to talk
%  to glovars
%
%  params:
%    1: path of image file to process 
%    2: output path 
%    3: imageJ .jar file path
%    4: turboreg_control handles.base_image_mode: 1-mean of passed path 
%         2: mean w/ frm rg (FAIL) 3: specific file mean
%    5: turboreg_control handles.base_image_path_edit - if param(4) = 3
%    6: tmp file path - for generating temporary average image for turboreg
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image stack 
%
function retparams = process(params)
  global glovars;
  retparams = [];
	settings = get_processors('turboreg');
	plugins_dir = [glovars.processors_path filesep 'turboreg' filesep];

	% 1) sanity checks -- is ImageJ installed on this machine?
	if (exist(params(3).value, 'file') == 0)
	  disp('You either do not have Image J or your get_processors.m file does not point to it in the turboreg section.');
	  disp('  Within get_processors.m, in the turboreg section, define processors.procesor_specific.ij_jar_path.');
		disp(['  Current value: ' params(3).value]);
		retparams = -1;
		return;
	end

	if (length(params) < 2)
	  disp('turboreg.m: params too short; see calling function.');
		retparams = -1;
		return;
	end

	% 2) output path
	turboreg_output_path = params(2).value;
  
  % 3) input file -- if -1, you must write it
	if (params(1).value == -1)
	  disp('turboreg.m: input file of current stack not supported; actual file needed.');
	end

  % 4) construct OR retrieve the image that will be used as registration reference (i.e., registered to)
	%TEMP -- just take mean of image, save to file...%
	if (params(4).value == 1) % mean of current image
	  sinf = imfinfo(params(1).value);
		im_tmp = zeros(sinf(1).Height, sinf(1).Width, length(sinf));
		for f=1:length(sinf);
			im_tmp(:,:,f) = imread(params(1).value,f);
		end
		% write to tmp file
		reference_image_path = [params(6).value filesep 'turboreg_avg_img.tif']; 
		%imwrite((double(mean(im_tmp,3))/double(max(max(max(im_tmp))))), reference_image_path, 'tif', 'WriteMode', 'overwrite', 'Compression', 'none');
		imwrite(uint16(mean(im_tmp,3)), reference_image_path, 'tif', 'WriteMode', 'overwrite', 'Compression', 'none');
	elseif (params(4).value == 2) % mean of current image frm rng
	  disp('Frame range not supported.  Code it or cry like a baby.');
	elseif (params(4).value == 3) % specific file
	  reference_image_path = params(5).value;
	else
	  disp('turboreg: invalid source image mode; aborting.');
		retparams = -1;
		return;
	end
  disp(['Using reference image: ' reference_image_path]);

	% 5) call turboreg with output to a temp file
	command_str = ['java -Xmx1536m -Dplugins.dir=' plugins_dir ' -cp ' ...
	  params(3).value ' ij.ImageJ -macro ' plugins_dir ...
		filesep 'plugins' filesep 'TurboReg.txt ' params(1).value ',' reference_image_path ',' ...
		turboreg_output_path ',' num2str(glovars.fluo_display.display_im_width) ','...
		num2str(glovars.fluo_display.display_im_height)];
	system(command_str);

	% 6) return output path
  retparams(1).value = turboreg_output_path;

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

	% 1) get gui-defined parameters
  si = params(1).value;
	if (get(glovars.processor_step(si).gui_handle.base_image_radio_mean, 'Value'))
	  bim = 1;
	elseif(get(glovars.processor_step(si).gui_handle.base_image_radio_mean_range, 'Value'))
	  bim = 2;
	elseif(get(glovars.processor_step(si).gui_handle.base_image_radio_path, 'Value'))
	  bim = 3;
	end
  bip = get(glovars.processor_step(si).gui_handle.base_image_path_edit, 'String');

  % 2) get processor settings
	prpar = get_processors('TurboReg');

  % 3) construct params for process()
	%    1: path of image file to process 
	%    2: output path 
	%    3: imageJ .jar file path
	%    4: turboreg_control handles.base_image_mode: 1-mean of passed path 
	%         2: mean w/ frm rg (FAIL) 3: specific file mean
	%    5: turboreg_control handles.base_image_path_edit - if param(4) = 3
	%    6: tmp file path - for generating temporary average image for turboreg
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = params(3).value; % output path
  pr_params(3).value = prpar.processor_specific.ij_jar_path; % imageJ .jar file path
	pr_params(4).value = bim; % turboreg_control handles.base_image_mode
	pr_params(5).value = bip; % turboreg_control handles.base_image_path_edit
	pr_params(6).value = glovars.tmp_path; % tmp path (globally set)

	% 4) call process()
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
%
%  retparams: 
%    1: cell ARRAY with path(s) of .mat file(s) generated
%
function retparams = process_batch (params)
  global glovars;
  retparams = [];

	% Pre-setup the target image and its preprocessing - dont want to repeat each time

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


