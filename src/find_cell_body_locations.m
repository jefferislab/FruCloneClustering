function cell_body_coords = find_cell_body_locations(image_file, threshold)
% Find cell body locations based on reformatted (and masked) image
%
% Input:
% image_file - reformated (and masked) image
%
% Output:
% cell_body_coords - likely location of cell bodies (uint16)
% threshold        - fraction of maximum intensity (default = 0.5)
%
% (Masked) image data is convolved with a 2x2x2 3D boxcar filter and then
% thresholded up to some feaction of the maximum intensity. These
% coordinates are the likely locations of cell bodies.
% 
% The mask used to generate the input images is the inverse of the neuropil
% mask used for neuronal projections since cell bodies in flies (insects)
% are located in a cortex on the outside of the brain
%
% See also 
if nargin < 2
	threshold = 0.5;
end
f = ones(2,2,2,'uint8');

[x, voxdims] = read3dimage(image_file);

image_size = size(x);

y = convn(x,f,'same');

max_intensity = double(max(y(:)));

ind = find(y > threshold * max_intensity);

% note use of [2 1 3] axis permutation to cope with image data in matlab's
% standard form (help ind2coord for details)
coords = ind2coord(image_size,ind,voxdims,[2 1 3]);

% TODO - Nick, why uint16 here?
cell_body_coords = uint16(coords);
