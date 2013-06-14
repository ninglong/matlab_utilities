%% Creation of variables
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
elseif animalId ==2
    file    = 'behaviorSummaryArray_ANM109664_100827b';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    orig_x = BehaviorANM109664_100827b;
    file    = 'CaImagingArrayANM109664_100827b';
    fileName = sprintf('%s%s',pathDir,file);
    load (fileName);
    y = CaImagingArrayANM109664_100827b;

end

% orig_names = {'V1','V2','V3','V4','V5','V6','V7','V8','V9','V10','V11'};
orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','trial_type','polePosition','poleUp','mov_row','mov_col','waterValve'};
% orig_names = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2'};

type = zeros(1,size(orig_x,1)); % 0 for continous, 1 for categorical variables
orig_x = permute (orig_x,[1 3 2]);
y = permute (y,[1 3 2]);



[new_x catNames] = createVariableMultiplePositions(orig_x,orig_names,'polePosition','poleUp',1,1,-1);
for i=1:length(catNames),
    new_name{i} = sprintf('%s%s','poleEventPos',catNames{i});
end
[x names type ]  = appendVariable (orig_x,orig_names,type,new_x,new_name,ones(1,length(catNames)));
for i=1:length(catNames),
    [x names type ]  = appendShifted (x,names,type,new_name{i},[-10:10] ,0);
    [x names type ]  = removeVariable (x,names,type,new_name{i});
end
vecShift = [[-5:1:-1] [1:1:5]];
[x names type ]  = appendShifted (x,names,type,'Lick',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'Amplitude',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'SetPoint',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'poleUp',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'AngularSpeed',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'maxAmplitude',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'retTouchKappa_W1',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'proTouchKappa_W1',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'touchKappa_W1',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'retTouchKappa_W2',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'proTouchKappa_W2',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'touchKappa_W2',vecShift,[ 0 0]);
[x names type ]  = appendShifted (x,names,type,'waterValve',[1:10],1);
[x names type ]  = removeVariable (x,names,type,{'mov_row','mov_col','trial_type','polePosition'});


% Re-arrange the x y matrices for use with bagtree
[x_train y_train] = getTrainingFormat (x,y,[]); %It can get what trials to include as input




%% Compute the full bagTree with its metrics and psth
N_bagging = 16;
N_time = size(x,3);
N_neurons = size(y,1);

minLeaf = 20*ones(1,N_neurons);

results                 = bagTreeRegression (x_train,y_train,x,y,type,N_bagging,N_time,minLeaf,0,0);
results                 = getPSTHMultipleGo (orig_x,y,orig_names,'trial_type','polePosition',results);
results                 = getFitPsthMultipleGo (orig_x,y,y_train,orig_names,'trial_type','polePosition',results);

%% Group variables
nameGroups = {'Lick','Amplitude','SetPoint','AngularSpeed','maxAmplitude','retTouchKappa_W1','proTouchKappa_W1','touchKappa_W1','retTouchKappa_W2','proTouchKappa_W2','touchKappa_W2','poleUp','waterValve'};
aux_N = length(nameGroups);
for i=1:length(catNames),
    nameGroups{aux_N+i} = new_name{i};
end
groups     = getGroups (names,nameGroups);
N_groups   = length(groups);

%% Run with only one grouped feature bagging trees
singleGroup = [1:N_groups];
% allExceptOne = zeros (N_groups,N_groups-1);
% for i=1:N_groups,
%     allExceptOne(i,:) = [[1:i-1] [i+1:N_groups]];
% end
for i=1:N_groups,
    resultsSingleFeature(i) = getGroupFeatureTree(x,y,type,N_bagging,N_time,minLeaf,groups,singleGroup(i),0);
%     resultsAllButOne(i)     = getGroupFeatureTree(x,y,type,N_bagging,N_time,minLeaf,groups,allExceptOne(i,:),0);
end

