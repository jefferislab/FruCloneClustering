function image_list = get_image_list(clone_list)
% given the cell array clone_list, which contains a list of images for each 
% clone, returns the list of images to process

image_list = [];

for i = 1:length(clone_list)
    image_list = [image_list clone_list{i}.images];
end
image_list = unique(image_list);