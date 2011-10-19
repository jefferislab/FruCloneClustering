%RUN_ALL_PROCESSES.m

% This script runs all the preprocessing steps required to turn a folder of
% source images into a set of processed dots that are cross-matched
% against dots in all other images.

addpath('C:\Users\Public\scripts')
%%%% Input and output directories

root_dir = 'F:\FruCloneClustering\';

original_images_dir=fullfile(root_dir,'Source_images');

processed_images_dir=fullfile(root_dir,'Processed_images');

segmented_images_dir=fullfile(root_dir,'Segmented_images');

dimension_reduced_dir=fullfile(root_dir,'dimension_reduced_images');

reformated_points_dir=fullfile(root_dir,'Reformated_points');

reformated_images_dir=fullfile(root_dir,'Reformated_images');

%properties_dir=[root_dir 'imageProperties/'];

Chiang_data_dir=['/Volumes/jefferis/projects/flycircuit/ChiangReg/reformatted/'];

mask_image = 'F:\FruCloneClustering\Masks\IS2_nym_mask.pic';

%%%%%


properties_dir='E:\imageProcessing\image_properties_June6\';
matched_dots_dir='E:\imageProcessing\matched_points_June6\';
%
% Loading set of images to use
load([root_dir,'final_image_list_feb_18.mat']);

%%%% Data directories

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
registration_dir='/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/Registration/warp/';

% Directory containing R script for initial image processing
RCode_dir='/Volumes/JData/JPeople/Greg/FruMARCMCode/';

% Directory of gregxform unix command to refomat the coordinates
gregxform_dir='/Applications/IGSRegistrationTools/bin/';

%%% Steps of the image data processing procedure


command=['cat ',RCode_dir,'scripts/SebaStartup.R ',' convert_nrrd_to_pic.R | R --vanilla --args ',...
	reformated_images_dir];
system(command);

% Anisotropic filtering and tubing using Fiji
command=['cat ',RCode_dir,'scripts/SebaStartup.R ',' PreprocessImages.R | R --vanilla --args ',...
	original_images_dir,' ',processed_images_dir];
system(command);

% Threshold and segment images - output is a mat file including voxdims
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction - output are points in external coords
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Reformat onto template brain
reformat_remaining_images(dimension_reduced_dir,reformatted_dir,registration_dir,processed_images_dir,gregxform_dir);
reformatx_remaining_images(original_images_dir,reformated_images_dir,registration_dir,templateimage)

% Calculate tangent vectors etc
calculate_properties_remaining_images(dimension_reduced_dir,properties_dir,mask_image,.25,reformated_images_dir,image_list);

% Find and store which dots in each image match dots in other images
find_matched_dots_remaining_images_GLTree(properties_dir,matched_dots_dir, [1 1], image_list); 


