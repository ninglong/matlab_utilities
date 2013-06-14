function r = file_info_qcamraw(fn)
%
%
% fn: string file name of QCAMRAW binary file.
%
% Returns: structure r with fields: width, height, nframes.
%

% fn = 'JF8635_green01_.qcamraw';

pf = fopen(fn, 'r');
fseek(pf, 0, 'eof');
fsize = ftell(pf);

gotThreeData = 0;

%get header infomation from the file
frewind(pf);
while gotThreeData < 3 
    tline = fgets(pf);
    [left, rem] = strtok( tline, ':');
    if strcmp(left, 'Fixed-Header-Size')
        right = strtok(rem, ':');
        fHeaderSize = strtok(right);
        fHeaderSize = str2num(fHeaderSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'Frame-Size')
        right = strtok(rem, ':');
        frameSize = strtok(right);
        frameSize = str2num(frameSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'ROI')
        right = strtok(rem, ':');
        [left, right]=strtok(right, ',');
        [left, right]=strtok(right, ',');
        [width, right]=strtok(right, ',');
        height = strtok(right, ',');
        width = str2num(width);
        height = str2num(height);
        gotThreeData = gotThreeData +1;
    else   
        continue;
    end
end
fclose(pf);

numberOfFrames = (fsize -fHeaderSize)/frameSize;

r.width = width;
r.height = height;
r.nframes = numberOfFrames;



