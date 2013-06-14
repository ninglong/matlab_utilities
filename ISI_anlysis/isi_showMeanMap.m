function isi_showMeanMap(varargin)
%
% Input arguments: any number of .mat files output by isi_writeRunMeans().
% Averages all these inputs, smooths slightly, and displays them.
%
% Requires: Image Processing Toolbox.
%
% DHO, 10/08.
%

nfiles = nargin;

if nfiles < 1
    error('Must input at least one file name.')
end



for j=1:nfiles

    fn = varargin{j};
    x = strfind(fn,'.mat');
    if isempty(x) % argument lacks .mat extension
        fn = [fn '.mat'];
    end
    if ~exist(fn,'file')
        error(['File not found: ' fn])
    end

    r = load(fn);
    if j==1
        m = r.diffMean;
    else
        m = m + r.diffMean;
    end

end

m = m ./ nfiles;


m = m';
G = fspecial('gaussian',[5 5],.75);
m = imfilter(m,G);
imtool(m,[-10 10])


