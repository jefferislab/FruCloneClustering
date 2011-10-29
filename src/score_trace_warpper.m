function score_trace_warpper(clone_classifier, n)

trace_dir = 'C:\Users\Nicolas Masse\Projects\Tracing\IS2\';
trace_files = dir([trace_dir '*.swc']);

current_trace_file = [trace_dir trace_files(n).name];

[clone_score, trace_coords] = score_trace(clone_classifier, current_trace_file, []);

[ranked_score ranked_clone] = sort(clone_score,'descend');

disp(['For trace ',trace_files(n).name,', the top 5 predicted clones are:'])
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