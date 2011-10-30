%RUN_ALL_PROCESSES Preprocessing to turn images into all x all dot database
%
% This script runs all the preprocessing steps required to turn a folder of
% source images into a set of processed dots that are cross-matched
% against dots in all other images.

% Ensure that both MatlabSupport code including ReadPIC, GLTreePro ...
% are in your matlab path

% In addition you need to ensure that any external command line tools are
% either have symbolic links in the root_dir/bin directory or are present
% in your _SYSTEM_ path. You can do this with the addsystempath command
% e.g. addsystempath('/Applications/IGSRegistrationTools/bin/');

%%%% Input and output directories
Set_Masse_Dirs

%%%%%
% Check path

addsystempath('/usr/local/bin');
% Loading set of images to use, grouped by clone
load(fullfile(root_dir,'data','clone_list.mat'));

%%% Steps of the image data processing procedure

% Preprocess images to emphasise tubular structures
preprocess_images_dir(original_images_dir, processed_images_dir);

% Threshold and segment images - output is a mat file including voxdims
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction - output are points in external coords
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Reformat onto template brain
% 1. reformat dimension reduced coordinates onto template brain 
reformat_remaining_images(dimension_reduced_dir,reformatted_dir,registration_dir,processed_images_dir,gregxform_dir);
% 2. reformat original images onto template image in order to extract 
%    candidate cell body locations (high intensity regions outside neuropil)
reformatx_remaining_images(original_images_dir,reformated_images_dir,registration_dir,...
	fullfile(mask_dir,'IS2_nym_mask_invert.nrrd'));

%% Can use some sample preprocessed image data to feed in at this point
% These are located in 2 directories:
% .mat files in dimension_reduced_dir
% .pic (or .nrrd FIXME) files in reformated_images_dir
% Nick to select ~ 20 samples for each dir and upload
% Greg to put these somewhere permanent and add docs

% Calculate tangent vectors etc, note that this uses the neuropil mask file
% 
calculate_properties_remaining_images(dimension_reduced_dir,properties_dir,...
	fullfile(mask_dir,'IS2_nym_mask.pic'),.25,reformated_images_dir,clone_list);

% Find and store which dots in each image match dots in other images
find_matched_dots_remaining_images_GLTree(properties_dir,matched_dots_dir, [1 1], clone_list);
