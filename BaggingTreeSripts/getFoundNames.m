function list = getFoundNames (arrayNames)
cont = 0;
N_var    = length(arrayNames);
for j=1:N_var,
    if ~isempty(arrayNames{j})            
        cont = cont + 1;
        list(cont) = j;
    end
end
