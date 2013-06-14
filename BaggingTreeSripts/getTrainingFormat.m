function [x_train y_train] = getTrainingFormat (x,y,trials)
if length(trials) ==0
    x_train = reshape(permute(x,[1 3 2]),size(x,1),[])';
    y_train = reshape(permute(y,[1 3 2]),size(y,1),[])';
else
    x_train = reshape(permute(x(:,trials,:),[1 3 2]),size(x,1),[])';
    y_train = reshape(permute(y(:,trials,:),[1 3 2]),size(y,1),[])';    
end

