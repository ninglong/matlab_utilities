function show_whisker_movies(varargin)


if nargin ==0
    [b a] = uigetfile({'*.mp4'; '*.seq'}, 'select a movie mp4 or seq');
    
    filename=[a b];
    cd(a)
    
    
elseif nargin ==1
    filename=varargin{1};
    [a b]=fileparts(filename);
    cd(a)
end




%filename = 'F:\Processed_Whiskers_DOM3_A\jf25607\jf25607x121409\jf25607x121409_0009.mp4';
slider.filename=filename;
slider.distance=0;
slider.path=a;
slider.val=1000;
slider.x=[];
slider.y=[];

if strcmp(slider.filename(end-2:end), 'mp4')
    slider.f=mmread(slider.filename, slider.val);
    ii=slider.f.frames(1).cdata(:,:,1);
elseif strcmp(slider.filename(end-2:end), 'seq')
    
    [seq_info, fid] = read_seq_header(slider.filename);
    slider.f.frames(1).cdata(:,:,1) = uint8(read_seq_images(seq_info, fid, slider.val));
    ii=slider.f.frames(1).cdata(:,:,1);%f.frames(1).cdata(:,:,1);
    
    slider.f.nrFramesTotal=seq_info.NumberFrames;
    slider.f.width=seq_info.Width;
    slider.f.height=seq_info.Height;
end



%slider.f=mmread(slider.filename, slider.val);





%slider.M = Whisker.read_whisker_measurements([slider.filename(1:end-4) '.measurements']);
if exist([slider.filename(1:end-4) '.measurements.mat'],'file')
    [slider.r, obj.trackerFileFormat] = Whisker.load_whiskers_file([slider.filename(1:end-4) '.whiskers']);
    
    a=load([slider.filename(1:end-4) '.measurements.mat']);
    slider.M=a.M;
    disp('loaded .measurements.mat file')
elseif exist([slider.filename(1:end-4) '.measurements'],'file')
    [slider.r, obj.trackerFileFormat] = Whisker.load_whiskers_file([slider.filename(1:end-4) '.whiskers']);
    slider.M = Whisker.read_whisker_measurements([slider.filename(1:end-4) '.measurements']);
    disp('loaded .measurements file')
else
    slider.M=[];
end


if  exist('DOM3_wrong_pulses.mat')
    a=load('DOM3_wrong_pulses.mat');
    slider.r_ms=a.r_ms/1000;
    
end



slider.fh=figure('Position', [5 200 2*slider.f.width 2*slider.f.height], 'Color', 'w', 'Name', [slider.filename]);
ii=plot_mp4(slider);
slider.ii=ii;
%
sh = uicontrol(slider.fh,'Style','slider',...
    'Max',abs(f.nrFramesTotal),'Min',1,'Value',slider.val,...
    'SliderStep',[1/abs(slider.f.nrFramesTotal) 20/abs(slider.f.nrFramesTotal)],...
    'Position',[10 10 100 20],...
    'Callback',@slider_callback);

eth = uicontrol(slider.fh,'Style','edit',...
    'String',num2str(get(sh,'Value')),...
    'Position',[10 60 100 20],...
    'Callback',@edittext_callback);

but = uicontrol(slider.fh,'Style','pushbutton',...
    'String','bar_tracker',...
    'Position',[10 80 100 20],...
    'Callback',@pushbut_callback);


op = uicontrol(slider.fh,'Style','pushbutton',...
    'String','open new file',...
    'Position',[10 100 100 20],...
    'Callback',@open_callback);

mp = uicontrol(slider.fh,'Style','pushbutton',...
    'String','measure pixels',...
    'Position',[10 120 100 20],...
    'Callback',@measurepix_callback);


pd = uicontrol(slider.fh,'Style','text',...
    'String',num2str(slider.distance) ,...
    'Position',[10 140 100 20],...
    'Callback',@pd_callback);


td = uicontrol(slider.fh,'Style','text',...
    'Position',[10 40 100 20],...
    'Callback',@time_callback);

%     'String',num2str(slider.r_ms(slider.val)) ,...

