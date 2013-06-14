function varargout = turboreg_control(varargin)
% TURBOREG_CONTROL M-file for turboreg_control.fig
%      TURBOREG_CONTROL, by itself, creates a new TURBOREG_CONTROL or raises the existing
%      singleton*.
%
%      H = TURBOREG_CONTROL returns the handle to a new TURBOREG_CONTROL or the handle to
%      the existing singleton*.
%
%      TURBOREG_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TURBOREG_CONTROL.M with the given input arguments.
%
%      TURBOREG_CONTROL('Property','Value',...) creates a new TURBOREG_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before turboreg_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to turboreg_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help turboreg_control

% Last Modified by GUIDE v2.5 24-Sep-2009 11:01:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @turboreg_control_OpeningFcn, ...
                   'gui_OutputFcn',  @turboreg_control_OutputFcn, ...
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


% --- Executes just before turboreg_control is made visible.
function turboreg_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to turboreg_control (see VARARGIN)

% SP ----------------------------------------------------------------------

% default option set
set(handles.base_image_radio_mean, 'Value', true);
% END SP ------------------------------------------------------------------


% Choose default command line output for turboreg_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes turboreg_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = turboreg_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles; % return handles structure


% --- Executes on button press in base_image_radio_mean.
function base_image_radio_mean_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_radio_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of base_image_radio_mean
set(handles.base_image_radio_mean, 'Value', true);
set(handles.base_image_radio_mean_range, 'Value', false);
set(handles.base_image_radio_path, 'Value', false);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in base_image_radio_path.
function base_image_radio_path_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_radio_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of base_image_radio_path
set(handles.base_image_radio_mean, 'Value', false);
set(handles.base_image_radio_mean_range, 'Value', false);
set(handles.base_image_radio_path, 'Value', true);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in base_image_radio_mean_range.
function base_image_radio_mean_range_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_radio_mean_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of base_image_radio_mean_range
set(handles.base_image_radio_mean, 'Value', false);
set(handles.base_image_radio_mean_range, 'Value', true);
set(handles.base_image_radio_path, 'Value', false);

% Update handles structure
guidata(hObject, handles);



function base_image_mean_range_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_mean_range_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_image_mean_range_start_edit as text
%        str2double(get(hObject,'String')) returns contents of base_image_mean_range_start_edit as a double


% --- Executes during object creation, after setting all properties.
function base_image_mean_range_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_image_mean_range_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function base_image_mean_range_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_mean_range_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_image_mean_range_end_edit as text
%        str2double(get(hObject,'String')) returns contents of base_image_mean_range_end_edit as a double


% --- Executes during object creation, after setting all properties.
function base_image_mean_range_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_image_mean_range_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function base_image_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_image_path_edit as text
%        str2double(get(hObject,'String')) returns contents of base_image_path_edit as a double


% --- Executes during object creation, after setting all properties.
function base_image_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_image_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in base_image_path_select_button.
function base_image_path_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to base_image_path_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

	% --- first invoke a dialogue for path selection
	startpath = glovars.data_lastpath;
	[filename, filepath]=uigetfile({'*.tif;*.tiff', 'TIFF file (*.tif, *.tiff)'; ...
                     '*.*','All Files (*.*)'},'Select TIFF file', startpath);

	% --- update gui elements -- during processing, pull name directly from gui, so no need
	%     for internal storage of variables
	set(handles.base_image_path_edit, 'String', [filepath filesep filename]);

	% set mode to path-based
	set(handles.base_image_radio_mean, 'Value', false);
	set(handles.base_image_radio_mean_range, 'Value', false);
	set(handles.base_image_radio_path, 'Value', true);
	
