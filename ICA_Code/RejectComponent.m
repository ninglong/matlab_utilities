function label = RejectComponent(mask,rowNum,colNum)
% function label = RejectComponent(mask,rowNum,colNum)
% This function reviews the masks found by an ROI search and
% applies the different criteria to see if one of the components
% should be eliminated.
%
% Shaul Druckmann, JFRC, June 2010

maxElements = 3;
%%  Criterion too many elements in component
if length(unique(mask)) > (maxElements+1)
  label = zeros(size(mask));
  return
end

%%  Criterion: rejction of line scans
% The long face of the bounding box bigger than 75% of the image
% and the short face smaller than 5 pixels

label = bwlabel(mask,8);
stats = regionprops(label,'BoundingBox');
p = cell2mat(struct2cell(stats));
if ~isempty(p)
  cRej = find((p(:,3) > colNum*0.75 & p(:,4) < 5 ...
    | p(:,4) > rowNum*0.75 & p(:,3) < 5));
  label(ismember(label,cRej)) = 0;
end
end
