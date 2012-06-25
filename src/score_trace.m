function [clone_score, trace_coords] = score_trace(clone_classifier, trace_coords_file, cell_body_info)
% Score single trace 
%
% cell_body_info can either be a list of coordinates, or a filename. If a
% filename is given, then file must be opened, filtered and 
%
% See also score_trace_wrapper

if exist('cell_body_info','var') && ~isempty(cell_body_info)
    if ischar(cell_body_info) %if cell_body_info is a fielname, load and process file
        trace_cell_body_coords = get_trace_cell_body_coords(trace_image_file);
    elseif isnumeric(cell_body_info) % use the list of cooridnates if given
        trace_cell_body_coords = cell_body_info;
    else
        error('cell_body_info must either be the name of a .PIC file or a list of coordinates.')
    end
else
    trace_cell_body_coords = [];
end

% extract the coordinates and calculate the tangent vectors for the trace
[trace_coords, trace_vect] = get_trace_properties(trace_coords_file);

%%%%%% TESTING PURPOSES ONLY, USING FIRST DOT AS CELL BODY
trace_cell_body_coords = trace_coords(:,1);
trace_coords = trace_coords(:,2:end);
trace_vect = trace_vect(:,2:end);
%%%%%%

% score this trace against all clones in the classifier
clone_score = compare_trace_to_all_clones(trace_coords, trace_cell_body_coords, ...
    trace_vect, clone_classifier);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clone_score = compare_trace_to_all_clones(trace_coords, ...
    trace_cell_body_coords, trace_vect, clone_classifier)

num_clones = length(clone_classifier);
num_dots_in_trace = size(trace_coords,2);
num_dots_in_trace_cell_body = size(trace_cell_body_coords,2);
dot_score = zeros(num_clones, num_dots_in_trace);
dot_score_cell_body = zeros(num_clones, num_dots_in_trace_cell_body);
clone_score = zeros(1, num_clones);
MI_percentile_threshold = 950; % a threshold of 950 corresponds to a 95th percentile cutoff

for i = 1:num_clones % loop through all clones in classifier
    
    if isfield(clone_classifier{i},'projection_templates')
        num_template_images = length(clone_classifier{i}.projection_templates);
        template_score = zeros(num_template_images, num_dots_in_trace);
        template_score_cell_body = zeros(num_template_images, num_dots_in_trace_cell_body);
        
        for j = 1:num_template_images % loop through each image for each clone in classifier
            
            template_coords = double(clone_classifier{i}.projection_templates{j}.coords);
            template_vect = clone_classifier{i}.projection_templates{j}.vect;
            % compare trace coords and tangent vector to image those template
            ptrtree = BuildGLTree3D(template_coords);
            [matched_dots_in_trace, matched_dots_in_template] = compareImages_GLTree(trace_coords, ...
                template_coords, trace_vect, template_vect, ptrtree, 'projection');
            DeleteGLTree3D(ptrtree);
            
            % for each template, calculate the percentile score for each dot
            for k = 1:length(matched_dots_in_template)
                pct_ind = find(clone_classifier{i}.projection_templates{j}.MI(matched_dots_in_template(k)) > ...
                    clone_classifier{i}.MI_percentile_projection ,1 ,'last');
                if ~isempty(pct_ind)  % only score dot if its mutual information is above the percentile threshold
                    template_score(j, matched_dots_in_trace(k)) = max(0, (pct_ind - MI_percentile_threshold));
                end
            end
            
            if ~isempty(trace_cell_body_coords)
                template_coords_cell_body = double(clone_classifier{i}.cell_body_templates{j}.coords);
                % compare trace coords and tangent vector to image those template
                ptrtree = BuildGLTree3D(template_coords_cell_body);
                [matched_dots_in_trace_cell_body, matched_dots_in_template_cell_body] = compareImages_GLTree(trace_cell_body_coords, ...
                    template_coords_cell_body, [], [], ptrtree, 'cell_body');
                DeleteGLTree3D(ptrtree);
                
                % for each template, calculate the percentile score for each dot
                for k = 1:length(matched_dots_in_template_cell_body)
                    pct_ind = find(clone_classifier{i}.cell_body_templates{j}.MI(matched_dots_in_template_cell_body(k)) > ...
                        clone_classifier{i}.MI_percentile_cell_body ,1 ,'last');
                    if ~isempty(pct_ind) % only score dot if its mutual information is above the percentile threshold
                        template_score_cell_body(j, matched_dots_in_trace_cell_body(k)) =  max(0, (pct_ind - MI_percentile_threshold));
                    end
                end
            end
        end
        
        % for each clone, caculate the mean percentile score for each dot
        dot_score(i,:) = mean(template_score);
        if ~isempty(trace_cell_body_coords)
            dot_score_cell_body(i,:) = mean(template_score_cell_body);
        end
        
        
    end
end

clone_score = calculate_trace_score(clone_classifier, dot_score, dot_score_cell_body);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clone_score = calculate_trace_score(clone_classifier, dot_score, dot_score_cell_body)

num_clones = size(dot_score,1);
num_dots_trace = size(dot_score,2);
num_dots_trace_cell_body = size(dot_score_cell_body,2);

clone_score_with_cell_body = zeros(1, num_clones);
clone_score_without_cell_body = zeros(1, num_clones);

[ranked_clone_scores, ranked_clones] = sort(dot_score,'descend');
[ranked_clone_scores_cell_body, ranked_clones_cell_body] = sort(dot_score_cell_body,'descend');

for i = 1:num_clones
    if isfield(clone_classifier{i},'weight_projection')
        pct_top_scores = sum(ranked_clones(1,:) == i & ranked_clone_scores(1,:) > 0)/num_dots_trace;
        pct_top_scores_cell_body = sum(ranked_clones_cell_body(1,:) == i  & ranked_clone_scores_cell_body(1,:) > 0)...
            /num_dots_trace_cell_body;
        % calculate scores both with and without the cell bodies
         clone_score_with_cell_body(i) = clone_classifier{i}.weight_projection * pct_top_scores + ...
            clone_classifier{i}.weight_cell_body * pct_top_scores_cell_body;
         clone_score_without_cell_body(i) = pct_top_scores;   
    end
end

% For the final clone score, use the greater of the scores with and without
% the cell body, provided that the score without the cell body is at least
% greater than the median. 
median_score_without_cell_body = median(clone_score_without_cell_body);
clone_score_with_cell_body(clone_score_without_cell_body <= median_score_without_cell_body) = 0;
clone_score = max([clone_score_with_cell_body; clone_score_without_cell_body]);

% remopve NaNs form clone_score
clone_score(isnan(clone_score)) = 0;

end