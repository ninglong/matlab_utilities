function varargout = fluo_roi_control(varargin)
% FLUO_ROI_CONTROL M-file for fluo_roi_control.fig
%      FLUO_ROI_CONTROL, by itself, creates a new FLUO_ROI_CONTROL or raises the existing
%      singleton*.
%
%      H = FLUO_ROI_CONTROL returns the handle to a new FLUO_ROI_CONTROL or the handle to
%      the existing singleton*.
%
%      FLUO_ROI_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUO_ROI_CONTROL.M with the given input arguments.
%
%      FLUO_ROI_CONTROL('Property','Value',...) creates a new FLUO_ROI_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluo_roi_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluo_roi_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluo_roi_control

% Last Modified by GUIDE v2.5 28-Sep-2009 22:09:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluo_roi_control_OpeningFcn, ...
                   'gui_OutputFcn',  @fluo_roi_control_OutputFcn, ...
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


% --- Executes just before fluo_roi_control is made visible.
function fluo_roi_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluo_roi_control (see VARARGIN)

% SP ----------------------------------------------------------------------
global glovars; 

% 0) Assign gloval variables that need to be 'zeroed'

% ROIs and their properties
glovars.fluo_roi_control.new_roi.n_corners = 0;
glovars.fluo_roi_control.new_roi.corners = [];
glovars.fluo_roi_control.new_roi.indices = [];
glovars.fluo_roi_control.new_roi.raw_fluo = [];
glovars.fluo_roi_control.new_roi.color = 'y';
glovars.fluo_roi_control.roi = [];
glovars.fluo_roi_control.n_rois = 0;

% GUI elements
glovars.fluo_roi_control.current_roi_text = handles.current_roi_text;

% GUI variables
glovars.fluo_roi_control.show_roi_numbers = 0;
glovars.fluo_roi_control.roi_selected = -1; % none ; 0 = all

% etc
glovars.fluo_roi_control.roi_colors = ['r', 'g', 'b', 'm', 'c'];
% END SP ------------------------------------------------------------------


% Choose default command line output for fluo_roi_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluo_roi_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set default gui parameters
set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
	  
 

% --- Outputs from this function are returned to the command line.
function varargout = fluo_roi_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in new_roi_button.
function new_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
	disp('Draw your ROI in fluo_display; click Done when finished');
	glovars.fluo_display_axes.mouse_mode = 1;
	glovars.fluo_roi_control.new_roi.n_corners = 0;
	glovars.fluo_roi_control.new_roi.corners = [];
	glovars.fluo_roi_control.new_roi.indices = [];
	glovars.fluo_roi_control.new_roi.raw_fluo = [];

% --- Executes on button press in select_roi_button.
function select_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in previous_roi_button.
function previous_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
		glovars.fluo_roi_control.roi_selected =  ...
			glovars.fluo_roi_control.roi_selected - 1;
		if (glovars.fluo_roi_control.roi_selected < 1)
			glovars.fluo_roi_control.roi_selected = ...
				glovars.fluo_roi_control.n_rois;
		end
		gvs = glovars.fluo_roi_control.roi_selected;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(gvs));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(gvs).color);
 
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end


% --- Executes on button press in next_roi_button.
function next_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
		glovars.fluo_roi_control.roi_selected =  ...
			glovars.fluo_roi_control.roi_selected + 1;
		if (glovars.fluo_roi_control.roi_selected > glovars.fluo_roi_control.n_rois)
			glovars.fluo_roi_control.roi_selected =  1;
		end
		gvs = glovars.fluo_roi_control.roi_selected;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(gvs));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(gvs).color);
 
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end


