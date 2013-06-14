function results = getGroupFeatureTreeBatch(x,y,type,N_bagging,N_time,minLeaf,groups,whichGroups,trialEnd)
% Count number of variables
N_groups = length (whichGroups);
cont = 0;
for i = 1:N_groups,
    cont = cont + length(groups{whichGroups(i)});
end
N_Var = cont;
x2     = zeros(N_Var,size(x,2),size(x,3));
type2  = zeros(N_Var,1);
start  = 1;
for i=1:N_groups
    idx = groups{whichGroups(i)};
    num = length(idx);
    x2(start:start+num-1,:,:) = x(idx,:,:); 
    type2(start:start+num-1)  = type(idx);
    start = start+num;
end
x_short            = cutTrialsWithNaN (x,trialEnd);
y_short            = cutTrialsWithNaN (y,trialEnd);

% Re-arrange the x y matrices for use with bagtree
[x_train y_train trial time] = getTrainingFormatExcludeNaN (x_short,y_short,[]);  % it returns the trial and time of each point for easy reconstruction
[x_train_norm mean_x_train sigma_x_train ] = zscore(x_train);
[y_train_norm mean_y_train sigma_y_train ] = zscore(y_train);

results = bagTreeRegressionBatch (x_train_norm,y_train_norm,type2, N_bagging,N_time,minLeaf,0,'nada',0);