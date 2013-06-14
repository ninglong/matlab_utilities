% Quick Figure Ver 1.1, Zach Lewis
% Changes from Ver 1:
% Added more verbage in the preferences file for what each variable changes for printing
% Consolidated all of the functions into the quick_figure.m file

function fig_handle = quick_figure(action,axh)
% function quick_figure() creates a new figure and adds UI menus for quick printing in various formats
% Returns the figure handle

quick_figure_prefs;                         %Get Quick Figure Preferences
if nargin == 0
    fig_handle = figure;
end
if nargin<1 || isempty(action)
    action = 'on';  %by default, turn the context menu on
end
if nargin<2 || isempty(axh)
    fig_handle = gcf;      %by default, use the current figure
end

% fig_handle = figure;
quick_figure_menu(action,fig_handle);            %Add UI menus for quick printing options

end


% Quick Figure Ver 1.1, Zach Lewis
% These uimenus will give the user the option to quickly print the figure to PPT,DOC,JPG,PDF,FIG

function quick_figure_menu(action,axh)
% function quick_figure_menu(action,axh) creates the UI menus for quick printing in various formats
% Optional input argument ACTION will perform the requested action such as turning the menu on/off or saving the figure in the desired format
% Optional input argument AXH defines the figure handle to attach the UI menu to, if none is given, the current figure is used
% Example:
% t = [0:5e-6:0.02];
% y = 100*sin(2*pi*100*t);
% quick_figure;  %Turns on the quick save context menu
% plot(t,y)
% quick_figure_menu('off');  %Turns off the quick save context menu

quick_figure_prefs;                         %Get Quick Figure Preferences

if nargin<1 || isempty(action)
    action = 'on';  %by default, turn the context menu on
end
if nargin<2 || isempty(axh)
    axh = gcf;      %by default, use the current figure
end

% Define the context menu items
cmenu = uicontextmenu;

item1 = uimenu(cmenu, 'Label', 'Quick Save to PPT','Callback',['quick_figure(''print_to_ppt'',[]);']);
item2 = uimenu(cmenu, 'Label', 'Quick Save to DOC','Callback',['quick_figure(''print_to_doc'',[]);']);
item3 = uimenu(cmenu, 'Label', 'Quick Save to JPG','Callback',['quick_figure(''print_to_jpg'',[]);']);
item4 = uimenu(cmenu, 'Label', 'Quick Save to PDF','Callback',['quick_figure(''print_to_pdf'',[]);']);
item5 = uimenu(cmenu, 'Label', 'Quick Save to Fig','Callback',['quick_figure(''print_to_fig'',[]);']);


