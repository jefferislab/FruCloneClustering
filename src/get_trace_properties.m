function [trace_coords, trace_vect] = get_trace_properties(trace_file)
%GET_TRACE_PROPERTIES Find dot properties from SWC or plain 3d coord file 
%   text files should be in white space separated columns
% GREG FIXME

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

fid = fopen(trace_file);		
rawcoords = textscan(fid,'%*s %*s %f %f %f %*s %*s',...
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
