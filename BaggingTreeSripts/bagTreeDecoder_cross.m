function results = bagTreeDecoder_cross (x_train,y_train,x_trial,y_trial,type, N_bagging,N_time,minLeaf,storeTrees)
% IMPORTANT
% This version has been corrected for cross-validation forced on trials

N = size(x_train,2);                     % Number of features
y_predict = zeros(size(y_train,1),N);    
features  = zeros(size(y_train,2),N);


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


% Remember the y here is the x of the encoding model
statset('TreeBagger');
options = statset('UseParallel','always');

y_predict_trial = zeros (N,N_trial,N_time);
for i=1:N,
    for j=1:5,
        j
        % Will save only the last tree
        aux_x = x_trial(:,trainingTrials{j},:);
        aux_y = y_trial(:,trainingTrials{j},:);
        [x_subset_train y_subset_train] = getTrainingFormat(aux_x,aux_y,[]);
        varX           = x_subset_train(:,i);
        if type(i) == 0
            bagTree{i}     = TreeBagger(N_bagging,y_subset_train,varX,'method','r','oobvarimp','on','minleaf',minLeaf(i),'Options',options);    % Regression
        else
            bagTree{i}     = TreeBagger(N_bagging,y_subset_train,varX,'method','c','oobvarimp','on','minleaf',1,'Options',options);    % Classification
        end
        aux_y = y_trial(:,testTrials{j},:);
        y_subset_test = reshape(permute(aux_y,[1 3 2]),size(aux_y,1),[])';
        aux_pred  = predict (bagTree{i},y_subset_test);  %Do not get confused, this is decoder, so the 'y' is the calcium signals and 'x' is the to be predicted variable. We still call the prediction y_predict
        y_predict_trial(i,testTrials{j},:) = reshape(aux_pred,N_time,[])';  %This y is actually a prediction of the x (the feautures) 
    end
    varX           = x_train(:,i);
%     aux_features   = bagTree{i}.OOBPermutedVarDeltaError;
%     features(:,i)  = aux_features';   
    auxx            = reshape(permute(y_predict_trial,[1 3 2]),size(y_predict_trial,1),[])';
    y_predict(:,i) = auxx(:,i);
    [R,P,RLO,RUP]  = corrcoef(varX,y_predict(:,i));
    aux_R(i)       = R(1,2)
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
if storeTrees == 1
    for i=1:N
        results.bagTree{i}   = compact(bagTree{i});
    end
end