switch action
    case 'on'   %Turn on the UI menu
        set(axh,'UIContextMenu',cmenu);
        set(axh,PropName,PropVal);
    case 'off'  %Turn off the UI menu
        set(axh,'UIContextMenu',[]);
    otherwise   %Init UI preferences

        quick_figure_prefs;                         %Get Quick Figure Preferences

        %Initialize Directory
        if(isempty(quick_figure_dir))
            quick_figure_dir = evalin('base',['pwd']);  %Default to current directory
        end
        if(quick_figure_dir(end) ~= '\')
            quick_figure_dir = [quick_figure_dir '\'];
        end

        %Initialize Title
        replace_x_label = 'qfxlab'; replace_y_label = 'qfylab'; replace_title_label = 'qftitle';
        replace_date_label = 'qfdate'; replace_time_label = 'qftime'; replace_return = '\n';

        ppt_word_title = strrep(ppt_word_title,replace_x_label,get(get(gca,'xlabel'),'string'));
        ppt_word_title = strrep(ppt_word_title,replace_y_label,get(get(gca,'ylabel'),'string'));
        ppt_word_title = strrep(ppt_word_title,replace_title_label,get(get(gca,'title'),'string'));
        ppt_word_title = strrep(ppt_word_title,replace_date_label,datestr(clock,'mm/dd/yy'));
        ppt_word_title = strrep(ppt_word_title,replace_time_label,datestr(clock,'HH:MM:SS'));
        ppt_word_title = strrep(ppt_word_title,replace_return,sprintf('\n'));
end  %% End Data Init

switch action  %Define the action to take for each menu item
    case 'print_to_ppt'     %Print to Powerpoint
        try
            quick_save_ppt([quick_figure_dir ppt_word_filename],ppt_word_title,gcf);
            disp(['Quick Figure Saved PPT to ' quick_figure_dir ppt_word_filename]);
        catch
            disp(['An Error Occurred - Unable to Quick Save PPT to ' quick_figure_dir ppt_word_filename]);
        end
    case 'print_to_doc'     %Print to Word
        try
            quick_save_word([quick_figure_dir ppt_word_filename],ppt_word_title,gcf);
            disp(['Quick Figure Saved DOC to ' quick_figure_dir ppt_word_filename]);
        catch
            disp(['An Error Occurred - Unable to Quick Save DOC to ' quick_figure_dir ppt_word_filename]);
        end
    case 'print_to_jpg'     %Print to JPG
        try
            quick_save_fig(gcf,jpg_pdf_filename,output_resolution,'jpeg');
            disp(['Quick Figure Saved JPG to ' quick_figure_dir jpg_pdf_filename]);
        catch
            disp(['An Error Occurred - Unable to Quick Save JPG to ' quick_figure_dir jpg_pdf_filename]);
        end
    case 'print_to_pdf'     %Print to PDF
        try
            quick_save_fig(gcf,jpg_pdf_filename,output_resolution,'pdf');
            disp(['Quick Figure Saved PDF to ' quick_figure_dir jpg_pdf_filename]);
        catch
            disp(['An Error Occurred - Unable to Quick Save PDF to ' quick_figure_dir jpg_pdf_filename]);
        end
    case 'print_to_fig'     %Print to Fig
        try
            hgsave([quick_figure_dir jpg_pdf_filename])
            disp(['Quick Figure Saved Fig to ' quick_figure_dir jpg_pdf_filename]);
        catch
            disp(['An Error Occurred - Unable to Quick Save Fig to ' quick_figure_dir jpg_pdf_filename]);
        end
end

end

% Quick Figure Ver 1.1, Zach Lewis
% These uimenus will give the user the option to quickly print the figure to PPT,DOC,JPG,PDF,FIG

function [full_fname] = quick_save_fig(varargin)

print_to = 'jpeg';  %Default Print_to
quick_figure_prefs;	%Get Quick Figure Preferences

if(nargin >= 1)
    figh = varargin(1); figh = figh{1};
end
if(nargin >= 2)
    print_name = varargin(2);
end
if(nargin >= 3)
    print_res = varargin(3); print_res = print_res{1};
end
if(nargin >= 4)
    print_to = varargin(4);
end

savefig([char(quick_figure_dir) char(print_name)],figh,char(print_to),'-soft','-rgb',['-r' num2str(print_res)]);

full_fname = [char(quick_figure_dir) char(print_name) '.' char(print_to)];

end

% Quick Figure Ver 1.1
% save_ppt function taken from the Mathworks Central File Exchange, the function was renamed to avoid any conflicts
% Ver 2.2, Copyright 2005, Mark W. Brown, mwbrown@ieee.org

function quick_save_ppt(filespec,titletext,figh,prnopt)
quick_figure_prefs;                         %Get Quick Figure Preferences

% Establish valid file name:
if nargin<2 | isempty(filespec);
    [fname, fpath] = uiputfile('*.ppt');
    if fpath == 0; return; end
    filespec = fullfile(fpath,fname);
else
    [fpath,fname,fext] = fileparts(filespec);
    if isempty(fpath); fpath = pwd; end
    if isempty(fext); fext = '.ppt'; end
    filespec = fullfile(fpath,[fname,fext]);
end

% Default title text:
if nargin<3
    titletext = '';
end

% Start an ActiveX session with PowerPoint:
ppt = actxserver('PowerPoint.Application');

% Temp printout of the current figure
if nargin<4
    pic_path = quick_save_fig(figh,'qstemp',250,'jpeg'); %print the temp image to insert
else
    pic_path = quick_save_fig(figh,'qstemp',250,'jpeg'); %print the temp image to insert
end

if ~exist(filespec,'file');
    % Create new presentation:
    op = invoke(ppt.Presentations,'Add');
    % Use template
    if(~isempty(ppt_template))
        try
            invoke(op,'ApplyTemplate',template_loc);
        catch
            error_window(error1)
        end
    end
else
    % Open existing presentation:
    op = invoke(ppt.Presentations,'Open',filespec,[],[],0);
end


% Get current number of slides:
slide_count = get(op.Slides,'Count');

% Add a new slide (with title object):
slide_count = int32(double(slide_count)+1);
new_slide = invoke(op.Slides,'Add',slide_count,11);

% Insert text into the title object:
set(new_slide.Shapes.Title.TextFrame.TextRange,'Text',titletext);

% Get height and width of slide:
slide_H = op.PageSetup.SlideHeight;
slide_W = op.PageSetup.SlideWidth;

% Insert the newly printed figure

pic2 = invoke(new_slide.Shapes,'AddPicture',pic_path,0,1,ppt_imgleft,ppt_imgtop,ppt_imgwidth,ppt_imgheight);
set(pic2,'Rotation',90);

% Get height and width of picture:
pic_H = get(pic2,'Height');
pic_W = get(pic2,'Width');

% Center picture on page (below title area):
set(pic2,'Left',single((double(slide_W) - double(pic_W))/2));

% set(pic2,'Top',single(double(slide_H)*.97 - double(pic_H)));

if ~exist(filespec,'file')
    % Save file as new:
    invoke(op,'SaveAs',filespec,1);
else
    % Save existing file:
    invoke(op,'Save');
end

% Close the presentation window:
invoke(op,'Close');

% Quit PowerPoint
invoke(ppt,'Quit');

% Delete the temporary jpeg
if(exist(pic_path,'file') > 0)
    delete(pic_path)
end

end

% Quick Figure Ver 1.1
% save_word function taken from the Mathworks Central File Exchange, the function was renamed to avoid any conflicts
%Ver 2.2, Copyright 2005, Mark W. Brown, mwbrown@ieee.org

function quick_save_word(filespec,titletext,figh,prnopt)
quick_figure_prefs;                         %Get Quick Figure Preferences

% Establish valid file name:
if nargin<1 | isempty(filespec);
    [fname, fpath] = uiputfile('*.doc');
    if fpath == 0; return; end
    filespec = fullfile(fpath,fname);
else
    [fpath,fname,fext] = fileparts(filespec);
    if isempty(fpath); fpath = pwd; end
    if isempty(fext); fext = '.doc'; end
    filespec = fullfile(fpath,[fname,fext]);
end

% Default title text:
if nargin<3
    titletext = '';
end

% Start an ActiveX session with Word:
word = actxserver('Word.Application');

% Temp printout of the current figure
if nargin<4
    curPropVals = get(figh,wrdPropName);
    set(figh,wrdPropName,wrdPropVal); %temporarily set the page to portrait for word
    pic_path = quick_save_fig(figh,'qstemp',250,'jpeg'); %print the temp image to insert
    set(figh,wrdPropName,curPropVals)
else
    curPropVals = get(figh,wrdPropName);
    set(figh,wrdPropName,wrdPropVal); %temporarily set the page to portrait for word
    pic_path = quick_save_fig(figh,'qstemp',250,'jpeg'); %print the temp image to insert
    set(figh,wrdPropName,curPropVals)
end

if ~exist(filespec,'file');
    % Create new presentation:
    op = invoke(word.Documents,'Add');
else
    % Open existing presentation:
    op = invoke(word.Documents,'Open',filespec);
end

% Find end of document and make it the insertion point:
end_of_doc = get(word.activedocument.content,'end');
set(word.application.selection,'Start',end_of_doc);
set(word.application.selection,'End',end_of_doc);

pic2 = invoke(word.application.selection.InlineShapes,'AddPicture',pic_path);

invoke(pic2,'Select');
invoke(word.application.selection,'InsertCaption','Figure',sprintf('     %s ',titletext));
end_of_doc = get(word.activedocument.content,'end');
set(word.application.selection,'End',end_of_doc);
invoke(word.application.selection,'TypeText',sprintf(' \n '))
set(pic2,'ScaleHeight',75)
set(pic2,'ScaleWidth',75)

% % Get height and width of picture:
% pic_H = get(pic2,'Height');
% pic_W = get(pic2,'Width');

% Center picture on page (below title area):
% set(pic2,'Left',single((double(slide_W) - double(pic_W))/2));
% set(pic2,'Top',single(double(slide_H)*.97 - double(pic_H)));

if ~exist(filespec,'file')
    % Save file as new:
    invoke(op,'SaveAs',filespec,1);
else
    % Save existing file:
    invoke(op,'Save');
end
% Close the presentation window:
invoke(op,'Close');

% Quit MS Word
invoke(word,'Quit');

% Close PowerPoint and terminate ActiveX:
delete(word);

% Delete the temporary jpeg
if(exist(pic_path,'file') > 0)
    delete(pic_path)
end

end

% Quick Figure Ver 1.1
% savefig function taken from the Mathworks Central File Exchange, the function was renamed to avoid any conflicts
%Ver 2.2, Copyright 2005, Mark W. Brown, mwbrown@ieee.org

function savefig(fname, varargin)

quick_figure_prefs;	%Get Quick Figure Preferences

% Usage: savefig(filename, fighandle, options)
% Copyright (C) Peder Axensten (peder at axensten dot se), 2006.

op_dbg=     false;													% Default value.

% Create gs command.
switch(computer)													% Get gs command.
    case 'MAC',		gs= '/usr/local/bin/gs';
    case 'PCWIN',	gs = ['"' path_to_ghostscript '"'];
    otherwise,		gs= 'gs';
end
gs=		[gs		' -q -dNOPAUSE -dBATCH -dEPSCrop'];					% Essential.

gs=		[gs		' -dDOINTERPOLATE -dUseFlateCompression=true'];		% Useful stuff.
gs=		[gs		' -dUseCIEColor -dAutoRotatePages=/None'];			% Probably good.
gs=		[gs		' -dHaveTrueTypes'];								% More probably good.
cmdEnd=			' -sDEVICE=%s -sOutputFile="%s" ';					% Essential.
epsCmd=			'';
epsCmd=	[epsCmd ' -dSubsetFonts=true -dEmbedAllFonts=false -dNOPLATFONTS'];% Future support?
epsCmd=	[epsCmd ' -dColorConversionStrategy=/UseDeviceIndependentColor' ...
    ' -dProcessColorModel=/%s'];						% Supported by gs in future?
pdfCmd=	[epsCmd cmdEnd ' -c .setpdfwrite'];							% Recommended by gs.
epsCmd=	[epsCmd cmdEnd];

gsAntiAlias=	' -dGraphicsAlphaBits=4 -dTextAlphaBits=4';			% Anti alias options

% Get file name.
if((nargin < 1) || isempty(fname) || ~ischar(fname))				% Check file name.
    error('No file name specified.');
end
[pathstr, namestr] = fileparts(fname);
if(isempty(pathstr)), fname= fullfile(cd, namestr);	end

% Get handle.
fighandle=		get(0, 'CurrentFigure'); % See gcf.					% Get figure handle.
if((nargin >= 2) && (numel(varargin{1}) == 1) && isnumeric(varargin{1}))
    fighandle=		varargin{1};
    varargin=		{varargin{2:end}};
end
if(isempty(fighandle)), error('There is no figure to save!?');		end

% Set up the various devices.
% Those commented out are not yet supported by gs (nor by savefig).
% pdf-cmyk works due to the Matlab '-cmyk' export being carried over from eps to pdf.
device.eps.rgb=		sprintf(epsCmd, 'DeviceRGB',	'epswrite', [fname '.eps']);
%	device.eps.cmyk=	sprintf(epsCmd, 'DeviceCMYK',	'epswrite', [fname '.eps']);
%	device.eps.gray=	sprintf(epsCmd, 'DeviceGray',	'epswrite', [fname '.eps']);
device.jpeg.rgb=	sprintf(cmdEnd,	'jpeg', 					[fname '.jpeg']);
%	device.jpeg.cmyk=	sprintf(cmdEnd,	'jpegcmyk', 				[fname '.jpeg']);
device.jpeg.gray=	sprintf(cmdEnd,	'jpeggray',					[fname '.jpeg']);
device.pdf.rgb=		sprintf(pdfCmd, 'DeviceRGB',	'pdfwrite', [fname '.pdf']);
device.pdf.cmyk=	sprintf(pdfCmd, 'DeviceCMYK',	'pdfwrite', [fname '.pdf']);
%	device.pdf.gray=	sprintf(pdfCmd, 'DeviceGray',	'pdfwrite', [fname '.pdf']);
device.png.rgb=		sprintf(cmdEnd,	'png16m', 					[fname '.png']);
%	device.png.cmyk=	sprintf(cmdEnd,	'png???', 					[fname '.png']);
device.png.gray=	sprintf(cmdEnd,	'pnggray', 					[fname '.png']);
device.tiff.rgb=	sprintf(cmdEnd,	'tiff24nc',					[fname '.tiff']);
device.tiff.cmyk=	sprintf(cmdEnd,	'tiff32nc', 				[fname '.tiff']);
device.tiff.gray=	sprintf(cmdEnd,	'tiffgray', 				[fname '.tiff']);

% Get options.
global savefig_defaults;											% Add global defaults.
if( iscellstr(savefig_defaults)), varargin=	{savefig_defaults{:}, varargin{:}};
elseif(ischar(savefig_defaults)), varargin=	{savefig_defaults, varargin{:}};
end
varargin=	{'-rgb', '-r300', varargin{:}};							% Add defaults.
res=		'';
types=		{};
crop=		false;
antialias=	gsAntiAlias;
for n= 1:length(varargin)											% Read options.
    if(ischar(varargin{n}))
        if(ismember(lower(varargin{n}), {'eps','jpeg','pdf','png','tiff'}))
            types{end+1}=	lower(varargin{n});
        elseif(strcmpi(varargin{n}, '-rgb')),	color=	'rgb';	deps= {'-depsc2'};
        elseif(strcmpi(varargin{n}, '-cmyk')),	color=	'cmyk';	deps= {'-depsc2', '-cmyk'};
        elseif(strcmpi(varargin{n}, '-gray')),	color=	'gray';	deps= {'-deps2'};
        elseif(strcmpi(varargin{n}, '-soft')),	antialias= gsAntiAlias;
        elseif(strcmpi(varargin{n}, '-hard')),	antialias= '';
        elseif(strcmpi(varargin{n}, '-crop')),	crop=	true;
        elseif(strcmpi(varargin{n}, '-dbg')),	op_dbg=			true;
        elseif(regexp (varargin{n}, '^\-r[0-9]+$')), res=		varargin{n};
        else	warning('Unknown option in argument: ''%s''.', varargin{n});
        end
    else
        warning('Wrong type of argument: ''%s''.', class(varargin{n}));
    end
end
types=		unique(types);
if(isempty(types)), error('No output format given.');	end
gs=			[gs ' ' res];											% Add resolution to cmd.

if(crop && ismember(types, {'eps', 'pdf'}))							% Crop the figure.
    fighandle= do_crop(fighandle);
end

% Output eps from Matlab.
renderer=	['-' lower(get(fighandle, 'Renderer'))];						% Use same as in figure.
if(strmatch('-none',renderer) == 1)
    renderer = '-painters';                                                 % Use this one if none is returned
end

print(fighandle, deps{:}, '-noui', renderer, res, [fname '-temp']);	% Output the eps.

% Convert to other formats.
for n= 1:length(types)												% Output them.
    if(isfield(device.(types{n}), color))
        cmd=		device.(types{n}).(color);						% Colour model exists.
    else
        cmd=		device.(types{n}).rgb;							% Use alternative.
        warning('No device for %s with colours %s. Using rgb instead.', types{n}, color);
    end
    if(isempty(findstr(types{n}, '.eps')) && isempty(findstr(types{n}, '.pdf')))
        cmd=		[cmd antialias];	% Anti aliasing only on pixel graphics.
    end
    cmd=	sprintf('%s %s -f "%s-temp.eps"', gs, cmd, fname);		% Add source file.
    system(cmd);	% [status, result]= system(cmd2);				% Run Ghostscript.
    if(op_dbg), disp(cmd);		end
end
delete([fname '-temp.eps']);										% Clean up.
end


function fig= do_crop(fig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Remove line segments that are outside the view.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

haxes=	findobj(fig, 'Type', 'axes', '-and', 'Tag', '');
for n=1:length(haxes)
    xl=		get(haxes(n), 'XLim');
    yl=		get(haxes(n), 'YLim');
    lines=	findobj(haxes(n), 'Type', 'line');
    for m=1:length(lines)
        x=				get(lines(m), 'XData');
        y=				get(lines(m), 'YData');

        inx=			(xl(1) <= x) & (x <= xl(2));	% Within the x borders.
        iny=			(yl(1) <= y) & (y <= yl(2));	% Within the y borders.
        keep=			inx & iny;						% Within the box.

        if(~strcmp(get(lines(m), 'LineStyle'), 'none'))
            crossx=		((x(1:end-1) < xl(1)) & (xl(1) < x(2:end))) ...	% Crossing border x1.
                |	((x(1:end-1) < xl(2)) & (xl(2) < x(2:end))) ...	% Crossing border x2.
                |	((x(1:end-1) > xl(1)) & (xl(1) > x(2:end))) ...	% Crossing border x1.
                |	((x(1:end-1) > xl(2)) & (xl(2) > x(2:end)));	% Crossing border x2.
            crossy=		((y(1:end-1) < yl(1)) & (yl(1) < y(2:end))) ...	% Crossing border y1.
                |	((y(1:end-1) < yl(2)) & (yl(2) < y(2:end))) ...	% Crossing border y2.
                |	((y(1:end-1) > yl(1)) & (yl(1) > y(2:end))) ...	% Crossing border y1.
                |	((y(1:end-1) > yl(2)) & (yl(2) > y(2:end)));	% Crossing border y2.
            crossp=	[(	(crossx & iny(1:end-1) & iny(2:end)) ...	% Crossing a x border within y limits.
                |	(crossy & inx(1:end-1) & inx(2:end)) ...	% Crossing a y border within x limits.
                |	crossx & crossy ...							% Crossing a x and a y border (corner).
                ),	false ...
                ];
            crossp(2:end)=	crossp(2:end) | crossp(1:end-1);		% Add line segment's secont end point.

            keep=			keep | crossp;
        end
        set(lines(m), 'XData', x(keep))
        set(lines(m), 'YData', y(keep))
    end
end
end

