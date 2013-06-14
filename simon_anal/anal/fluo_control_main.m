function varargout = fluo_control_main(varargin)
% FLUO_CONTROL_MAIN M-file for fluo_control_main.fig
%      FLUO_CONTROL_MAIN, by itself, creates a new FLUO_CONTROL_MAIN or raises the existing
%      singleton*.
%
%      H = FLUO_CONTROL_MAIN returns the handle to a new FLUO_CONTROL_MAIN or the handle to
%      the existing singleton*.
%
%      FLUO_CONTROL_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUO_CONTROL_MAIN.M with the given input arguments.
%
%      FLUO_CONTROL_MAIN('Property','Value',...) creates a new FLUO_CONTROL_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluo_control_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluo_control_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluo_control_main

% Last Modified by GUIDE v2.5 30-Nov-2009 07:25:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluo_control_main_OpeningFcn, ...
                   'gui_OutputFcn',  @fluo_control_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before fluo_control_main is made visible.
function fluo_control_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluo_control_main (see VARARGIN)

% SP ----------------------------------------------------------------------
global glovars;

%  connect relevant gui elements to glovars
glovars.fluo_control_main.min_color_slider = handles.min_color_slider;
glovars.fluo_control_main.min_color_edit = handles.min_color_edit;
glovars.fluo_control_main.max_color_slider = handles.max_color_slider;
glovars.fluo_control_main.max_color_edit = handles.max_color_edit;
glovars.fluo_control_main.processing_steps_list = handles.processing_steps_list;
glovars.fluo_control_main.source_images_path_edit = handles.source_images_path_edit;
glovars.fluo_control_main.source_images_wildcard_edit = handles.source_images_wildcard_edit;
glovars.fluo_control_main.output_images_path_edit = handles.output_images_path_edit;
glovars.fluo_control_main.display_mode_frame_radio = handles.display_mode_frame_radio;
glovars.fluo_control_main.display_mode_mean_radio = handles.display_mode_mean_radio;
glovars.fluo_control_main.display_mode_max_radio = handles.display_mode_max_radio;
glovars.fluo_control_main.um_per_pix_hor_edit = handles.um_per_pix_hor_edit;
glovars.fluo_control_main.um_per_pix_ver_edit = handles.um_per_pix_ver_edit;
glovars.fluo_control_main.processor_enable_parallel_checkbox = handles.processor_enable_parallel_checkbox;
glovars.fluo_control_main.nchan_edit = handles.nchan_edit;
glovars.fluo_control_main.usedchan_edit = handles.usedchan_edit;

% set up the aspect ratio toolbar
set(handles.aspect_ratio_menu, 'String', {'Square', 'Image Size', 'Mag-based'});

% Set up mode radios
set(handles.display_mode_frame_radio, 'Value', true);
set(handles.display_mode_mean_radio, 'Value', false);
set(handles.display_mode_max_radio, 'Value', false);

% Set default number of channels
set(handles.nchan_edit, 'String', num2str(1));
set(handles.usedchan_edit, 'String', num2str(1));

% --- Here are the processor-chain related items; this is the heart of this
% first, a list of what you need to populate:
% glovars.processor_step.uid (UNIQUE id -- numerical)
% glovars.processor_step.name - preferably unique id string
% glovars.processor_step.im_path [DO NOT STORE im anymore!]
% glovars.processor_step.im_fname [path + fname = file]
% glovars.processor_step.im_nchan = 1; how many channels -- 1 except for Base Image
%	glovars.processor_step.im_usechan = 1; which channel? -- 1 except for Base Image
% glovars.processor_step.gui_handle - handle to controlling gui, if present
% glovars.processor_step.processor - structure from get_processor
% glovars.processor_step.processor.type_id - unique id
% glovars.processor_step.processor.name - name in messages
% glovars.processor_step.processor.subpath - where processing source resides
% glovars.processor_step.processor.func_name - function invoked
% glovars.processor_step.processor.gui_present - if 1, func_name_control is your gui
% glovars.processor_step.processor.image_output - if 1, yes; if 0, no images come from this
% glovars.processor_step.processor.batch_style - 1: must finish this step before moving on 
%                                                 2: no interstep dependency

% set up processors toolbar
glovars.processors = get_processors();
for p=1:length(glovars.processors)
  proc_list{p} = glovars.processors(p).name;
end
set(handles.processor_menu, 'String', proc_list);

