function color_convert
% COLOR: Converts your images into differently colored images.

%==========================================================================
[FileName,PathName] = uigetfile('*.jpg','Select any rgb image');
y=fullfile(PathName,FileName); 
img=imread(y,'jpg');
%==========================================================================
disp('CHOOSE COLOR AS FOLLOWS:');
disp('COLOR           ENTER COLOR CHOICE');
disp('      ');
disp('RED                   1');
disp('GREEN                 2');
disp('BLUE                  3');
disp('YELLOW                4');
disp('CYAN                  5');
disp('MAGNETA               6');

color=input('ENTER COLOR CHOICE = ');
%==========================================================================
dion=[1 0 0 ;
      0 1 0 ;
      0 0 1 ;
      1 1 0 ;
      0 1 1 ;
      1 0 1];
%==========================================================================
img(:,:,~dion(color,:))=0; 
%==========================================================================
img=uint8(img);
[FileName,PathName] = uiputfile('*.jpg','Select any name for the colored image');

y= fullfile(PathName,[FileName '.jpg']);
imwrite(img,y,'jpg');

figure,imagesc(img);
title('THE IMAGE YOU JUST SAVED');
axis image;
axis off