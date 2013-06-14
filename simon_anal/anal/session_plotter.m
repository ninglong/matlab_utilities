function varargout = session_plotter(varargin)
% SESSION_PLOTTER M-file for session_plotter.fig
%      SESSION_PLOTTER, by itself, creates a new SESSION_PLOTTER or raises the existing
%      singleton*.
%
%      H = SESSION_PLOTTER returns the handle to a new SESSION_PLOTTER or the handle to
%      the existing singleton*.
%
%      SESSION_PLOTTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SESSION_PLOTTER.M with the given input arguments.
%
%      SESSION_PLOTTER('Property','Value',...) creates a new SESSION_PLOTTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before session_plotter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to session_plotter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help session_plotter

% Last Modified by GUIDE v2.5 21-Oct-2009 07:43:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @session_plotter_OpeningFcn, ...
                   'gui_OutputFcn',  @session_plotter_OutputFcn, ...
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


% --- Executes just before session_plotter is made visible.
function session_plotter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to session_plotter (see VARARGIN)

% SP ----------------------------------------------------------------------
if (isglobal('glospvars')) ; clear global glospvars ; end
global glospvars; 

% 0) teh globals -- connect to gui, iniitialize others
% init:
glospvars.session = []; % session structure from file

% timseries params
glospvars.ts_type_ids = []; % stores typeids for all timeseries
glospvars.ts_unique_ids= []; % stores unique ids for all timeseries
glospvars.ts_colors = []; % 3xn matrix with color for each time series
glospvars.ts_id_strs = {}; % stores id strs for all timeseries
glospvars.ts_use_flags = []; % 0: off ; 1: show as TS ; 2: show as backdrop

% plot data
glospvars.backdrop_img = []; % stores bkg image for speed
glospvars.backdrop_img_trial_idx = -1; % so that you dont regenerate if unneeded

% internal state info
glospvars.plot_mode = 1; % 1: series as image, multi trial
                         % 2: series as raw, multi trial
                         % 3: single trial
												 % 4: multiseries, mutli-trial as image

% GUI connection:
glospvars.session_plotter.series_list = handles.series_list;
glospvars.session_plotter.trial_file_edit = handles.trial_file_edit;
glospvars.figure = figure;

% 1) gui setup

% set up the plot style pulldown
set(handles.plot_style_menu, 'String', {'Series as image', 'Series as raw', 'Single trial', ...
  'All trials, all series as img'});
set(handles.selected_text, 'String', 'Select series:');

% 2) load file
if (length(varargin) > 0)
  session_plotter_load_trials(varargin{1});
end

% END SP ------------------------------------------------------------------

% Choose default command line output for session_plotter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes session_plotter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = session_plotter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function trial_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to trial_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_file_edit as text
%        str2double(get(hObject,'String')) returns contents of trial_file_edit as a double


% --- Executes during object creation, after setting all properties.
function trial_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trial_file_select_button.
function trial_file_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to trial_file_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
	% invoke the dialog
	[filename, filepath]=uigetfile({'*.mat', 'MATfile (*.mat)'; ...
									 '*.*','All Files (*.*)'},'Select MAT file with trial data', '~/data');

	% pass the information to the loading function


% --- Executes on selection change in plot_style_menu.
function plot_style_menu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_style_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_style_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_style_menu


% --- Executes during object creation, after setting all properties.
function plot_style_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_style_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prev_button.
function prev_button_Callback(hObject, eventdata, handles)
% hObject    handle to prev_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glospvars;

	% --- response based on mode
	switch glospvars.plot_mode
	  case 1%  single series, mutli trial, as image - change background img trial
		  bti = find(glospvars.ts_use_flags == 2);
			if (length(bti) < 1) % not allowed
			  disp('Cannot change - must select a backdrop img first!')
			else % increment, display
			  glospvars.ts_use_flags(bti) = 0;
				if (bti-1 < 1)
				  glospvars.ts_use_flags(length(glospvars.ts_use_flags)) = 2;
				else
				  glospvars.ts_use_flags(bti-1) = 2;
				end
				session_plotter_update_series_list();
				session_plotter_plot_series_as_image();
			end
	end
	  


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glospvars;

	% --- response based on mode
	switch glospvars.plot_mode
	  case 1%  single series, mutli trial, as image - change background img trial
		  bti = find(glospvars.ts_use_flags == 2);
			if (length(bti) < 1) % not allowed
			  disp('Cannot change - must select a backdrop img first!')
			else % increment, display
			  glospvars.ts_use_flags(bti) = 0;
				if (bti+1 > length(glospvars.ts_use_flags))
				  glospvars.ts_use_flags(1) = 2;
				else
				  glospvars.ts_use_flags(bti+1) = 2;
				end
				session_plotter_update_series_list();
				session_plotter_plot_series_as_image();
			end
	end
	  