% set up processor chain, tie to update display
glovars.processor_step = [];
glovars.current_processor_step = 0;

% END SP ------------------------------------------------------------------

% Choose default command line output for fluo_control_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluo_control_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fluo_control_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in aspect_ratio_menu.
function aspect_ratio_menu_Callback(hObject, eventdata, handles)
% hObject    handle to aspect_ratio_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns aspect_ratio_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aspect_ratio_menu

% 1) retrieve current aspect ratio
global glovars;

% 2) retrieve assigned aspect ratio
current_aspect = glovars.fluo_display.aspect_ratio;
new_aspect = get(hObject,'Value');

% 3) different? assign, update display
if (new_aspect ~= current_aspect)
  glovars.fluo_display.aspect_ratio = new_aspect;
	fluo_display_update_display();
end

% --- Executes during object creation, after setting all properties.
function aspect_ratio_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aspect_ratio_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function um_per_pix_hor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to um_per_pix_hor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of um_per_pix_hor_edit as text
%        str2double(get(hObject,'String')) returns contents of um_per_pix_hor_edit as a double

% 1) retrieve global variables
global glovars;

% 2) determine if both hor and ver are on
h_mag = get(handles.um_per_pix_hor_edit,'String');
v_mag = get(handles.um_per_pix_ver_edit,'String');

if (length(h_mag) > 0 & length(v_mag) > 0)
  h_mag = double(eval(h_mag));
	v_mag = double(eval(v_mag));

  % assign globals
  glovars.fluo_display.hor_pix2um = h_mag;
  glovars.fluo_display.ver_pix2um = v_mag;

	% update aspect ratio
	set(handles.aspect_ratio_menu, 'Value', 3);
	glovars.fluo_display.aspect_ratio = 3;

  % and update display
	fluo_display_update_display();
end


% --- Executes during object creation, after setting all properties.
function um_per_pix_hor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to um_per_pix_hor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function um_per_pix_ver_edit_Callback(hObject, eventdata, handles)
% hObject    handle to um_per_pix_ver_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of um_per_pix_ver_edit as text
%        str2double(get(hObject,'String')) returns contents of um_per_pix_ver_edit as a double

% 1) retrieve global variables
global glovars;

% 2) determine if both hor and ver are on
h_mag = get(handles.um_per_pix_hor_edit,'String');
v_mag = get(handles.um_per_pix_ver_edit,'String');

if (length(h_mag) > 0 & length(v_mag) > 0)
  h_mag = double(eval(h_mag));
	v_mag = double(eval(v_mag));

  % assign globals
  glovars.fluo_display.hor_pix2um = h_mag;
  glovars.fluo_display.ver_pix2um = v_mag;

	% update aspect ratio
	set(handles.aspect_ratio_menu, 'Value', 3);
	glovars.fluo_display.aspect_ratio = 3;

  % and update display
	fluo_display_update_display();
end



% --- Executes during object creation, after setting all properties.
function um_per_pix_ver_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to um_per_pix_ver_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function min_color_slider_Callback(hObject, eventdata, handles)
% hObject    handle to min_color_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  global glovars;
  glovars.fluo_display.colormap_min = get(hObject,'Value');
	fluo_display_update_display();

% --- Executes during object creation, after setting all properties.
function min_color_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_color_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function min_color_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_color_edit as text
%        str2double(get(hObject,'String')) returns contents of min_color_edit as a double
  global glovars;
  glovars.fluo_display.colormap_min = str2num(get(hObject,'String'));
	fluo_display_update_display();


% --- Executes during object creation, after setting all properties.
function min_color_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function max_color_slider_Callback(hObject, eventdata, handles)
% hObject    handle to max_color_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  global glovars;
  glovars.fluo_display.colormap_max = get(hObject,'Value');
	fluo_display_update_display();


% --- Executes during object creation, after setting all properties.
function max_color_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_color_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function max_color_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_color_edit as text
%        str2double(get(hObject,'String')) returns contents of max_color_edit as a double
  global glovars;
  glovars.fluo_display.colormap_max = str2num(get(hObject,'String'));
	fluo_display_update_display();


% --- Executes during object creation, after setting all properties.
function max_color_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in processor_menu.
function processor_menu_Callback(hObject, eventdata, handles)
% hObject    handle to processor_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns processor_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processor_menu


