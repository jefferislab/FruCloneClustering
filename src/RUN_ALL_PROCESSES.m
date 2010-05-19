%RUN_ALL_PROCESSES.m

% This script runs all the preprocessing steps required to turn a folder of
% source images into a set of processed dots that are cross-matched
% against dots in all other images.

%%%% Input and output directories

root_dir = '/Users/jefferis/projects/Nick/FruCloneClustering/';

original_images_dir=[root_dir 'Source_images/'];

processed_images_dir=[root_dir 'Processed_images/'];

segmented_images_dir=[root_dir 'Segmented_images/'];

dimension_reduced_dir=[root_dir 'Dimension_reduced_images/'];

reformatted_dir=[root_dir 'Reformatted_images/'];

properties_dir=[root_dir 'Properties_images/'];

matched_points_dir=[root_dir 'Matched_images/'];

%%%%%


%%%% Data directories

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
registration_dir='/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/Registration/warp/';

% Directory containing R script for initial image processing
RCode_dir='/Volumes/JData/JPeople/Greg/FruMARCMCode/';

% Directory of gregxform unix command to refomat the coordinates
gregxform_dir='/Applications/IGSRegistrationTools/bin/';

% Directory of ANN unix coomand
% TODO - use of ann_sample command line tool is a bit ugly (and slow).
% replace with appropriate library - however not sure if there
% is something that we could use in both Matlab and Octave
ann_dir=[root_dir 'ann_1.1.2/bin/'];
%%%%


%%% Different steps of the procedure

% Anisotropic filtering and tubing using Fiji
command=['cat ',RCode_dir,'scripts/SebaStartup.R ',RCode_dir,'nick/PreprocessImages.R | R --vanilla --args ',...
	original_images_dir,' ',processed_images_dir];
system(command);

% Threshold and segment images
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Refomat onto template brain
reformat_remaining_images(dimension_reduced_dir,reformatted_dir,registration_dir,gregxform_dir,processed_images_dir);

calculate_properties_remaining_images(reformatted_dir,properties_dir,ann_dir);

find_matched_dots_remaining_images(properties_dir,matched_points_dir);

