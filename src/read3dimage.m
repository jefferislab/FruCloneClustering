function [ data, voxdims ] = read3dimage( file )
%read3dimage Reads a pic or nrrd, returning both data and voxel dimensions
% file - path to input image
%
% Returns:
% data    - array of image data in matlab's standard form
% voxdims - 1 x N array of voxel dimensions
%
% data is returned with x and y axes swapped so that it is compatible
% with matlab's imread/image/imshow functions
%
% Depends on ReadPIC and teem in MatlabSupport
% 
% See also readpic, impicinfo, nrrdLoad, imread


[pathstr, name, ext] = fileparts(file);

switch lower(ext)
	case {'.nrrd','.nhdr'}
		data=nrrdLoad(file);
		% reorder image data to look like something read in by matlab's imread
		data = permute(data, [2 1 3]);
		ni=nrrdLoadOrientation(file);
		% FIXME - check if there are any off-diagonal terms
		% TODO - actually implement off-diagonal terms!
		voxdims=diag(ni)';
	case '.pic'
		data=readpic(file);
		iminfo=impicinfo(file);
		voxdims=iminfo.Delta;
	otherwise
      disp('Unknown file format.')
end

end
