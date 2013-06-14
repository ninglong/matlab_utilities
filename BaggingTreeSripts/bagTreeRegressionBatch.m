function results = bagTreeRegressionBatch (x_train,y_train,type, N_bagging,N_time,minLeaf,addShiftedY,baseName,savePerCell)
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

for i=1:N,
    i
    varY           = y_train(:,i);
    if addShiftedY == 1
        aux      = reshape(y_train(:,i),N_time,[])';
        shiftY   = [zeros(size(aux,1),1) aux(:,1:end-1)];
        x_train_2 = x_train;
        x_train_2(:,size(x_train,2)+1) = reshape(shiftY',size(aux,1)*size(aux,2),1);
        bagTree     = TreeBagger(N_bagging,x_train_2,varY,'method','r','oobvarimp','on','cat',find(type==1),'minleaf',minLeaf(i),'Options',options);
        singleCellResults.x_train = x_train_2;
    else
        bagTree     = TreeBagger(N_bagging,x_train,varY,'method','r','oobvarimp','on','cat',find(type==1),'minleaf',minLeaf(i),'Options',options);
        singleCellResults.x_train = x_train;
    end
    aux_features   = bagTree.OOBPermutedVarDeltaError;
    features(:,i)  = aux_features';
    aux_predict    = oobPredict(bagTree);
    y_predict(:,i) = aux_predict;
    [R,P,RLO,RUP]  = corrcoef(varY,aux_predict);
    aux_R(i)       = R(1,2);
    aux_P(i)       = P(1,2);
    aux_RLO(i)     = RLO(1,2);
    aux_RUP(i)     = RUP(1,2);
    if savePerCell == 1
        singleCellResults.features  = features(:,i);
        singleCellResults.y_predict = y_predict(:,i);
        singleCellResults.R         = aux_R(i);
        singleCellResults.P         = aux_P(i);
        singleCellResults.RLO       = aux_RLO(i);
        singleCellResults.RUP       = aux_RUP(i);
        singleCellResults.cell_no   = i;
        singleCellResults.tree      = compact(bagTree);
        singleCellResults.y_train   = varY;
        fileToSave = sprintf('%s%s%.3d',baseName,'_Cell',i);
        save (fileToSave,'singleCellResults','-append');
    end
end
results.features  = features;
results.y_predict = y_predict;
results.R         = aux_R;
results.P         = aux_P;
results.RLO       = aux_RLO;
results.RUP       = aux_RUP;
