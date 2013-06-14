function [L, Sus] = ICABlobAnalysis(Component,RowNum,ColNum,CompName,plotFlag)
% Function to get blobs from an ICA component
%   RowNum = 128;
%   ColNum = 256;
  %Old settings
%   StdThresh = 3;
%   InitialMinSize = 15;
  %New settings
  StdThresh = 3.5;
  InitialMinSize = 100;
  FinalMinSize = 40;
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
  Stats = regionprops(L,'Area');
  Small = find(cell2mat(struct2cell(Stats)) < InitialMinSize);
  L(ismember(L,Small)) = 0;
  if plotFlag == 1
    figure();imagesc(NC);
    title(['Component ' CompName])

    figure();imagesc(L);
    title(['Component ' CompName])
  end
  SMask = zeros(size(NC));
  SMask(find(abs(NC) > StdThresh)) = 1;
  SL = bwlabel(SMask,8);
  SStats = regionprops(SL,'Area');
  SSmall = find(cell2mat(struct2cell(SStats)) < FinalMinSize);
  SL(ismember(SL,SSmall)) = 0;
  b = unique(SL);
  Sus = 0;
  if length(b) > 12 % Unlikely to get 12 blobs in a component
    Sus = 1;
  end
end