% --- Executes during object creation, after setting all properties.
function processor_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processor_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processor_run_single_step_button.
%
% For running of a single *step* in a sequence.
%
function processor_run_single_step_button_Callback(hObject, eventdata, handles)
% hObject    handle to processor_run_single_step_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	global glovars;

	% figure out processor to call
  step_idx = get(handles.processing_steps_list, 'Value');
  if (step_idx == 1) 
	  disp('Base Image is not a process; cannot run');
		return;
	end

  % construct params -- for a processor, this is always:
	%  1: id of process step in processor_step array
	%  2: path of source image file 
	%  3: output path 
	params(1).value = step_idx;

	% get the filename for the step before this that output file
	for p=step_idx-1:-1:1
	  if(glovars.processor_step(p).processor.image_output == 1)
      params(2).value = [glovars.processor_step(p).im_path filesep glovars.processor_step(p).im_fname];
			break;
		end
	end

	% output path: for now just temp file ; soon -- if outpath is set, put it there with appropriate 
	%  name chg
	outfile = ['processor_step_' num2str(step_idx) '.tif'];
	params(3).value = [glovars.tmp_path filesep outfile];

  % make the call
	func = 'process_single';
	retparams = eval([glovars.processor_step(step_idx).processor.func_name '(func,params);']);

  % --- process return
	if (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 1)
	  if (retparams == -1 )
		  disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' failed: retparams -1.']);
		elseif (length(retparams) == 0)
		  disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' failed: no returned values.']);
		else
		  disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' failed: unknown reason.']);
		end
	% valid bc no image output exected -- BUT if -1 problem
	elseif (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 0)
		if (retparams == -1 )
			disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: retparams -1.']);
		else
			disp(['Processor execution of ' glovars.processor_step(s).processor.name ' successful.']);
		end
	% valid? then update processor steps, display to point to output image (IF APPLICABLE)
	else
		% did this (should this!) return an image? - then update display
		im_path = '';
		im_fname = '';
		if (glovars.processor_step(step_idx).processor.image_output == 1)
      out_path = retparams(1).value;
			if (out_path(length(out_path)) == filesep) ; out_path = out_path(1:length(out_path)-1); end
			sli = find(out_path == filesep, 1, 'last');
     
		  % - load file
		  im_path = out_path(1:sli-1);
		  im_fname = out_path(sli+1:length(out_path));
   		fluo_display_open_stack (im_path, im_fname, []);
			glovars.processor_step(step_idx).im_path = im_path;
			glovars.processor_step(step_idx).im_fname = im_fname;

			% - set the current processor step as ... well, the current processor step!
			glovars.current_processor_step = step_idx;
      fluo_control_main_update_processing_steps_list();
    end % otherwise do nothing - leave gui as is

    % --- update glovars.processor_step structure
		disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' successful.']);
	end