% Set edit text UserData property to slider structure.


set(eth,'UserData',slider)


    function slider_callback(hObject,eventdata)
        % Get slider from edit text UserData.
        slider = get(eth,'UserData');
        slider.previous_val = slider.val;
        slider.val = round(get(hObject,'Value'));
        set(eth,'String',num2str(slider.val));
        %        set(td,'String',num2str(slider.r_ms(slider.val)));
        
        % Save slider in UserData before returning.
        ii=plot_mp4(slider);
        slider.ii=ii;
        set(eth,'UserData',slider)
        
    end

    function pushbut_callback(hObject,eventdata)
        
        slider = get(eth,'UserData');
        bartracker(slider.ii)
    end


    function time_callback(hObject,eventdata)
        slider = get(eth,'UserData');
        %set(td,'String',num2str(slider.r_ms(slider.val)));
    end

    function pd_callback(hObject,eventdata)
        
        slider = get(eth,'UserData');
        %set(pd,'UserData',slider);
        set(pd,'String',num2str(slider.distance));
        set(eth,'UserData',slider);
    end

    function  measurepix_callback(hObject,eventdata)
        
        %global x y
        
        slider = get(eth,'UserData');
        %measure_pixels(slider)
        [x, y] = getline
        hold on; plot(x,y);
        hold off;
        slider.distance=0
        for i=1:length(x)-1
            r=norm([x(i),y(i)]-[x(i+1),y(i+1)]);
            slider.distance=slider.distance+r;
            
        end
        
        slider.distance
        slider.x=x;
        slider.y=y;
        set(eth,'UserData',slider)
        set(pd,'String',num2str(slider.distance));
    end



    function open_callback(hObject,eventdata)
        slider = get(eth,'UserData');
        [b a] = uigetfile({'*.mp4'; '*.seq'}, 'select a movie mp4 or seq');
        slider.filename=[a b];
        
        cd(a)
        
        if strcmp(slider.filename(end-2:end), 'mp4')
            slider.f=mmread(slider.filename, slider.val);
            ii=slider.f.frames(1).cdata(:,:,1);
        elseif strcmp(slider.filename(end-2:end), 'seq')
            
            [seq_info, fid] = read_seq_header(slider.filename);
            slider.f.frames=[];
            slider.f.frames(1).cdata(:,:,1) = uint8(read_seq_images(seq_info, fid, slider.val));
            ii=slider.f.frames(1).cdata(:,:,1);%f.frames(1).cdata(:,:,1);
            
            slider.f.nrFramesTotal=seq_info.NumberFrames;
            slider.f.width=seq_info.Width;
            slider.f.height=seq_info.Height;
        end
        
        
        
        if exist([slider.filename(1:end-4) '.measurements.mat'],'file')
            [slider.r, obj.trackerFileFormat] = Whisker.load_whiskers_file([slider.filename(1:end-4) '.whiskers']);
            
            a=load([slider.filename(1:end-4) '.measurements.mat']);
            slider.M=a.M;
            disp('loaded .measurements.mat file')
        elseif exist([slider.filename(1:end-4) '.measurements'],'file')
            [slider.r, obj.trackerFileFormat] = Whisker.load_whiskers_file([slider.filename(1:end-4) '.whiskers']);
            slider.M = Whisker.read_whisker_measurements([slider.filename(1:end-4) '.measurements']);
            disp('loaded .measurements file')
        else
            slider.M=[];
        end
        
        
        
        ii=plot_mp4(slider);
        slider.ii=ii;
        set(eth,'UserData',slider);
        
    end

    function edittext_callback(hObject,eventdata, filename)
        % Get slider from edit text UserData.
        slider = get(eth,'UserData');
        slider.previous_val = slider.val;
        slider.val = round(str2double(get(hObject,'String')));
        % Determine whether slider.val is a number between the
        % slider's Min and Max. If it is, set the slider Value.
        if isnumeric(slider.val) && ...
                length(slider.val) == 1 && ...
                slider.val >= get(sh,'Min') && ...
                slider.val <= get(sh,'Max')
            set(sh,'Value',slider.val);
        else
            slider.val = slider.previous_val;
        end
        % Save slider structure in UserData before returning.
        
        
        ii=plot_mp4(slider);
        slider.ii=ii;
        % set(td,'String',num2str(slider.r_ms(slider.val)));
        set(eth,'UserData',slider)
    end
