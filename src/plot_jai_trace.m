function coords = plot_jai_trace(trace_file)
% Plot points from a trace_file (or from coords array)
% 
% coords = plot_jai_trace(trace_file)
%
% trace_file - character array of path to file or 3xN array of coordinates

if ischar(trace_file)
	coords = readpoints(trace_file);
else
	coords = trace_file;
	% swap Nx3 to 3xN if required
	siz = size(coords);
	if siz(1)~=3 && siz(2)==3
		warning('swapping input coords from Nx3 to 3xN')
		coords=coords';
	end
end
% TODO - check if we can/should set up plot axes to match neuronatomical
% defaults
plot3(coords(1,:),coords(1,:),coords(2,:),'r.');