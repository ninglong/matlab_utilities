function results = getPSTHMultipleGo (x,y,names,varTrialType,varPolePosition,results)
idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
N                      = size(y,1);
for i=1:4,
    trialsType{i}  = find(squeeze(x(idxVar,:,1))==i-1);
end
idxPos  = find(ismember (names,varPolePosition));
cat = unique(squeeze(x(idxPos,:,1)));
N_cat = length(cat);
for i=1:N_cat,
    trialsMultipleGo{i} = find(squeeze(x(idxPos,:,1))==cat(i));
end

% trials_GO          = find(squeeze(x(idxVar,:,1))==1);
% trials_NOGO        = find(squeeze(x(idxVar,:,1))==0);

for i=1:N,
    results.psth.data.all(i,:)    = mean(squeeze(y(i,:,:)),1);
    results.y_tree(i,:,:)         = reshape (results.y_predict(:,i),N_time,[])';
    results.psth.model.all(i,:)   = mean(squeeze(results.y_tree(i,:,:)),1);
    for j=1:4,
        results.psth.data.trialType{j}(i,:)     = mean(squeeze(y(i,trialsType{j},:)),1);        
        results.psth.model.trialType{j}(i,:)    = mean(squeeze(results.y_tree(i,trialsType{j},:)),1);
    end
    for j=1:N_cat,
        results.psth.data.multipleGo{j}(i,:)     = mean(squeeze(y(i,trialsMultipleGo{j},:)),1);        
        results.psth.model.multipleGo{j}(i,:)    = mean(squeeze(results.y_tree(i,trialsMultipleGo{j},:)),1);
    end
end