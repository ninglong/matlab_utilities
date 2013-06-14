function [new_x catNames] = createVariableMultiplePositions(x,names,varTrialType,varEvent,separate,startEvent,duration)
%varEvent: can be none, in which case it starts from time 1 (for instance
%to have a time-block that indicates trial-type)
%separate: indicates whether it creates  separable variables for the different trials types 
%duration: -1 indicates same duration of varEvent
%startEvent if you want to creat time-blocks indicating trial-types. (for
%instance pre-pole, post-pole, etc

idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
idxEvent           = find(ismember (names,varEvent));

%fix the polePosition for the NoGo to be -10 instead of 0
trialsZero = find (x(idxVar,:,1)==0);
x(idxVar,trialsZero,:) = -10;

% Check how many categories you have
categories = sort(unique (squeeze(x(idxVar,:,1))));

N_cat      = length (categories);
categoryTrials = zeros(1,N_cat);
if separate == 1
    new_x              = zeros(N_cat,N_trials,N_time);
else
    new_x              = zeros(N_trials,N_time);
    if ~isempty(idxEvent)
        catNames{1}        = sprintf('%s%s%s',varTrialType,'_triggeredBy_',varEvent);
    else
        catNames{1}        = sprintf('%s%s',varTrialType,'_type');
    end
end
for i=1:N_cat,
    trials_cat{i}  = find(squeeze(x(idxVar,:,1))==categories(i));    
    if isnumeric(categories(i))   
        catNames{i}    = num2str(categories(i));
        categoryTrials(i) = categories(i);
    else
        catNames{i}    = categories;       
        categoryTrials(i) = i;
    end
end
% trials_GO          = find(squeeze(x(idxVar,:,1))==1);
% trials_NOGO        = find(squeeze(x(idxVar,:,1))==-1);

if (isempty(varEvent))
% It will start from startEvent (1 if not specified) to startEvent + duration
    if isempty(startEvent)
        startEvent = 1;
    end
    if separate == 1
        for i=1:N_cat
            new_x(i,trials_cat{i},startEvent: startEvent + duration-1)   = ones(length(trials_cat{i}),duration);
        end
    else
        for i=1:N_cat
            new_x(trials_cat{i},startEvent: startEvent + duration-1)     = categoryTrials(i)*ones(length(trials_cat{i}),duration);
        end
    end
else
    if separate == 1
        if duration == -1
            %Exact copy of the varEvent but multiplied by the category
            % This assume that the varEvent is one one present, 0 otherwise
            % and then the new_x will be 0 if nothing is present, and the
            % correspondent category otherwise
            for i=1:N_cat
                new_x(i,trials_cat{i},:)   = categoryTrials(i)*squeeze(x(idxEvent,trials_cat{i},:));
            end
        else  % This is for starting form the event for 'duration' after the event was triggered (for instance pole-up)
            for i=1:N_cat
                timeEventCat{i} = zeros(N_trials,N_time);
            end
            for k=1:N_trials,
                aux = squeeze(find (x(idxEvent,k,:)),1,'first');
                for i=1:length(N_cat)
                    if ismember(k,trials_cat{i})
                        minDur = max (aux+duration-1,N_time);
                        timeEventCat{i}(k,aux:minDur) = 1;
                    end                    
                end
            end
            for i=1:N_cat
                new_x(i,:,:)  = timeEventCat{i};
            end
        end
    else
        if duration == -1
            %Exact copy of the varEvent but multiplied by category 
            for i=1:N_cat
                new_x(trials_cat{i},:)   = categoryTrials(i)*squeeze(x(idxEvent,trials_cat{i},:));
            end
        else
            timeEventCat = zeros(N_trials,N_time);
            for k=1:N_trials,
                aux = squeeze(find (x(idxEvent,k,:)),1,'first');
                for i=1:N_cat
                    if ismember(k,trials_cat{i})
                        minDur = max (aux+duration-1,N_time);
                        timeEventCat(k,aux:minDur) = categoryTrials(i);
                    end                    
                end
            end
            new_x  = timeEvent;         
        end
    end
end
