function [trace_coords, trace_vect] = get_trace_properties(trace_file)
%GET_TRACE_PROPERTIES Find dot properties from SWC neuron or plain 3d coord file
% 
% Ignores a header containing a mix of blank lines or comments beginning with #
% Reads in swc files with 8 cols where 3-5 are XYZ coords
% Reads in csv (comma separated) files with 3 cols and no column names
% otherwise reads in first 3 columns of white space separated numbers

fid = fopen(trace_file);
if fid < 0
	error(['Unable to open tracing:' trace_file]);
end
% Find the number of header lines in the swc format file
headerLines=0;
while 1
	l=fgetl(fid);
	if l<0
		break % end of file
	end
	if ~ ( strncmp(l,'#',1) || strcmp(l,'') )
		break % neither comment nor blank line
	end
	headerLines=headerLines+1;
end
fclose(fid);

[pathstr, name, ext] = fileparts(trace_file);
switch lower(ext)
	case '.swc'
		formatspec = '%*s %*s %f %f %f %*s %*s';
	case '.csv'
		formatspec = '%f,%f,%f';
	otherwise
		formatspec = '%f %f %f';
end

fid = fopen(trace_file);
rawcoords = textscan(fid,formatspec,...
	'TreatAsEmpty',{'NA','na'},'HeaderLines',headerLines);

trace_coords = [rawcoords{1},rawcoords{2},rawcoords{3}]';
% remove any NaNs
goodcols=sum(isfinite(trace_coords))==3;
trace_coords=trace_coords(:,goodcols);

if length(trace_coords(1,:))==0
	trace_vect=[];
	return
end

% Calculate the tangent vectors corresponding to trace
[~, trace_vect]=extract_properties(trace_coords');

end
