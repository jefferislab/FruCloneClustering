function indices = coord2ind(img,voxdims,coords)
% COORD2IND - find 1D indices into 3D image of XYZ coordinates
% 
% Input:
% img     - 3d img array
% voxdims - vector of 3 voxel dimensions (width, height, depth, dx,dy,dz)
% coords  - 3xN XYZ triples 
% 
% indices  - 1D indices into the image array
% 
% NB for the time being no reordering of image axes is done
%
% See also SUB2IND

imsize=size(img);
if(length(imsize)) ~= 3
	error('coords2ind only handles 3d data');
end
	
pixcoords=zeros(size(coords));

% first convert from physical coords to pixel coords
pixcoords(1,:)=round(coords(1,:)/voxdims(1));
pixcoords(2,:)=round(coords(2,:)/voxdims(2));
pixcoords(3,:)=round(coords(3,:)/voxdims(3));

% make sure no points are out of range
pixcoords(1,:)=min(imsize(1),max(1,pixcoords(1,:)));
pixcoords(2,:)=min(imsize(2),max(1,pixcoords(2,:)));
pixcoords(3,:)=min(imsize(3),max(1,pixcoords(3,:)));
% TODO: convert pixel coords to array subscripts by swapping X and Y axes
% and flipping Y?  Either the image or these coords must be flipped

% convert to 1d indices
indices=sub2ind(imsize,pixcoords(1,:),pixcoords(2,:),pixcoords(3,:));
end