%% plot the image from the mp4 movie
    function ii=plot_mp4(slider)
        if strcmp(slider.filename(end-2:end), 'mp4')
            f=mmread(slider.filename, slider.val);
            ii=f.frames(1).cdata(:,:,1);
        elseif strcmp(slider.filename(end-2:end), 'seq')
            
            [seq_info, fid] = read_seq_header(slider.filename);
            ii= uint8(read_seq_images(seq_info, fid, slider.val));
            % ii=uint8(fff);%f.frames(1).cdata(:,:,1);)
            
            f.nrFramesTotal=seq_info.NumberFrames;
            f.width=seq_info.Width;
            f.height=seq_info.Height;
            f.frames(1)=[];
            f.frames(1).cdata(:,:,1)=ii;
        end
        
        
        
        h2=imagesc(ii); colormap ('gray');
%         pos = get(slider.fh,'Position');
%         h2 = imshow(ii); set(gcf,'Position',pos);% , 'Parent',slider.fh);
        hold on; plot(slider.x, slider.y, 'r'); hold off;
        
        if ~isempty(slider.M)
            
            ccc=['rgbmcky'];
            for i=[0,1,2,3,4,5,6]
                seg_pos=[];
                x=[];
                y=[];
                seg_pos=find(slider.M(:, 2)==slider.val-1 & slider.M(:, 1)==i);
                if seg_pos>0
                    seg=slider.M(seg_pos, 3);
                    pos=find(slider.r{slider.val}{2}==seg);
                    x=slider.r{slider.val}{3}{pos};
                    y=slider.r{slider.val}{4}{pos};
                    hold on; plot(x, y, 'Color',ccc(i+1), 'linewidth', 3);
                end
            end
            
            
        end
        
        
        
        
        set(slider.fh, 'Name', slider.filename)
    end

%% bar tracker
    function bartracker(ii)
        
        
        [x,y] = ginput(1);
        %close(h1)
        cs=30;
        xpos=round(x);
        ypos=round(y);
        if ypos >cs && ypos>cs
            
            cropped_image=ii( ypos-cs:ypos+cs, xpos-cs:xpos+cs);
        else
            cropped_image=ii(1:cs, 1:cs);
        end
        h5=figure;
%         imshow(cropped_image);
        imagesc(cropped_image); colormap('gray'); 
        hold on;
        rectangle ('position', [10 10 40 40 ], 'curvature', [1, 1], 'LineWidth', 2, 'EdgeColor', 'r');
        plot(cs, cs, 'ro');
        
        bb='No';
        p=0;
        
        while p==0
            bb=questdlg('accept bar?', 'Accept bar' );
            close(h5);
            switch bb
                case 'Yes'
                    %save the files
                    p=1;
                    
                case 'No'
                    %cd(movie_path)
                    [b a] = uigetfile('*.mp4', 'select go trial');
                    slider.filename=[a b];
                    ii=plot_mp4(slider);
                    slider.ii=ii;
                    set(eth,'UserData',slider)
                    [x,y] = ginput(1);
                    %close(h1);
                    
                    cs=30;
                    xpos=round(x);
                    ypos=round(y);
                    if ypos >cs && ypos>cs
                        
                        cropped_image=ii( ypos-cs:ypos+cs, xpos-cs:xpos+cs);
                    else
                        cropped_image=ii(1:cs, 1:cs);
                    end
                    
                    h5=figure; 
                    imagesc(cropped_image); colormap('gray'); 