% --- Executes on button press in processor_run_single_seq_button.
%
% For running of an entire processing sequence on the current Base Image.
%
function processor_run_single_seq_button_Callback(hObject, eventdata, handles)
% hObject    handle to processor_run_single_seq_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	global glovars;

  % --- determine which step is last with image output -- this will be gui-loaded
	last_im_idx = 1;
	for s=2:length(glovars.processor_step)
	  if (glovars.processor_step(s).processor.image_output == 1) ; last_im_idx = s ; end
	end
	tstart_all = tic;

  % --- go thru all the processors after base image -- and set base image as first last_out_path
	last_out_path = [glovars.processor_step(1).im_path filesep glovars.processor_step(1).im_fname];
	for s=2:length(glovars.processor_step)
	  tstart_step = tic;
		% construct params -- for a processor, this is always:
		%  1: id of process step in processor_step array
		%  2: path of source image file 
		%  3: output path 
		step_idx = s;

		params(1).value = step_idx;

		% source path -- last step's output; this is "safe" in terms of processors
		%  that do not output files since only ones that DO get to affect last_out_path
		params(2).value = last_out_path;

		% output path: for now just temp file ; soon -- if outpath is set, put it there with appropriate 
		%  name chg
		outfile = ['processor_step_' num2str(step_idx) '.tif'];
		params(3).value = [glovars.tmp_path filesep outfile];

		% make the call
		func = 'process_single';
		retparams = eval([glovars.processor_step(s).processor.func_name '(func,params);']);

		% --- process return case 1, expect image
		if (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 1)
			if (retparams == -1 )
				disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: retparams -1.']);
			elseif (length(retparams) == 0)
				disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: no returned values.']);
			else
				disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: unknown reason.']);
			end
		% valid bc no image output exected -- BUT if -1 problem
		elseif (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 0)
			if (retparams == -1 )
				disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: retparams -1.']);
			else
				disp(['Processor execution of ' glovars.processor_step(s).processor.name ' successful.']);
			end
		% valid? then update processor steps, display to point to output image (IF APPLICABLE)
		else
			% did this (should this!) return an image? - then update display
			im_path = '';
			im_fname = '';
			if (glovars.processor_step(step_idx).processor.image_output == 1)
				out_path = retparams(1).value;
				if (out_path(length(out_path)) == filesep) ; out_path = out_path(1:length(out_path)-1); end
				sli = find(out_path == filesep, 1, 'last');
			 
				% - assign file
				im_path = out_path(1:sli-1);
				im_fname = out_path(sli+1:length(out_path));
				glovars.processor_step(step_idx).im_path = im_path;
				glovars.processor_step(step_idx).im_fname = im_fname;

        % - update gui if this is last step with image output
				if (step_idx == last_im_idx)
					fluo_display_open_stack (im_path, im_fname, []);
					glovars.current_processor_step = step_idx;
					fluo_control_main_update_processing_steps_list();
				end

				% - keep last output path pointing to this step since it is your last step w/ a file output
				last_out_path = [im_path filesep im_fname];
			end % otherwise do nothing - leave gui as is

			% --- update glovars.processor_step structure
			telapsed = toc(tstart_step);
			disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' successful. ' num2str(telapsed) ' seconds used.']);
		end
  end
	telapsed = toc(tstart_all);
	disp(['Total time elapsed: ' num2str(telapsed) ' seconds']);


