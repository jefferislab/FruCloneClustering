function [ result ] = CheckForNewerInput( infiles, outfile, verbose)
% CHECKFORNEWERINPUT Check if any input files are newer than outfile
%
% Usage: CheckForNewerInput( infiles, outfile, [verbose])
% 
% infiles - cell string array or string containing 1 or more inputs
% outfile - string containing one output file
% verbose - print warning messages (default = false)

if nargin < 3
	verbose = false;
end

if ~iscell(infiles)
	input_file_cell=cell(1);
	input_file_cell{1} = infiles;
else
	input_file_cell=infiles;
end

result = false;

if ~all(cellfun(@exist,input_file_cell))
% 	missing input files
	if verbose, disp('Missing input files'), end;
elseif ~exist(outfile,'file')
	result = true;
	if verbose, disp('Output missing'), end;
else
	mtimeout=modification_time(outfile);
	mtimesin = cellfun(@modification_time,input_file_cell);
	if any(mtimesin)>mtimeout
		% some input file is newer
		result = true;
		if verbose, disp('Overwriting output as some inputs are newer'), end;
	else
		if verbose, disp('skipping as output newer than inputs'), end;
	end
end
end

function [mtime] = modification_time (input_file)
	mtime = NaN;
	listing = dir (input_file);
	if length(listing)>0
		mtime = listing.datenum(1);
	end
	mtime = listing.datenum;
end
