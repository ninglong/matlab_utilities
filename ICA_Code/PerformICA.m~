function ComponentMasks = PerformICA(Data,U,S,V,RowNum,ColNum)
% function ComponentMasks = PerformICA(Data,U,S,V,RowNum,ColNum)
% Main function for running ICA in order to define ROIs for
% calcium imaging data.
%
% Input:
% The first three inputs are the data.
% Data - the data concatenated: (no. of samples x imaging window)
% U,S,V - the SVD decomposition of the same data
% RowNum,ColNum - the 2D imaging data is flattened into a 1D vector
%   these two parameters give the original dimensions
%
% Output:
% The final result of the analysis, the component masks, which
% translate directly into the ROIs
%
% Shaul Druckmann, JFRC, February 2010

SVDCompVec = 1:30;
SVDComponentNum = length(SVDCompVec);
SVDBase = Data*...
  (S(SVDCompVec,SVDCompVec)*...
  V(:,SVDCompVec)')';

%% ICA
IComponentNum = 20;
[A, W]=fastica(SVDBase','numOfIC',IComponentNum);
ICAComp = W*...
  (V(:,SVDCompVec)*S(SVDCompVec,SVDCompVec))';

%% Get Time series from components
ComponentMasks = cell(IComponentNum,1);
ComponentTS = cell(IComponentNum,1);
SuspiciousVec = zeros(IComponentNum,1);

windowSize = 30;
Filt = ones(1,windowSize)/windowSize;
BlobNumVec = zeros(IComponentNum,1);

for ii=1:length(ComponentMasks)
  [ComponentMasks{ii} SuspiciousVec(ii)] = ICABlobAnalysis(ICAComp(ii,:),RowNum,ColNum,num2str(ii),1);
end
[compCorr,maskInd] = ComponentCorrelation(Data,ComponentMasks,0);

for ii=1:length(ComponentMasks)
  ComponentMasks{ii} = RejectComponent(ComponentMasks{ii},RowNum,ColNum);
end
[compCorr,maskInd] = ComponentCorrelation(Data,ComponentMasks,0);

%%  Separate weakly correlated components
breakThresh = 0.85;

ComponentMasks = SeparateComponent(ComponentMasks,maskInd,compCorr,breakThresh);

[compCorr,maskInd] = ComponentCorrelation(Data,ComponentMasks,0);

%%  Remove overlapping components after separation
overlapThresh = 0.98;

ComponentMasks = RemoveOverlapComponent(ComponentMasks,overlapThresh);

[compCorr,maskInd] = ComponentCorrelation(Data,ComponentMasks,0);
%%  Clean empty components

emptyVec = [];
for ii=1:length(ComponentMasks)
  if unique(ComponentMasks{ii}) == 0;
    emptyVec = [emptyVec; ii];
  end
end

ComponentMasks(emptyVec) = [];
end