% --- Executes on button press in processor_run_batch_seq_button.
%
% For running of an entire processing sequence iteratively on all source images
%  within the source path directory.
%
function processor_run_batch_seq_button_Callback(hObject, eventdata, handles)
% hObject    handle to processor_run_batch_seq_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  % --- gather variables ...
	global glovars;
	output_path = get(glovars.fluo_control_main.output_images_path_edit,'String');
	source_path = get(glovars.fluo_control_main.source_images_path_edit,'String');
	source_wildcard = get(glovars.fluo_control_main.source_images_wildcard_edit,'String');

  % if 1, process via parallel -- for now, "fire and forget" so you kickoff processes but do NOT
	%  wait for their completion
  parallel_exec = get(glovars.fluo_control_main.processor_enable_parallel_checkbox,'Value');
  dep_filepath = ''; % blank means nothing
  
  % --- sanity checks
  if (0 == length(output_path)) 
	  disp('Output path not specified.');
		return;
	end
  if (0 == length(source_path)) 
	  disp('Source path not specified.');
		return;
	end

  % --- waitbar instantiate
	wb = waitbar(0, 'Initializing batch processor ...');

  % --- first, create output directory if necessary
	if (exist(output_path,'dir') == 0)
	  disp(['Batch output directory, ' output_path ', does not exist; creating.']);
    mkdir(output_path);
	end
  
	% --- make the log file and put it in the output directory

  % --- "Internal" execution arises in completing each *processor* for all
	%     files before moving on; this is the more conservative assumption

  % get file list ; assign last_out_path for each file stream as the main source file
  flist = dir([source_path filesep source_wildcard]);
	for f=1:length(flist)
		last_out_path{f} = [source_path filesep flist(f).name];
	end
	last_step_is_base = 1; % 1: previous step was base image ; sets to 0 after first output

  % --- TOP LOOP --- go thru all the processors 
	ns = length(glovars.processor_step);
	for s=2:length(glovars.processor_step)
		step_idx = s;
		file_output = 0;

		step_name = glovars.processor_step(step_idx).name;

    % if this has batch_style of 3 or 4, assign dep file for *previous* step
		if(glovars.processor_step(step_idx).processor.batch_style == 3 &  ...
		   s > 2)
		  dep_filepath = [glovars.par_path filesep 'parfile_' num2str(s-1) '_*']; % tmp and mat should be included
		end
		if(glovars.processor_step(step_idx).processor.batch_style == 4 &  ...
		   s > 2)
		  dep_filepath = [glovars.par_path filesep 'parfile_' num2str(s-1) '_*']; % tmp and mat 
		end

    % --- SECOND LOOP ---go thru all the files
    for f=1:length(flist)
			waitbar(((s-2)*length(flist)+f)/((ns-1)*length(flist)), wb, ...
			  [step_name ' processing: ' strrep(flist(f).name,'_','-') ' ...']);

			% construct params -- for a processor, this is always:
			%  1: id of process step in processor_step array
			%  2: path of source image file 
			%  3: output path 
			params(1).value = step_idx;

			% source path -- last step's output; this is "safe" in terms of processors
			%  that do not output files since only ones that DO get to affect last_out_path
			params(2).value = last_out_path{f};

			% output path: based on specified path, processor name
			if (glovars.processor_step(step_idx).processor.image_output == 1)
				params(3).value = [output_path filesep strrep(glovars.processor_step(step_idx).processor.name,' ', '_') '_' flist(f).name];
			else
			  params(3).value = -1;
			end

			% setup parallel processing pertinent info
			if (parallel_exec == 1)

				% 0) .mat file name -- for parallel processing -- params(4)
				if (s == 2 & f == 1) % VERY FIRST so check for unfinished
				  par_list = dir([glovars.par_path filesep '*.mat']);
					if (length(par_list) > 1)
					  disp(['There are .mat files in ' glovars.par_path ' implying incomplete execution.  Delete or move them before proceeding.']);
						return;
					end
				end
				mat_fpath = [glovars.par_path filesep 'parfile_' num2str(step_idx) '_' num2str(f) '.mat'];
        params(4).value = mat_fpath;
  
				% 1) dependencies -- if other step must be done before, specify it as params(5)
				params(5).value = dep_filepath;

				% make the call to process batch IF PARALLEL EXECUTION ; 
				func = 'process_batch';
				retparams = eval([glovars.processor_step(s).processor.func_name '(func,params);']);
      else
				% make the call to process batch IF PARALLEL EXECUTION ; 
				func = 'process_single';
				retparams = eval([glovars.processor_step(s).processor.func_name '(func,params);']);
			end

			% --- process return
			if (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 1)
				if (retparams == -1 )
					disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: retparams -1.']);
				elseif (length(retparams) == 0)
					disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: no returned values.']);
				else
					disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: unknown reason.']);
				end
			% valid bc no image output exected -- BUT if -1 problem
			elseif (isstruct(retparams) == 0 & glovars.processor_step(s).processor.image_output == 0)
				if (retparams == -1 )
					disp(['Processor execution of ' glovars.processor_step(s).processor.name ' failed: retparams -1.']);
				else
					disp(['Processor execution of ' glovars.processor_step(s).processor.name ' successful.']);
				end
			% valid? then update processor steps, display to point to output image (IF APPLICABLE)
			else
			  if (parallel_exec == 0) % not parallel, then process as-usual
					% did this (should this!) return an image? - then update display
					im_path = '';
					im_fname = '';
					if (glovars.processor_step(step_idx).processor.image_output == 1)
						out_path = retparams(1).value;
						if (out_path(length(out_path)) == filesep) ; out_path = out_path(1:length(out_path)-1); end
						sli = find(out_path == filesep, 1, 'last');
					 
						% - assign file
						im_path = out_path(1:sli-1);
						im_fname = out_path(sli+1:length(out_path));
						glovars.processor_step(step_idx).im_path = im_path;
						glovars.processor_step(step_idx).im_fname = im_fname;

						% - if the PREVIOUS *file* step was not base image, then 
						%   delete its output - no longer needed
						if (last_step_is_base == 0)
							% ONLY delete if output is not input, as happens in many chains
						  if (strcmp(last_out_path{f}, [im_path filesep im_fname]) ~= 1) 
								delete(last_out_path{f});
							end
						end

            file_output = 1;
						% - keep last output path pointing to this step since it is your last step w/ a file output
						last_out_path{f} = [im_path filesep im_fname];
					end % otherwise do nothing - leave gui as is

					% --- update glovars.processor_step structure
					disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' successfully completed.']);
				else % parallel? similar to above BUT with caveats - e.g., not updating local images
					% did this (should this!) return an image? - then update next step so that it knows to look to new file
					im_path = '';
					im_fname = '';
					if (glovars.processor_step(step_idx).processor.image_output == 1)
            file_output = 1;

            % - extract filename
						out_path = params(3).value;
						if (out_path(length(out_path)) == filesep) ; out_path = out_path(1:length(out_path)-1); end
						sli = find(out_path == filesep, 1, 'last');
						im_path = out_path(1:sli-1);
						im_fname = out_path(sli+1:length(out_path));

						% - keep last output path pointing to this step since it is your last step w/ a file output
						last_out_path{f} = [im_path filesep im_fname];
		      end	

          % EVENTUALLY you should have 2 checkboxes 1) parallel mode 2) wait for par to execute ; if user selects 2
					%  as well as 1, this should ping every few seconds to see how much is left, and update gui at end 
					disp(['Processor execution of ' glovars.processor_step(step_idx).processor.name ' successfully queued.']);
					disp(['.MAT file path: ' retparams(1).value]);
				end
			end
		end

    % if this has batch_style of 1, assign dep file for *next* step
		if(glovars.processor_step(step_idx).processor.batch_style == 1)
		  dep_filepath = [glovars.par_path filesep 'parfile_' num2str(s) '_*.mat'];
		end
		if(glovars.processor_step(step_idx).processor.batch_style == 4)
		  dep_filepath = [glovars.par_path filesep 'parfile_' num2str(s) '_*.mat'];
		end

		% if there was file output, and last step was base, last step is no longer base
		if (last_step_is_base & file_output)
		  last_step_is_base = 0;
		end
	end

	% --- cleanup
	close(wb);


