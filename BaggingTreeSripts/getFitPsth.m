function results = getFitPsth (x,y,y_train,names,varTrialType,results)
N            = size(y,2);
idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
N                      = size(y,1);
trials_GO          = find(squeeze(x(idxVar,:,1))==1);
trials_NOGO        = find(squeeze(x(idxVar,:,1))==0);


for i=1:N,
    results.RMSE_norm.allPoints.all(i)        =  (mean((y_train(:,i) - results.y_predict(:,i)).^2)/mean(y_train(:,i).^2))^.5;
    results.RMSE.allPoints.all(i)             =  (mean((y_train(:,i) - results.y_predict(:,i)).^2))^.5;
    
    y_GO        = squeeze(y(i,trials_GO,:)); 
    y_pred_GO   = squeeze(results.y_tree(i,trials_GO,:));
    y_NOGO      = squeeze(y(i,trials_NOGO,:)); 
    y_pred_NOGO = squeeze(results.y_tree(i,trials_NOGO,:));

    results.RMSE_norm.allPoints.GO(i)     = (mean(mean((y_GO-y_pred_GO).^2))/mean(mean(y_GO.^2)))^.5;    
    results.RMSE_norm.allPoints.NOGO(i)   = (mean(mean((y_NOGO-y_pred_NOGO).^2))/mean(mean(y_NOGO.^2)))^.5;     
    results.RMSE_norm.psth.all(i)      = (mean((results.psth.data.all(i,:)-results.psth.model.all(i,:)).^2)/mean(results.psth.data.all(i,:).^2))^.5;
    results.RMSE_norm.psth.GO(i)      = (mean((results.psth.data.GO(i,:)-results.psth.model.GO(i,:)).^2)/mean(results.psth.data.GO(i,:).^2))^.5;
    results.RMSE_norm.psth.NOGO(i)    = (mean((results.psth.data.NOGO(i,:)-results.psth.model.NOGO(i,:)).^2)/mean(results.psth.data.NOGO(i,:).^2))^.5;
    
    results.RMSE.allPoints.GO(i)     = (mean(mean((y_GO-y_pred_GO).^2)))^.5;    
    results.RMSE.allPoints.NOGO(i)   = (mean(mean((y_NOGO-y_pred_NOGO).^2)))^.5;     
    results.RMSE.psth.all(i)         = (mean((results.psth.data.all(i,:)-results.psth.model.all(i,:)).^2))^.5;
    results.RMSE.psth.GO(i)          = (mean((results.psth.data.GO(i,:)-results.psth.model.GO(i,:)).^2))^.5;
    results.RMSE.psth.NOGO(i)        = (mean((results.psth.data.NOGO(i,:)-results.psth.model.NOGO(i,:)).^2))^.5;
    
end