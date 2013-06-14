%% Decoding sensory-motor parameters from neural populations
pathDir = 'E:\Diego\Matlab\temp\Leo\';
if animalId == 1
    file    = 'behaviorSummaryArray_114050_101013d';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    orig_x = BehaviorANM114050_101013d;
    file    = 'CaImagingSummaryArray_114050_101013d';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    y = CaImagingArrayANM114050_101013d;
    orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve'};

elseif animalId == 2
    file    = 'behaviorSummaryArray_ANM109664_100827b';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    orig_x = BehaviorANM109664_100827b;
    file    = 'CaImagingArrayANM109664_100827b';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    y = CaImagingArrayANM109664_100827b;
    orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve'};

elseif animalId == 3    
    file = 'BaggingTreesResultsSingleFeaturesExperimentSummary_108205_100813b';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    orig_x = ExperimentSummary_108205_100813b.behaviorDataArray;
    orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve','retTouchKappa_W3','proTouchKappa_W3','touchKappa_W3'};
    y = ExperimentSummary_108205_100813b.CaImagingData;
elseif animalId == 4
    file = 'BaggingTreesResultsSingleFeaturesExperimentSummary114050_101013d';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    orig_x = ExperimentSummaryANM114050_101013d.behaviorDataArray;
    orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve','retTouchKappa_W3','proTouchKappa_W3','touchKappa_W3'};
    y = ExperimentSummaryANM114050_101013d.CaImagingData;    

end
type = zeros(1,size(orig_x,1)); % 0 for continous, 1 for categorical variables
orig_x = permute (orig_x,[1 3 2]);
y = permute (y,[1 3 2]);


[x names_x type_x ]  = removeVariable (orig_x,orig_names,type,{'retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve','retTouchKappa_W3','proTouchKappa_W3','touchKappa_W3'});

N_time = size(x,3);
N_neurons = size(y,1);
N_var  = size(x,1);
for i=1:N_neurons
    names_y{i} = sprintf('%s%.3d','Cell_',i);
end
type_y = zeros(1,N_neurons);
vecShifts = [[-8:-1] [1:8]];
for i=1:N_neurons,
    [y names_y type_y ]  = appendShifted (y,names_y,type_y,names_y{i},vecShifts,[0 0]);
%     [y names_y type_y ]  = removeVariable (y,names_y,type_y,names_y{1});
end


% Re-arrange the x y matrices for use with bagtree
[x_train y_train] = getTrainingFormat (x,y,[]); %It can get what trials to include as input
[coef score latent] = princomp(y_train);
y_train_PCA = score(:,1:50);

%% Find minimum Leaf for each neuron
numTrees  = 50;
N_bagging = 16;

minLeaf = 20*ones(1,N_neurons);

%% Compute the full bagTree with its metrics and psth
% Keep x and y in same way, bagTreeDecoder will interchange what is the
% independent and dependent variables
% results                 = bagTreeDecoder (x_train,y_train_PCA,type,N_bagging,N_time,minLeaf,0);
results                 = bagTreeDecoder_cross (x_train,y_train_PCA,x,y,type,N_bagging,N_time,minLeaf,0);
pathDir = 'E:\Diego\Matlab\temp\Leo\';
baseName = sprintf('%s%s',pathDir,file);
save(sprintf('%s%s',baseName,'_decoding'));
