function find_matched_dots_remaining_images_GLTree(input_dir,output_dir,neuronal_feature,image_list)

% find_matched_dots_remaining_images_GLTree.m
%
% This function compares paris of images to determine what parts of the image match. If instructed to 
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
%   neuronal_feature:   1 X 2 binary vector used to specify the brain structures to compare. If the first 
%                       element is 1, the function will compare cell bodies between brains. If the second 
%                       element is 1, the function will compare neuronal projections between brains.
%                       The deafault is [1 1]
%   image_list:         Cell array containing names of image files to be processed. If an image list is not 
%                       speicifed, the default will be to take all the *properties.mat files in the input directory. 
%
% Uses: BuildGLTree3D, DeleteGLTree3D, jlab_filestem, matching_images, compareImages_GLTree


% Option to check existing saved matched dots files. Use if you've matched
% dots for an inital set of images, and have since added to the image list.
check_existing_saved_files = 0;

if nargin < 3
    neuronal_feature = [1 1]; 
end

if nargin < 4
    %  remove the suffix after the '-', and then only use unique images
    properties_data=dir(fullfile(input_dir,'*_properties.mat'));
    image_list_temp={};
    for i=1:length(properties_data)
        image_list_temp{i}=jlab_filestem(properties.data(i).name,'-');
    end
    image_list_temp = sort(image_list_temp);
    image_list={};
    count=0;
    for i=1:length(image_list_temp)
        if i>1 & ~strcmp(image_list_temp{i-1},image_list_temp{i})
            count=count+1;
            image_list{count}=image_list_temp{i};
        end
    end
    
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
        
        if makelock(lockfile)
            
            if match_exists
                load([output_dir first_matching_image],'matched_images','match1','match2','coords_cell_bodies','coords_projections');
            else
                match1=[];
                match2=[];
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
                            
                            if neuronal_feature(1) == 1
                                coords1_1 = p.cell_body_coords;
                                vect1_1 = [];
                                [dummy n1_1] = size(coords1_1);  
                            end
                            
                            if neuronal_feature(2) == 1
                                coords1_2 = p.gamma3;
                                vect1_2 = p.vect3;
                                [dummy n1_2] = size(coords1_2);
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
                        
                        if neuronal_feature(1) == 1                  
                            coords2_1=p.cell_body_coords;
                            vect2_1=[];
                            [dummy n2_1]=size(coords2_1);
                            
                            if n1_1 > 100 & n2_1 > 100 % something wrong with either image if it contains less than 20 points
                                y1 = zeros(n1_1,1,'uint8');
                                ptrtree = BuildGLTree3D(double(coords2_1));
                                [ind_union] = compareImages_GLTree(coords1_2,coords2_2,vect1_2,vect2_2,ptrtree,2);
                                DeleteGLTree3D(ptrtree);
                                y1(ind_union) = 1;
                                match1 = [match1 y1];
                            else
                                y1 = zeros(n1_1,1,'uint8');
                                match1 = [match1 y1];
                            end
                        end
                        
                        if neuronal_feature(2) == 1
                            coords2_2 = p.gamma3;
                            vect2_2 = p.vect3;
                            [dummy n2_2] = size(coords2_2);
                            
                            if n1_2 > 20 & n2_2 > 20 % something wrong with either image if it contains less than 20 points
                                y1 = zeros(n1_2,1,'uint8');
                                ptrtree = BuildGLTree3D(double(coords2_2));
                                [ind_union] = compareImages_GLTree(coords1_2,coords2_2,vect1_2,vect2_2,ptrtree,2);
                                DeleteGLTree3D(ptrtree);
                                y1(ind_union) = 1;
                                match2 = [match2 y1];
                            else
                                y1 = zeros(n1_2,1,'uint8');
                                match2 = [match2 y1];
                            end
                        end
                    end                   
                end
            end
            
            if ~match_exists
                if neuronal_feature(1) == 1
                    coords_cell_bodies = coords1_1;
                else
                    coords_cell_bodies = [];
                end
                
                if neuronal_feature(2) == 1
                    coords_projections = coords1_2;
                    vect_projections = vect1_2;
                else
                    coords_projections = [];
                    vect_projections = [];
                end
            end
             
            save(fullfile(output_dir,[current_image,'_matched_dots.mat']),'match1','match2','coords_cell_bodies', ...
                'coords_projections','vect_projections','matched_images');
            % delete lockfile
            removelock(lockfile);
        end 
    end     
end

                
        
