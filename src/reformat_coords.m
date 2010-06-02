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
	gregxform_dir = '/Applications/IGSRegistrationTools/bin/';
end

if ~exist(registration,'file')
	error('Unable to read registration %s',registration);
end

% TODO: Some new versions of gregxform were bailing out due to an assertion
% failure in GetJacobian:
% Assertion failed: ((f[dim] >= 0.0) && (f[dim] <= 1.0)), function GetJacobian, 
% file /Users/jefferis/dev/cmtk/core/libs/Base/cmtkSplineWarpXformJacobian.cxx, line 228.
% Abort trap
% Need to fix/discuss with Torsten Rohlfing

infile = [tempname '-input.txt'];
outfile = [tempname '-output.txt'];

fid = fopen(infile, 'w');
fwrite(fid, coords, 'float');
fclose(fid);

command=[gregxform_dir 'gregxform --binary -i ' infile ' -o ' outfile ' ' registration];
% TODO: Check when gregxform returns non-zero and suppress error messages
status = system(command);

if ~status
	fid = fopen(outfile, 'r');
	y=fread(fid, size(coords), '*float');
	fclose(fid);

	y=y(:,~isnan(y(1,:)));
end

delete(infile);
delete(outfile);

end
