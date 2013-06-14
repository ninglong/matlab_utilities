%% Search for variables that modulate Ca
clear x;
N_trials = size(aa.deltaKappa,1);
N_time   = size(aa.deltaKappa,2);
N_var_Cont        = 8;
N_var_Categorical = 3;
varNameContinuous  = {'deltaKappa', 'amplitude', 'setpoint', 'lick_rate','touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint'};
varNameCategorical = {'poleDown_GO', 'poleDown_NOGO','water_valve'};  
trials_GO   = find (aa.trial_type(:,1) == 1); 
trials_NOGO = find (aa.trial_type(:,1) == 0); 

poleDown_GO = zeros(N_trials,N_time);
poleDown_GO(trials_GO,:)   = aa.pole_in_reach(trials_GO,:);
poleDown_GO(trials_NOGO,:) = repmat(-aa.pole_in_reach(trials_GO(1),:),length(trials_NOGO),1);
poleDown_NOGO = zeros(N_trials,N_time);
poleDown_NOGO(trials_NOGO,:)   = aa.pole_in_reach(trials_NOGO,:);
poleDown_NOGO(trials_GO,:)     = repmat(-aa.pole_in_reach(trials_NOGO(1),:),length(trials_GO),1);


for i=1:N_var_Cont,
    aux  = getfield(aa, varNameContinuous{i});
    aux2 = reshape (aux(trials_GO,:)',length(trials_GO)*N_time,1); 
    x(:,i)=aux2; 
end
% aux2 = reshape (poleDown_GO',N_trials*N_time,1); 
% x(:,N_var_Cont+1)= aux2;
% aux2 = reshape (poleDown_NOGO',N_trials*N_time,1); 
% x(:,N_var_Cont+2)= aux2;
% aux2 = reshape (aa.water_valve',N_trials*N_time,1); 
% x(:,N_var_Cont+3)= aux2;

y = reshape(aa.ca{2}(trials_GO,:)',length(trials_GO)*N_time,1);

stats = regstats(y,x,'linear');
% SIGMA = stats.covb;
% dfe = stats.fstat.dfe;
% beta = stats.beta;
% c = zeros(N_var_Cont,1);
% H = eye(N_var_Cont);
% [p,F] = linhyptest(beta,SIGMA,c,dfe);
