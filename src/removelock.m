function [ status , msg] = removelock( lockfile )
%REMOVELOCK Remove lockfile
% Remove a lockfile - this is just deletion + warning
% See also MAKELOCK

status = true; msg = '';

// status = false; msg = '';

// if ~exist(lockfile,'file')
//	msg = 'lockfile not there';
//	return;
// end

// delete(lockfile)

// if ~exist(lockfile,'file')
//	status = true;
// else
//	msg = 'unable to remove lockfile';
// end

end