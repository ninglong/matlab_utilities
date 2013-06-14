function [x y_ca y_cad names type] = getData (fileName)
% Input : fileName with the full path. The data is assumed to be loaded in
%         a structure named 'aa'
% Output: x     is a 3D matrix Independent Variables x Trials x Time
%         y_ca  is a 3D matrix Neurons x Trials x Time (raw Ca Signal)
%         y_cad is a 3D matrix Neurons x Trials x Time (Ca Signal after
%         event detection)

% Gets the original data
load(fileName);
names = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','pole_in_reach','water_valve','trial_type','trial_class'};
            
          
type  = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1];
N_neurons   = length(aa.ca);
N_time      = size(aa.ca{1},2);
N_trials    = size(aa.ca{1},1);
N_var       = length(names);
y_ca        = zeros (N_neurons,N_trials,N_time);
y_cad       = zeros (N_neurons,N_trials,N_time);
x           = zeros (N_var,N_trials,N_time);
for i=1:N_neurons,
    y_ca(i,:,:) = aa.ca{i};
    y_cad(i,:,:) = aa.cad{i};
end
for i=1:N_var,
    aux       = getfield(aa, names{i});
    x(i,:,:)  = aux;
end
y_ca(find(isnan(y_ca)))=0;
y_cad(find(isnan(y_cad)))=0;
