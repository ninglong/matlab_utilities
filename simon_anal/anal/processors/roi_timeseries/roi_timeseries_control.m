function varargout = roi_timeseries_control(varargin)
% ROI_TIMESERIES_CONTROL M-file for roi_timeseries_control.fig
%      ROI_TIMESERIES_CONTROL, by itself, creates a new ROI_TIMESERIES_CONTROL or raises the existing
%      singleton*.
%
%      H = ROI_TIMESERIES_CONTROL returns the handle to a new ROI_TIMESERIES_CONTROL or the handle to
%      the existing singleton*.
%
%      ROI_TIMESERIES_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_TIMESERIES_CONTROL.M with the given input arguments.
%
%      ROI_TIMESERIES_CONTROL('Property','Value',...) creates a new ROI_TIMESERIES_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roi_timeseries_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roi_timeseries_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roi_timeseries_control

% Last Modified by GUIDE v2.5 30-Sep-2009 10:15:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roi_timeseries_control_OpeningFcn, ...
                   'gui_OutputFcn',  @roi_timeseries_control_OutputFcn, ...
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


% --- Executes just before roi_timeseries_control is made visible.
function roi_timeseries_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roi_timeseries_control (see VARARGIN)

% SP ----------------------------------------------------------------------

% END SP ------------------------------------------------------------------

% Choose default command line output for roi_timeseries_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roi_timeseries_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roi_timeseries_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles;



function roi_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_file_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_file_edit as a double


% --- Executes during object creation, after setting all properties.
function roi_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in roi_file_select_button.
function roi_file_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to roi_file_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % look for ROI file in the directory your base image is in
	[filename, filepath]=uigetfile({'*.mat'},'Select ROI file', ...
										 glovars.processor_step(1).im_path);
	
	% verify . . . 
	if (exist([filepath filesep filename], 'file') == 0)
	  disp('Invalid file selection');
	else
		set(handles.roi_file_edit, 'String', [filepath filesep filename]);
	end



function roi_frame_length_ms_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_frame_length_ms_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_frame_length_ms_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_frame_length_ms_edit as a double

  % pull from gui
  val = get(hObject, 'String');
  num = str2num(val);

  % verification - number?
  if (length(val) > 0)
    % gui update
    set(handles.roi_frame_rate_hz_edit, 'String', num2str(1000/num));
  else
    disp('Must enter numeric value');
  end


% --- Executes during object creation, after setting all properties.
function roi_frame_length_ms_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_frame_length_ms_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_frame_rate_hz_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_frame_rate_hz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_frame_rate_hz_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_frame_rate_hz_edit as a double

  % pull from gui
  val = get(hObject, 'String');
  num = str2num(val);

  % verification - number?
  if (length(val) > 0)
    % assign

    % gui update
    set(handles.roi_frame_length_ms_edit, 'String', num2str(1000/num));
  else
    disp('Must enter numeric value');
  end


% --- Executes during object creation, after setting all properties.
function roi_frame_rate_hz_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_frame_rate_hz_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_timeseries_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_timeseries_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_timeseries_file_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_timeseries_file_edit as a double


% --- Executes during object creation, after setting all properties.
function roi_timeseries_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_timeseries_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in roi_timeseries_file_select_button.
function roi_timeseries_file_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to roi_timeseries_file_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % look for an existing output file in the directory your base image is in
	[filename, filepath]=uiputfile({'*.mat'},'Select ROI file', ...
										 glovars.processor_step(1).im_path);
	
	% verify . . . 
	set(handles.roi_timeseries_file_edit, 'String', [filepath filesep filename]);

  % if it exists, load it
  if (exist([filepath filesep filename], 'file') ~= 0)
    disp(['Found ' filepath filesep filename '; loading.']);

    load([filepath filesep filename]);

%O		glovars.roi_timeseries.roi = roi_ts.roi;

    % set frame rate
%O		glovars.roi_timeseries_control.ms_per_frame = roi_ts.frame_length_ms;
%O    set(glovars.roi_timeseries_control.roi_frame_length_ms_edit, 'String', num2str(roi_ts.frame_length_ms));
%O		glovars.roi_timeseries_control.frame_rate_hz = roi_ts.frame_rate_hz; 
%O    set(glovars.roi_timeseries_control.roi_frame_rate_hz_edit, 'String', num2str(roi_ts.frame_rate_hz));
  end


% --- Executes on button press in plot_all_rois_one_trial_button.
function plot_all_rois_one_trial_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all_rois_one_trial_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
	disp('Plot all ROIs one trial function should in fact use session_plotter; FIX THIS');

  % 1) sanity check -- trial num assigned?
  tn = get(handles.plot_all_rois_one_trial_trialnum_edit,'String');
  fn = get(handles.roi_timeseries_file_edit,'String');
  if (length(tn) == 0)
    disp('Must pick trial # to plot.');
    return;
  elseif (length(fn) == 0 | exist(fn, 'file') ==0)
    disp('Must assign valid ROI timeseries file to plot.');
  else % all is well -- plot
    tn = str2num(tn);

    % pull appropriate trial from file
    load(fn);
    rois = roi_ts.trial(tn).roi;
    
    % compute dff
