function varargout = imreg_control(varargin)
% IMREG_CONTROL M-file for imreg_control.fig
%      IMREG_CONTROL, by itself, creates a new IMREG_CONTROL or raises the existing
%      singleton*.
%
%      H = IMREG_CONTROL returns the handle to a new IMREG_CONTROL or the handle to
%      the existing singleton*.
%
%      IMREG_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMREG_CONTROL.M with the given input arguments.
%
%      IMREG_CONTROL('Property','Value',...) creates a new IMREG_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imreg_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imreg_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imreg_control

% Last Modified by GUIDE v2.5 27-Nov-2009 16:26:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imreg_control_OpeningFcn, ...
                   'gui_OutputFcn',  @imreg_control_OutputFcn, ...
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


% --- Executes just before imreg_control is made visible.
function imreg_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imreg_control (see VARARGIN)

% SP ----------------------------------------------------------------------

% --- GUI initial values
set(handles.target_process_menu, 'String', {'Raw Image', 'Mean of', 'Median of', 'Max. Proj. of', 'Max. Proj. Moving Avg. 20%'});
set(handles.target_process_menu, 'Value', 2);
set(handles.method_menu, 'String', {'Piecewise Rigid (globally non-Rigid)', 'Greeberg et al. (non-Rigid)', 'FFT (Rigid)', 'Rigid with Rotation', '3D Affine', 'Dombeck et al. HMM (non-Rigid)'});
set(handles.method_menu, 'Value', 1);
set(handles.target_current_trial_stack_radio, 'Value', 1);
set(handles.target_specific_file_radio, 'Value', 0);
set(handles.target_auto_radio,  'Value', 0);
set (handles.source_as_is_radio, 'Value', 1);
set (handles.source_mean_radio, 'Value', 0);
set (handles.source_mean_of_frames_radio, 'Value', 0);

% END SP ------------------------------------------------------------------

% Choose default command line output for imreg_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imreg_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imreg_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles; % return handles structure


% --- Executes on button press in target_current_trial_stack_radio.
function target_current_trial_stack_radio_Callback(hObject, eventdata, handles)
% hObject    handle to target_current_trial_stack_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of target_current_trial_stack_radio

  set (handles.target_current_trial_stack_radio, 'Value', 1);
  set (handles.target_specific_file_radio, 'Value', 0);
  set (handles.target_auto_radio, 'Value', 0);


% --- Executes on button press in target_specific_file_radio.
function target_specific_file_radio_Callback(hObject, eventdata, handles)
% hObject    handle to target_specific_file_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of target_specific_file_radio

  set (handles.target_current_trial_stack_radio, 'Value', 0);
  set (handles.target_specific_file_radio, 'Value', 1);
  set (handles.target_auto_radio, 'Value', 0);


% --- Executes on button press in target_auto_radio.
function target_auto_radio_Callback(hObject, eventdata, handles)
% hObject    handle to target_auto_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of target_auto_radio

  % only allow this if you are in a processor with batch_mode 3 or 4
  set (handles.target_current_trial_stack_radio, 'Value', 0);
  set (handles.target_specific_file_radio, 'Value', 0);
  set (handles.target_auto_radio, 'Value', 1);


% --- Executes on button press in target_select_stack_path_button.
function target_select_stack_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to target_select_stack_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

	% --- first invoke a dialogue for path selection
	startpath = glovars.data_lastpath;
	[filename, filepath]=uigetfile({'*.tif;*.tiff', 'TIFF file (*.tif, *.tiff)'; '*.mat', 'MAT file (*.mat)'; ...
                     '*.*','All Files (*.*)'},'Select TIFF file', startpath);

	% --- update gui elements -- during processing, pull name directly from gui, so no need
	%     for internal storage of variables
	set(handles.target_stackpath_edit, 'String', [filepath filesep filename]);

	% set mode to path-based
	set(handles.target_current_trial_stack_radio, 'Value', false);
	set(handles.target_specific_file_radio, 'Value', true);


