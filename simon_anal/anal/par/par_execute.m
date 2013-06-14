%
% S Peron Nov. 2009
%
% Pass parpath - the path to a directory you want it to look for .mat files in.
% 
% Sample execution using screen, which in OS X or Linux makes it a background 
%  process.  My advice for Windows users is always the same: use a better OS.
%
% screen -d -m /usr/bin/matlab -nojvm -nosplash -r "par_execute('~/sci/anal/par/')"
%
% screen -d -m /Applications/MATLAB_R2007b/bin/matlab -nojvm -nosplash -r "par_execute('~/sci/anal/par/')"
%
% This looks to a given directory for .mat files, and assumes they have within them:
%  funcname - a function that should be in path (add below if needbe) and is called
%  subfunc - the first parameter passed to funcname; intended as a secondary subfunction
%            within funcname.m
%  params - structure passed as second parameter to funcname
%  
%  That is, calls eval([funcname '(' subfunc ',' params)]).
%
%  dep_file_path - a wildcard (or '') string that, if dir returns anything for, results
%                  in delay of execution
% 
% To terminate execution, 'touch' stop_par.m in the directory.  A lockfile for the
%  directory, lock.m, prevents inter-file conflict.  
%
function par_execute(parpath)
  % --- to add stuff to path, invoke addpath below - you should just have it in
	%     your permanent path!

  % --- paths
  lock_path = [parpath '/lock.m'];
  stop_path = [parpath '/stop_par.m'];

  disp(['Using path: ' parpath]);

  % Disable multithreading - you don't want interprocess toe stepping
%	maxNumCompThreads(1);  % by default I leave it on, as I find that it works slightly better 

  % If stop_par.m exists, this will terminate ...
  while(exist(stop_path, 'file') ~= 2)
		% lock the file -- OR WAIT
		while(exist(lock_path, 'file') == 2)
			disp(['Lock ' lock_path '  exists -- waiting 1 s']);
			pause(1);
		end
		fid = fopen(lock_path, 'w');
		fclose(fid);

		% Read the LAST .mat file - do this so that length of flist is the amount left
		%  in Q letting generate work
		flist = dir([parpath '/parfile_*.mat']);
    if (length(flist) > 0)
		  % go thru list and finda file with no dependencies to run
			file_found = 0;
		  for f=1:length(flist)
				my_file = flist(f).name;
				load([parpath '/' my_file]);

				% check dependencies
%  save(mat_file_path, 'funcname', 'subfunc', 'params', 'dep_file_path');
        if (length(dep_file_path) == 0) 
				  deps = [];
				else 
					deps = dir(dep_file_path);
				end
				% No dependencies? this is your file to run - tmp it to mark execution
				if (length(deps) == 0)
          file_found = 1;
					movefile([parpath '/' my_file],[parpath '/' my_file '.tmp']);
					break;
        end
		  end
    end

		% Unlock directory -- you now longer care
		delete(lock_path);

    % Execute ... if there are files and you found a valid one
    if (length(flist) > 0 & file_found)
      exec_str = [funcname '(''' subfunc '''' ',params);'];
      
	  	disp(['par_execute.m::Executing ' exec_str]);
      eval(exec_str);
      delete([parpath '/' my_file '.tmp']);
    else
      disp ('No file found; waiting 10 s');
      pause(10);
    end
  end
  disp(['par_execute.m::Exit signal received - ' stop_path ' exists. Terminating. (If you just started par_execute, delete the aforementioned file and restart par_execute)']);
	exit;
