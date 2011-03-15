function y=reformat_coords(coords,registration,gregxform_dir,return_nans)
%REFORMAT_COORDS transform a 3 x N matrix using a CMTK registration file
% 
% Usage: y=reformat_coords(coords,registration,gregxform_dir,return_nans)
%
% Input:
% coords        - 3 x N matrix of XYZ coordinates in original image space
% registration  - path to CMTK registration file or .list dir containing it
% gregxform_dir - location of registration binary
%                 defaults to /Applications/IGSRegistration/bin/
% return_nans   - return matrix containg NaNs for points that could not be
%                 transformed (default false, ie omit these points)
%
% Output: 3 x N matrix of points in the template registration space

if nargin<3
	gregxform_dir = '/Applications/IGSRegistrationTools/bin/';
end

if nargin<4
	return_nans=false;
end

if ~exist(registration,'file') && ~exist(registration,'dir')
	error('Unable to read registration %s',registration);
end

% Note some binary versions of gregxform can fail with assertion failures:
% Assertion failed: ((f[dim] >= 0.0) && (f[dim] <= 1.0)), function GetJacobian, 
% file /Users/jefferis/dev/cmtk/core/libs/Base/cmtkSplineWarpXformJacobian.cxx, line 228.
% The assertion failure turns out to be harmless, but we shouldn't be
% seeing it anyway. It happens that the builds on macosx have been Debug 
% not Release builds for a while. Assertions are ignored in Release.

infile = [tempname '-input.txt'];
outfile = [tempname '-output.txt'];

fid = fopen(infile, 'w');
fwrite(fid, coords, 'float');
fclose(fid);

gregxform = fullfile(gregxform_dir,'gregxform');

if ~exist(gregxform,'file')
	error ('Unable to locate gregxform binary at %s',gregxform);
end

command=[ gregxform ' --binary -i ' infile ' -o ' outfile ' ' registration ];
% TODO: Check when gregxform returns non-zero and suppress error messages
if isunix
	command = [ command ' 2>&1' ];
end

[status result] = system(command);

if ~status
	fid = fopen(outfile, 'r');
	y=fread(fid, size(coords), '*float');
	fclose(fid);
	
	% omit points that could not be transformed
	if ~return_nans
		nans=isnan(y(1,:));
		num_nans=sum(nans);
		if num_nans>0
			warning('omitting %d / %d points that could not be transformed',...
				num_nans,length(coords));
			y=y(:,~nans);
		end
	end
else
	error('error in gregxform: %s',result);
end

delete(infile);
delete(outfile);

end
