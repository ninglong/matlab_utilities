
% 
% This updates the display of fluo movie in fluo_display_axes
%
function fluo_display_update_display
  global glovars;

  % does the fluo display exist?
  
	% --- some prelims
  im_size = size(glovars.fluo_display.display_im);

  % --- fluo_display_axes: image itself
  %  update it
  axes(glovars.fluo_display.fluo_display_axes);
	switch glovars.fluo_display.display_mode
	  case 1 % just the current frame, plain and simple
		  disp_im = glovars.fluo_display.display_im(:,:,glovars.fluo_display.display_im_frame);

		case 2 % mean across frames
		  disp_im = mean(glovars.fluo_display.display_im, 3);

		case 3 % max across frames
		  disp_im = max(glovars.fluo_display.display_im, [], 3);
%		  disp_im = max(glovars.fluo_display.display_im, [], 3) - mean(glovars.fluo_display.display_im,3);
%		  disp_im = std(glovars.fluo_display.display_im,0,3);
		  disp_im = disp_im-std(glovars.fluo_display.display_im,0,3);
	end
  tmp = imshow(disp_im, [glovars.fluo_display.colormap_min glovars.fluo_display.colormap_max]);
  set(tmp,'ButtonDownFcn', 'fluo_display(''fluo_display_axes_ButtonDownFcn'',gcbo,[],guidata(gcbo))');

	% aspect ratio ...
	switch glovars.fluo_display.aspect_ratio
	  case 1 % square
		  s1 = im_size(2)/max(im_size(1:2));
		  s2 = im_size(1)/max(im_size(1:2));
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [s1 s2 1]);

		case 2 % based on image -- i.e., free
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [1 1 1]);

		case 3 % based on mag
		  M = max(glovars.fluo_display.hor_pix2um,glovars.fluo_display.ver_pix2um);
		  s1 =  glovars.fluo_display.ver_pix2um/M;
		  s2 = glovars.fluo_display.hor_pix2um/M;
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [s1 s2 1]);
      set(glovars.fluo_control_main.um_per_pix_hor_edit, 'String', ... 
			    num2str(glovars.fluo_display.hor_pix2um));
      set(glovars.fluo_control_main.um_per_pix_ver_edit, 'String', ... 
			    num2str(glovars.fluo_display.ver_pix2um));

			% - draw the distance bar 
			ver_extent = glovars.fluo_display.ver_pix2um * im_size(1);
%			hor_extent = glovars.fluo_display.hor_pix2um * im_size(2);
			p = floor(log10(ver_extent));
			hold on ; 
			plot([10 10], [10 10+((10^p)/glovars.fluo_display.ver_pix2um)], ...
			  'Color', [1 1 1], 'LineWidth', 3);
			 text (15 , 10+0.5*((10^p)/glovars.fluo_display.ver_pix2um),  ...
			  [num2str(10^p) ' um'], 'Color' ,[1 1 1]);
				
      
	end

  % --- fluo_display_axes: ROIs
	for r=1:glovars.fluo_roi_control.n_rois
	  roi = glovars.fluo_roi_control.roi(r);
		lw = 1;

    % - thicker lines for selected roi (or all)
    if (r == glovars.fluo_roi_control.roi_selected | ...
        glovars.fluo_roi_control.roi_selected == 0)
		  lw = 2;
		end

		hold on;
    % - most points
		for p=1:length(roi.corners)-1
		  plot ([roi.corners(1,p) roi.corners(1,p+1)], ...
		        [roi.corners(2,p) roi.corners(2,p+1)], ...
						[roi.color '-'], 'LineWidth', lw);
		end
		% - last point connection
		plot ([roi.corners(1,1) roi.corners(1,p+1)], ...
					[roi.corners(2,1) roi.corners(2,p+1)], ...
				  [roi.color '-'], 'LineWidth', lw);

		% - number?
		if (glovars.fluo_roi_control.show_roi_numbers == 1)
		  text(mean(roi.corners(1,:)), ...
		       mean(roi.corners(2,:)), ...
					 num2str(r), 'Color', 'w');
		end
		hold off;
  end

	% --- fluo_display_message_text

	% --- fluo_display_frame_slider, fluo_display_framenum_text
	if (numel(im_size) > 2) % only if multiframe
		set(glovars.fluo_display.fluo_display_frame_slider,'Min', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'Max', im_size(3));
		set(glovars.fluo_display.fluo_display_frame_slider,'SliderStep', [1/(im_size(3)-1) min(1,10/(im_size(3)-1))]);
		set(glovars.fluo_display.fluo_display_frame_slider,'value', glovars.fluo_display.display_im_frame);
		set(glovars.fluo_display.fluo_display_framenum_text, 'String', ...
			['Frame ' num2str(glovars.fluo_display.display_im_frame) ' of ' num2str(im_size(3)) ...
			' (' num2str(im_size(1)) ' lines x ' num2str(im_size(2)) ' pixels per line)']);
		set(glovars.fluo_display.fluo_display_message_text,'String', glovars.fluo_display.im_filename);
  else
  	set(glovars.fluo_display.fluo_display_frame_slider,'Min', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'Max', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'SliderStep', [1 1]);
		set(glovars.fluo_display.fluo_display_frame_slider,'value', glovars.fluo_display.display_im_frame);
		set(glovars.fluo_display.fluo_display_message_text,'String', glovars.fluo_display.im_filename);
		set(glovars.fluo_display.fluo_display_framenum_text, 'String', ...
			['Single frame (' num2str(im_size(1)) ' lines x ' num2str(im_size(2)) ' pixels per line)']);
	 end

	% --- fluo_control_main min/max color slider/text
	set(glovars.fluo_control_main.min_color_slider,'Min', 0);
	set(glovars.fluo_control_main.min_color_slider,'Max', 4096);
	set(glovars.fluo_control_main.min_color_slider,'value', glovars.fluo_display.colormap_min);
	set(glovars.fluo_control_main.min_color_edit,'String', num2str(glovars.fluo_display.colormap_min));
	set(glovars.fluo_control_main.max_color_slider,'Min', 0);
	set(glovars.fluo_control_main.max_color_slider,'Max', 4096);
	set(glovars.fluo_control_main.max_color_slider,'value', glovars.fluo_display.colormap_max);
	set(glovars.fluo_control_main.max_color_edit,'String', num2str(glovars.fluo_display.colormap_max));



