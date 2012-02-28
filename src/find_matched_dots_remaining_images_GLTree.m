function find_matched_dots_remaining_images_GLTree(input_dir,output_dir,neuronal_feature,clone_list)

% Find matching dots for all pairwise combinations of property files in directory
%
% This function compares pairs of images to determine what parts of the image match. If instructed to 
% compare cell bodies, the function will determine whether dots representing cell bodies in different 
% images are within a certain distance (specified in compareImages_GLTree) to be considered a match. 
% If instructed to compare neuronal projections, will determine whether dots representing projections 
% are withina certain distances and if their tangent vectors are within a certain angle (also specified 
% in compareImages_GLTree). Results are saved to [image_name]_matched_dots.mat files.
%

%
% INPUTS:
%   input_dir:          Directory in which the *properties.mat files are saved.
%   output_dir:         Directory in which the *matched_dots.mat fils will be saved to.
%   neuronal_feature:   a cell used to specify the brain structures to compare. Enter 'cell_body' to
%                       only compare cell bodies between brains. Enter 'projection' to only compare 
%                       neuronal projections between brains. Enter {'cell_body';'projection'} to compare 
%                       both. The deafault is 'projection'.
%   image_list:         Cell array containing names of image files to be processed. If an image list is not 
%                       speicifed, the default will be to take all the *properties.mat files in the input directory. 
%
% Uses: BuildGLTree3D, DeleteGLTree3D, jlab_filestem, matching_images, compareImages_GLTree


% Option to check existing saved matched dots files. Use if you've matched
% dots for an inital set of images, and have since added to the image list.
check_existing_saved_files = 0;

if ~exist('neuronal_feature','var') || isempty(neuronal_feature)
    neuronal_feature = 'projection'; 
end

if ~exist('clone_list','var') || isempty(clone_list)
    % remove the suffix after the '-',and then only use unique images
    properties_data = dir(fullfile(input_dir,'*_properties.mat'));
    image_list = {};
    count = 0;
    for i = 1:length(properties_data)
        if properties_data(i).bytes > 9999 % something is wrong if size is less than 9999 bytes
            count = count + 1;
            image_list{count} = jlab_filestem(properties_data(i).name,'-');
        end
    end
    image_list = unique(image_list);% remove duplicates  
else
    image_list = get_image_list(clone_list);
end

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

image_list = sort(image_list);

for i=1:length(image_list)
    
    current_image=jlab_filestem(image_list{i});
    lockfile=[output_dir,current_image,'-in_progress.lock'];
    current_image_file_loaded = 0; % a flag used to ensure we don't keep loading the same properties file
    % The final argument, '-', removes everything after '-' from the image
    % name. If there exists multiple versions of the image (ie, SAKU1-1,
    % SAKU1-2), we only want to use one of them.
    [match_exists, first_matching_image] = matching_images(current_image, [output_dir,'*_matched_dots.mat'],'_');
    
    if check_existing_saved_files | ~match_exists
        
        disp(['Calculating matched dots for image ',current_image])
        
        if makelock(lockfile)
            
            if match_exists
                load([output_dir first_matching_image],'matched_images','match_cell_body','match_projection','coords_cell_bodies','coords_projections');
            else
                match_cell_body=[];
                match_projection=[];
                matched_images={};                
            end
            
            for j=1:length(image_list)

                if ~any(strcmp(image_list{j},matched_images))
                    
                    if ~current_image_file_loaded
                        
                        current_image_file_loaded = 1;
                          % Added '_', NYM May 21, 2011
                        [second_image_match_exists, matching_image] = matching_images(current_image, [input_dir,'*properties.mat'],'_');
    
                        if ~second_image_match_exists
                            error([image_list{i},' was not found in the input directory']);
                        else        
                            load([input_dir,matching_image],'p');
                            
                            if any(strcmp(neuronal_feature,'cell_body')) 
                                coords_cell_bodies_1 = p.cell_body_coords;
                                vect_cell_bodies_1 = [];
                            end
                            
                            if any(strcmp(neuronal_feature,'projection')) 
                                coords_projections_1 = p.projection_coords;
                                vect_projections_1 = p.projection_tangent_vector;
                            end                      
                        end  
                    end
                    
                    % Added '-', NYM May 21, 2011
                    [second_image_match_exists, matching_image] = matching_images(image_list{j}, [input_dir,'*properties.mat'],'_');
                  
                    if ~second_image_match_exists
                        error([image_list{j},' was not found in the input directory']);
                    else
                        %h1 = dir([input_dir,first_matching_image]);
                        load([input_dir,matching_image],'p');
                        matched_images{end+1}=image_list{j};
                        
                        if any(strcmp(neuronal_feature,'cell_body'))  % compare cell bodies                  
                            coords_cell_bodies_2=p.cell_body_coords;
                            vect_cell_bodies_2=[];
                            
                            if size(coords_cell_bodies_1, 2) & size(coords_cell_bodies_2, 2) > 20 % something wrong with either image if it contains less than 20 points
                                y1 = zeros(size(coords_cell_bodies_1, 2),1,'uint8');
                                ptrtree = BuildGLTree3D(double(coords_cell_bodies_2));
                                [ind_union] = compareImages_GLTree(coords_cell_bodies_1,coords_cell_bodies_2,...
                                    vect_cell_bodies_1,vect_cell_bodies_2,ptrtree,'cell_body');
                                DeleteGLTree3D(ptrtree);
                                y1(ind_union) = 1;
                                match_cell_body = [match_cell_body y1];
                            else
                                y1 = zeros(n1_1,1,'uint8');
                                match_cell_body = [match_cell_body y1];
                            end
                        end
                        
                         if any(strcmp(neuronal_feature,'projection'))  % compare neural projections   
                            coords_projections_2 = p.projection_coords;
                            vect_projections_2 = p.projection_tangent_vector;
                            
                            if size(coords_projections_1,2) > 20 & size(coords_projections_2,2 ) > 20 % something wrong with either image if it contains less than 20 points
                                y1 = zeros(size(coords_projections_1,2),1,'uint8');
                                ptrtree = BuildGLTree3D(double(coords_projections_2));
                                [ind_union] = compareImages_GLTree(coords_projections_1,coords_projections_2,...
                                    vect_projections_1,vect_projections_2,ptrtree,'projection');
                                DeleteGLTree3D(ptrtree);
                                y1(ind_union) = 1;
                                match_projection = [match_projection y1];
                            else
                                y1 = zeros(n1_2,1,'uint8');
                                match_projection = [match_projection y1];
                            end
                        end
                    end                   
                end
            end
            
            if ~match_exists
                if any(strcmp(neuronal_feature,'cell_body'))
                    coords_cell_bodies = coords_cell_bodies_1;
                else
                    coords_cell_bodies = [];
                end
                
                if any(strcmp(neuronal_feature,'projection'))
                    coords_projections = coords_projections_1;
                    vect_projections = vect_projections_1;
                else
                    coords_projections = [];
                    vect_projections = [];
                end
            end
             
            save(fullfile(output_dir,[current_image,'_matched_dots.mat']),'match_cell_body','match_projection','coords_cell_bodies', ...
                'coords_projections','vect_projections','matched_images');
            % delete lockfile
            removelock(lockfile);
        end 
    end     
end