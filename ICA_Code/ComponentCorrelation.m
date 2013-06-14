function [CorrMat,MaskInd] = ComponentCorrelation(Data,ComponentMasks,compPlotFlag)
%function [CorrMat,MaskInd] = ComponentCorrelation(Data,ComponentMasks,compPlotFlag)
% Function that takes a set of ROIs found, calculates and plots
% the correlation between them to see their relationships
%
% Inputs:
% Data - the (time samples x imaging window) matrix of imaging data
%   required for actually calculating the correlations
% ComponentMaks - the masks that defined the components (ROIs)
% compPlotFlag - indicator of plotting the shape of the components
%   0 means no plotting, 1 enable plotting
%
% Outputs:
% CorrMat - calculated correlation in the data of components
% MaskInd - indicates the relationship between the (possibly multiple)
%   ROIs in each component
%
% Shaul Druckmann, JFRC, February 2010

if compPlotFlag == 1
  for ii=1:length(ComponentMasks)
    figure();
    imagesc(ComponentMasks{ii})
    title(['Component number ' num2str(ii)])
  end
end

compNum = length(ComponentMasks);
windowSize = 15;
Filt = ones(1,windowSize)/windowSize;
BlobNumVec = zeros(compNum,1);
ComponentTS = cell(compNum,1);
SuspiciousVec = zeros(compNum,1);

for ii=1:compNum
  b = unique(ComponentMasks{ii});
  b(b==0) = [];
  BlobNumVec(ii) = length(b);
  TS = zeros(length(b),size(Data,1));
  for jj=1:length(b)
    T = mean(Data(:,ComponentMasks{ii} == b(jj)),2);
    T = (T-median(T))./median(T);
    T = filter(Filt,1,T);
    TS(jj,:) = T;
  end
  ComponentTS{ii} = TS;
end
CS = cumsum(BlobNumVec);
MaskInd = [[1; CS(1:end-1)+1] CS];
BlobData = zeros(sum(BlobNumVec),size(Data,1));
for ii=1:compNum
  BlobData(MaskInd(ii,1):MaskInd(ii,2),:) = ComponentTS{ii};
end
BN = sum(BlobNumVec);
CorrMat = corr(BlobData');
figure();imagesc(CorrMat);
hold on
for ii=1:compNum
  line([0.5 BN+0.5],[CS(ii)+0.5 CS(ii)+0.5]...
    ,'Color','k','LineWidth',4);
  line([CS(ii)+0.5 CS(ii)+0.5],[0.5 BN+0.5]...
    ,'Color','k','LineWidth',4);
end

CB = zeros(size(ComponentMasks{1}));
for jj=1:length(ComponentMasks);CB(ComponentMasks{jj}>0)=jj;end
figure();imagesc(CB)
end