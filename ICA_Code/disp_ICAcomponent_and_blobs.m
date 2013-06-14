function disp_ICAcomponent_and_blobs(Component, RowNum, ColNum, h_figs)
% 
%
%
% - NX, Jan, 2011
StdThresh = 3;
%%  Normalize
  NC = (Component - mean(Component))./std(Component);
  Direction = sign(mean(NC(abs(NC) > StdThresh)));
  
  NC = reshape(NC,RowNum,ColNum);
  F = fspecial('gaussian');
  
%   NC = conv2(NC,F);
  NC = imfilter(NC,F,'symmetric');

  Mask = zeros(size(NC));
  if Direction >= 0
    Mask(NC > StdThresh) = 1;
  else
    Mask(NC < -StdThresh) = 1;
  end
  L = bwlabel(Mask,8);
  
  if ~exist('h_figs','var')
      h_figs(1) = figure('Position',[236   247   560   420]);
      h_figs(2) = figure('Position',[806   250   560   420]);
  end
 figure(h_figs(1)); gca;
 imagesc(NC); set(gca, 'DataAspectRatio',[ColNum/RowNum 1 1]);
 figure(h_figs(2)); gca;
 imagesc(L); set(gca, 'DataAspectRatio',[ColNum/RowNum 1 1]);
% imArray.plot_rois(gcf);

