%
% S Peron Nov. 2009
%
% This generates a .mat file in the specified location that par_execute can run.
%
% par_execute will call funcname(subfunc, params).  Params is a structure that
%  is yours to constrain.  subfunc allows you to have a master method in funcname.m
%  that directs to specific subfunctions.
%
% par_generate will generate a .MAT file at mat_file_path, and par_execute will NOT
%  run the given instance until any files obtained by calling dir(dep_file_path) no
%  longer exist.  This last constraint allows you to set up dependencies if, for 
%  instance, certain processing steps depend on others and therefore the first must
%  be run before the others can go.
%
function retpath = par_generate(funcname, subfunc, params, mat_file_path, dep_file_path)
  save(mat_file_path, 'funcname', 'subfunc', 'params', 'dep_file_path');
	retpath = mat_file_path;

