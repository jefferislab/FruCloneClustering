% Scripts
%   RUN_ALL_PROCESSES                      - Preprocessing to turn images into all x all dot database
%
% Top Level Functions (directory processing)
%   segment_remaining_images               - Find connected regions with pixels > threshold
%   process_images_for_dimension_reduction - Dimension reduction on all dots
%   reformat_remaining_images              - Transform points into template brain space
%   calculate_properties_remaining_images  - find local tangent vector and dimensionality (alpha)

%
%   build_MI_structure                     - Calculate mutual information for one clone type
%   create_image_classifier                - Make a classifier structure for all clones
%   collect_clone_information              - Make cell containing name of each clone and brains containing each clone
%
% Top Level Functions (single image)
%   classify_image                         - Determine whether an image contains a clone of interest
%   classify_image_not_in_database         - This function is used to determine whether an image contains a clone of
%   compare_image_to_all_clones            - 

%
% Image Processing Functions
%   reformat_coords                        - Transform a 3 x N matrix using a CMTK registration file
%   compareImages_ANNTree                  - Compare point sets derived from images by position and vector similarity
%   compareImages_GLTree                   - Find matching dots in two images (for cell bodies or projections)
%   extract_properties                     - Calculate tangent vector and local moment of inertia
%   image_dimension_reduction              - (Further) enhance tubular structure in dot collections
% 
% Image Processing Support Functions
%   ann_meta_wrapper                       - Meta wrapper for different methods of calling ANN nearest neighbours
%   coord2ind                              - Find 1D indices into 3D image of XYZ coordinates
%   ind2coord                              - find XYZ coords corresponding to 1D indices into a 3D image
%   load3dtif                              - Loads 3d tif by loading each 2d plane into a 3d matrix
%
% Utility Functions
%   addsystempath                          - adds a given path to the current system path
%   check_newer_input                     - Check if any input files are newer than outfile
%   jlab_filestem                          - return stem of image name up to first underscore (by default)
%   makelock                               - Make a lockfile (NFS safe in principle)
%   matching_images                        - see if any file has same image stem as filename
%   removelock                             - Remove lockfile
%   writedots                              - write out dots to amiramesh files
%   write_points_amira                        - write_points_amira Write 3D points to a text file that can be opened in Amira
%
% Unknown Function
%   detectProb                             - TODO:Nick explain what this does! Or remove it!
%
% Dependencies:
% 1. Matlab code from 
%   git://github.com/jefferis/MatlabSupport.git
% this includes 
% a) ANN Nearest Neighbour library as wrapped for Matlab or Octave
%   Original is from http://www.wisdom.weizmann.ac.il/~bagon
%   see also http://octave-swig.sourceforge.net/octave-ann.html
% 
% b) ReadPic Matlab code - to read Biorad format images
% 
% c) GLTreePro for finding nearest neighbour points
%   compile with TestMexFiles3D.m
%
% 2. CMTK Image Registration and Analysis
%	http://www.nitrc.org/projects/cmtk/
%
% 3. Fiji
% http://fiji.sc
%
% MATLAB INSTALL:
% 1. Download or git clone MatlabSupport
% 2. Compile ann_wrapper using the ann_class_compile script (see
% ann_wrapper/README.txt in cse of trouble)
% 3. Add ann_wrapper and ReadPIC to your path
% 4. Adjust the paths in RUN_ALL_PROCESSES to match your setup
%   find_matched_dots_remaining_images_GLTree - Find matching dots for all pairwise combinations of property files in directory
