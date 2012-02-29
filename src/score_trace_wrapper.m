function [template_coords, template_coords_cell_body] = score_trace_wrapper(trace_file, clone_classifier)
%SCORE_TRACE_WRAPPER Find best clones matching a tracing from a classifier
% 
% trace_file       - trace file in SWC format
%	clone_classifier - classifier structure built by score_all_clones_cross_validated
%	                   where missing, the default fruitless clone
%					           classifier is loaded using Load_Classifier script
% Returns:
% template_coords - position of informative dots from template images
% template_coords_cell_body - position of informative cell body regions 
%							  from template images
%
% Examples:
% Set_Masse_Dirs % to make sure that we can locate traces
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0065.swc'));
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0066.swc'));
%
% [bestmatchxyz, bestmatchxyz_cb] =
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0066.swc'));
% write_points_amira(fullfile(root_dir,'traces','66points.am'),bestmatchxyz)
% write_points_amira(fullfile(root_dir,'traces','66pointscb.am'),bestmatchxyz_cb)
%
% Specific clones:
% mAL-a / aDT-b / aDT2
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0065.swc'));
% mAL-PNs / aDT-a / aDT3
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0123.swc'));
% AL-b / aSP-l / aSP7
% score_trace_wrapper(fullfile(root_dir,'traces','Jai','N0729.swc'));
% 
% See also score_trace

if nargin<2
	clone_classifier=evalin('base', 'classifier','[]');
	if isempty(clone_classifier)
		Load_Classifier
		assignin('base', 'classifier', classifier);
		clone_classifier=evalin('base', 'classifier');
	end
end

[clone_score, trace_coords] = score_trace(clone_classifier, trace_file, []);

[ranked_score ranked_clone] = sort(clone_score,'descend');

disp(['For trace ',trace_file,', the top 5 predicted clones are:'])
for i = 1:5 
    disp([clone_classifier{ranked_clone(i)}.clone_name,' score = ',num2str(ranked_score(i))])
end

% plot the trace coords along with informative dots from the template images from the
% predicted clone
clone_rank = 1;

MI_threshold = clone_classifier{ranked_clone(clone_rank)}.MI_percentile_projection(950); % find the 95th percentile
MI_threshold_cell_body = clone_classifier{ranked_clone(clone_rank)}.MI_percentile_cell_body(950);
template_coords = [];
template_coords_cell_body = [];
for i = 1:length(clone_classifier{ranked_clone(clone_rank)}.s2)
    ind = find(clone_classifier{ranked_clone(clone_rank)}.s2{i}.MI > MI_threshold);
    template_coords = [template_coords clone_classifier{ranked_clone(clone_rank)}.s2{i}.coords(:,ind)];
    ind = find(clone_classifier{ranked_clone(clone_rank)}.s1{i}.MI > MI_threshold_cell_body);
    template_coords_cell_body = [template_coords_cell_body clone_classifier{ranked_clone(clone_rank)}.s1{i}.coords(:,ind)];
end
figure;
plot3(template_coords(1,:),template_coords(2,:),template_coords(3,:),'k.')
hold on
plot3(315.13 - template_coords(1,:),template_coords(2,:),template_coords(3,:),'k.')
plot3(template_coords_cell_body(1,:),template_coords_cell_body(2,:),template_coords_cell_body(3,:),'g.')
hold on
plot3(315.13 - template_coords_cell_body(1,:),template_coords_cell_body(2,:),template_coords_cell_body(3,:),'g.')

plot3(trace_coords(1,:),trace_coords(2,:),trace_coords(3,:),'r.');
end