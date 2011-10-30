function [s, MI_percentile] = build_MI_structure(matched_dots_dir, file_names_with_clone, ...
    file_names_without_clone, neuronal_feature)

%BUILD_MI_STRUCTURE Calculate mutual information for one clone type
%Given a list of file names given by the cell file_names_with_clone and file_names_without_clone,
% this function computes the mutual information between matched dots and to which list the image
%belong to. The general purpose is to feed in the file
%names that all contain the same clone, and those that don't, and this function will identify how
%informative each dots in each these files is of the clone.
%
% See also create_image_classifier


% set default neuronal_feature to 'projection'
if ~exist('neuronal_feature','var') || isempty(neuronal_feature)
    neuronal_feature = 'projection';
end

% get index of image files with and without clones with the list
% matched_images (located within *_matched_dots.mat files)
[images_with_clone_ind, images_without_clone_ind] = get_image_index(matched_dots_dir, ...
    file_names_with_clone, file_names_without_clone);

s = cell(1,length(images_with_clone_ind));
MI = [];

for i=1:length(images_with_clone_ind)
    
    matched_dots_file = dir([matched_dots_dir, file_names_with_clone{i},'_matched_dots.mat']); % chaned '*' to '_' NYM May 22,2011
    
    if ~isempty(matched_dots_file)
        
        if strcmp(neuronal_feature,'cell_body') 
            load([matched_dots_dir matched_dots_file(1).name],'coords_cell_bodies','match_cell_body','matched_images');
            match = match_cell_body;
            coords = coords_cell_bodies;
            vect=[];
        elseif strcmp(neuronal_feature,'projection') 
            load([matched_dots_dir matched_dots_file(1).name],'coords_projections','vect_projections','match_projection','matched_images');
            match = match_projection; 
            coords = coords_projections;
            vect = vect_projections;
        else
            error('neuronal_feature must be either "cell_body" or "projection"');
        end
    
    
    % match is a matrix in each *_matched_dots.mat file where each dot is
    % described by a row. A one in a column mean that dot in the image matched
    % another dot in the image specified by the column.
  
    score_with_clone = double(match(:,images_with_clone_ind([1:i-1 i+1:end])));% remove the comparaison between the image and itself
    score_without_clone = double(match(:,images_without_clone_ind));
    num_with_clone = length(images_with_clone_ind) - 1;
    num_without_clone = length(images_without_clone_ind);
    num_total = num_with_clone + num_without_clone;
    num_dots = size(score_with_clone,1); 
    
    % initalize a vector of mutual information values
    s{i}.MI=zeros(1, num_dots); 
    
    t11 = sum(score_with_clone,2)/num_total+10^(-20);
    t01 = num_with_clone/num_total-sum(score_with_clone,2)/num_total+10^(-20);
    t10 = sum(score_without_clone,2)/num_total+10^(-20);
    t00 = num_without_clone/num_total-sum(score_without_clone,2)/num_total+10^(-20);
    
    s{i}.MI(:) = s{i}.MI(:)+(t11.*log2(t11./((t11+t10).*(t11+t01))));
    s{i}.MI(:) = s{i}.MI(:)+(t10.*log2(t10./((t11+t10).*(t10+t00))));
    s{i}.MI(:) = s{i}.MI(:)+(t01.*log2(t01./((t00+t01).*(t11+t01))));
    s{i}.MI(:) = s{i}.MI(:)+(t00.*log2(t00./((t00+t01).*(t10+t00))));
    
    s{i}.image = file_names_with_clone{i};
    s{i}.match = uint8(match);
    % use single numeric type to save memory
    s{i}.coords = single(coords);
    s{i}.MI = single(s{i}.MI);
    s{i}.vect = vect;
    s{i}.matched_images = matched_images;
    MI = [MI s{i}.MI];
   
    clear match
    
    end

end

% calculate the percentile scores of the mutual information in 0.1%
% incremenets. These scores will be used for predicted clones froms traces.
MI_percentile = prctile(MI, [0:0.1:99.9]);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [image_with_clone_ind, image_without_clone_ind] = get_image_index(matched_dots_dir, ...
    file_names_with_clone, file_names_without_clone)

image_with_clone_ind = [];
image_without_clone_ind = [];

% Must first extract the list matched_images; load this from first
% matched_dots file
for i = 1:length(file_names_with_clone)
     matched_dots_file = dir([matched_dots_dir, file_names_with_clone{i},'_matched_dots.mat']);
     if ~isempty(matched_dots_file)
        load([matched_dots_dir matched_dots_file(1).name],'matched_images');
        break
     end
end

% Error out if cannot extract matched_images
if ~exist('matched_images','var') || isempty(matched_images)
    error('Could not load the matched_images list');
end

% Find index of images with clone within matched_images
for i = 1:length(file_names_with_clone)
    ind = find(strcmp(file_names_with_clone{i}, matched_images));
    image_with_clone_ind = [image_with_clone_ind ind];

end

% Find index of images without clone within matched_images
for i=1:length(file_names_without_clone)
    ind = find(strcmp(file_names_without_clone{i}, matched_images));
    image_without_clone_ind = [image_without_clone_ind ind];
end

end