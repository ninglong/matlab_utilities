function varargout = fluo_display(varargin)
% FLUO_DISPLAY M-file for fluo_display.fig
%      FLUO_DISPLAY, by itself, creates a new FLUO_DISPLAY or raises the existing
%      singleton*.
%
%      H = FLUO_DISPLAY returns the handle to a new FLUO_DISPLAY or the handle to
%      the existing singleton*.
%
%      FLUO_DISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUO_DISPLAY.M with the given input arguments.
%
%      FLUO_DISPLAY('Property','Value',...) creates a new FLUO_DISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluo_display_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluo_display_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluo_display

% Last Modified by GUIDE v2.5 14-Dec-2009 12:26:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluo_display_OpeningFcn, ...
                   'gui_OutputFcn',  @fluo_display_OutputFcn, ...
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



% --- Executes just before fluo_display is made visible.
function fluo_display_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluo_display (see VARARGIN)

% SP ----------------------------------------------------------------------
if (isglobal('glovars')) ; clear global glovars ; end
global glovars; 

% 0) Assign global variable settings that need to be 'zeroed'
glovars.fluo_display_axes.mouse_mode = 0; % 0 - nothing ; 1 - roi-selection
glovars.fluo_display.display_mode = 1; % 1: frame 2: stack mean 3: stack max proj
glovars.fluo_display.display_im_x_matrix = []; % for use in computations ; populated in loading im
glovars.fluo_display.display_im_y_matrix = [];
glovars.fluo_display.stop_movie = 0; % set to 1 during movie play to stop

% 1) load config file --

% a) ALL THIS should be assignable from the future config gui
glovars.data_rootpath = '/home/speron/data/';
% analyzed data is output here, in a mirror of data_rootpath directory substructure; if the
%  analout is same as data rootpath, obviously no dirs are made
glovars.analout_rootpath = '/home/speron/anal/'; 
glovars.fluo_display.hor_pix2um = 1; % in um/pix
glovars.fluo_display.ver_pix2um = 1; % in um/pix
glovars.fluo_display.nchan = 1; % number of image channels
glovars.fluo_display.usedchan = 1; % used image channel

% b) things that are not necessarily assignable
glovars.data_lastpath = '/home/speron/data/mouse_gcamp_learn/';

% 2) files in place?
glovars.root_path = strrep(which('fluo_display'), 'fluo_display.m','');
if (exist([glovars.root_path filesep 'tmp'], 'dir') == 0)
  mkdir([glovars.root_path filesep 'tmp']);
end
glovars.processors_path = [glovars.root_path filesep 'processors'];
glovars.tmp_path = [glovars.root_path filesep 'tmp'];
glovars.par_path = [glovars.root_path filesep 'par']; % directory for parallel processing .mat files and scripts

% 3) connect relevant gui elements to glovars
glovars.fluo_display.fluo_display_axes = handles.fluo_display_axes;
glovars.fluo_display.fluo_display_message_text = handles.fluo_display_message_text;
glovars.fluo_display.fluo_display_frame_slider = handles.fluo_display_frame_slider;
glovars.fluo_display.fluo_display_framenum_text = handles.fluo_display_framenum_text;

% 4) assign default values to glovar members that need it
glovars.fluo_display.aspect_ratio = 1; % 1: square ; 2: image size ; 3: pix/um-based

% 5) open other relevant guis
fluo_control_main();
fluo_roi_control();

% 6) load image file
if (length(varargin) > 1)
	fluo_display_open_stack(varargin{1},varargin{2});
end

% END SP ------------------------------------------------------------------

% Choose default command line output for fluo_display
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluo_display wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fluo_display_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_open_stack_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_open_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_display_open_stack();


% --- Executes on slider movement.
function fluo_display_frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_display_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  global glovars;

  im_frame = round(get(hObject,'Value'));
	glovars.fluo_display.display_im_frame = im_frame;
	glovars.fluo_display.stop_movie = 1;
	fluo_display_update_display();

