function dh_whisker_linkerB (varargin)
% function dh_whisker_linkerA (x,y,num_whiskers, min_length)


if nargin ==3
    xt=varargin{1};
    yt=varargin{2};
    num_whiskers=varargin{3};
    min_length=varargin{4};
elseif nargin==0
    
    
    %%
    [b a] = uigetfile('*.seq; *. mp4', 'select go trial');
    seq_file=[a b];
    
    if strcmp(seq_file(end-2:end), 'seq')
    
    %seq_file='G:\_data\DOM2_whisker_examples\test\jf30422x062509_0044.seq';
    [seq_info, fid] = read_seq_header(seq_file);
    seq_image = read_seq_images(seq_info, fid, 5);
    imagesc(seq_image); colormap ('gray');
    [xt, yt] = getline
    hold on; plot(xt,yt);
    %%
    elseif strcmp(seq_file(end-2:end), 'mp4')
        f=mmread(seq_file, 600);
        
        ii=f.frames(1).cdata(:,:,1);
        h2=imagesc(ii); colormap ('gray');
    [xt, yt] = getline
    hold on; plot(xt,yt);
    %hold on; plot(xt, yt)
    end
    
    num_whiskers=3;
    min_length=70; 
    % minimal whisker length
end



[b a] = uigetfile('*.whiskers', 'select whiskers files');
filename=[a b];

file_names=selectFilesFromList(a, '*.whiskers');


%cd(a);

for fn=1:length(file_names)
    
    tracker_file_name=[a file_names{fn}(1:(end-9))];
    %tracker_file_name='F:\Processed_Whiskers_DOM3_A\jf25607\jf25607x121509\jf25607x121509_0019';
    obj.trajectoryIDs=[0,1,2,3 ];
    [r, obj.trackerFileFormat] = Whisker.load_whiskers_file([tracker_file_name '.whiskers']);
    
    if exist([tracker_file_name '.measurements'],'file')
        M = Whisker.read_whisker_measurements([tracker_file_name '.measurements']);
        trajectory_ids = M(:,1);
        frame_nums = M(:,2);
        segment_nums = M(:,3);
        if exist([tracker_file_name '.trajectories'],'file')
            disp(['For ' tracker_file_name 'found both .measurements and .trajectories files---using .measurements.'])
        end
    else
        % .measurements file not found; choose .trajectories file.
        [trajectory_ids, frame_nums, segment_nums] = Whisker.load_trajectories([tracker_file_name '.trajectories']);
    end
    
    if exist([tracker_file_name '.bar'],'file')
        [bar_f, bar_x, bar_y] = Whisker.load_bar([tracker_file_name '.bar']);
        obj.barPos = [bar_f, bar_x, bar_y];
    end
    
    
    x_i=[];
    y_i=[];
    
    %N=M;
    M(:, 1)=-1;
    
    %f=13;
    for f=1:size(r, 2) %go through all the frames starting at 1
        f
        %f=670;
        size_ids{f}=r{f}{2}; %ID of the tracked segments
        for no_id=1:size(r{f}{2},1) % go through all the whisker no_id tracked
            %no_id
            x1=[];
            y1=[];
            
            x1=r{f}{3}{no_id};
            y1=r{f}{4}{no_id};
            
            if ~isempty(intersections(x1,y1,xt,yt,0))
                if size((intersections(x1,y1,xt,yt,0)), 1)>1
                    [aaa,bbb]=intersections(x1,y1,xt,yt,0);
                    x_i(f, no_id)=aaa(1);
                    y_i(f, no_id)=bbb(1);
                else
                    [x_i(f, no_id),y_i(f, no_id)] = intersections(x1,y1,xt,yt,0);
                end
                
            else
                x_i(f, no_id)=0;
                y_i(f, no_id)=0;
            end
            
            
            %classifiy the detected intersection by size
            lx=x_i(f, :);
            ly=y_i(f, :);
            %hold on;  plot(lx, ly, 'ro')
            gw_mask_b{f}=[];
            gw_mask{f}=[];
            gw_mask{f}=find(lx>0);
            
            Y=[];
            I=[];
            dd=[];
            ddi=0;
            gw_mask_b{f}=gw_mask{f}; %backup copy
            if length(gw_mask_b{f})>num_whiskers
                for i=1:length(gw_mask_b{f})
                    %i
                    if ~isempty(find((M(:,2)==f-1 & M(:,3)==size_ids{f}(gw_mask_b{f}(i)) & M(:,4)<min_length)));
                        ddi=ddi+1;
                        dd(ddi)=i;
                    end
                end
                
            end
            gw_mask{f}(dd)=[];
            
            o_id{f}=size_ids{f}(gw_mask{f});
            [Y,I]=sort(lx(gw_mask{f}));
            n_id{f}=o_id{f}(I)';
            
            % go through the Measurements array
            
            fr_mask=[];
            for m=1:length(n_id{f})
                %m
                oo=n_id{f}(m);
                fr_mask = find(M(:,2)==f-1 & M(:,3)==oo);%find the according fframe data in M
                M(fr_mask, 1)=m-1;
            end
            
            
            
            
        end
        
    end
    new_name=[tracker_file_name, '.measurements.mat']
    save (new_name, 'M');
    disp(['saved  ' tracker_file_name, '.measurements.mat' ])
end


%     figure; plot(M(:,1), 'ro')
%     figure; hist(M(:,1))
%
%     ii=find(M(:,1)==3);
%     M(ii, 2);
%


%
%
%     aa=questdlg('Save to measurement.mat file ! ', 'Save?');
%
%
%     switch aa
%         case 'Yes'
%             %save the files
%             new_name=[tracker_file_name, '.measurements.mat'];
%             save (new_name, 'M');
%
%
%             disp('done')
%
%
%         case 'No'
%             disp('done')
%     end
end
%
% frame=616;
% hold on;
% ccc=['rgbmc'];
% for i=[0,1,2,3,4]
%     seg_pos=[];
%     x=[];
%     y=[];
%     seg_pos=find(M(:, 2)==frame & M(:, 1)==i)
%     if seg_pos>0
%         seg=M(seg_pos, 3);
%         pos=find(r{frame}{2}==seg)
%         x=r{frame}{3}{pos};
%         y=r{frame}{4}{pos};
%         hold on; plot(x, y, 'Color',ccc(pos))
%     end
%
%
% end