base_frames = [1 5] ; % ASSUMPTION gui should set later
disp('Assumption: base frames are 1 to 5; should be GUI set in future.');
		dff = zeros(length(rois), length(roi_ts.time_vec));
		for r=1:length(rois)
			roi = rois(r);
			f0 = mean(roi.fluo(base_frames(1):base_frames(2)));
			dff(r,:) = (roi.fluo-f0)/f0;
		end

    % plot it
    figure;
    title (['Trial: ' num2str(tn)]);
		offset = 1.2*max(max(dff));
		t = 1:glovars.fluo_display.display_im_nframes;
		hold on;
		for r=1:glovars.fluo_roi_control.n_rois
			plot(t, (r-1)*offset + dff(r,:), glovars.fluo_roi_control.roi(r).color);
		 
			% line @ "0"
			plot([min(t) max(t)], [(r-1)*offset (r-1)*offset], 'k:');

			% label #
			text(min(t) + 0.1*(max(t)-min(t)), (r-0.75)*offset , num2str(r), 'Color', 'k');
		end
%    roi_ts.trial.roi.fluo
    
  end


function plot_all_rois_one_trial_trialnum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all_rois_one_trial_trialnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plot_all_rois_one_trial_trialnum_edit as text
%        str2double(get(hObject,'String')) returns contents of plot_all_rois_one_trial_trialnum_edit as a double


% --- Executes during object creation, after setting all properties.
function plot_all_rois_one_trial_trialnum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_all_rois_one_trial_trialnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_all_trials_one_roi_button.
function plot_all_trials_one_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all_trials_one_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
	disp('Plot all trials one ROI function should in fact use session_plotter; FIX THIS');

  % 1) sanity check -- ROI num, filename assigned?
  rn = get(handles.plot_all_trials_one_roi_roinum_edit,'String');
  fn = get(handles.roi_timeseries_file_edit,'String');
  if (length(rn) == 0)
    disp('Must pick ROI # to plot.');
    return;
  elseif (length(fn) == 0 | exist(fn, 'file') ==0)
    disp('Must assign valid ROI timeseries file to plot.');
  else % all is well -- plot
    rn = str2num(rn);

    % load file
    load(fn);
base_frames = [1 5] ; % ASSUMPTION gui should set later
max_dff = [1] ; % ASSUMPTION gui should set later

    % matrix for image
    trials = roi_ts.trial;
		dff = zeros(length(trials), length(roi_ts.time_vec));
    npad = ceil(length(trials)/length(roi_ts.time_vec));

    % loop over trials
    for t=1:length(trials)
      roi = trials(t).roi(rn);
%disp(['f: ' roi_ts.fname_index{t} ' t,l: ' num2str(t) ',' num2str(length(roi.fluo))]);
      % occasionally single frame movies exist ; these are usually tests so skip 
      if (length(roi.fluo) == 1)
        disp(['ROI data for ' roi_ts.fname_index{t} ' has only one frame; omitting from analysis.']);
			  continue;
			end 
			% compute dff
			f0 = mean(roi.fluo(base_frames(1):base_frames(2)));
			dff(t,:) = (roi.fluo-f0)/f0;
    end

    % pad?
    if (0 == 1 & npad > 1)
			ndff = zeros(length(trials), npad*length(roi_ts.time_vec));
      for t=1:length(roi_ts.time_vec)
        for n=(t-1)*npad+1:t*npad
          ndff(:,n) = dff(:,t); 
        end
      end
      dff = ndff;
    end

    % plot it
    dt =  glovars.roi_timeseries_control.ms_per_frame/1000;
    f = figure;
    title (['ROI: ' num2str(rn)]);
max_dff = max(max(dff));
%		dff(find(dff > max_dff)) = max_dff;
		dff = dff*(100/max_dff);
    image(dff, 'XData', (dt/2)+[min(roi_ts.time_vec)/1000 (max(roi_ts.time_vec)/1000)-dt-dt/4]);
    set (gca, 'TickDir', 'out');
		title(['max : ' num2str(max_dff)]);
    colormap( jet(100));
    colorbar;

    % figure out tick positions
if ( 1 == 0)
    dt =  glovars.roi_timeseries_control.ms_per_frame;
    nf = length(roi_ts.time_vec);
    n_ticks = floor(dt*nf/1000);
    tickvec = [];
    ticklabels = {};
    for n=1:n_ticks
      tickvec = [tickvec n*(1000/dt)+0.5]; % image starts w/ x = 0.5
      ticklabel{n} = num2str(n);
    end
    set(gca, 'XTick', tickvec);
    set(gca, 'XTickLabel', ticklabel);
end   
    xlabel('Time (s)');
    ylabel ('Trial number');
  end



function plot_all_trials_one_roi_roinum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all_trials_one_roi_roinum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plot_all_trials_one_roi_roinum_edit as text
%        str2double(get(hObject,'String')) returns contents of plot_all_trials_one_roi_roinum_edit as a double


% --- Executes during object creation, after setting all properties.
function plot_all_trials_one_roi_roinum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_all_trials_one_roi_roinum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