% --- Executes on selection change in method_menu.
function method_menu_Callback(hObject, eventdata, handles)
% hObject    handle to method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns method_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from method_menu

% --- Executes during object creation, after setting all properties.
function method_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_frame1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to target_frame1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_frame1_edit as text
%        str2double(get(hObject,'String')) returns contents of target_frame1_edit as a double


% --- Executes during object creation, after setting all properties.
function target_frame1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_frame1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in target_process_menu.
function target_process_menu_Callback(hObject, eventdata, handles)
% hObject    handle to target_process_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns target_process_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from target_process_menu


% --- Executes during object creation, after setting all properties.
function target_process_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_process_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_stackpath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to target_stackpath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_stackpath_edit as text
%        str2double(get(hObject,'String')) returns contents of target_stackpath_edit as a double


% --- Executes during object creation, after setting all properties.
function target_stackpath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_stackpath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_frame2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to target_frame2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_frame2_edit as text
%        str2double(get(hObject,'String')) returns contents of target_frame2_edit as a double


% --- Executes during object creation, after setting all properties.
function target_frame2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_frame2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in target_autoselect_still_checkbox.
function target_autoselect_still_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to target_autoselect_still_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of target_autoselect_still_checkbox
  if (get(hObject,'Value') == 1)
		if (length(get(handles.target_nstill_frames_edit,'String')) == 0)
			disp('Must select a number of stillest frames to use this option');
			set(hObject,'Value', 0);
		else
			set(handles.target_frame1_edit, 'String', '');
			set(handles.target_frame2_edit, 'String', '');
		end
  end

function target_nstill_frames_edit_Callback(hObject, eventdata, handles)
% hObject    handle to target_nstill_frames_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_nstill_frames_edit as text
%        str2double(get(hObject,'String')) returns contents of target_nstill_frames_edit as a double
	if (length(get(handles.target_nstill_frames_edit)) > 0)
		set(handles.target_frame1_edit, 'String', '');
		set(handles.target_frame2_edit, 'String', '');
		set(handles.target_autoselect_still_checkbox,'Value', 1);
  else
		set(handles.target_autoselect_still_checkbox,'Value', 0);
	end


% --- Executes during object creation, after setting all properties.
function target_nstill_frames_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_nstill_frames_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in source_as_is_radio.
function source_as_is_radio_Callback(hObject, eventdata, handles)
% hObject    handle to source_as_is_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of source_as_is_radio

  set (handles.source_as_is_radio, 'Value', 1);
  set (handles.source_mean_radio, 'Value', 0);
  set (handles.source_mean_of_frames_radio, 'Value', 0);


% --- Executes on button press in source_mean_radio.
function source_mean_radio_Callback(hObject, eventdata, handles)
% hObject    handle to source_mean_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of source_mean_radio

  set (handles.source_as_is_radio, 'Value', 0);
  set (handles.source_mean_radio, 'Value', 1);
  set (handles.source_mean_of_frames_radio, 'Value', 0);


% --- Executes on button press in source_mean_of_frames_radio.
function source_mean_of_frames_radio_Callback(hObject, eventdata, handles)
% hObject    handle to source_mean_of_frames_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of source_mean_of_frames_radio
  
	disp('Mean-of-frames not supported for source');

  set (handles.source_as_is_radio, 'Value', 0);
  set (handles.source_mean_radio, 'Value', 1);
  set (handles.source_mean_of_frames_radio, 'Value', 0);



function source_frame1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to source_frame1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_frame1_edit as text
%        str2double(get(hObject,'String')) returns contents of source_frame1_edit as a double

	disp('Mean-of-frames not supported for source');

% --- Executes during object creation, after setting all properties.
function source_frame1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_frame1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function source_frame2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to source_frame2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_frame2_edit as text
%        str2double(get(hObject,'String')) returns contents of source_frame2_edit as a double

	disp('Mean-of-frames not supported for source');

% --- Executes during object creation, after setting all properties.
function source_frame2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_frame2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
