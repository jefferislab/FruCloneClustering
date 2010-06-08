function [ success ] = makelock( lockfile, lockmsg, verbose, createDirectories )
%MAKELOCK Make a lockfile (NFS safe in principle)
%  Make a lockfile containing lockmsg
%  lockmsg defaults to matlab's tempname preceded (on unix) by hostname
%  When running as a grid engine job defaults to hostname:JOB_ID
%  verbose = false by default
%  Create director(y|ies) containing lockfile if required
%  Returns 1 for success, 0 otherwise
%
%  See also REMOVELOCK

if nargin<3
    verbose=false;
end
if(nargin<4)
	createDirectories = true;
end

if nargin<2 || isempty(lockmsg)
	if isunix
		% get this hostname as additional protection against
		% collision of unique identifier
		[status, hostname]=system('hostname');
		% Gridengine sets this
		jobid=getenv('JOB_ID');
		if ~isempty(jobid)
			lockmsg=strcat(strtrim(hostname),':',jobid);
		else
			% note strtrim removes trailing whitespace from hostname
			lockmsg = strcat(strtrim(hostname),':',tempname);
		end

	else
		lockmsg = tempname;
	end
end

lockdir = fileparts(lockfile);
if ~isempty(lockdir)
	if ~exist(lockdir,'dir')
		if createDirectories
			% nb mkdir is recursive
            if verbose, disp(['making directory ' lockdir]),end
			mkdir(lockdir);
		else
			error('Lock directory for lockfile %s does not exist',lockfile);
		end
	end
end

% default
success = false;

if exist(lockfile,'file')
	% somebody else already made the lockfile
    if verbose, disp(['somebody already made the lockfile ' lockfile]),end
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
        if verbose, disp(['successfully made lockfile ' lockfile]),end
		success = true;
    else
        if verbose, disp(['someone else already made ' lockfile]),end
		% neck and neck race which we lost by a head
		% Multiple processes wrote to same lockfile and we weren't first
	end
end
end