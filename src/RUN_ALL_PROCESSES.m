%RUN_ALL_PROCESSES Preprocessing to turn images into all x all dot database
%
% This script runs all the preprocessing steps required to turn a folder of
% source images into a set of processed dots that are cross-matched
% against dots in all other images.

root_dir = '/lmb/home/jefferis/projects/FruCloneClustering/';

isOctave = exist('OCTAVE_VERSION','builtin') ~= 0;

if isOctave && strcmp(program_name,'RUN_ALL_PROCESSES.m')
    % We're running as a script
    % get argv and take first element as root_dir
    % NB if no argument besides scriptname is given then
    % first argument is scriptname so gaurd against that
    arg_list=argv();
    if length(arg_list) > 0 && ~strcmp(arg_list{1},program_name())
        root_dir = arg_list{1};
        disp(['Setting root_dir to ' root_dir]);
    end
%     for i=1:length(arg_list)
%         printf('%s ',arg_list{i});
%     end
%     printf('\n');
end

% make sure root_dir ends in slash
root_dir=fullfile(root_dir,filesep);

%%%% Input and output directories

original_images_dir=[root_dir 'images/'];

backsub_images_dir=[root_dir 'BackgroundSubtracted_images/'];

processed_images_dir=[root_dir 'Processed_images/'];

segmented_images_dir=[root_dir 'Segmented_images/'];

dimension_reduced_dir=[root_dir 'Dimension_reduced_images/'];

reformatted_dir=[root_dir 'Reformatted_images/'];

properties_dir=[root_dir 'Properties_images/'];

matched_points_dir=[root_dir 'Matched_images/'];

data_dir=[root_dir 'data/'];

%%%%%
% Check path

addsystempath('/usr/local/bin');

%%%% Data directories

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
registration_dir='/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/Registration/warp/';
% this should now work on hex; set up a symlink on JData
registration_dir=[root_dir 'Registration/warp/'];

% Directory containing R script for initial image processing
RCode_dir='/Volumes/JData/JPeople/Greg/FruMARCMCode/';

% Directory of gregxform unix command to refomat the coordinates
gregxform_dir='/Applications/IGSRegistrationTools/bin/';

%%% Steps of the image data processing procedure

% Anisotropic filtering and tubing using Fiji
rescale_images(backsub_images_dir,processed_images_dir,'-4xd-tubed');

% Threshold and segment images - output is a mat file including voxdims
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction - output are points in external coords
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Reformat onto template brain
reformat_remaining_images(dimension_reduced_dir,reformatted_dir,registration_dir,processed_images_dir,gregxform_dir);

% Calculate tangent vectors etc
calculate_properties_remaining_images(reformatted_dir,properties_dir,[data_dir 'IS2_nym_mask.PIC']);

% Find and store which dots in each image match dots in other images
find_matched_dots_remaining_images(properties_dir,matched_points_dir);
