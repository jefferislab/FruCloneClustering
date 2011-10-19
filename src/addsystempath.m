function newpath = addsystempath (pathtoadd, prepend)
% ADDSYSTEMPATH adds a given path to the current system path
%
% Usage: newpath = addsystempath (pathtoadd, [prepend])
%
% By default pathtoadd is appended to the system path. If the optional
% argument prepend is true then it is added to the beginning of the system
% path.  This can be used to override system binaries with user binaries.
%
% See also getenv, setenv

if nargin < 2
	prepend = false;
end

curpath = getenv('PATH');

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
