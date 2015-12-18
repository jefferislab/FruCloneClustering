#!/usr/bin/env bash

# Script to pre-process a set of images 

# Request at least 4G of memory /node (with the dimension reduction in mind,
# otherwise shouldn't be that memory intensive)
#$ -l h_vmem=4G

octave <<EOF
Set_Masse_Dirs('221')

% Preprocess images to emphasise tubular structures
% Downsample by [4 4 2] (and do anisotropic diffusion filtering by default)
% rescale_images( input_dir, output_dir, suffix, scale, anisofilter, tube, fiji, fijiopts)
rescale_images(original_images_dir, processed_images_dir,'-tubed.nrrd',1./[2 2 1],[],true,[],'--mem 2048M');

% Threshold and segment images - output is a mat file including voxdims
segment_remaining_images(processed_images_dir,segmented_images_dir)

% Dimension reduction - output are points in external coords
process_images_for_dimension_reduction(segmented_images_dir,dimension_reduced_dir);

% Reformat onto template brain
% 1. reformat dimension reduced coordinates onto template brain 
reformat_remaining_images(dimension_reduced_dir,reformated_points_dir,registration_dir,processed_images_dir);
EOF
