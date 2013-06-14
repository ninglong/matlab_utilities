%
% This function returns processors structure, which consists of a struct with 
%  the following elements for each processor:
%    type_id -- unique number for each processor ; allows ID'ing
%    name -- name, as it appears in messages etc.
%    subpath -- directory within processors that has the gear
%    func_name -- the function that invokes the processor -- some caveats:
%                 1) must be in func_name.m
%                 2) gui must be in func_name_control.m/func_name_control.fig
%    gui_present (1=yes, 0=no)
%    image_output -- 1=yes, 0=no ; if no, no images come from this
%    batch_style -- 1: all matching stacks must be run through this processor 
%                      before the next step
%                   2: no inter-stack dependence
%                   3: all matching stacks must be run through the processor PRECEDING
%                      this step if in sequence - this is if, e.g., the processor 
%                      depends on previous step's output.  
%                   4: 1 AND 3 
%                   if any step is 1, all are executed in mode 1
%
%  Additionally, a substructure, processor_specific, contains processor-specific parameters
%
%  The variable passed form -- processor_name -- is used by processors to access their settings
%
function processors = get_processors(processor_name)
  i = 1;
   
  % --------------------------------------------------------------------------
  % the main image registration processor -- 
	processors(i).type_id = i;
	processors(i).name = 'Image Registration';
	processors(i).subpath = 'imreg';
	processors(i).func_name = 'imreg';
	processors(i).gui_present = 1;
	processors(i).image_output = 1;
	processors(i).batch_style = 4; % requires all stacks before next step bc it looks for best
	                               % stack to match others to for intertrial/interday move

	% proc specific
	processors(i).processor_specific = [];
  i = i + 1;
 
  % --------------------------------------------------------------------------
  % the main image registration corrective postprocessing processor -- 
	processors(i).type_id = i;
	processors(i).name = 'Post-Processing for ImReg';
	processors(i).subpath = 'imreg_postprocess';
	processors(i).func_name = 'imreg_postprocess';
	processors(i).gui_present = 1;
	processors(i).image_output = 1;
	processors(i).batch_style = 2; % requires all stacks before next step bc it looks for best
	                               % stack to match others to for intertrial/interday move

	% proc specific
	processors(i).processor_specific = [];
  i = i + 1;
  
  % --------------------------------------------------------------------------
  % the fft registration processor -- 
	processors(i).type_id = i;
	processors(i).name = 'FFT Registration';
	processors(i).subpath = 'fft_register';
	processors(i).func_name = 'fft_register';
	processors(i).gui_present = 1;
	processors(i).image_output = 1;
	processors(i).batch_style = 2;

	% proc specific
	processors(i).processor_specific = [];
  i = i + 1;

  % --------------------------------------------------------------------------
  % the roi_timeseries processor -- 
	processors(i).type_id = i;
	processors(i).name = 'ROI timeseries';
	processors(i).subpath = 'roi_timeseries';
	processors(i).func_name = 'roi_timeseries';
	processors(i).gui_present = 1;
	processors(i).image_output = 0; % does NOT output images - outputs timeseries
	processors(i).batch_style = 2;

  % proc specific
	processors(i).processor_specific = []; % roi struct
  i = i + 1;

  
  % --------------------------------------------------------------------------
  % the turboreg processor -- 
	processors(i).type_id = i;
	processors(i).name = 'TurboReg';
	processors(i).subpath = 'turboreg';
	processors(i).func_name = 'turboreg';
	processors(i).gui_present = 1;
	processors(i).image_output = 1;
	processors(i).batch_style = 2;

	% proc specific
	processors(i).processor_specific.ij_jar_path = '/home/speron/bin/ImageJ/ImageJ64.app/Contents/Resources/Java/ij.jar'; % where the imageJ jar file is
  i = i + 1;
  % --------------------------------------------------------------------------
  % blank
%	processors(i).type_id = i;
%	processors(i).name = ''; % name of the processor as it appears in guis, messages, etc.
%	processors(i).subpath = ''; % subpath in processors directory ; often same as name
%	processors(i).func_name = ''; % name of function to call; often same as name
%	processors(i).gui_present = 0; % has a gui if 1 ; otherwise no
%	processors(i).image_output = 0; % 1: outputs images (which will be displayed in gui) ; 0: does not
%	processors(i).processor_specific = []; % in this structure, define sub-variables specific to your processor
% i=i+1;

  % --------------------------------------------------------------------------
  % return all?
	if (exist('processor_name','var') == 1)
	  new_processors = [];
		for i=1:length(processors)
		  if (strcmp(processors(i).name,processor_name))
			  new_processors = processors(i);
				break;
			end
    end
		processors = new_processors;
	end
