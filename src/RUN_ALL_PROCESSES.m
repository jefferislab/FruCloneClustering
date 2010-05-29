%RUN_ALL_PROCESSESs.m


%%%% Input and output directories

original_images_dir='/Users/jefferis/NickTempFolder/Source_images/';

processed_images_dir='/Users/jefferis/NickTempFolder/Processed_images/';

segmented_images_dir='/Users/jefferis/NickTempFolder/Segmented_images/';

dimension_reduced_dir='/Users/jefferis/NickTempFolder/Dimension_reduced_images/';

reformated_dir='/Users/jefferis/NickTempFolder/Reformated_images/';

properties_dir='/Users/jefferis/NickTempFolder/Properties_images/';

matched_points_dir='/Users/jefferis/NickTempFolder/Matched_images/';

%%%%%



%%%% Data directories

registration_dir='/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/Registration/warp/';

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
root_dir='/Volumes/JData/JPeople/Greg/FruMARCMCode/';

% Directory of gregxform unix command to refomat the coordinates
gregxform_dir='/Applications/IGSRegistrationTools/bin/';

% Directory of ANN unix coomand
ann_dir='~/NickTempFolder/ann_1.1.2/bin/';
%%%%




%%% Different steps of the procedure

command=['cat ',root_dir,'scripts/SebaStartup.R ',root_dir,'nick/PreprocessImages.R | R --vanilla --args ',...
	original_images_dir,' ',processed_images_dir];

% Anisotropic filtering and tubing
system(command);

% Threshold and segment
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimenison reduction
%process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Refomat onto template brain
%reformat_remaining_images(dimension_reduced_dir,reformated_dir,registration_dir,gregxform_dir,processed_images_dir);

%calculate_properties_remaining_images(reformated_dir,properties_dir,ann_dir);

find_matched_dots_remaining_images(properties_dir,matched_points_dir);

