function [new_x ] = createVariableTrialType(x,names,varTrialType,varEvent,separate,duration)
%varEvent: can be none, in which case it starts from time 1
%separate: indicates whether it creates two separable variables for go or no
%go (1 for separate)
%duration: -1 indicates same duration of varEvent

idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
if separate == 1
    new_x              = zeros(2,N_trials,N_time);
else
    new_x              = zeros(N_trials,N_time);
end
idxEvent           = find(ismember (names,varEvent));
trials_GO          = find(squeeze(x(idxVar,:,1))==1);
trials_NOGO        = find(squeeze(x(idxVar,:,1))==-1);

if (isempty(varEvent))
% It will start from 1 to duration
    if separate == 1
        new_x(1,trials_GO,1:duration)   = ones(length(trials_GO),duration);
        new_x(1,trials_NOGO,1:duration) = zeros(length(trials_NOGO),duration);
        new_x(2,trials_GO,1:duration)   = zeros(length(trials_GO),duration);
        new_x(2,trials_NOGO,1:duration) = ones(length(trials_NOGO),duration);
    else
        new_x(trials_GO,1:duration)     = ones(length(trials_GO),duration);
        new_x(trials_NOGO,1:duration)   = -ones(length(trials_GO),duration);        
    end
else
    if separate == 1
        if duration == -1
            %Exact copy of the varEvent but with 1 for Go, 0 for NoGo in
            %one variable, and opposite in the other
            new_x(1,trials_GO,:)   = squeeze(x(idxEvent,trials_GO,:));
            new_x(1,trials_NOGO,:) = 0; % Sure, it is redundant, just for clarity
            new_x(2,trials_NOGO,:) = squeeze(x(idxEvent,trials_NOGO,:));
            new_x(2,trials_GO,:)   = 0; % Sure, it is redundant, just for clarity 
        else
            timeEvent_GO   = zeros(N_trials,N_time);
            timeEvent_NOGO = zeros(N_trials,N_time); 
            for k=1:N_trials,
                aux = squeeze(find (x(idxEvent,k,:)),1,'first');
                if ismember(k,trials_GO)
                    minDur = max (aux+duration-1,N_time);
                    timeEvent_GO(k,aux:minDur)   = 1;
                    timeEvent_NOGO(k,aux:minDur) = 0;
                elseif ismember(k,trials_NOGO)
                    minDur = max (aux+duration-1,N_time);
                    timeEvent_NOGO(k,aux:minDur)   = 1;
                    timeEvent_GO(k,aux:minDur)     = 0;
                end
            end
            new_x(1,:,:)  = timeEvent_GO;
            new_x(2,:,:)  = timeEvent_NOGO;            
        end
    else
        if duration == -1
            %Exact copy of the varEvent but with 1 for Go, -1 for NoGo 
            new_x(trials_GO,:)   = squeeze(x(idxEvent,trials_GO,:));
            new_x(trials_NOGO,:) = -squeeze(x(idxEvent,trials_NOGO,:));
        else
            timeEvent  = zeros(N_trials,N_time);    
            for k=1:N_trials,
                aux = squeeze(find (x(idxEvent,k,:)),1,'first');
                if ismember(k,trials_GO)
                    minDur = max (aux+duration-1,N_time);
                    timeEvent(k,aux:minDur)   = 1;
                elseif ismember(k,trials_NOGO)
                    minDur = max (aux+duration-1,N_time);
                    timeEvent(k,aux:minDur)   = -11;
                end
            end
            new_x  = timeEvent;         
        end
    end
end
