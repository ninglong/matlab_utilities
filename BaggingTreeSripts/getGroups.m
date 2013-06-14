function groups = getGroups (names,nameGroups)
N_groups = length(nameGroups);
N_var    = length(names);
groups   = cell(N_groups,1);
for i=1:N_groups
    aux = regexp(names,nameGroups{i});
    aux2 = regexp(nameGroups,nameGroups{i});
    cont2 = 0;
    extraGroup = [];
    listFound        = getFoundNames (aux);
    % Check name is not subset of another
    listOverlapNames = getFoundNames (aux2);
    listOverlapNames(find(listOverlapNames==i)) = [];
    if isempty(listOverlapNames)
        groups{i} = listFound;
    else
        tempList = listFound;
        for k=1:length(listOverlapNames)
            aux3 = regexp(names,nameGroups{listOverlapNames(k)});
            listOverlap = getFoundNames(aux3);
            tempList = setdiff(tempList,listOverlap);
        end
        groups{i} = tempList;
    end

    
end