function goto_edit_Callback(hObject, eventdata, handles)
% hObject    handle to goto_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goto_edit as text
%        str2double(get(hObject,'String')) returns contents of goto_edit as a double


% --- Executes during object creation, after setting all properties.
function goto_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goto_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goto_button.
function goto_button_Callback(hObject, eventdata, handles)
% hObject    handle to goto_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in series_list.
function series_list_Callback(hObject, eventdata, handles)
% hObject    handle to series_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns series_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from series_list


% --- Executes during object creation, after setting all properties.
function series_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to series_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function backdrop_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to backdrop_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backdrop_id_edit as text
%        str2double(get(hObject,'String')) returns contents of backdrop_id_edit as a double



% --- Executes during object creation, after setting all properties.
function backdrop_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backdrop_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in backdrop_set_button.
function backdrop_set_button_Callback(hObject, eventdata, handles)
% hObject    handle to backdrop_set_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glospvars;

  % --- grab selection
  idx = get(glospvars.session_plotter.series_list, 'Value');

	% --- response based on mode
	switch glospvars.plot_mode
	  case 1%  single series, mutli trial, as image - change background img trial to selected
		  bti = find(glospvars.ts_use_flags == 2);
			glospvars.ts_use_flags(bti) = 0;
			glospvars.ts_use_flags(idx) = 2;

			% gui and list update
			session_plotter_update_series_list();
			session_plotter_plot_series_as_image();
	end
	  



function enable_eventseries_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to enable_eventseries_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enable_eventseries_id_edit as text
%        str2double(get(hObject,'String')) returns contents of enable_eventseries_id_edit as a double


% --- Executes during object creation, after setting all properties.
function enable_eventseries_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enable_eventseries_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enable_eventseries_button.
function enable_eventseries_button_Callback(hObject, eventdata, handles)
% hObject    handle to enable_eventseries_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function enable_timeseries_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to enable_timeseries_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enable_timeseries_id_edit as text
%        str2double(get(hObject,'String')) returns contents of enable_timeseries_id_edit as a double


% --- Executes during object creation, after setting all properties.
function enable_timeseries_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enable_timeseries_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enable_timeseries_button.
function enable_timeseries_button_Callback(hObject, eventdata, handles)
% hObject    handle to enable_timeseries_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in print_button.
function print_button_Callback(hObject, eventdata, handles)
% hObject    handle to print_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in print_to_file_button.
function print_to_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to print_to_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in disable_plot_element_button.
function disable_plot_element_button_Callback(hObject, eventdata, handles)
% hObject    handle to disable_plot_element_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function disable_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to disable_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of disable_id_edit as text
%        str2double(get(hObject,'String')) returns contents of disable_id_edit as a double


% --- Executes during object creation, after setting all properties.
function disable_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to disable_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_plot_settings_button.
function save_plot_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_plot_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_plot_settings_button.
function load_plot_settings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_plot_settings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------

%
% Loads a .mat file with trial information ; assigns the structure to
%  glospvars.session
%
%  filepath: the file in question
%
function session_plotter_load_trials(filepath)
  global glospvars;

  % 1) sanity check

	% 2) load the trial file ; gui filename set
	load(filepath);
  set(glospvars.session_plotter.trial_file_edit, 'String', filepath)
% FOR NOW, this is roi_trial
session.trial = roi_trial;

	% 3) check for errors within

	% 4) assign
	glospvars.session = session;

	% 5) setup ts_xxx es_xxx vectors/matrices
	disp('Warning: currently assuming that all trials have same timeseries/eventseries');
	list_entries = {};
  for s=1:length(session.trial(1).timeseries)
	  glospvars.ts_type_ids(s) = session.trial(1).timeseries(s).type_id;
	  glospvars.ts_unique_ids(s) = session.trial(1).timeseries(s).unique_id;
	  glospvars.ts_id_strs{s} = session.trial(1).timeseries(s).id_str;
	  glospvars.ts_colors(s,:) = [0 0 0];
	  glospvars.ts_use_flags(s) = 0;

		% also set up the cellarray for list entries:
	  list_entries{s} = [num2str(session.trial(1).timeseries(s).type_id) '.'  num2str(session.trial(1).timeseries(s).unique_id) ...
		                   ' ' session.trial(1).timeseries(s).id_str];
	end
  glospvars.ts_use_flags(1) = 2; % default . . .

  % 6) update list 
  session_plotter_update_series_list();

	% 7) plot default
  session_plotter_plot_series_as_image();

