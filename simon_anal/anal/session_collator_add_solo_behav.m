%
% Populates the session structure with Solo data, returning new session structure.
%   Solo data is given primacy, meaning that even when intermingling, trials are
%   aligned *to the solo data* ; if no corresponding solo data, bye bye.
%
%    session = session_collator_add_solo_behav(old_session, behav_solo_path, map_vec)
%
%    old_session - previously obtained session structure; if [], make from scratch.  
%      this will be shifted around 
%    behav_solo_path - .MAT file with Solo data; if [], but map_vec is populated,
%      it will simply remap
%    map_vec - a mapping vector ; if [], assume correspondence; if not,
%      session.trial(map_vec(x)) :: solo_trial(x).  
%
function session = session_collator_add_solo_behav(old_session, behav_solo_path, map_vec)

  % --- Sanity check
	if (length(behav_solo_path) == 0 & length(map_vec) == 0)
	  disp('session_collator_add_behav:nothing to do; returning.');
		return;
	end

	% --- reshuffle? 
  if (length(behav_solo_path) == 0)
	end

	% --- populate straight up 
	if (length(behav_solo_path) > 0)
	  % default indexing vector
	  if (length(map_vec) == 0 & length(old_session)>0)
      map_vec = 1:length(old_session.trial);
		end

		% --- The nitty gritty 

		% 0) Some preliminaries
		session.trial_classes = [1 2 3 4];
		session.trial_class_str = {'Hit', 'Miss', 'FA', 'CR'};

		% 1) load the file
    solodat = load(behav_solo_path);
    nt = length(solodat.saved_history.RewardsSection_LastTrialEvents);

    % populate some stuff, based on assumption that same mouse, etc. was used throuhgout
    session.mouse_id_str = solodat.saved.SavingSection_MouseName;
    session.date_str = solodat.saved.SavingSection_SaveTime;

		% 2) cycle thru the trials
    for t=1:nt
      events = solodat.saved_history.RewardsSection_LastTrialEvents{t};
			es_idx = 1;

      % --- trial start
			tsti = find(events(:,1) == 40,1);
			if (length(tsti) == 0) 
			  tst = 0; 
			else
			  tst = events(tsti,3);
			end
			session.trial(t).start_time = tst*1000; % s -> ms
			session.trial(t).time_unit_id = 1; % ms

      % --- trial class
		  isgo = solodat.saved.SidesSection_previous_sides(t) == 114; % 114 charcode for 'r' (thus 1 = GO) , 108 'l' 
			iscorrect = solodat.saved.pole_detect_nxobj_hit_history(t); % 1 = correct ; 0 = not
			if (isgo & iscorrect) % HIT
			  session.trial(t).class = 1;
			elseif (isgo & iscorrect==0) % miss
			  session.trial(t).class = 2;
			elseif (isgo == 0 & iscorrect == 0) % FA
			  session.trial(t).class = 3;
			elseif (isgo == 0 & iscorrect) % CR
			  session.trial(t).class = 4;
			end

      % --- stimulus position
			session.trial(t).stimulus = solodat.saved_history.MotorsSection_motor_position{t};

			% --- misc parameters that are NOT time/event series -- water valve time,
			%    sampling period, extra timeout

			% --- beam break eventseries (1)
      session.trial(t).eventseries(es_idx).sourcefile = behav_solo_path;
			session.trial(t).eventseries(es_idx).type_id = 1; % 1: beam break
			session.trial(t).eventseries(es_idx).unique_id= -1;
			session.trial(t).eventseries(es_idx).id_str = 'Beam Breaks';
			session.trial(t).eventseries(es_idx).time_unit_id = 1; %ms

			tsti = find(events(:,2) == 1);
			if (length(tsti) == 0)
			  e_times = [];
			else
			  e_times = (events(tsti,3)-tst)*1000; % conver to ms
			end
			% strays -- nonzero
			val = find(e_times > 0);
			e_times = e_times(val);
			% strays -- doubles
			e_times = unique(e_times);
			session.trial(t).eventseries(es_idx).time = e_times; % THE DATA

			es_idx = es_idx + 1;

			% --- water valve open eventseries (2)
      session.trial(t).eventseries(es_idx).sourcefile = behav_solo_path;
			session.trial(t).eventseries(es_idx).type_id = 2; % 2: water valve
			session.trial(t).eventseries(es_idx).unique_id= -1;
			session.trial(t).eventseries(es_idx).id_str = 'Water Valve Open Time';
			session.trial(t).eventseries(es_idx).time_unit_id = 1; %ms

			tsti_s = find(events(:,1) == 43 & events(:,2) == 0, 1, 'first');
			tsti_e = find(events(:,1) == 43 & events(:,2) == 3, 1, 'first');
			if (length(tsti) == 0)
			  e_times = [];
			else
			  e_times = [(events(tsti_s,3)-tst) (events(tsti_e,3)-tst)]*1000; % conver to ms
			end
			% strays -- doubles
			e_times = unique(e_times,'rows');
			session.trial(t).eventseries(es_idx).time = e_times; % THE DATA

			es_idx = es_idx + 1;


      % --- drinking allowed time eventseries (4)
      session.trial(t).eventseries(es_idx).sourcefile = behav_solo_path;
			session.trial(t).eventseries(es_idx).type_id = 4; % 4: drinking allowed period
			session.trial(t).eventseries(es_idx).unique_id= -1;
			session.trial(t).eventseries(es_idx).id_str = 'Drinking Allowed Period';
			session.trial(t).eventseries(es_idx).time_unit_id = 1; %ms

			tsti_s = find(events(:,1) == 44 & events(:,2) == 0, 1, 'first');
			tsti_e = find(events(:,1) == 44 & events(:,2) == 3, 1, 'first');
			if (length(tsti) == 0)
			  e_times = [];
			else
			  e_times = [(events(tsti_s,3)-tst) (events(tsti_e,3)-tst)]*1000; % conver to ms
			end
			% strays -- doubles
			e_times = unique(e_times,'rows');
			session.trial(t).eventseries(es_idx).time = e_times; % THE DATA

			es_idx = es_idx + 1;

			% --- airpuff eventseries (2) -- THIS ONLY PICKS UP PROGRAM-INDUCED
			%     PUFFS, NOT MANUALLY TRIGGERED ONES
      session.trial(t).eventseries(es_idx).sourcefile = behav_solo_path;
			session.trial(t).eventseries(es_idx).type_id = 2; % airpuff
			session.trial(t).eventseries(es_idx).unique_id= -1;
			session.trial(t).eventseries(es_idx).id_str = 'Airpuffs';
			session.trial(t).eventseries(es_idx).time_unit_id = 1; %ms

			tsti_s = find(events(:,1) == 49 & events(:,2) == 0, 1, 'first');
			tsti_e = find(events(:,1) == 49 & events(:,2) == 3, 1, 'first');
			if (length(tsti) == 0)
			  e_times = [];
			else
			  e_times = [(events(tsti_s,3)-tst) (events(tsti_e,3)-tst)]*1000; % conver to ms
			end
			% strays -- doubles
			e_times = unique(e_times,'rows');
			session.trial(t).eventseries(es_idx).time = e_times; % THE DATA

			es_idx = es_idx + 1;
		end
    
	end

	% --- old_session handling -- combine them
	if (length(old_session) > 0)
	end

