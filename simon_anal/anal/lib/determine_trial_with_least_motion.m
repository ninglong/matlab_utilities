%
% Goes through a directory and all files matching img_path are assumed to be tif 
%  stacks.  They are checked for motion based on the sum of inter-trial difference
%  (therefore, luminance conditions for files are assumed to be the same).  The
%  trial with the minimum rating in this regard is set to the variable tgt_path,
%  and this variable is saved in the mat file mat_path.  imopt is passed to load_image.
%
% blank imopt and mat_path are allowed.
%
function [fd flist] = determine_trial_with_least_motion(img_path, mat_path, imopt)
  tgt_path = '';

  % loop thru files and compute diff
	flist = dir(img_path);
	fs_idx = find(img_path == filesep);
	root_path = img_path(1:fs_idx(length(fs_idx)));
  for f=1:length(flist)
	  fullname = [root_path flist(f).name]
		im = load_image(fullname, -1, imopt);
		fd_tmp = abs(diff(im,[],3));
    if (length(fd_tmp) == 0)  % single framers
		  fd(f) = 0;
		else % multi-framers
		  fd(f) = sum(sum(sum(fd_tmp)))/size(im,3);
		end
	end

	% the min? forget single-framers
	fd(find(fd == 0)) = max(fd);
  [irr idx] = min(fd);
  tgt_path = [root_path flist(idx).name];

  % and save
	if (length(mat_path) > 0)
		save (mat_path, 'tgt_path');
	end
