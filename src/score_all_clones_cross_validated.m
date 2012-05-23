function score_all_clones_cross_validated(matchedPoints_dir, clone_info_cell, ...
    cross_validate, calssifier_save_name)
% Create clone classifer (and score using leave one out cross validation)
%
% INPUTS:
%     clone_info_cell: file name of the .tab file from FileMaker containing
%         the clone iforrmation
%         matchedPoints_dir: directory of the XXXmatchedPOints.mat files
%         calibrate = 0 or 1
% When secondary = 0, the mutual information per dot is calculated based on
% whether the image contains the clone or does not. When secondary = 1, the
% function computes a confusion matrix, and calculates a secondary mutual
% information per dot based on whether the image contained the clone or
% contained a possible confused clone.
% When calibrate = 1, the scripts determines the optimal mutual information
% level for each clone; might be a bit slow.


% If cross_validation = 1, will loop through all images. If cross_validation = 0, will
% loop trhough only those images containing the clone.

% Make sure that dirs have a trailing slash
matchedPoints_dir = fullfile(matchedPoints_dir, filesep);

classifier = cell(1,length(clone_info_cell));

disp('This code takes dadvantage of the parallel computing toolbox for Matlab. If you are not set up to use this toolbox,')
disp('search for the line "parfor j=1:length(all_images)" and change it to a regular for loop.');

% get the list of all image files
all_images = get_all_images(clone_info_cell);

