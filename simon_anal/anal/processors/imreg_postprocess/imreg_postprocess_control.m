function varargout = imreg_postprocess_control(varargin)
% IMREG_POSTPROCESS_CONTROL M-file for imreg_postprocess_control.fig
%      IMREG_POSTPROCESS_CONTROL, by itself, creates a new IMREG_POSTPROCESS_CONTROL or raises the existing
%      singleton*.
%
%      H = IMREG_POSTPROCESS_CONTROL returns the handle to a new IMREG_POSTPROCESS_CONTROL or the handle to
%      the existing singleton*.
%
%      IMREG_POSTPROCESS_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMREG_POSTPROCESS_CONTROL.M with the given input arguments.
%
%      IMREG_POSTPROCESS_CONTROL('Property','Value',...) creates a new IMREG_POSTPROCESS_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imreg_postprocess_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imreg_postprocess_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imreg_postprocess_control

% Last Modified by GUIDE v2.5 13-Dec-2009 22:08:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imreg_postprocess_control_OpeningFcn, ...
                   'gui_OutputFcn',  @imreg_postprocess_control_OutputFcn, ...
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

% --- Executes just before imreg_postprocess_control is made visible.
function imreg_postprocess_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imreg_postprocess_control (see VARARGIN)

% SP ----------------------------------------------------------------------
% --- GUI initial values
set(handles.init_mf_size_edit,'String','20');
set(handles.alpha_corr_corr_edit,'String','0.9');
set(handles.beta_corr_corr_edit,'String','1');
set(handles.gbs_corr_corr_edit,'String','20');
set(handles.final_mf_size_edit,'String','20');

set(handles.init_mf_checkbox,'Value',1);
set(handles.corr_corr_checkbox,'Value',1);
set(handles.final_mf_checkbox,'Value',1);

% --- store the processor step
handles.procstep_id = varargin{1};
% END SP ------------------------------------------------------------------


% Choose default command line output for imreg_postprocess_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imreg_postprocess_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imreg_postprocess_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles; % return handles structure


% --- Executes on button press in init_mf_checkbox.
function init_mf_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to init_mf_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of init_mf_checkbox



function init_mf_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to init_mf_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of init_mf_size_edit as text
%        str2double(get(hObject,'String')) returns contents of init_mf_size_edit as a double


% --- Executes during object creation, after setting all properties.
function init_mf_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to init_mf_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in corr_corr_checkbox.
function corr_corr_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to corr_corr_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of corr_corr_checkbox



function alpha_corr_corr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha_corr_corr_edit as text
%        str2double(get(hObject,'String')) returns contents of alpha_corr_corr_edit as a double


% --- Executes during object creation, after setting all properties.
function alpha_corr_corr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function beta_corr_corr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to beta_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta_corr_corr_edit as text
%        str2double(get(hObject,'String')) returns contents of beta_corr_corr_edit as a double


% --- Executes during object creation, after setting all properties.
function beta_corr_corr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gbs_corr_corr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gbs_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gbs_corr_corr_edit as text
%        str2double(get(hObject,'String')) returns contents of gbs_corr_corr_edit as a double


% --- Executes during object creation, after setting all properties.
function gbs_corr_corr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gbs_corr_corr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in final_mf_checkbox.
function final_mf_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to final_mf_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of final_mf_checkbox



function final_mf_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to final_mf_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of final_mf_size_edit as text
%        str2double(get(hObject,'String')) returns contents of final_mf_size_edit as a double


% --- Executes during object creation, after setting all properties.
function final_mf_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to final_mf_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_dx_dy_corr_button.
function show_dx_dy_corr_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_dx_dy_corr_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % --- determine path/existence 
	mat_path = [glovars.processor_step(handles.procstep_id).im_path filesep glovars.processor_step(handles.procstep_id).im_fname];
	mat_path = strrep(mat_path,'.tif','.imreg_pproc_out');

	% --- found the file? then plot each used step's dx/dy
	load(mat_path, '-mat');
	sdx = size(dx_o);

	dx_o = reshape(dx_o',[],1);
	dy_o = reshape(dy_o',[],1);

	dx_c = reshape(dx_c',[],1);
	dy_c = reshape(dy_c',[],1);

	dx_mf1 = reshape(dx_mf1',[],1);
	dy_mf1 = reshape(dy_mf1',[],1);
 
	dx_mf2 = reshape(dx_mf2',[],1);
	dy_mf2 = reshape(dy_mf2',[],1);

	err = reshape(err',[],1);

  l = 1:size(dx_o);

  % determine plot spacing
	offs = max([dx_o' dy_o' dx_c' dy_c' dx_mf1' dy_mf1' dx_mf2' dy_mf2']);
	offs = offs + abs(min([dx_o' dy_o' dx_c' dy_c' dx_mf1' dy_mf1' dx_mf2' dy_mf2']));
	offs = 5*ceil(offs/5);
	O = 0;

  % plot itself -- plot what is there only
	figure;
	plot(l,dx_o,'r-', l, dy_o, 'b-');
	text(0.1*max(l), O+0.25*offs, 'Original');
	legend('x displacement', 'y displacement');
	hold on;

	if (length(err) > 1)
	  O = O - 2*offs;
		plot(l,O+offs*err,'k-');
		merr = median(err);
		plot([0 max(l)],[1 1]*(O+offs*merr),'m:');
		plot([0 max(l)],[O O],'k:');
		plot([0 max(l)],[O O]+offs,'k:');
		text(0.1*max(l), O+0.25*offs, 'line-by-line correlation');
		text(0.1*max(l), O+0.5*offs, 'median correlation', 'Color', [1 0 1]);
		text(0.05*max(l), O+0.1*offs, '0');
		text(0.05*max(l), O+1.1*offs, '1');
	end

  if (length(dx_mf1) > 1)
	  O = O - offs;
		text(0.1*max(l), O+0.25*offs, 'After first med. filt.');
		plot(l,dx_mf1+O,'r-', l, dy_mf1+O, 'b-');
	end

  if (length(dx_c) > 1)
	  O = O - offs;
		text(0.1*max(l), O+0.25*offs, 'After correlation-based correction');
		plot(l,dx_c+O,'r-', l, dy_c+O, 'b-');
	end

  if (length(dx_mf2) > 1)
	  O = O - offs;
		text(0.1*max(l), O+0.25*offs, 'After 2nd med. filt.');
		plot(l,dx_mf2+O,'r-', l, dy_mf2+O, 'b-');
	end

  % frame lines? YUK
  for f=1:sdx(1)
%	  plot(sdx(2)*[f f], [O-offs 0+offs], 'm:');
	end

	xlabel('line');
	ylabel('displacement (pixels)');
	


