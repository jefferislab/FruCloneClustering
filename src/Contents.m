% Scripts
%   RUN_ALL_PROCESSES                         - Preprocessing to turn images into all x all dot database
%   Download_Sample_Data                      - Script to download sample data from web
%   Easy_Compile_Masse                        - Script to compile the support functions required for the source code.
%   Easy_Install_Masse                        - Script for simple installation of Matlab code and dependencies 
%   Load_Classifier                           - Script to load the default fruitless clone classifier
%   Set_Masse_Dirs                            - Set up the standard directory locations used in later processing stages
%
% Top Level Functions (directory processing)
%   preprocess_images_dir                     - Preprocess PIC images with ImageJ/Fiji & anisofilter (emphasise neurites)
%   rescale_images                            - Rescale and preprocess input images to emphasise neurites
%   segment_remaining_images                  - Find connected regions with pixels > threshold
%   process_images_for_dimension_reduction    - Dimension reduction on all dots
%   reformat_remaining_images                 - Transform points into template brain space
%   reformatx_remaining_images                - Transform (cell body) images into template brain space
%   calculate_properties_remaining_images     - find local tangent vector and dimensionality (alpha)
%   find_matched_dots_remaining_images_GLTree - Find matching dots for all pairwise combinations of property files in directory
%
%   collect_clone_information                 - Make cell containing name of each clone and brains containing each clone
%   build_MI_structure                        - Calculate mutual information for one clone type
%   create_image_classifier                   - Make a classifier structure for all clones
%   score_all_clones_cross_validated          - Create clone classifer (and score using leave one out cross validation)
%
% Top Level Functions (single image)
%   classify_image                            - Determine whether an image contains a clone of interest
%   classify_image_not_in_database            - This function is used to determine whether an image contains a clone of
%   compare_image_to_all_clones               - 
%   find_cell_body_locations                  - Find cell body locations based on reformatted (and masked) image
%   score_trace                               - Score single trace 
%   score_trace_wrapper                       - Find best clones matching a tracing from a classifier
%
%
% Dot Processing Functions
%   compareImages_ANNTree                     - Compare point sets derived from images by position and vector similarity
%   compareImages_GLTree                      - Find matching dots in two images (for cell bodies or projections)
%   extract_properties                        - Calculate tangent vector and local moment of inertia
%   get_trace_properties                      - Find dot properties from SWC neuron or plain 3d coord file
%   image_dimension_reduction                 - (Further) enhance tubular structure in dot collections
%   reformat_coords                           - Transform a 3 x N matrix using a CMTK registration file
% 
% Image Processing Support Functions
%   ann_meta_wrapper                          - Meta wrapper for different methods of calling ANN nearest neighbours
%   coord2ind                                 - Find 1D indices into 3D image of XYZ coordinates
%   ind2coord                                 - find XYZ coords corresponding to 1D indices into a 3D image
%   load3dtif                                 - Loads 3d tif by loading each 2d plane into a 3d matrix
%   read3dimage                               - Reads a pic or nrrd, returning both data and voxel dimensions
%
% Utility Functions
%   addsystempath                             - adds a given path to the current system path
%   check_newer_input                         - Check if any input files are newer than outfile
%   jlab_filestem                             - return stem of image name up to first underscore (by default)
%   makelock                                  - Make a lockfile (NFS safe in principle)
%   matching_images                           - see if any file has same image stem as filename
%   get_image_list                            - Find list of images to process from clone_list cell array
%   removelock                                - Remove lockfile
%   plot_jai_trace                            - Plot points from a trace_file (or from coords array)
%   write_points_amira                        - Write 3D points to a text file that can be opened in Amira
%
% Unknown / Deprecated Function
%   detectProb                                - TODO:Nick explain what this does! Or remove it!
%   convert_jai_results_to_cachero            - TODO - Nick describe this or put it somewhere else/remove it
%   create_image_classifier_cross_validated   - TODO - Decide whether to keep this since now marked out of date
%   detectProb_2D                             - TODO - Nick explain what this does.
%   score_trace_w_cell_bodies                 - TODO - Nick determine if this is still useful
%   remove_isolated_points                    - Function was used to clean up isolated points that mask left behind. 
%
% Dependencies:
% 1. Matlab code from 
%   git://github.com/jefferis/MatlabSupport.git
% 
% this includes 
% a) ANN Nearest Neighbour library as wrapped for Matlab or Octave
%   Original is from http://www.wisdom.weizmann.ac.il/~bagon
%   see also http://octave-swig.sourceforge.net/octave-ann.html
% 
% b) GLTreePro for finding nearest neighbour points
% 
% c) ReadPic Matlab code - to read Biorad format images
% d) nrrdio Matlab code - to read Nrrd format images
% e) teem compiled (mex) package to read nrrd images
% 
%
% The full image processing pipeline has a number of external dependencies:
%
% 2. CMTK Image Registration and Analysis
%	http://www.nitrc.org/projects/cmtk/
%
% 3. Fiji
% http://fiji.sc
% 
% 4. Neura/anisofilter for additional emphasis of tubular structures in
% images.
% See http://www.neura.org/ (includes original source code)
% and https://github.com/jefferis/neura
% (updated source with fixes for macosx and recent linux by Greg)
% 
%
% MATLAB INSTALL:
% see https://github.com/jefferis/FruCloneClustering
% essential dependencies can be installed/compiled as part of this install
% process
% 
% External DEPENDENCIES:
% CMTK should be installed into a location like /usr/local/bin (on unix)
% that is in the system path OR failing that, installed into
% FruCloneClustering/bin
% 
% Fiji: it may be necessary to put the fiji command in the system path.
% 
% Neura/anisofilter should be in the path or placed in FruCloneClustering/bin