%
% Session structure:
%   session.mouse_id_str
%   session.date_str 
%   session.trial_classes                      vector of numbers containing classes of trials
%   session.trial_class_str                    cell array corresponding to classes with descriptiosn of classes
%   session.trial_class_color                  for plots where classes are color sorted, corresponds to trial_classes; 3xn
%   session.trial_class_symbol                 for plots where classes are symbol sorted, corresponds to trial_classes
%
%   session.trial().start_time                 start time -- absolute
%   session.trial().time_unit_id               time unit
%   session.trial().stimulus                   what is the stimulus? (pole position, e.g.)
%   session.trial().class                      trial class in terms of session.trial_classes
%
%   session.trial().eventseries().sourcefile    where raw data resides
%   session.trial().eventseries().time          corresponding to values, time vector; relative to eventseries start
%                                               if TWO column, col 1 = start col 2 = end 
%   session.trial().eventseries().time_unit_id  (1=ms, 2=s, 3=min, 4=h) unit for all time variables of this TS
%   session.trial().eventseries().type_id       1: beam brake ; 2*: water administration ; 3*: air puff ; 4*: reward period 
%                                               * implies 2xn matrix with both start and end time
%   session.trial().eventseries().unique_id     1,2,3: irrel
%   session.trial().eventseries().id_str
%
%   session.trial().timeseries().sourcefile    where raw data resides
%   session.trial().timeseries().values        values vector
%   session.trial().timeseries().time          corresponding to values, time vector; relative to timeseries start
%   session.trial().timeseries().start_time    absolute; -1 means same as trial start
%   session.trial().timeseries().dt            all in time_unit_id units
%   session.trial().timeseries().time_unit_id  (1=ms, 2=s, 3=min, 4=h) unit for all time variables of this TS
%   session.trial().timeseries().type_id       1: ROI raw fluo
%   session.trial().timeseries().unique_id     depends on type id; 1: uid = roi id
%   session.trial().timeseries().id_str
%  
