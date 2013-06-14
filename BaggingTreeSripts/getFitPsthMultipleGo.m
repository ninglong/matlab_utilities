function results = getFitPsthMultipleGo (x,y,y_train,names,varTrialType,varPolePosition,results)
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

for i=1:N,
    results.RMSE_norm.allPoints.all(i)        =  (mean((y_train(:,i) - results.y_predict(:,i)).^2)/mean(y_train(:,i).^2))^.5;
    results.RMSE_norm.psth.all(i)             =  (mean((results.psth.data.all(i,:)-results.psth.model.all(i,:)).^2)/mean(results.psth.data.all(i,:).^2))^.5;
    results.RMSE.allPoints.all(i)             =  (mean((y_train(:,i) - results.y_predict(:,i)).^2))^.5;
    results.RMSE.psth.all(i)         = (mean((results.psth.data.all(i,:)-results.psth.model.all(i,:)).^2))^.5;
    
    for j=1:4,
        y_trialType{j}      = squeeze(y(i,trialsType{j},:)); 
        y_pred_trialType{j} = squeeze(results.y_tree(i,trialsType{j},:)); 
        results.RMSE_norm.allPoints.trialType{j}(i)     = (mean(mean((y_trialType{j}-y_pred_trialType{j}).^2))/mean(mean(y_trialType{j}.^2)))^.5;    
        results.RMSE_norm.psth.trialType{j}(i)          = (mean((results.psth.data.trialType{j}(i,:)-results.psth.model.trialType{j}(i,:)).^2)/mean(results.psth.data.trialType{j}(i,:).^2))^.5;
        results.RMSE.allPoints.trialType{j}(i)          = (mean(mean((y_trialType{j}-y_pred_trialType{j}).^2)))^.5;    
        results.RMSE.psth.trialType{j}(i)               = (mean((results.psth.data.trialType{j}(i,:)-results.psth.model.trialType{j}(i,:)).^2))^.5;

    end
    for j=1:N_cat,
        y_multipleGo{j}      = squeeze(y(i,trialsMultipleGo{j},:)); 
        y_pred_multipleGo{j} = squeeze(results.y_tree(i,trialsMultipleGo{j},:)); 
        results.RMSE_norm.allPoints.multipleGo{j}(i)     = (mean(mean((y_multipleGo{j}-y_pred_multipleGo{j}).^2))/mean(mean(y_multipleGo{j}.^2)))^.5;    
        results.RMSE_norm.psth.multipleGo{j}(i)          = (mean((results.psth.data.multipleGo{j}(i,:)-results.psth.model.multipleGo{j}(i,:)).^2)/mean(results.psth.data.multipleGo{j}(i,:).^2))^.5;
        results.RMSE.allPoints.multipleGo{j}(i)          = (mean(mean((y_multipleGo{j}-y_pred_multipleGo{j}).^2)))^.5;    
        results.RMSE.psth.multipleGo{j}(i)               = (mean((results.psth.data.multipleGo{j}(i,:)-results.psth.model.multipleGo{j}(i,:)).^2))^.5;

    end
    
%     y_GO        = squeeze(y(i,trials_GO,:)); 
%     y_pred_GO   = squeeze(results.y_tree(i,trials_GO,:));
%     y_NOGO      = squeeze(y(i,trials_NOGO,:)); 
%     y_pred_NOGO = squeeze(results.y_tree(i,trials_NOGO,:));

%     results.RMSE_norm.allPoints.GO(i)     = (mean(mean((y_GO-y_pred_GO).^2))/mean(mean(y_GO.^2)))^.5;    
%     results.RMSE_norm.allPoints.NOGO(i)   = (mean(mean((y_NOGO-y_pred_NOGO).^2))/mean(mean(y_NOGO.^2)))^.5;     
%     results.RMSE_norm.psth.GO(i)      = (mean((results.psth.data.GO(i,:)-results.psth.model.GO(i,:)).^2)/mean(results.psth.data.GO(i,:).^2))^.5;
%     results.RMSE_norm.psth.NOGO(i)    = (mean((results.psth.data.NOGO(i,:)-results.psth.model.NOGO(i,:)).^2)/mean(results.psth.data.NOGO(i,:).^2))^.5;
%     
%     results.RMSE.allPoints.GO(i)     = (mean(mean((y_GO-y_pred_GO).^2)))^.5;    
%     results.RMSE.allPoints.NOGO(i)   = (mean(mean((y_NOGO-y_pred_NOGO).^2)))^.5;     
%     results.RMSE.psth.GO(i)          = (mean((results.psth.data.GO(i,:)-results.psth.model.GO(i,:)).^2))^.5;
%     results.RMSE.psth.NOGO(i)        = (mean((results.psth.data.NOGO(i,:)-results.psth.model.NOGO(i,:)).^2))^.5;
    
end