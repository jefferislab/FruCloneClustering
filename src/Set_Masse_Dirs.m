function Set_Masse_Dirs(subdir)
% SET_MASSE_DIRS   Set up the directories used in later processing stages
% 
% Usage: Set_Masse_Dirs(subdir)
%
% Optionally include a subdir for the data specific directories so that we
% can keep multiple runs with different parameters organised and separate
% 
% Created by Gregory Jefferis on 2012-03-03.
% Copyright (c)  MRC LMB. All rights reserved.

if nargin<1
	subdir='';
end

% Script to set standard location of directories used throughout project

src_dir = fileparts(which('RUN_ALL_PROCESSES'));

assignin('base','src_dir' , src_dir);

root_dir = fileparts(src_dir);
assignin('base','root_dir', root_dir);

assignin('base','original_images_dir',fullfile(root_dir,'Source_images',subdir));

assignin('base','processed_images_dir',fullfile(root_dir,'Processed_images',subdir));

assignin('base','segmented_images_dir',fullfile(root_dir,'Segmented_images',subdir));

assignin('base','dimension_reduced_dir',fullfile(root_dir,'dimension_reduced_images',subdir));

assignin('base','reformated_points_dir',fullfile(root_dir,'Reformated_points',subdir));

assignin('base','reformated_images_dir',fullfile(root_dir,'Reformated_images',subdir));

assignin('base','properties_dir',fullfile(root_dir,'image_properties',subdir));

mask_dir = fullfile(root_dir,'masks');

assignin('base','matched_dots_dir',fullfile(root_dir,'matched_points',subdir));

% Directory with the warp registration data (ie directory containing IS2_SAKW9-1_01_warp_m0g80c8e1e-1x26r4.list)
registration_dir=fullfile(root_dir,'Registration');

% Directory of gregxform unix command to refomat the coordinates
bin_dir=fullfile(root_dir,'bin');
end %  function