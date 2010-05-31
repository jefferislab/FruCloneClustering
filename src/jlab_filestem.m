function [filestem] = jlab_filestem( filename, sep )
% JLAB_FILESTEM return stem of image name up to first underscore (by default)
%   sep = '_' by default
%
% returns the original filename if sep does not occur

if nargin<2
	sep = '_';
end

n=find(filename == sep , 1, 'first');
if isempty(n)
	filestem = filename;
else
	filestem = filename(1:n-1);
end

end
