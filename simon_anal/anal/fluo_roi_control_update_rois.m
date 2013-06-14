%
% Updates the ROI raw fluo traces from image -- NO display update
%
function fluo_roi_control_update_rois()
  global glovars;

	% loop over frames
	for f=1:glovars.fluo_display.display_im_nframes
		frame_im = glovars.fluo_display.display_im(:,:,f);
		% loop over rois
		for r=1:glovars.fluo_roi_control.n_rois
			if (f == 1) ; glovars.fluo_roi_control.roi(r).raw_fluo = []; end % clear previous
		  glovars.fluo_roi_control.roi(r).raw_fluo(f) = ...
			  mean (frame_im(glovars.fluo_roi_control.roi(r).indices));
		end
  end