% --- Executes on button press in delete_roi_button.
function delete_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	gvs = glovars.fluo_roi_control.roi_selected;
	roi = glovars.fluo_roi_control.roi;

  % all -- are you SURE?
	if (glovars.fluo_roi_control.roi_selected == 0)
	  choice = questdlg('Are you sure you want to delete all ROIs?', ...
		 'Warning of imminent death', ...
		 'Yes, I know what I am doing','No, I am a retard', 'No, I am a retard');
		% Handle response
		delete_all = 0;
		switch choice
			case 'Yes, I know what I am doing'
				disp([choice ' coming right up.'])
				delete_all = 1;
			case 'No, I am a retard'
		end
		% did the user REALLY want to?
		if (delete_all)
			glovars.fluo_roi_control.new_roi.n_corners = 0;
			glovars.fluo_roi_control.new_roi.corners = [];
			glovars.fluo_roi_control.new_roi.indices = [];
			glovars.fluo_roi_control.new_roi.raw_fluo = [];
			glovars.fluo_roi_control.new_roi.color = 'y';
			glovars.fluo_roi_control.roi = [];
			glovars.fluo_roi_control.n_rois = 0;
		end
	end

	% delete it
	nr = 1;
	newrois = [];
	for r=1:glovars.fluo_roi_control.n_rois
	  % skip the victim
	  if (r == gvs) ; continue ; end

		% assign
		newrois(nr).color = roi(r).color;
		newrois(nr).corners= roi(r).corners;
		newrois(nr).n_corners= roi(r).n_corners;
		newrois(nr).indices = roi(r).indices;
		newrois(nr).raw_fluo = roi(r).raw_fluo;
		nr = nr + 1;
  end
	glovars.fluo_roi_control.roi = newrois;

	glovars.fluo_roi_control.n_rois = max(glovars.fluo_roi_control.n_rois - 1,0);
	if (glovars.fluo_roi_control.n_rois == 0) 
	  glovars.fluo_roi_control.roi_selected = -1; 
		set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
	end

	% update graphics, structure
	fluo_display_update_display();

% --- Executes on button press in save_rois_button.
function save_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
	global glovars;

	% go to appropriate directory
	cwd = pwd();

	% dialog
  cd (glovars.processor_step(1).im_path);
	[filename, pathname, filt] = ... 
	  uiputfile({'*.mat'}, 'Save ROI data to file', 'ROI.mat');

  % and save ...
	if (isequal(filename,0) == 0)
		fluo_roi_control_update_rois();
	  roi = glovars.fluo_roi_control.roi;
	  n_rois = glovars.fluo_roi_control.n_rois;
		save([pathname filesep filename], 'roi', 'n_rois');
		disp(['ROI data saved to ' pathname filesep filename]);
	end
  % cleanup
	cd(cwd);

% --- Executes on button press in load_rois_button.
function load_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % dialog, exist test
	[filename, filepath]=uigetfile({'*.mat'}, ...
	  'Select ROI file', glovars.processor_step(1).im_path);

	% load
	if (exist([filepath filesep filename],'file') ~= 0)
	  load([filepath filesep filename]);
	  glovars.fluo_roi_control.roi = roi;
		glovars.fluo_roi_control.n_rois = n_rois;

    glovars.fluo_roi_control.roi_selected = 0; % default is select all for fast plotting
		set(glovars.fluo_roi_control.current_roi_text,'String', 'All');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
 
		fluo_roi_control_update_rois();

		% update screen
		fluo_display_update_display();
		disp(['Loaded ROI file ' filepath filesep filename]);
  else
		disp(['Invalid ROI file: ' filepath filesep filename]);
	end
	
% --- Executes on button press in autodetect_rois_button.
function autodetect_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to autodetect_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in autoselect_roi_list.
function autoselect_roi_list_Callback(hObject, eventdata, handles)
% hObject    handle to autoselect_roi_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns autoselect_roi_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from autoselect_roi_list


% --- Executes during object creation, after setting all properties.
function autoselect_roi_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoselect_roi_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done_roi_button.
function done_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
	
	if (glovars.fluo_roi_control.new_roi.n_corners > 1)
		% Done with selecting new ROI -- lets build it
		nr = glovars.fluo_roi_control.n_rois + 1;
		glovars.fluo_roi_control.n_rois = nr;
	 
		% 1) define corners, color
		glovars.fluo_roi_control.roi(nr).n_corners = glovars.fluo_roi_control.new_roi.n_corners;
		glovars.fluo_roi_control.roi(nr).corners = [glovars.fluo_roi_control.new_roi.corners ...
			glovars.fluo_roi_control.new_roi.corners(:,1)];
		ci = rem(nr,length(glovars.fluo_roi_control.roi_colors))+1;
		glovars.fluo_roi_control.roi(nr).color = glovars.fluo_roi_control.roi_colors(ci);

		% 2) determine indices (i.e., indices within image matrix for easy access)
		xv = glovars.fluo_roi_control.roi(nr).corners(1,:);
		yv = glovars.fluo_roi_control.roi(nr).corners(2,:);
    in = inpolygon(glovars.fluo_display.display_im_x_matrix, ...
                   glovars.fluo_display.display_im_y_matrix, ...
									 xv, yv);
		glovars.fluo_roi_control.roi(nr).indices = find(in == 1);

		% 3) raw fluo across the movie
		for f=1:glovars.fluo_display.display_im_nframes
			frame_im = glovars.fluo_display.display_im(:,:,f);
		  glovars.fluo_roi_control.roi(nr).raw_fluo(f) = ...
			  mean (frame_im(glovars.fluo_roi_control.roi(nr).indices));
		end

		% 4) clear new roi, mouse mode
		glovars.fluo_roi_control.new_roi.n_corners = 0;
		glovars.fluo_roi_control.new_roi.corners = [];
		glovars.fluo_roi_control.new_roi.indices = [];
		glovars.fluo_roi_control.new_roi.raw_fluo = [];
		glovars.fluo_display_axes.mouse_mode = 0;

		% 5) update display
		glovars.fluo_roi_control.roi_selected = nr;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(nr));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(nr).color);
		fluo_display_update_display();
  end 



