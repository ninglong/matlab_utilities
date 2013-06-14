function results = bagTreeRegression (x_train,y_train,x_trial,y_trial,type, N_bagging,N_time,minLeaf,addShiftedY,storeTrees)
% N = size(y_train,2);
% y_predict = zeros(size(x_train,1),N);
% if addShiftedY == 0
%     features  = zeros(size(x_train,2),N);
% else
%     features  = zeros(size(x_train,2)+1,N);   
%     x_train_2 = zeros(size(x_train,1),size(x_train,2)+1);
% end
% statset('TreeBagger');
% options = statset('UseParallel','always');
% 
% for i=1:N,
%     i
%     varY           = y_train(:,i);
%     if addShiftedY == 1
%         aux      = reshape(y_train(:,i),N_time,[])';
%         shiftY   = [zeros(size(aux,1),1) aux(:,1:end-1)];
%         x_train_2 = x_train;
%         x_train_2(:,size(x_train,2)+1) = reshape(shiftY',size(aux,1)*size(aux,2),1);
%         bagTree     = TreeBagger(N_bagging,x_train_2,varY,'method','r','oobpred','on','cat',find(type==1),'minleaf',minLeaf(i),'Options',options);
%     else
%         bagTree     = TreeBagger(N_bagging,x_train,varY,'method','r','oobpred','on','cat',find(type==1),'minleaf',minLeaf(i),'Options',options);
%     end
% %     varY           = y_train(:,i);
% %     aux_features   = bagTree.OOBPermutedVarDeltaError;
% %     features(:,i)  = aux_features';
%     aux_predict    = oobPredict(bagTree);
%     y_predict(:,i) = aux_predict;
%     [R,P,RLO,RUP]  = corrcoef(varY,aux_predict);
%     R(1,2)
%     aux_R(i)       = R(1,2);
%     aux_P(i)       = P(1,2);
%     aux_RLO(i)     = RLO(1,2);
%     aux_RUP(i)     = RUP(1,2);
% 
% end
% % results.features  = features;
% results.y_predict = y_predict;
% results.R         = aux_R;
% results.P         = aux_P;
% results.RLO       = aux_RLO;
% results.RUP       = aux_RUP;
% % if storeTrees == 1
% %     for i=1:N
% %         results.bagTree{i}   = compact(bagTree{i});
% %     end
% % end

N = size(y_train,2);
y_predict = zeros(size(x_train,1),N);
if addShiftedY == 0
    features  = zeros(size(x_train,2),N);
else
    features  = zeros(size(x_train,2)+1,N);   
    x_train_2 = zeros(size(x_train,1),size(x_train,2)+1);
end
statset('TreeBagger');
options = statset('UseParallel','always');

%We have to reshape to get the trials
N_trial = size(x_trial,2);

allTrials = randperm(N_trial);
NTrialsPerValidate = floor (0.2*N_trial);
for i=1:5,
    if i==5
        testTrials{i} = allTrials([(i-1)*NTrialsPerValidate+1:N_trial]);
    else
        testTrials{i} = allTrials([(i-1)*NTrialsPerValidate+1:i*NTrialsPerValidate]);
    end
    trainingTrials{i} = setdiff(allTrials,testTrials{i});
end


y_predict_trial = zeros(N,N_trial,N_time);
for i=1:N,
    i
    for j=1:5,
        aux_x = x_trial(:,trainingTrials{j},:);
        aux_y = y_trial(:,trainingTrials{j},:);
        [x_subset_train y_subset_train] = getTrainingFormat(aux_x,aux_y,[]);
        varY           = y_subset_train(:,i);
        bagTree{i}     = TreeBagger(N_bagging,x_subset_train,varY,'method','r','oobpred','on','cat',find(type==1),'minleaf',minLeaf(i),'Options',options);
        aux_x = x_trial(:,testTrials{j},:);
        x_subset_test = reshape(permute(aux_x,[1 3 2]),size(aux_x,1),[])';
        aux_pred  = predict (bagTree{i},x_subset_test);  
        y_predict_trial(i,testTrials{j},:) = reshape(aux_pred,N_time,[])';  

    end
    varY           = y_train(:,i);
%     aux_features   = bagTree{i}.OOBPermutedVarDeltaError;
%     features(:,i)  = aux_features';   
    auxx            = reshape(permute(y_predict_trial,[1 3 2]),size(y_predict_trial,1),[])';
    y_predict(:,i) = auxx(:,i);
    [R,P,RLO,RUP]  = corrcoef(varY,y_predict(:,i));
    R(1,2)
    corr(varY,y_predict(:,i),'type','Spearman')
    aux_R(i)       = R(1,2);
    aux_P(i)       = P(1,2);
    aux_RLO(i)     = RLO(1,2);
    aux_RUP(i)     = RUP(1,2);
    
end
% results.features  = features;
results.y_predict = y_predict;
results.R         = aux_R;
results.P         = aux_P;
results.RLO       = aux_RLO;
results.RUP       = aux_RUP;
results.y_predict_trial = y_predict_trial;
% if storeTrees == 1
%     for i=1:N
%         results.bagTree{i}   = compact(bagTree{i});
%     end
% end
