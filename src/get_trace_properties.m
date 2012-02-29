function [trace_coords, trace_vect, trace_alpha] = get_trace_properties(trace_file)
% Find dot properties from SWC neuron or plain 3d coord file
%
% [trace_coords, trace_vect, trace_alpha] = GET_TRACE_PROPERTIES(trace_file)
% 
% Ignores a header containing a mix of blank lines or comments beginning with #
% Reads in swc files with 8 cols where 3-5 are XYZ coords
% Reads in csv (comma separated) files with 3 cols and no column names
% otherwise reads in first 3 columns of white space separated numbers
%
% See also extract_properties

trace_coords = readpoints(trace_file);

if length(trace_coords(1,:))==0
	trace_vect=[];
	return
end

% Calculate the tangent vectors corresponding to trace
[trace_alpha, trace_vect]=extract_properties(trace_coords');

end
