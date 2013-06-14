function results = getPSTH (x,y,names,varTrialType,results)
idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
N                      = size(y,1);
trials_GO          = find(squeeze(x(idxVar,:,1))==1);
trials_NOGO        = find(squeeze(x(idxVar,:,1))==0);

for i=1:N,
    results.psth.data.all(i,:)    = mean(squeeze(y(i,:,:)),1);
    results.psth.data.GO(i,:)     = mean(squeeze(y(i,trials_GO,:)),1);
    results.psth.data.NOGO(i,:)   = mean(squeeze(y(i,trials_NOGO,:)),1);
    results.y_tree(i,:,:)         = reshape (results.y_predict(:,i),N_time,[])';
    results.psth.model.all(i,:)   = mean(squeeze(results.y_tree(i,:,:)),1);
    results.psth.model.GO(i,:)    = mean(squeeze(results.y_tree(i,trials_GO,:)),1);
    results.psth.model.NOGO(i,:)  = mean(squeeze(results.y_tree(i,trials_NOGO,:)),1);    
end