function cell_body_coords = find_cell_body_locations(image_file)

% image_file is a PIC file of the reformated (and masked) image
% outputs a list of coordinates of the filtered image that are above
% threshold. These coordinates are the likely locations of cell bodies.

f = ones(2,2,2,'uint8');

x = readpic(image_file);

metadata = impicinfo(image_file);

voxdims = metadata.Delta;

image_size = size(x);

y = convn(x,f,'same');

max_intensity = double(max(max(max(y))));

ind = find(y > 0.5 * max_intensity);

coords = ind2coord(image_size,ind,voxdims,[1 2 3]);

cell_body_coords = uint16(coords);