% --- Executes during object creation, after setting all properties.
function fluo_display_frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fluo_display_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on mouse press over main_axes background.
function fluo_display_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  this_point = get(handles.fluo_display_axes,'CurrentPoint');

	switch (glovars.fluo_display_axes.mouse_mode)
	  case 1 % ROI selection -- highlight w/ yellow line / dot
		  np = glovars.fluo_roi_control.new_roi.n_corners + 1;
		  glovars.fluo_roi_control.new_roi.n_corners = np;

		  glovars.fluo_roi_control.new_roi.corners(:,np) = ...
			  [this_point(1,1) this_point(1,2)];
	    draw_x(glovars.fluo_roi_control.new_roi.corners(1,np), ...
	           glovars.fluo_roi_control.new_roi.corners(2,np), 1, ...
						 glovars.fluo_roi_control.new_roi.color);
			if (np > 1) % connect line to last point if needbe
			  hold on;
			  plot([glovars.fluo_roi_control.new_roi.corners(1,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(1,np)], ...
			        [glovars.fluo_roi_control.new_roi.corners(2,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(2,np)], ...
							[glovars.fluo_roi_control.new_roi.color '-']);
				hold off;
			end
	end


% --------------------------------------------------------------------
function config_menu_Callback(hObject, eventdata, handles)
% hObject    handle to config_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_user_settings_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_user_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_gui_settings_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_gui_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_stack_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
	global glovars;

	% go to appropriate directory
	cwd = pwd();

	% dialog
  cd (glovars.processor_step(1).im_path);
%cd ('~/Desktop/lab_mtg_movies'); %% TEMP
	[filename, pathname, filt] = ... 
	  uiputfile({'*.tif'}, 'Save stack to file ...', ...
		strrep(glovars.processor_step(1).im_fname, '.tif', '_2.tif'));

  % and save ...
	if (isequal(filename,0) == 0)
	  stack = glovars.fluo_display.display_im;
		imwrite(uint16(stack(:,:,1)), [pathname filesep filename], 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');
		for s=2:size(stack,3)
			imwrite(uint16(stack(:,:,s)), [pathname filesep filename], 'tif', 'Compression', 'none', 'WriteMode', 'append');
		end
		disp(['Image stack saved to ' pathname filesep filename]);
	end

  % cleanup
	cd(cwd);


% --- Executes on button press in play_movie_button.
function play_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

  % sanity
	if (glovars.fluo_display.display_im_nframes == 1)
	  disp('Only one frame - that would be stOOOpid.');
		return;
	end

  % grab current frame
  cf = glovars.fluo_display.display_im_frame;
	glovars.fluo_display.stop_movie = 0;

	% loop start to finish, around current frame
	frame_dt = min(0.1, 5/glovars.fluo_display.display_im_nframes);
  for f=[cf:glovars.fluo_display.display_im_nframes 1:cf]
		glovars.fluo_display.display_im_frame = f;
		if (glovars.fluo_display.stop_movie) ; break ; end
		fluo_display_update_display();
		pause (frame_dt); % 10 hz -- OR 10 s at most in case long movie
	end

 


% --- Executes on button press in stop_movie_button.
function stop_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;
	glovars.fluo_display.stop_movie = 1;


% --- Executes on button press in play_loop_button.
function play_loop_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_loop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

  % sanity
	if (glovars.fluo_display.display_im_nframes == 1)
	  disp('Only one frame - that would be stOOOpid.');
		return;
	end

  % enable playing
	glovars.fluo_display.stop_movie = 0;

	% loop around and around and around
	frame_dt = min(0.1, 5/glovars.fluo_display.display_im_nframes);
  f = glovars.fluo_display.display_im_frame;

	while (~ glovars.fluo_display.stop_movie)
    % increment
		f = f+1;
		if (f > glovars.fluo_display.display_im_nframes) ; f = 1 ; end

		% display & pozz
		glovars.fluo_display.display_im_frame = f;
		fluo_display_update_display();
		pause (frame_dt); % 10 hz -- OR 10 s at most in case long movie
	end



% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------