function base_frame_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_frame_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_frame_start_edit as text
%        str2double(get(hObject,'String')) returns contents of base_frame_start_edit as a double


% --- Executes during object creation, after setting all properties.
function base_frame_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_frame_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function base_frame_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_frame_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_frame_end_edit as text
%        str2double(get(hObject,'String')) returns contents of base_frame_end_edit as a double


% --- Executes during object creation, after setting all properties.
function base_frame_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_frame_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_dff_button.
function plot_dff_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_dff_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
%% 
base_frames = [1 5];

  % 0) update rois ; determine which one(s) is/are selected
  fluo_roi_control_update_rois();
  croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % 1) compute
	dff = zeros(glovars.fluo_roi_control.n_rois, glovars.fluo_display.display_im_nframes);
  for r=1:length(R)
    roi = glovars.fluo_roi_control.roi(R(r));
		f0 = mean(roi.raw_fluo(base_frames(1):base_frames(2)));
		dff(r,:) = (roi.raw_fluo-f0)/f0;
	end

	% 2) plot -- separate loops bc we want to know things about *all* plots
	figure;
	offset = 1.2*max(max(dff));
	t = 1:glovars.fluo_display.display_im_nframes;
	hold on;
	for r=1:length(R)
	  plot(t, (r-1)*offset + dff(r,:), glovars.fluo_roi_control.roi(R(r)).color);
   
	  % line @ "0"
    plot([min(t) max(t)], [(r-1)*offset (r-1)*offset], 'k:');

		% label #
    text(min(t) + 0.1*(max(t)-min(t)), (r-0.75)*offset , num2str(R(r)), 'Color', 'k');
	end


% --- Executes on button press in plot_raw_fluo_button.
function plot_raw_fluo_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_raw_fluo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% 0) refresh in case of img change etc.
  fluo_roi_control_update_rois();

  % 1) compute
	fl = zeros(glovars.fluo_roi_control.n_rois, glovars.fluo_display.display_im_nframes);
  for r=1:glovars.fluo_roi_control.n_rois
    roi = glovars.fluo_roi_control.roi(r);
		fl(r,:) = roi.raw_fluo;
	end

	% 2) plot -- separate loops bc we want to know things about *all* plots
	figure;
	offset = 1.2*max(max(fl));
	t = 1:glovars.fluo_display.display_im_nframes;
	hold on;
	for r=1:glovars.fluo_roi_control.n_rois
	  plot(t, (r-1)*offset + fl(r,:), glovars.fluo_roi_control.roi(r).color);
   
	  % line @ "0"
    plot([min(t) max(t)], [(r-1)*offset (r-1)*offset], 'k:');

		% label #
    text(min(t) + 0.1*(max(t)-min(t)), (r-0.75)*offset , num2str(r), 'Color', 'k');
	end


% --- Executes on button press in show_numbers_checkbox.
function show_numbers_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_numbers_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_numbers_checkbox
  global glovars;
	if (glovars.fluo_roi_control.show_roi_numbers == 0)
	  glovars.fluo_roi_control.show_roi_numbers = 1;
		set (hObject,'Value', 1);
	else
	  glovars.fluo_roi_control.show_roi_numbers = 0;
		set (hObject,'Value', 0);
	end
	fluo_display_update_display();


% --- Executes on button press in move_rois_left_button.
function move_rois_left_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) - 1;
		end
		fluo_display_update_display();
  end


% --- Executes on button press in move_rois_right_button.
function move_rois_right_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_right_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) + 1;
		end
		fluo_display_update_display();
  end

% --- Executes on button press in move_rois_down_button.
function move_rois_down_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_down_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) + 1;
		end
		fluo_display_update_display();
	end


% --- Executes on button press in move_rois_up_button.
function move_rois_up_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_up_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) - 1;
		end
		fluo_display_update_display();
	end


% --- Executes on button press in select_all_rois.
function select_all_rois_Callback(hObject, eventdata, handles)
% hObject    handle to select_all_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
		glovars.fluo_roi_control.roi_selected = 0;
		set(glovars.fluo_roi_control.current_roi_text,'String', 'All');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------

