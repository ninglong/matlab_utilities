function results = getGroupFeatureTree(x,y,type,N_bagging,N_time,minLeaf,groups,whichGroups,storeTrees)
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
[x_train y_train] = getTrainingFormat (x2,y,[]);
results = bagTreeRegression (x_train,y_train,x2,y,type2, N_bagging,N_time,minLeaf,0,storeTrees);