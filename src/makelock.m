function [ success ] = makelock( lockfile, lockmsg, createDirectories )
%MAKELOCK Make a lockfile (NFS safe in principle)
%  Make a lockfile containing lockmsg
%  lockmsg defaults of matlab's tempname preceded (on unix) by hostname
%  Create director(y|ies) containing lockfile if required
%  Returns 1 for success, 0 otherwise
%
%  See also REMOVELOCK

if(nargin<3)
	createDirectories = true;
end
if(nargin<2)
	if isunix
		% get this hostname as additional protection against
		% collision of unique identifier
		[~, hostname]=system('hostname');
		% note strcat removes trailing whitespace from hostname
		lockmsg = strcat(hostname,tempname);
	else
		lockmsg = tempname;
	end
end

[lockdir,~,~] = fileparts(lockfile);
if ~isempty(lockdir)
	if ~exist(lockdir,'dir')
		if createDirectories
			% nb mkdir is recursive
			mkdir(lockdir);
		end
	else
		error('Lock directory for lockfile %s does not exist',lockfile);
	end
end

% default
success = false;

if exist(lockfile,'file')
	% somebody else already made the lockfile
else
	% write a (unique) message to lockfile
	fid = fopen(lockfile,'a');
	fprintf(fid,'%s\n',lockmsg);
	fclose(fid);
	% now read file back in
	fid = fopen(lockfile,'r');
	firstLine = fgetl(fid);
	% check if the first line contains our (unique) message
	if strcmp(firstLine,lockmsg)
		success = true;
	else
		% neck and neck race which we lost by a head
		% Multiple processes wrote to same lockfile and we weren't first
	end
end
end