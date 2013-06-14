function groups = getGroupsAll (names,nameGroups)
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
        groups{i} = listFound;

    
end