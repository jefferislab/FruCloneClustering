function y=reformat_coords(coords,registration,gregxform_dir)
%REFORMAT_COORDS transform a 3 x N matrix using a CMTK registration file
% Input:
% coords        - 3 x N matrix of XYZ coordinates in original image space
% registration  - path to CMTK registration file or .list dir containing it
% gregxform_dir - location of registration binary
%                 defaults to /Applications/IGSRegistration/bin/
% 
% Output: 3 x N matrix of points in the template registration space

if nargin<3
	gregxform_dir = '/Applications/IGSRegistration/bin/';
end

if ~exist(registration,'file')
	error('Unable to read registration %s',registration);
end

% change to N x 3 columnar organisation expected by gregxform
coords=coords';

% TODO: Some new versions of gregxform were bailing out due to an assertion
% failure in GetJacobian:
% Assertion failed: ((f[dim] >= 0.0) && (f[dim] <= 1.0)), function GetJacobian, 
% file /Users/jefferis/dev/cmtk/core/libs/Base/cmtkSplineWarpXformJacobian.cxx, line 228.
% Abort trap
% Need to fix/discuss with Torsten Rohlfing

infile = [tempname '-input.txt'];
outfile = [tempname '-output.txt'];

dlmwrite(infile,coords,'\t');

command=[gregxform_dir 'gregxform ' registration ' <' infile ' >' outfile];
system(command);

[f1 f2 f3]=textread(outfile,'%s %s %s');

y=zeros(length(f1),3);

for i=1:length(f1);

	if f1{i}(1)~='E'

		y(i,1)=str2double(f1{i});
		y(i,2)=str2double(f2{i});
		y(i,3)=str2double(f3{i});

	end

end

% restrict to points with valid X coord and transpose back to 3 x N
y=y(y(:,1)>0,:)';

delete(infile);
delete(outfile);

end

