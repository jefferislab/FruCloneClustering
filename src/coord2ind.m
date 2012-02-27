function indices = coord2ind(img,voxdims,coords,aperm,origin)
% COORD2IND - find 1D indices into 3D image of XYZ coordinates
% 
% Input:
% img     - 3d img array (or size of img array)
% voxdims - vector of 3 voxel dimensions (width, height, depth, dx,dy,dz)
% coords  - 3xN XYZ triples 
% aperm   - permutation order for axes
% origin  - 3D position/centre of first voxel in image in physical coords
%
% indices  - 1D indices into the image array
% 
% NB can handle axis permutations but NOT flips
%
% Origin
% ------
% This is equivalent to the space origin definition of the nrrd format and
% identifies the location (for voxels as point objects - aka node) or the
% centre (for voxels considered to have physical extent = voxdims aka
% cell). See http://teem.sourceforge.net/nrrd/format.html#spaceorigin for
% details.
%
% See also IND2COORD, SUB2IND, SIZE

imsize=size(img);

if length(imsize) == 2 && imsize(1)==1
	imsize=img;
end

if length(imsize) ~= 3
	error('coord2ind only handles 3d data');
end

if isempty(coords)
    warning('Coords are empty. Return empty indices');
    indices = [];
    return
end

if nargin>=4
	if any(aperm)<0
		error('coord2indhandles axis permutations but NOT flips');
	end
else
	aperm = [1 2 3];
end

if nargin<5
    origin = [0;0;0];
end

pixcoords=zeros(size(coords));

% first convert from physical coords to pixel coords,
% adding one to everything since spatial coord origin will be at (0,0,0)
% whereas index origin will [1 1 1] since matlab is 1-indexed
pixcoords(1,:)=round((coords(1,:)-origin(1))/voxdims(1))+1;
pixcoords(2,:)=round((coords(2,:)-origin(2))/voxdims(2))+1;
pixcoords(3,:)=round((coords(3,:)-origin(3))/voxdims(3))+1;

for i = 1:3
	% make sure no points are out of range
	% nb imsize needs to be matched with permuted axis order
	pixcoords(aperm(i),:)=min(imsize(i),max(1,pixcoords(aperm(i),:)));
end


% convert to 1d indices
indices=sub2ind(imsize,pixcoords(aperm(1),:),...
	pixcoords(aperm(2),:),pixcoords(aperm(3),:));
