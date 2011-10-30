% Set_Masse_Dirs.m
% Quick script to set the location of directories that we will use elsewhere

src_dir = fileparts(which('RUN_ALL_PROCESSES'));

root_dir = fileparts(src_dir);

original_images_dir=fullfile(root_dir,'Source_images');

processed_images_dir=fullfile(root_dir,'Processed_images');

segmented_images_dir=fullfile(root_dir,'Segmented_images');

dimension_reduced_dir=fullfile(root_dir,'dimension_reduced_images');

reformated_points_dir=fullfile(root_dir,'Reformated_points');

reformated_images_dir=fullfile(root_dir,'Reformated_images');

properties_dir=[root_dir 'image_properties'];

mask_dir = fullfile(root_dir,'masks');

matched_dots_dir=fullfile(root_dir,'matched_points');

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
registration_dir=fullfile(root_dir,'Registration');

% Directory of gregxform unix command to refomat the coordinates
bin_dir=fullfile(root_dir,'bin');
