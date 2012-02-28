function [ data, voxdims, origin ] = read3dimage( file )
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
% Depends on ReadPIC and teem OR nrrdio in MatlabSupport
% teem is compiled and therefore faster but depends on a teem installation
% nrrdio is pure matlab (slower) and limited to 3d images
% (in raw or gzip encoding)
% 
% See also readpic, impicinfo, nrrdLoad, imread

[pathstr, name, ext] = fileparts(file);
origin=[0;0;0];
switch lower(ext)
	case {'.nrrd','.nhdr'}
		if exist('nrrdLoad','file')
			data=nrrdLoad(file);
			% reorder image data to look like something read in by matlab's imread
			data = permute(data, [2 1 3]);
			iminfo=imnrrdinfo(file);
		else
			% fall back to pure matlab code
			[data,iminfo]=readnrrd(file);
		end
	case '.pic'
		data=readpic(file);
		iminfo=impicinfo(file);
	otherwise
      disp('Unknown file format.')
	  return
end

voxdims=iminfo.Delta;
origin=iminfo.Origin;
end