for i=1:length(clone_info_cell)
    
    disp(['Building classifier for clone ', clone_info_cell{i}.cloneName]);
    classifier{i}.clone_name = clone_info_cell{i}.cloneName;
    
    score_with_clone_cell_body = [];
    score_with_clone_projection = [];
    score_without_clone_cell_body = [];
    score_without_clone_projection = [];
    image_list_with_clone = clone_info_cell{i}.images;
    image_list_without_clone = setdiff(all_images, image_list_with_clone);
    
    % ensure there are at least two images containing the clone
    if length(image_list_with_clone) > 1
        
        [classifier{i}.cell_body_templates, classifier{i}.MI_percentile_cell_body] = build_MI_structure(matchedPoints_dir, ...
            image_list_with_clone, image_list_without_clone,'cell_body');
        [classifier{i}.projection_templates, classifier{i}.MI_percentile_projection] = build_MI_structure(matchedPoints_dir,image_list_with_clone,...
            image_list_without_clone,'projection');
        
        if cross_validate
            
            % Leave one out cross-validation
            parfor j=1:length(all_images); % change this to a regular for loop if not set up for parallel computing
                
                % remove current image from with and without clone lists
                [image_list_with_clone, image_list_without_clone, current_image_contains_clone] = get_image_list(clone_info_cell{i}, all_images, j);
                u=min(length(image_list_with_clone),5);
                % build classifiers with current image removed
                cell_body_templates = build_MI_structure(matchedPoints_dir, image_list_with_clone(1:u), ...
                    image_list_without_clone, 'cell_body');
                projection_templates = build_MI_structure(matchedPoints_dir, image_list_with_clone(1:u), ...
                    image_list_without_clone, 'projection');
                    
                
                % score the current image against the classifiers
                score_cell_body = classify_image(cell_body_templates, all_images(j));
                score_projection = classify_image(projection_templates, all_images(j));
                
                if current_image_contains_clone
                    score_with_clone_cell_body=[score_with_clone_cell_body score_cell_body'];
                    score_with_clone_projection=[score_with_clone_projection score_projection'];
                else
                    score_without_clone_cell_body=[score_without_clone_cell_body score_cell_body'];
                    score_without_clone_projection=[score_without_clone_projection score_projection'];
                end
            end
            
            % calculate ROC values from individual cell_bdoy and projection scores
            classifier{i} = calculate_individual_AROC_scores(classifier{i}, score_without_clone_cell_body, score_without_clone_projection, ...
                score_with_clone_cell_body, score_with_clone_projection);
            
            %  calculate ROC value from combined cell_body and projection scores
            classifier{i} = calculate_combined_AROC_scores(classifier{i});
            
            % removing matched dots matricies because of memory concerns
            classifier{i} = remove_match_subfileds(classifier{i});
            
        end
        classifier{i}
    end
end
save(calssifier_save_name,'classifier','-v7.3')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classifier = remove_match_subfileds(classifier)
% removing matched dots matricies because of memory concerns
for j = 1:length(classifier.projection_templates)
    if ~isempty(classifier.cell_body_templates{j})
        classifier.cell_body_templates{j} = rmfield(classifier.cell_body_templates{j},'match');
    end
    if ~isempty(classifier.projection_templates{j})
        classifier.projection_templates{j} = rmfield(classifier.projection_templates{j},'match');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  classifier = calculate_combined_AROC_scores(classifier)
%  calculate score clones based on combined cell_body and projection scores

% we set the maximum AROC score to 0.9999 for numerical stability
% weights are subtracted by since we want a weight of 0 if the AROC score
% equals 0.5
weight_cell_body = 1/(1 - min(0.9999,classifier.AROC_cell_body)) - 2 ;
weight_projection = 1/(1 - min(0.9999,classifier.AROC_projection)) - 2;

% ensure the projection and cell body weights add to one
total_weight = weight_cell_body + weight_projection;
weight_cell_body = weight_cell_body/total_weight;
weight_projection = weight_projection/total_weight;

null_scores_cell_body = classifier.null_score_distribution_cell_body(classifier.threshold_cell_body,:);
clone_scores_cell_body = classifier.clone_score_distribution_cell_body(classifier.threshold_cell_body,:);
null_score_projection = classifier.null_score_distribution_projection(classifier.threshold_projection,:);
clone_scores_projection = classifier.clone_score_distribution_projection(classifier.threshold_projection,:);

classifier.AROC_combined = detectProb(weight_cell_body*null_scores_cell_body + weight_projection*null_score_projection, ...
    weight_cell_body*clone_scores_cell_body + weight_projection*clone_scores_projection);
classifier.weight_cell_body = weight_cell_body;
classifier.weight_projection = weight_projection;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [image_list_with_clone, image_list_without_clone, current_image_contains_clone] = get_image_list(clone_info_cell, all_images, j)
% remove current image from with and without clone lists

ind = find(strcmp(clone_info_cell.images, all_images{j}));
if ~isempty(ind)
    image_list_with_clone = clone_info_cell.images([1:ind-1 ind+1:end]);
    current_image_contains_clone = true;
else
    image_list_with_clone = clone_info_cell.images;
    current_image_contains_clone = false;
end
image_list_without_clone = setdiff(all_images([1:j-1 j+1:end]), image_list_with_clone);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classifier = calculate_individual_AROC_scores(classifier, score_without_clone_cell_body, score_without_clone_projection, ...
    score_with_clone_cell_body, score_with_clone_projection)
% calculate ROC values from cell_bdoy and projection scores


% Used num_thresholds number of thresholds to calculate scores.
% Will now calculate ROC values for all thresholds.
num_thresholds = size(score_with_clone_projection,1);
AROC_cell_body = zeros(1,num_thresholds);
AROC_projection = zeros(1,num_thresholds);
for j=1:num_thresholds
    AROC_cell_body(j)=detectProb(score_without_clone_cell_body(j,:)',score_with_clone_cell_body(j,:)');
    AROC_projection(j)=detectProb(score_without_clone_projection(j,:)',score_with_clone_projection(j,:)');
end

[~, t1]=max(AROC_cell_body);
[~, t2]=max(AROC_projection);

classifier.AROC_cell_body = AROC_cell_body(t1);
classifier.threshold_cell_body = t1;
classifier.null_score_distribution_cell_body = score_without_clone_cell_body;
classifier.clone_score_distribution_cell_body = score_with_clone_cell_body;

classifier.AROC_projection = AROC_projection(t2);
classifier.threshold_projection = t2;
classifier.null_score_distribution_projection = score_without_clone_projection;
classifier.clone_score_distribution_projection = score_with_clone_projection;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function all_images = get_all_images(clone_info_cell)
% get the list of all image files
% Find list of images to process from clone_list cell array
% 
% Given the cell array clone_list, which contains a list of images for each 
% clone, returns the list of images to process

all_images = [];

for i = 1:length(clone_info_cell)
    if isfield(clone_info_cell{i},'images')
        all_images = [all_images clone_info_cell{i}.images];
    elseif isfield(clone_info_cell{i},'image')
        all_images = [all_images clone_info_cell{i}.image];
    end
end

all_images = unique(all_images);