% --- Executes on button press in remove_processing_step_button.
function remove_processing_step_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_processing_step_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
	global glovars;
	cps = get(handles.processing_steps_list, 'Value');

	% 1) sanity check - selected? no remove base!
	if (length(cps) == 0)
	  disp('Must select a step to remove!');
	elseif (cps == 1)
	  disp('Cannot remove Base Image step.  To change Base Image, load a new image/stack.');
		return;
	end

	% 2) remove step ; if image output step, reset path for all subsequent steps  
	%    bc they must be rerun.  Also, run processor shutdown method and delete gui.
  new_processor_step(1) = glovars.processor_step(1);
	ni = 2;
	invalidate_output = 0; % once set to 1, all subsequent outputs eleted
  for s=2:length(glovars.processor_step)
	  if (s ~= cps) 
			new_processor_step(ni) = glovars.processor_step(s);
		else
		  if (glovars.processor_step(s).processor.image_output)
			  invalidate_output = 1;
		  end
			% delete gui
			if (glovars.processor_step(s).processor.gui_present == 1)
				root_func = glovars.processor_step(s).processor.func_name;
				params(1).value = s;
				func = 'shutdown';
				eval([root_func '(func,params);']);

				delete(glovars.processor_step(s).gui_handle.figure1);
			end

		  continue; % skip the rest
    end

		% invalidate output?
		if (invalidate_output)
		  new_processor_step(ni).im_path = [];
		  new_processor_step(ni).im_fname = [];
		end
	end
	glovars.processor_step = new_processor_step;

	% 3) update gui ...
	cps = cps-1;
	glovars.current_processor_step = cps;
	fluo_control_main_update_processing_steps_list();

% --- Executes on selection change in processing_steps_list.
function processing_steps_list_Callback(hObject, eventdata, handles)
% hObject    handle to processing_steps_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns processing_steps_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processing_steps_list
  global glovars;
  cps = get(hObject, 'Value');
	o_cps = glovars.current_processor_step;

  % IF the selected step outputs images but has not been run, tell the user
	if (glovars.processor_step(cps).processor.image_output == 1 & length(glovars.processor_step(cps).im_path) == 0)
	  disp('The processor step you requested has not been run yet; click Run Seq. to execute on current image');
	end

	% If the user selected a step with no image output, be all like BITCH you can't do that
	if (glovars.processor_step(cps).processor.image_output == 0)
	  disp('Cannot select a step without image output.');
	end

	% now go back to most recent step that has image output that exists (if needbe)
	while ((glovars.processor_step(cps).processor.image_output ~= 1 | length(glovars.processor_step(cps).im_path) == 0) ...
	       & cps > 0) ; cps = cps - 1 ; end

	% Load images only if  needbe
	if (cps ~= o_cps)
	  set(handles.nchan_edit,'String',num2str(glovars.processor_step(cps).im_nchan));
	  set(handles.usedchan_edit,'String',num2str(glovars.processor_step(cps).im_usedchan));
		fluo_display_open_stack (glovars.processor_step(cps).im_path, ...
			glovars.processor_step(cps).im_fname);
  end

	% update the list gui element
	glovars.current_processor_step = cps;
	fluo_control_main_update_processing_steps_list();


