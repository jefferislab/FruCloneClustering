function score_all_clones_cross_validated(matchedPoints_dir, clone_info_cell, ...
    cross_validate, calssifier_save_name)

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

% get the list of all image files
all_images = [];
for i = 1:length(clone_info_cell)
    all_images = [all_images clone_info_cell{i}.images];
end
all_images = unique(all_images);

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
        
        classifier{i}.s1 = build_MI_structure(matchedPoints_dir, ...
            image_list_with_clone, image_list_without_clone,'cell_body');
        classifier{i}.s2=build_MI_structure(matchedPoints_dir,image_list_with_clone,...
            image_list_without_clone,'projection');
        
        if cross_validate
            
            % Leave one out cross-validation
            for j=1:length(all_images);
                
                % remove current image from with and without clone lists
                ind = find(strcmp(clone_info_cell{i}.images, all_images{j}));
                if ~isempty(ind)
                    image_list_with_clone = clone_info_cell{i}.images([1:ind-1 ind+1:end]);
                    current_image_contains_clone = true;
                else
                    image_list_with_clone = clone_info_cell{i}.images;
                    current_image_contains_clone = false;
                end
                image_list_without_clone = setdiff(all_images([1:j-1 j+1:end]), image_list_with_clone);
                
                % build classifiers with current image removed
                s1=build_MI_structure(matchedPoints_dir, image_list_with_clone, ...
                    image_list_without_clone, 'cell_body');
                s2=build_MI_structure(matchedPoints_dir, image_list_with_clone, ...
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
            
            
            % Calculated 40 different scores by subracting MI with 40 different
            % thresholds before rectifying. Calcuating AROC scores for all 40.
            for j=1:40
                
                ARUC_cell_body(j)=detectProb(score_without_clone_cell_body(j,:)',score_with_clone_cell_body(j,:)');
                ARUC_projection(j)=detectProb(score_without_clone_projection(j,:)',score_with_clone_projection(j,:)');
                
            end
            
            [~, t1]=max(ARUC_cell_body);
            [~, t2]=max(ARUC_projection);
            
            classifier{i}.ARUC_cell_body = ARUC_cell_body(t1);
            classifier{i}.threshold_cell_body = t1;
            classifier{i}.null_score_distribution_cell_body = score_without_clone_cell_body;
            classifier{i}.clone_score_distribution_cell_body = score_with_clone_cell_body;
            
            classifier{i}.ARUC_projection = ARUC_projection(t2);
            classifier{i}.threshold_projection = t2;
            classifier{i}.null_score_distribution_projection = score_without_clone_projection;
            classifier{i}.clone_score_distribution_projection = score_with_clone_projection;
            %
            %
            %     % TODO: The below finds weights used to combine cell body and
            %     % projection scores. Should come up with a better way. Current methods
            %     % is not optimized for Jai's tarces (ie N0071.swc)
            %     % Nicolas Masse, Feb 22, 2011
            %
            %     for i = 1:length(x)
            %
            %         x1=x{i}.null_score_distribution_CB(x{i}.threshold_CB,:);x2=x{i}.clone_score_distribution_CB(x{i}.threshold_CB,:);
            %         y1=x{i}.null_score_distribution_P(x{i}.threshold_P,:);y2=x{i}.clone_score_distribution_P(x{i}.threshold_P,:);
            %
            %         dp = detectProb_2D([x1' y1'],[x2' y2']);
            %         % Adding a prior to increase weighting of projection scores which are usually more reliable.
            %         dp = dp + 0.005 * sind([1:360]);
            %
            %         [dummy ang] = max(dp);
            %
            %         x{i}.optimal_weighting = [cosd(ang) sind(ang)];
            %         x{i}.AROC_combined = dp(ang) - 0.005 * sind(ang);
            %
            %     end
            %
            %
            %
            %
            % removing matched dots matricies because of memory concerns
            for j = 1:length(classifier{i}.s2)
                if ~isempty(classifier{i}.s1{j})
                    classifier{i}.s1{j} = rmfield(classifier{i}.s1{j},'match');
                end
                if ~isempty(classifier{i}.s2{j})
                    classifier{i}.s2{j} = rmfield(classifier{i}.s2{j},'match');
                end
                
            end
            
        end
    end
    
    classifier{i}
end

save(calssifier_save_name,'classifier','-v7.3')
    