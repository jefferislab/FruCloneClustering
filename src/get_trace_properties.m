function [trace_coords, trace_vect] = get_trace_properties(trace_file)
%GET_TRACE_PROPERTIES Find dot properties from SWC or plain 3d coord file 
%   text files should be in white space separated columns
% GREG FIXME

% Assuming trrace_file is in .swc format. The x,y,z coordinates are located
% in the 3rd to 5th columns, and begin at line 7.
fid = fopen(trace_file);
coords_string = textscan(fid,'%s %s %s %s %s %s %s');
num_dots = length(coords_string{3})-6;
trace_coords = zeros(3, num_dots);
for i=7:num_dots + 6;
    if ~isempty(str2double(coords_string{3}{i}))
        trace_coords(1, i-6)=str2double(coords_string{3}{i});
        trace_coords(2, i-6)=str2double(coords_string{4}{i});
        trace_coords(3, i-6)=str2double(coords_string{5}{i});
    end
end

% Calculate the tangent vectors corresponding to trace
ptrtree=BuildGLTree3D(trace_coords);
[~, trace_vect]=extract_properties(trace_coords', ptrtree);
DeleteGLTree3D(ptrtree);

end