% --- Executes during object creation, after setting all properties.
function processing_steps_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processing_steps_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in select_source_images_path_button.
function select_source_images_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_source_images_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % --- first, prompt user for directory with dialog
	startpath = glovars.data_lastpath;
	if(0 ~= length(get(glovars.fluo_control_main.source_images_path_edit, 'String')))
	  startpath = get(glovars.fluo_control_main.source_images_path_edit, 'String');
	end
  sourcepath = uigetdir(startpath);
	if (sourcepath == 0) ; sourcepath = '' ; end
	
	% --- update the edit box, from which final path is always drawn
	set(glovars.fluo_control_main.source_images_path_edit, 'String', sourcepath);
	if(0 == length(get(glovars.fluo_control_main.output_images_path_edit, 'String')))
	  set(glovars.fluo_control_main.output_images_path_edit, 'String', [sourcepath '/fluo_batch_out/']);
	end

function source_images_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to source_images_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_images_path_edit as text
%        str2double(get(hObject,'String')) returns contents of source_images_path_edit as a double
  global glovars;

  % --- pull the sourcepath
  sourcepath = get(hObject,'String');
	
	% --- send it to output path if that is blank
	if(0 == length(get(glovars.fluo_control_main.output_images_path_edit, 'String')))
	  set(glovars.fluo_control_main.output_images_path_edit, 'String', [sourcepath '/fluo_batch_out/']);
	end


% --- Executes during object creation, after setting all properties.
function source_images_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_images_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_output_images_path_button.
function select_output_images_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_output_images_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % --- pull the output path; assign it to edit box 
	startpath = glovars.data_lastpath;
	if(0 ~= length(get(glovars.fluo_control_main.output_images_path_edit, 'String')))
	  startpath = get(glovars.fluo_control_main.output_images_path_edit, 'String');
	end
  outpath = uigetdir(startpath);
	if (outpath == 0) ; outpath = '' ; end
	set(glovars.fluo_control_main.output_images_path_edit, 'String', outpath);
	



function output_images_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_images_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_images_path_edit as text
%        str2double(get(hObject,'String')) returns contents of output_images_path_edit as a double


% --- Executes during object creation, after setting all properties.
function output_images_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_images_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function source_images_wildcard_edit_Callback(hObject, eventdata, handles)
% hObject    handle to source_images_wildcard_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_images_wildcard_edit as text
%        str2double(get(hObject,'String')) returns contents of source_images_wildcard_edit as a double


% --- Executes during object creation, after setting all properties.
function source_images_wildcard_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_images_wildcard_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in display_mode_frame_radio.
function display_mode_frame_radio_Callback(hObject, eventdata, handles)
% hObject    handle to display_mode_frame_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_mode_frame_radio

% GUI upate
set(handles.display_mode_frame_radio, 'Value', true);
set(handles.display_mode_mean_radio, 'Value', false);
set(handles.display_mode_max_radio, 'Value', false);

% assign mode ; update
global glovars;
glovars.fluo_display.display_mode = 1;
fluo_display_update_display();


% --- Executes on button press in display_mode_mean_radio.
function display_mode_mean_radio_Callback(hObject, eventdata, handles)
% hObject    handle to display_mode_mean_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_mode_mean_radio

% GUI upate
set(handles.display_mode_frame_radio, 'Value', false);
set(handles.display_mode_mean_radio, 'Value', true);
set(handles.display_mode_max_radio, 'Value', false);

% assign mode ; update
global glovars;
glovars.fluo_display.display_mode = 2;
fluo_display_update_display();


% --- Executes on button press in display_mode_max_radio.
function display_mode_max_radio_Callback(hObject, eventdata, handles)
% hObject    handle to display_mode_max_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_mode_max_radio

% GUI upate
set(handles.display_mode_frame_radio, 'Value', false);
set(handles.display_mode_mean_radio, 'Value', false);
set(handles.display_mode_max_radio, 'Value', true);

% assign mode ; update
global glovars;
glovars.fluo_display.display_mode = 3;
fluo_display_update_display();


