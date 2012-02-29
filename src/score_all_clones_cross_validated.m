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
    
    disp(['Building classifier for clone ', clone_info_cell{i}.clone_name]);
    classifier{i}.clone_name = clone_info_cell{i}.clone_name;
    
    score_with_clone_cell_body = [];
    score_with_clone_projection = [];
    score_without_clone_cell_body = [];
    score_without_clone_projection = [];
    image_list_with_clone = clone_info_cell{i}.images;
    image_list_without_clone = setdiff(all_images, image_list_with_clone);
    
    % ensure there are at least two images containing the clone
    if length(image_list_with_clone) > 1
        
        [classifier{i}.s1, classifier{i}.MI_percentile_cell_body] = build_MI_structure(matchedPoints_dir, ...
            image_list_with_clone, image_list_without_clone,'cell_body');
        [classifier{i}.s2, classifier{i}.MI_percentile_projection] = build_MI_structure(matchedPoints_dir,image_list_with_clone,...
            image_list_without_clone,'projection');
        
        if cross_validate
            
            % Leave one out cross-validation
            parfor j=1:length(all_images); % change this to a regular for loop if not set up for parallel computing
                
                % remove current image from with and without clone lists
                [image_list_with_clone, image_list_without_clone, current_image_contains_clone] = get_image_list(clone_info_cell{i}, all_images, j);
                
                % build classifiers with current image removed
                s1 = build_MI_structure(matchedPoints_dir, image_list_with_clone, ...
                    image_list_without_clone, 'cell_body');
                s2 = build_MI_structure(matchedPoints_dir, image_list_with_clone, ...
                    image_list_without_clone, 'projection');
                
                
                % score the current image against the classifiers
                score_cell_body = classify_image(s1, all_images(j));
                score_projection = classify_image(s2, all_images(j));
                
                if current_image_contains_clone
                    score_with_clone_cell_body=[score_with_clone_cell_body score_cell_body'];
                    score_with_clone_projection=[score_with_clone_projection score_projection'];
                else
                    score_without_clone_cell_body=[score_without_clone_cell_body score_cell_body'];
                    score_without_clone_projection=[score_without_clone_projection score_projection'];
                end
            end
            
            % calculate ROC values from individual cell_bdoy and projection scores
            classifier{i} = calculate_individual_ARUC_scores(classifier{i}, score_without_clone_cell_body, score_without_clone_projection, ...
                score_with_clone_cell_body, score_with_clone_projection);
            
            %  calculate ROC value from combined cell_body and projection scores
            classifier{i} = calculate_combined_ARUC_scores(classifier{i});
            
            % removing matched dots matricies because of memory concerns
            classifier{i} = remove_match_subfileds(classifier{i});
            
        end
        classifier{i}
    end
end
save(calssifier_save_name,'classifier','-v7.3')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classifier = remove_match_subfileds(classifier)
% removing matched dots matricies because of memory concerns
for j = 1:length(classifier.s2)
    if ~isempty(classifier.s1{j})
        classifier.s1{j} = rmfield(classifier.s1{j},'match');
    end
    if ~isempty(classifier.s2{j})
        classifier.s2{j} = rmfield(classifier.s2{j},'match');
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  classifier = calculate_combined_ARUC_scores(classifier)
%  calculate score clones based on combined cell_body and projection scores

if classifier.ARUC_projection < 0.99 && classifier.ARUC_cell_body < 0.99
    weight_cell_body = (1 - cos(pi*(classifier.ARUC_cell_body - 0.5)));
    weight_projection = (1 - cos(pi*(classifier.ARUC_projection - 0.5)));
elseif classifier.ARUC_projection > 0.99 && classifier.ARUC_projection > classifier.ARUC_cell_body
    weight_cell_body = 0;
    weight_projection = 1;
elseif classifier.ARUC_cell_body > 0.99 && classifier.ARUC_cell_body > classifier.ARUC_projection
    weight_cell_body = 1;
    weight_projection = 0;
end

% ensure the projection and cell body weights add to one
total_weight = weight_cell_body + weight_projection;
weight_cell_body = weight_cell_body/total_weight;
weight_projection = weight_projection/total_weight;

null_scores_cell_body = classifier.null_score_distribution_cell_body(classifier.threshold_cell_body,:);
clone_scores_cell_body = classifier.clone_score_distribution_cell_body(classifier.threshold_cell_body,:);
null_score_projection = classifier.null_score_distribution_projection(classifier.threshold_projection,:);
clone_scores_projection = classifier.clone_score_distribution_projection(classifier.threshold_projection,:);

classifier.ARUC_combined = detectProb(weight_cell_body*null_scores_cell_body + weight_projection*null_score_projection, ...
    weight_cell_body*clone_scores_cell_body + weight_projection*clone_scores_projection);
classifier.weight_cell_body = weight_cell_body;
classifier.weight_projection = weight_projection;
end


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
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classifier = calculate_individual_ARUC_scores(classifier, score_without_clone_cell_body, score_without_clone_projection, ...
    score_with_clone_cell_body, score_with_clone_projection)
% calculate ROC values from cell_bdoy and projection scores


% Used num_thresholds number of thresholds to calculate scores.
% Will now calculate ROC values for all thresholds.
num_thresholds = size(score_with_clone_projection,1);
ARUC_cell_body = zeros(1,num_thresholds);
ARUC_projection = zeros(1,num_thresholds);
for j=1:num_thresholds
    ARUC_cell_body(j)=detectProb(score_without_clone_cell_body(j,:)',score_with_clone_cell_body(j,:)');
    ARUC_projection(j)=detectProb(score_without_clone_projection(j,:)',score_with_clone_projection(j,:)');
end

[~, t1]=max(ARUC_cell_body);
[~, t2]=max(ARUC_projection);

classifier.ARUC_cell_body = ARUC_cell_body(t1);
classifier.threshold_cell_body = t1;
classifier.null_score_distribution_cell_body = score_without_clone_cell_body;
classifier.clone_score_distribution_cell_body = score_with_clone_cell_body;

classifier.ARUC_projection = ARUC_projection(t2);
classifier.threshold_projection = t2;
classifier.null_score_distribution_projection = score_without_clone_projection;
classifier.clone_score_distribution_projection = score_with_clone_projection;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function all_images = get_all_images(clone_info_cell)
% get the list of all image files
all_images = [];
for i = 1:length(clone_info_cell)
    all_images = [all_images clone_info_cell{i}.images];
end
all_images = unique(all_images);

end