%                     imshow(cropped_image); 
                    hold on
                    rectangle ('position', [10 10 40 40 ], 'curvature', [1, 1], 'LineWidth', 2, 'EdgeColor', 'r');
                    plot(cs, cs, 'ro');
                    
                    p=0;
            end
        end
        
        
        cor=normxcorr2(cropped_image, ii);
        
        %figure; imagesc(cor);colormap('gray')
        %figure; mesh(cor);
        
        [a b]= max(max(cor, [], 1));
        [c d]= max(max(cor, [], 2));
        
        
        x_calc=b-cs;
        y_calc=d-cs;
        
        %% go through all files
        if strcmp(slider.filename(end-2:end), 'mp4')
            movie_files=selectFilesFromList(slider.path, '*.mp4');
        elseif strcmp(slider.filename(end-2:end), 'seq')
            movie_files=selectFilesFromList(slider.path, '*.seq');
        end
        
        ci=zeros(2*cs+1, 2*cs+1, length(movie_files)); %preallocate memory
        
        
        hh=waitbar(0,'correlating', 'Position', 1000* [0.1    0.1    0.2700    0.0563]);
        sp=figure('position', [200 200 20*cs 20*cs]);
        
        
        for i=1:length(movie_files)
            
            waitbar(i/length(movie_files),hh,['correlating...'  num2str(i) '..of..' num2str(length(movie_files))] );
            i
            %clf;
            if strcmp(movie_files{1}(end-2:end), 'mp4')
                
                f=mmread([slider.path movie_files{i}], slider.val);
                iii=f.frames(1).cdata(:,:,1);
                %         f=mmread(slider.filename, slider.val);
                %          ii=f.frames(1).cdata(:,:,1);
            elseif strcmp(movie_files{1}(end-2:end), 'seq')
                
                [seq_info, fid] = read_seq_header(slider.filename);
                f = read_seq_images(seq_info, fid, slider.val);
                iii=f;%f.frames(1).cdata(:,:,1);
                
            end
            
            
            
            frame_num(i)=abs(slider.f.nrFramesTotal); %frame number to generate bar file
            
            cor=normxcorr2(cropped_image, iii);
            [a b]= max(max(cor, [], 1));
            [c d]= max(max(cor, [], 2));
            final_pos(i, 1)=b-cs;
            final_pos(i, 2)=d-cs;
            
            ci(:,:, i)=iii( final_pos(i, 2)-cs:final_pos(i, 2)+cs, final_pos(i, 1)-cs:final_pos(i, 1)+cs);
            
            figure(sp);
            subplot(2,1,1); 
%             imshow(iii); % 
            imagesc(iii);colormap('gray');
            
            subplot(2,1,2); 
%             imshow(ci(:,:,i)); %
            imagesc(ci(:,:,i)); colormap('gray');
            hold on;
            h3=rectangle ('position', [10 10 40 40 ], 'curvature', [1, 1], 'LineWidth', 2, 'EdgeColor', 'r');
            plot(cs, cs, 'ro');
            set(sp, 'Name', [movie_files{i}]);
            %pause
        end
        close(hh)
        close(sp)
        
        %% reviews
        
        h6=figure('Position', [5 200 2*slider.f.width 2*slider.f.height], 'Color', 'w', 'Name', [slider.filename]);
%         imshow(ii); %
        imagesc(ii); colormap ('gray');
        
        hold on; plot(final_pos(:,1),final_pos(:,2), 'ro');
        
        
        %% detailed review of the locations
        
        cc=questdlg('review locations', 'review');
        switch cc
            case 'Yes'
                
                hhh=figure('position', [200 200 20*cs 20*cs]);
                pause on;
                for i=1:size(ci, 3)
                    clf;