% --- Executes on button press in add_processing_step_button.
function add_processing_step_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_processing_step_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	global glovars;

  % 0) preliminaries
  % --- determine the selected processor and obtain the processor structure
  processor_idx = get(handles.processor_menu, 'Value');
  processor_names = get(handles.processor_menu, 'String');
	processor_name = processor_names{processor_idx};
	processor = get_processors(processor_name);

  % 1) based on extant processing steps, determine the id for this one
  for s=1:length(glovars.processor_step)
	  uid(s) = glovars.processor_step(s).uid;
		tid(s) = glovars.processor_step(s).processor.type_id;
	end
	t_match = find(tid == processor.type_id);
	
	% 2) create it, add it
	new_step.name = [processor.name ' ' num2str(length(t_match)+1)];
	new_step.uid = max(uid)+1;
	new_step.im_path = '';
	new_step.im_fname = '';
  new_step.im_nchan = 1; 
  new_step.im_usedchan = 1; 
	new_step.gui_handle = [];
	new_step.processor = processor;

	step_idx = length(glovars.processor_step)+1;
	glovars.processor_step(step_idx) = new_step;

	% 3) invoke gui and store the gui pointer in glovars
	if (new_step.processor.gui_present == 1)
		root_func = processor.func_name;
		func = 'init'; % call the init function within the processor
		params(1).value = step_idx;
		eval([root_func '(func,params);']);
		set(glovars.processor_step(step_idx).gui_handle.figure1, 'name', ...
		    glovars.processor_step(step_idx).name);
	end

	% 4) Update list in GUI
  fluo_control_main_update_processing_steps_list()


% --- Executes on selection change in processor_output_format_menu.
function processor_output_format_menu_Callback(hObject, eventdata, handles)
% hObject    handle to processor_output_format_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processor_output_format_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processor_output_format_menu


% --- Executes during object creation, after setting all properties.
function processor_output_format_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processor_output_format_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in processor_enable_parallel_checkbox.
function processor_enable_parallel_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to processor_enable_parallel_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of processor_enable_parallel_checkbox


function nchan_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nchan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nchan_edit as text
%        str2double(get(hObject,'String')) returns contents of nchan_edit as a double
  global glovars;
	oldnchan = glovars.fluo_display.nchan;
	glovars.fluo_display.nchan = str2num(get(hObject,'String'));

  % If changed, reload image
	if (oldnchan ~= glovars.fluo_display.nchan)
	  % SOON, update processor steps accordingly??
	  disp('WARNING: changing channel properties does not currently work with processor chains.');
		cps = 1;
		glovars.current_processor_step = cps;
		fluo_display_open_stack (glovars.processor_step(cps).im_path, ...
			glovars.processor_step(cps).im_fname, []);
		glovars.processor_step(1).im_nchan = glovars.fluo_display.nchan;
		glovars.processor_step(1).im_usedchan = glovars.fluo_display.usedchan;

		% wipe other processor steps
		for s=2:length(glovars.processor_step)
		  glovars.processor_step(s).im_path = '';
		  glovars.processor_step(s).im_fname = '';
		end
	end


% --- Executes during object creation, after setting all properties.
function nchan_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nchan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function usedchan_edit_Callback(hObject, eventdata, handles)
% hObject    handle to usedchan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of usedchan_edit as text
%        str2double(get(hObject,'String')) returns contents of usedchan_edit as a double
  global glovars;
	oldchan = glovars.fluo_display.usedchan;
	glovars.fluo_display.usedchan = str2num(get(hObject,'String'));

  % If changed, reload image
	if (oldchan ~= glovars.fluo_display.usedchan)
	  % SOON, update processor steps accordingly??
	  disp('WARNING: changing channel properties does not currently work with processor chains.');
		cps = 1;
		glovars.current_processor_step = cps;
		fluo_display_open_stack (glovars.processor_step(cps).im_path, ...
			glovars.processor_step(cps).im_fname, []);
		glovars.processor_step(1).im_nchan = glovars.fluo_display.nchan;
		glovars.processor_step(1).im_usedchan = glovars.fluo_display.usedchan;

		% wipe other processor steps
		for s=2:length(glovars.processor_step)
		  glovars.processor_step(s).im_path = '';
		  glovars.processor_step(s).im_fname = '';
		end
	end

 
% --- Executes during object creation, after setting all properties.
function usedchan_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to usedchan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------


