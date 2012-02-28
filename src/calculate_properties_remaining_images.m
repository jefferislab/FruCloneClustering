function calculate_properties_remaining_images(input_dir,output_dir,mask_file,alpha_thresh,...
    cell_bodies_image_dir,clone_list)
%
% find local tangent vector and dimensionality (alpha)
%
% Function takes reformatted images and calculates: principal eigenvector (tangent vector) from momemnt
% of inertia, cell body locations, and dots that fall within the image mask. Outputs are saved to a
% structure p in [image_name]_properties.mat
%
% INPUTS:
%   input_dir:              Directory containing the *_reformated.mat files
%   output_dir:             Directory in which the *_properties.mat files will be saved to.
%   mask_file:              PIC file used to mask points.
%   alpha_thresh:           Cutoff used to determine whether a projection is sufficiently one-dimensional.
%                           Points above this threshold are saved to p.gamma2. Alpha=1  -> one-dimenionsal,
%                           Alpha=0 -> isotropic). Default is 0.25
%   cell_bodies_image_dir:  Directory containing PIC files of the orignal images after reformating.
%   image_list:             Cell array containing names of image files to be processed. If an image list is not
%                           speicifed, the default will be to take all the *_reformated.mat files in the input
%                           directory.
%
% Uses: extract_properties

if ~exist('clone_list','var') || isempty(clone_list)
    % remove the suffix after the '-',and then only use unique images
    reformated_data = dir(fullfile(input_dir,'*_reformated.mat'));
    image_list = {};
    count = 0;
    for i = 1:length(reformated_data)
        if reformated_data(i).bytes > 9999 % something is wrong if size is less than 9999 bytes
            count = count + 1;
            image_list{count} = jlab_filestem(reformated_data(i).name,'-');
        end
    end
    image_list = unique(image_list);% remove duplicates  
else
    image_list = get_image_list(clone_list);
end

% If cell_bodies_image_dir has been specified, then calculate and save cell
% body locations.
if ~exist('cell_bodies_image_dir','var') || isempty(cell_bodies_image_dir)
    find_cell_bodies_flag = 0;   
else   
    find_cell_bodies_flag = 1;   
end


if ~exist('alpha_thresh','var') || isempty(alpha_thresh)
    alpha_thresh = 0.25;
end

if exist('mask_file','var') || isempty(mask_file)
    mask_temp = readpic(mask_file);
    mask = zeros(384,384,173);
    for i=1:173
        % readpic now works with [2 1 3] axis orientation
        mask(:,:,i)=mask_temp(:,:,i)';
    end
    maskiminfo = impicinfo(mask_file);
else
    % Set default to empty array
    mask = [];
end

% Make sure that dirs have a trailing slash
input_dir = fullfile(input_dir, filesep);
output_dir = fullfile(output_dir, filesep);
cell_bodies_image_dir = fullfile(cell_bodies_image_dir, filesep);

if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

for i=1:length(image_list)
    % This contains just the image stem (everything up to first underscore)
    % e.g. SAKW12-1_reformated.mat => SAKW12-1
    current_image=jlab_filestem(image_list{i});
    % Check if we should process current image
    if matching_images(current_image,...
            [output_dir,'*_properties.mat'])
        % skip this image since corresponding output exists
        continue
    elseif ~makelock([output_dir,current_image,'-in_progress.mat'])
        % Looks like someone else is working on this image
        continue
    end   
    
    %%%% Main code
    p=[];
    p.projection_coords=[];
    p.alpha=[];
    p.projection_tangent_vector=[];
    
    % Added '-' before '*', NYM May 22, 2011 
    [match_exists, first_matching_image] = matching_images(current_image, [input_dir,'*reformated.mat'],'-');  
    if ~match_exists
        disp([current_image,' is not in the input directory']);
		continue
    else
        indata=load([input_dir, first_matching_image]);
    end 
    
    for j=1:length(indata.dotsReformated) % iterate over each group of connected dots
        y = indata.dotsReformated{j}; % dots in reference coord space
        
        if ~isempty(y)
            [dummy num_dots]=size(y);
            
            if num_dots > 20
                p.projection_coords=[p.projection_coords single(y)];
                [alpha,vect]=extract_properties(y');
                p.alpha=[p.alpha alpha];
                p.projection_tangent_vector=[p.projection_tangent_vector vect];
            end
        end
    end
      
   
    
    % This part removes any points outside of a mask that covers the
    % central brain and all of its tracts. It also removes points with
    % p.alpha (eigenvalue 1 - eigenvalue 2)/sum(eigenvalues)) below 0.25
    % (by default) that are not part of a linear structure.

    if ~isempty(mask)
        indices=coord2ind(mask,maskiminfo.Delta,p.projection_coords); 
        if isempty(alpha_thresh)
            maskInd = mask(indices)>0;
        else
            maskInd = mask(indices)>0 & p.alpha>alpha_thresh;
        end 
        p.projection_coords=p.projection_coords(:,maskInd);
        p.projection_tangent_vector=p.projection_tangent_vector(:,maskInd);  
        p.alpha=p.alpha(:,maskInd);  
    elseif ~isempty(alpha_thresh)
        p.projection_coords=p.projection_coords(:,p.alpha>alpha_thresh);
        p.projection_tangent_vector=p.projection_tangent_vector(:,p.alpha>alpha_thresh);
        p.alpha=p.alpha(:,p.alpha>alpha_thresh);
    end   

     % Check to make sure coordinates do exist
    if isempty(p.projection_coords)
        warning([current_image,' does not contain any coordinates. Will not save properties file'])
    else

        %%%% This part downsamples the resolution to 1 um
        disp(current_image)
        coords=max(1,round(p.projection_coords));
        m1=max(coords(1,:));
        m2=max(coords(2,:));
        m3=max(coords(3,:));
        ind = sub2ind([m1 m2 m3],coords(1,:),coords(2,:),coords(3,:));
        [dummy included_ind] = unique(ind);
        p.projection_coords = p.projection_coords(:,included_ind);
        p.projection_tangent_vector = p.projection_tangent_vector(:, included_ind);
        p.alpha = p.alpha(:, included_ind);

        % Will find the location of putative cell bodies if a directory with
        % the reformated images was specified
        if find_cell_bodies_flag
    %        h = dir([cell_bodies_image_dir,current_image,'*.pic']);
            [match_exists, first_matching_image] = matching_images(current_image, [cell_bodies_image_dir,'*.pic'],'-');
            if ~match_exists
                p.cell_body_coords = [];
            else
                p.cell_body_coords = find_cell_body_locations([cell_bodies_image_dir, first_matching_image]);
            end
        else
            p.cell_body_coords = [];
        end
        save([output_dir,current_image,'_properties.mat'],'p','-v7');
    end
    removelock([output_dir,current_image,'-in_progress.mat']);
end
end
