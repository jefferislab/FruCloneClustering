function [filestem] = jlab_filestem( filename, sep )
% JLAB_FILESTEM return stem of image name up to first underscore (by default)
%   sep = '_' by default
%
% returns the original filename if sep does not occur

% if nargin<2
% 	sep = '_';
% end
% if filename begins with know template brain then chop that
% off the front
% templates = ['JFRC2';'IS2';'FCWB'];

% [startInd,endInd] = regexp(filename, '(JFRC2|IS2|FCWB)');
% if (~isempty(endInd))
%     % + 2 to account for the underscore
%     filestem = filename(endInd+2:end);
% else
%     filestem = filename;
% end
% 
% 
% % now look for evidence of a channel name 
% % _0[0-9]_(warp|9dof|ght).*
% [startInd, endInd] = regexp(filename, '_0[0-9]_(warp|9dof|ght).*');

regexExp = 'JFRC';
filestem = regexp(filename, regexExp, 'match');
filestem = filestem{1};

% n=find(filename == sep , 1, 'first');
% if isempty(n)
%	filestem = filename;
% else
% 	filestem = filename(1:n-1);
% end

end
