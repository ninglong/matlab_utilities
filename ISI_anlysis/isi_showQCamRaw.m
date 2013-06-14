function isi_showQCamRaw(fn, frameNumbers)
%
% Inputs: 
%     fn: file name of .qcamraw file, given with or without 
%         '.qcamraw' extension.
%     frameNumbers: Vector of frame numbers from file to average before
%         displaying. Optional---if missing, all frames are read and
%         averaged.
%
%
% % Requires: read_qcamraw.m, Image Processing Toolbox.
%
% DHO, 10/08.
%

x = strfind(fn,'.qcamraw');
if isempty(x) % argument lacks .qcamraw extension
    fn = [fn '.qcamraw'];
end
if ~exist(fn,'file')
    error(['File not found: ' fn])
end

    
if nargin==1
    r = file_info_qcamraw(fn); nframes=r.nframes;
    m = read_qcamraw(fn, 1:nframes);
else
    m = read_qcamraw(fn, frameNumbers);
end

m = (mean(m,3))';
%imtool(m(end:-1:1,end:-1:1),[0 4095])
imtool(m,[0 4095])