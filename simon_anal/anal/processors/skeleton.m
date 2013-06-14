% 
% S Peron Sept. 2009
%
% This is a processor SKELETON; make a directory, edit get_processors.m, and put
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
function retparams = skeleton(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize skeleton processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('skeleton processor init start ...');
	% --- start the gui

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	
	disp('skeleton processor init end ...');

%
% Closes the skeleton processor -- basically destructor.
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
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image stack if params 2 != -1
%
function retparams = process(params)
  retparams = [];

%
% Processor wrapper for single instance mode ; should setup params and make a 
%  single process() call.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    2: path of image file to process 
%    3: output path (if not an outputting processor, will be ignored)
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image path if this is an outputting processor
%
%  glovars used:
%
function retparams = process_single(params)
  global glovars;
  retparams = [];

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



