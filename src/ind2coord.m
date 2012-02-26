function coords = ind2coord(img, IND, voxdims, axperm, origin)
% IND2COORD find XYZ coords corresponding to 1D indices into a 3D image
% 
% Usage: coords = ind2coord(siz, IND, voxdims, [axperm])
%
% Input:
% img     - 3d image array (or its size)
% IND     - 1D indices into the image array
% voxdims - vector of 3 voxel dimensions (width, height, depth, dx,dy,dz)
% axperm  - 3-vector containing reordering of axes, negatives imply flip
% origin  - 3D position/centre of first voxel in image in physical coords
%           
% coords  - 3xN XYZ triples 
%
% Origin
% ------
% This is equivalent to the space origin definition of the nrrd format and
% identifies the location (for voxels as point objects - aka node) or the
% centre (for voxels considered to have physical extent = voxdims aka
% cell). See http://teem.sourceforge.net/nrrd/format.html#spaceorigin for
% details.
%
% Permutations and Flips:
% -----------------------
% axperm = [1 2 3]  do nothing
% axperm = [-1 2 3] flip the points along the array's first axis
% axperm = [-2 1 3] flip 1st axis and then swap 1st and 2nd
%
% axperm = [1 -2 3] fixes coords from images loaded by older versions of readpic
% available from matlab central
%
% axperm = [2 1 3] fixes coords from images loaded by imread (eg tif)
% NB This also by Greg's fixed version of readpic
% (sha1 4d1208cc9c2ed4b46e9fcae0f94770a8134e3d65, Tue Jun 01 2010 04:08:34)
% which obeys the matlab convention for reading in image data blocks
% so that imshow and friends behave as expected.
%
% See also coord2ind, ind2sub, size

siz=size(img);

if length(siz) == 2 && siz(1)==1
	siz=img;
end

if length(siz) ~= 3
	error('ind2coord only handles 3d data');
end

if nargin < 5
	origin = [0; 0 ;0];
end

pixcoords=zeros(3,length(IND));

% first convert from indices to (1-indexed) pixel coords
[pixcoords(1,:) pixcoords(2,:) pixcoords(3,:)] = ind2sub(siz,IND);

% specify default axis permutation if required.
if(nargin<4)
	axperm = [1 2 3];
end

% flip and swap axes if required
for i=1:3
	% NB want (pix)coords to be 0-indexed whereas subscripts are 1-indexed,
	% so we subtract 1 implicitly or explixicitly below
	if(axperm(i)<0)
		% flip axis (NB siz(i)-1-pixcoords would give 1-indexed flip)
		pixcoords(i,:)=siz(i)-pixcoords(i,:);
	else
		pixcoords(i,:)=pixcoords(i,:)-1;
	end
end
pixcoords=pixcoords(abs(axperm),:);

% then convert from pixel coords to physical coords
coords(1,:)=pixcoords(1,:)*voxdims(1)+origin(1);
coords(2,:)=pixcoords(2,:)*voxdims(2)+origin(2);
coords(3,:)=pixcoords(3,:)*voxdims(3)+origin(3);

end
