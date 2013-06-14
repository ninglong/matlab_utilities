function AllData = ICA_LoadData(DataDir,FileBaseName,FileNums)
% function AllData = LoadData(BaseDir, FileNums)
% function AllData = LoadData(FileNum)
% Simple function to process multiple tiff files and output
% a concantenated data

% Shaul Druckmann, JFRC, February 2010

AllData = [];
DataSize = [128 512];
files = dir([DataDir filesep FileBaseName '*.tif']);
if ~exist('FileNums','var')
    FileNums = 1: length(files);
end
hw = waitbar(0, 'Loading Imaging data ...');
for ii=1:length(FileNums)
  
%   BaseDir = 'NX102527_100625_tuft1_reg/';
%   BaseFile = 'NX102527_100625_tuft1_greenberg_0';

%   BaseDir = 'NXJF36703_090716_tuft2/';
%   BaseFile = 'NXJF36703_090716_tuft2_d52_beh_dftReg_greenberg_0';
%   Base = [BaseDir BaseFile];
%   if ii< 10; Base = [Base '0'];   end
%   %         str = ['[~,Aout] = scim_openTif(\''' Base '00' num2str(ii) '.tif'')'];
%   str = ['scim_openTif(''' Base num2str(ii) '.tif'')'];
%   [~,Aout] = eval(str);
%   Aout = squeeze(Aout);
  Aout = imread_multi(fullfile(DataDir, files(FileNums(ii)).name),'g');
  Aout = double(Aout);
  AllData = [AllData; reshape(Aout,DataSize(1)*DataSize(2)...
    ,size(Aout,3))'];
  waitbar(ii/length(FileNums), hw, sprintf('Loading Imaging data, %d/%d trials', ii, length(FileNums)));  
end
delete(hw)
