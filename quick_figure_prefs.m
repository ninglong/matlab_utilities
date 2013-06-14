% Quick Figure Ver 1.1, Zach Lewis
% All Quick Figure Preferences are Defined in this File

%% Preferences Start

% 1)  Directory and Filenames
quick_figure_dir = 'C:\';                                               %Define the directory to save the results to
ppt_word_filename = 'Quick_Figure_Output';                              %Define the filename to save PPT or DOC results to, new slides and images are appended if this file already exists
jpg_pdf_filename = ['Quick_Figure_Output_' datestr(clock,'HH_MM_SS')];  %Define the filename to save JPG or PDF results to
output_resolution = 250;                                                %Define the output resolution of saved images, typically you shouldn't have to change this number
% path_to_ghostscript = 'C:\Program Files\gs\gs8.51\bin\GSWin32c.exe';  %Define the path to the exe for Ghostscript.  Quick Figure requires Ghostscript 8.51 or later to work correctly.
path_to_ghostscript = 'C:\Program Files\gs\gs8.62\bin\GSWin32c.exe';    %Define the path to the exe for Ghostscript.  Quick Figure requires Ghostscript 8.51 or later to work correctly.

% 2)  Figure Page Setup/Orientation/Size, note this is currently setup to maximize the figure onto a ppt slide.

PropName(1) = {'PaperOrientation'};                                     %Page setup layout / page orientation
PropName(2) = {'PaperPositionMode'};                                    %Position of the figure on the screen / relatively centered.
PropName(3) = {'PaperPosition'};                                        %Position of the paper
PropVal(1) = {'landscape'};                                             %Set to landscape
PropVal(2) = {'auto'};                                                  %Auto positioned
PropVal(3) = {[0.25 0.25 10.5 7]};                                      %Maximum landscape page size

% 3)  Powerpoint and Word Title
% The function will replace the following variables in the PPT or DOC title
% qfxlab - xlabel of the current axis that is being printed
% qfylab - ylabel of the current axis that is being printed
% qftitle - title of the current axis that is being printed
% qfdate - the current date in mm/dd/yy format
% qftime - the current time in HH:MM:SS format
% \n - a return

% For example, if my current figure has a title 'Figure 1', and I changed the below variable ppt_word_title to 'Test
% qstitle', the ppt slide title or word figure will be 'Test Figure 1'

% PPT and DOC File Preferences
ppt_word_title = ['Quick Figure Results qfxlab vs. qfylab'];

ppt_template = '';                          %Define the powerpoint background template slide to use if any (.pot file), leave blank '' for a blank background slide

% 4)  PPT Image Preferences, this defines the position on the page for the figure image
ppt_imgleft = 100;
ppt_imgtop = -20;
ppt_imgwidth = -1;
ppt_imgheight = -1;

% 5)  Word Page Preferences
wrdPropName(1) = {'PaperOrientation'};      %Page setup layout / page orientation
wrdPropName(2) = {'PaperPositionMode'};     %Position of the figure on the screen / relatively centered.
wrdPropName(3) = {'PaperPosition'};         %Position of the paper
wrdPropName(4) = {'PaperSize'};             %Paper size
wrdPropVal(1) = {'portrait'};               %Set layout to Portrait
wrdPropVal(2) = {'manual'};                 %Paper size to Manual
wrdPropVal(3) = {[0.25 0.25 9 7.5]};        %Max paper position
wrdPropVal(4) = {[9.5 8]};                  %Max paper size

%% Preferences End