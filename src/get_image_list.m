function image_list = get_image_list(clone_list)
% Find list of images to process from clone_list cell array
% 
% Given the cell array clone_list, which contains a list of images for each 
% clone, returns the list of images to process

image_list = [];

for i = 1:length(clone_list)
    if isfield(clone_list{i},'images')
        image_list = [image_list clone_list{i}.images];
    elseif isfield(clone_list{i},'image')
        image_list = [image_list clone_list{i}.image];
    end
end
image_list = unique(image_list);