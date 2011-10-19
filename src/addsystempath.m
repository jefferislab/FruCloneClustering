function newpath = addsystempath (pathtoadd, prepend)
% ADDSYSTEMPATH adds a given path to the current system path
%
% Usage: newpath = addsystempath (pathtoadd, [prepend])
%
% By default pathtoadd is appended to the system path. If the optional
% argument prepend is true then it is added to the beginning of the system
% path.  This can be used to override system binaries with user binaries.
% When called without any parameters, the current system path is returned
%
% See also getenv, setenv

curpath = getenv('PATH');

if nargin < 1
	newpath = curpath;
	return
end
if nargin < 2
	prepend = false;
end

% FIXME - should really split system path into each separate component and
% then check for exact match
if isempty(strfind(curpath,pathtoadd))
	if prepend
		newpath = [pathtoadd ':' curpath];
	else
		newpath = [curpath ':' pathtoadd];
	end
	setenv('PATH', newpath);
else
	newpath=curpath;
end

end