%
% Updates the series list box for session plotter, assigning * and ** to
%  timeseries that are displayed and used as backdrop, respectively.  Also
%  colors the text appropriately.
%
function session_plotter_update_series_list()
  global glospvars;

	% go and construct your strings ; flag = 1: * ; flag = 2: **
	list_entries = {};
  for s=1:length(glospvars.ts_use_flags)
	  if (glospvars.ts_use_flags(s) == 1) % shown ; *
		  list_entries{s} = ['* ' num2str(glospvars.ts_type_ids(s)) '.' num2str(glospvars.ts_unique_ids(s)) ...
			                   ' ' glospvars.ts_id_strs{s}];
		elseif (glospvars.ts_use_flags(s) == 2) % backdrop ; **
		  list_entries{s} = ['** ' num2str(glospvars.ts_type_ids(s)) '.' num2str(glospvars.ts_unique_ids(s)) ...
			                   ' ' glospvars.ts_id_strs{s}];
		else % all other instances -- should all be zero!
		  list_entries{s} = [num2str(glospvars.ts_type_ids(s)) '.' num2str(glospvars.ts_unique_ids(s)) ...
			                   ' ' glospvars.ts_id_strs{s}];
		end
	end

	% update gui
  set(glospvars.session_plotter.series_list, 'String', list_entries);

%
% Plotting function for plotting series-as-image via session plotter.
%
% Basically, it will plot the specified timeseries (use_flag==2) as the backdrop
%  in the appropriate colormap.  Additional event series (use_flag == 1) will
%  be displayed as ticks, for now.
%
function session_plotter_plot_series_as_image()
  global glospvars;

	% --- construct background image
	bti = find(glospvars.ts_use_flags == 2);
	if (length(bti) > 0)
	  bti = bti(1); % in case several, do first.
    time_vec = glospvars.session.trial(1).timeseries(bti).time; % time vector; ASSUMES first trial same as rest
    dt = glospvars.session.trial(1).timeseries(bti).dt; % dt; ASSUMES first trial same as rest

    if (glospvars.backdrop_img_trial_idx ~= bti) % build new if needbe
			ntp = length(glospvars.session.trial(1).timeseries(bti).values); % number of time points ; ASSUMES first trial indicative of rest

			% construc tthe matrix by looping thru trials
			glospvars.backdrop_img = zeros(length(glospvars.session.trial), ntp);
disp(['ntr: ' num2str(length(glospvars.session.trial))]);
			for t=1:length(glospvars.session.trial)
			  % processing based on type-id
				if (glospvars.ts_type_ids(bti) == 1) % ROI data - convert from raw fluo to df/f **later make this optional**
				  f0 = mean(glospvars.session.trial(t).timeseries(bti).values(1:5));
					glospvars.backdrop_img(t,:) = (glospvars.session.trial(t).timeseries(bti).values-f0)/f0;
				else
					glospvars.backdrop_img(t,:) = glospvars.session.trial(t).timeseries(bti).values;
				end
			end

			% assign index to what you have selected so you dont repeat later
			glospvars.backdrop_img_trial_idx = bti;
		end

		% --- plot it
		figure(glospvars.figure);
		M = max(max(glospvars.backdrop_img));
		dt = dt/1000;
		image(100*glospvars.backdrop_img/M, 'XData', (dt/2)+[min(time_vec)/1000 (max(time_vec)/1000)-dt-dt/4]);
	%	title(['max : ' num2str(max_dff)]);
		set(gca, 'TickDir', 'out');
		colormap( jet(100));
		colorbar;
		title(strrep(glospvars.ts_id_strs(bti), '_', '-'));
	end

%
% Session structure:
%   session.mouse_id_str
%   session.date_str 
%   session.trial_classes                      vector of numbers containing classes of trials
%   session.trial_class_str                    cell array corresponding to classes with descriptiosn of classes
%   session.trial_class_color                  for plots where classes are color sorted, corresponds to trial_classes; 3xn
%   session.trial_class_symbol                 for plots where classes are symbol sorted, corresponds to trial_classes
%
%   session.trial().start_time                 start time -- absolute
%   session.trial().time_unit_id               time unit
%
%   session.trial().eventseries()
%
%   session.trial().timeseries().sourcefile    where raw data resides
%   session.trial().timeseries().values        values vector
%   session.trial().timeseries().time          corresponding to values, time vector; relative to timeseries start
%   session.trial().timeseries().start_time    absolute; -1 means same as trial start
%   session.trial().timeseries().dt            all in time_unit_id units
%   session.trial().timeseries().time_unit_id  (1=ms, 2=s, 3=min, 4=h) unit for all time variables of this TS
%   session.trial().timeseries().type_id
%   session.trial().timeseries().unique_id
%   session.trial().timeseries().id_str
%  
%
