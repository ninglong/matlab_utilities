%
% deals with updating processor step list in fluo_control_main
%
function fluo_control_main_update_processing_steps_list()
  global glovars;

	for s=1:length(glovars.processor_step)
	  fs{s} = glovars.processor_step(s).name;
	end

	set(glovars.fluo_control_main.processing_steps_list, 'String', fs);

	set(glovars.fluo_control_main.processing_steps_list, 'val', glovars.current_processor_step);
