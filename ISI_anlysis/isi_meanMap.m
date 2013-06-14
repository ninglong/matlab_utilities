function isi_meanMap(varargin)
%
% Input arguments: any number of *.qcamraw files.  Errors if files are
% not all qcamraw files with .qcamraw extension. Input file names can
% either include or omit the '.qcamraw' extension.
%
% For each *.qcamraw input file, computes the mean of stimulus period
% images, mean of baseline period images, and the mean difference image.
% These mean difference images from each run are then all averaged, 
% smoothed slightly, and displayed.
%
% Requires: read_qcamraw.m, Image Processing Toolbox.
%
% DHO, 10/08.
%

nfiles = nargin;

if nfiles < 1
    error('Must input at least one file name.')
end


stimPeriod = 1:4; basePeriod = 11:20; chunksize = 20; nchunks = 30;

for j=1:nfiles

    fn = varargin{j};
    x = strfind(fn,'.qcamraw');
    if ~isempty(x) % argument includes .qcamraw extension
        fn = fn(1:(x-1));
    end
    if ~exist([fn '.qcamraw'],'file')
        error(['File not found: ' fn '.qcamraw'])
    end

    f = 1;
    for k = 1:nchunks
        rep = read_qcamraw([fn '.qcamraw'], f:(f+chunksize-1));
        stim = mean(rep(:,:,stimPeriod),3);
        base = mean(rep(:,:,basePeriod),3);
        if k==1
            stimMean = stim;
            baseMean = base;
            diffMean = stim-base;
        else
            stimMean = (stimMean + stim)/2;
            baseMean = (baseMean + base)/2;
            diffMean = (diffMean + (stim-base))/2;
        end
        f = f+chunksize;
    end
    %     outfn = [fn '.mat'];
    %     save(outfn, 'stimMean', 'baseMean','diffMean');

    if j==1
        m = diffMean;
    else
        m = m + diffMean;
    end

    m = m ./ nfiles;


    m = m';
%     G = fspecial('gaussian',[5 5],.75);
%     m = imfilter(m,G);
    imtool(m,[-10 10])
%     imtool(m)

end


