function ComponentMasks = SeparateComponent(ComponentMasks,maskInd,compCorr,breakThresh)
% function addCell = SeparateComponent(ComponentMasks,maskInd,breakThresh)
% Function to separate ROIs within single component that
% show weak correlation
%
% Shaul Druckmann, JFRC, June 2010
addCell = [];

mulVec = find(diff(maskInd(:,1))>1);
for ii=1:length(mulVec)
  sepVec = [];
  u = unique(ComponentMasks{mulVec(ii)});
  u(1) = [];
  C = compCorr(maskInd(mulVec(ii),:),maskInd(mulVec(ii),:));
  for jj=1:(size(C,1)-1)
    if min(C(jj+1:end,jj)) < breakThresh
      sepVec = [sepVec; u(jj)];
    end
  end
  for jj=1:length(sepVec)
    newMask = ComponentMasks{mulVec(ii)}==sepVec(jj);
    ComponentMasks{mulVec(ii)}(newMask)=0;
    addCell = [addCell; {newMask}];
  end
end
ComponentMasks = [ComponentMasks; addCell];
end