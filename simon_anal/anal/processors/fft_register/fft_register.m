% 
% S Peron Oct. 2009
%
% This is a processor that runs imreg_fft to register a movie stack to a 
%  target image.
% 
function retparams = fft_registration(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);


% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize fft_register processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('fft_registration processor init start ...');
	% --- start the gui
	[winhan handles_struct] = fft_register_control();

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	glovars.processor_step(params(1).value).gui_handle = handles_struct;
	
	disp('fft_registration processor init end ...');

%
% Closes the fft_processor processor -- basically destructor.
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
%    3: base image mode 1: mean of stack 2: frame range 3: file
% 	 4: path of image stack if params(3) has value 3
%    5: image registration method - deprecated and always 1
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image stack 
%
function retparams = process(params)
  retparams = [];

	% 1) sanity checks 
	if (length(params) < 5)
	  disp('fft_registration.m: params too short; see calling function.');
		retparams = -1;
		return;
	end


  % 2) output path
	fft_register_output_path = params(2).value;
  
  % 3) input file -- if -1, you must write it
	if (params(1).value == -1)
	  disp('fft_registration.m: input file of current stack not supported; actual file needed.');
	else
	  im_inf = imfinfo(params(1).value);
		im_s = zeros(im_inf(1).Height , im_inf(1).Width, length(im_inf));
		for f=1:length(im_inf)
		  im_s(:,:,f) = imread(params(1).value, f);
		end
	end

  % 4) construct OR retrieve the image that will be used as registration reference (i.e., registered to)
	%TEMP -- just take mean of image, save to file...%
	if (params(3).value == 1) % mean of current image
		im_t = mean(im_s,3);
	elseif (params(3).value == 2) % mean of current image frm rng
	  disp('not supported');
	elseif (params(3).value == 3) % specific file
		im_t = imread(params(4).value);
	else
	  disp('fft_register: base image mode is not valid; aborting.');
		retparams = -1;
		return;
	end

	% 5) call fft_registration ; output to file
	switch params(5).value
	  case 1 % FFT
			[new_im dx dy E] = imreg_fft(im_s, im_t, []);
		case 2 % IRRELEVANT
		  disp('Use imreg processor for this; this is fft only.');
			[new_im dx dy E] = imreg_fft(im_s, im_t, []);
	end

	new_im = double(new_im);
	if (length(size(new_im)) == 2)
		new_im = new_im/max(max(new_im));
	else
		new_im = new_im/max(max(max(new_im)));
	end
	disp(['FFT registration output to ' fft_register_output_path]);
	if (length(size(new_im)) == 2)
	  imwrite(new_im, fft_register_output_path, 'tif', 'Compression', 'none');
	else
	  imwrite(new_im(:,:,1), fft_register_output_path, 'tif', 'Compression', 'none');
	  for f=2:size(new_im,3)
			imwrite(new_im(:,:,f), fft_register_output_path, 'tif','WriteMode', 'append', 'Compression', 'none');
		end
	end

	% 6) return it
  retparams(1).value = fft_register_output_path;

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

	si = params(1).value;
	%  get gui-defined parameters
	bim = 1;
	if (get(glovars.processor_step(si).gui_handle.base_image_radio_mean_range,'Value'))
	  bim = 2; 
	elseif (get(glovars.processor_step(si).gui_handle.base_image_radio_path,'Value'))
	  bim = 3;
	end
  bipe = get(glovars.processor_step(si).gui_handle.base_image_path_edit,'String');

  % construct passed params
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = params(3).value; % output path
  pr_params(3).value = bim; % base image mode: 1 mean 2 frm rng 3 file
	pr_params(4).value = bipe; % path of file if above is 3
	pr_params(5).value = 1; % process mode - fft ALWAYS

	% 3) call process()
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