%                     imshow(ci(:,:,i)); % 
                    imagesc(ci(:,:,i));colormap('gray'); 
                    hold on;
                    rectangle ('position', [10 10 40 40 ], 'curvature', [1, 1], 'LineWidth', 2, 'EdgeColor', 'r');
                    plot(cs, cs, 'ro');
                    set(hhh, 'Name', [movie_files{i}]);
                    i
                    pause(0.2)
                    
                end
                close (hhh)
                pause off
                
                
            case 'No'
        end
        %% save the bar files
        
        aa=questdlg('Save to bar files? Will overwrite and existing bar file! ', 'Save?');
        close(h6);
        
        switch aa
            case 'Yes'
                %save the files
                
                
                for i=1:length(movie_files)
                    %i=3
                    i
                    bm=[];
                    bm(:, 2:3)=repmat(final_pos(i, :),  frame_num(i), 1);
                    bm(:, 1)=[1: frame_num(i)]';
                    barname{i}=[movie_files{i}(1:end-4), '.bar'];
                    fid=fopen(barname{i}, 'wt');
                    fprintf(fid, '%u %4.4f %4.4f \n', bm');
                    %sprintf('%u %4.4f %4.4f \n', bm')
                    fclose(fid);
                    
                end
                disp('done')
                
                
            case 'No'
                disp('done')
        end
        
        
    end


    function [seq_info, fid] = read_seq_header(seq_file)
        % [seq_info, fid] = read_seq_header(seq_file)
        % this function reads a sequence header for a StreamPix .seq file
        % seq_file is a string with the file name
        % Thus far only tested on 8 bit monichrome sequences - MBR 6/19
        
        fid = fopen(seq_file, 'r');
        % put in an error message here if file not found
        status = fseek(fid, 548, 'bof'); % the CImageInfo structure starts at byte 548
        
        if status == 0
            CImageInfo = fread(fid, 6, 'uint32');
            seq_info.Width = CImageInfo(1);            % Image width in pixel
            seq_info.Height = CImageInfo(2);           % Image height in pixel
            seq_info.BitDepth = CImageInfo(3);         % Image depth in bits (8,16,24,32)
            seq_info.BitDepthReal = CImageInfo(4);     % Precise Image depth (x bits)
            seq_info.SizeBytes = CImageInfo(5);        % Size used to store one image
            seq_info.ImageFormat = CImageInfo(6);      % format information, should be 100 monochrome (LSB)
        end
        
        seq_info.NumberFrames = fread(fid, 1, 'uint32');
        status = fseek(fid, 580, 'bof');
        seq_info.TrueImageSize = fread(fid, 1, 'uint32');
        seq_info.FrameRate = fread(fid, 1, 'double');
    end



    function seq_image = read_seq_images(seq_info, fid, frames)
        % seq_im = read_seq_images(seq_info, fid, frames)
        % reads the frames specified by frames, either a range, or -1 for all of
        % them, and returns in the seq_im structure
        
        if frames == -1  % if -1, then set frames to entire sequence
            frames = 1:seq_info.NumberFrames;
        end
        
        seq_image = zeros(length(frames), seq_info.Height, seq_info.Width);
        
        if length(frames) == 1 % if just one frame, do not return a structure
            image_address = 1024 + (frames-1)*seq_info.TrueImageSize;
            status = fseek(fid, image_address, 'bof');
            seq_image = fread(fid, [seq_info.Width, seq_info.Height], 'uint8')';
        else
            for j = 1:length(frames)
                image_address = 1024 + (frames(j)-1)*seq_info.TrueImageSize;
                status = fseek(fid, image_address, 'bof');
                seq_image(j,:,:) = fread(fid, [seq_info.Width, seq_info.Height], 'uint8')';
            end
        end
    end

    function names = selectFilesFromList(path, type)
        
        global gh state
        
        if nargin < 1
            path = pwd;
            type = '.tif'
        end
        
        if nargin == 1
            try
                filetype = get(gh.autotransformGUI.fileType, 'String');
                value = get(gh.autotransformGUI.fileType, 'Value');
                filetype = filetype{value};
            catch
                filetype = type;
            end
        end
        if nargin == 2
            filetype = type;
        end
        
        d = dir(fullfile(path, ['/*' filetype]));
        if length(d) == 0
            str = 'No Files Found';
        else
            str = {d.name};
        end
        str = sortrows({d.name}');
        if isempty(str)
            names = {};
            disp('No Files with that Extension Selected. Please choose a Path with Image files');
            return
        end
        
        [s,v] = listdlg('PromptString','Select a file:', 'OKString', 'OK',...
            'SelectionMode','multiple',...
            'ListString', str, 'Name', 'Select a File');
        names = str(s);
        
        
    end
end

