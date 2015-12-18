#!/usr/bin/env bash

# Script to pre-process a set of images 

octave <<EOF
Set_Masse_Dirs('884')

% Preprocess images to emphasise tubular structures
% Downsample by [8 8 4] (and do anisotropic diffusion filtering by default)
rescale_images(original_images_dir, processed_images_dir,'-tubed.nrrd',1./[8 8 4]);

% Threshold and segment images - output is a mat file including voxdims
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction - output are points in external coords
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Reformat onto template brain
% 1. reformat dimension reduced coordinates onto template brain 
reformat_remaining_images(dimension_reduced_dir,reformated_points_dir,registration_dir,processed_images_dir);
EOF
