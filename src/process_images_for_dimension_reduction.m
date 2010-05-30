function process_images_for_dimension_reduction(input_dir,output_dir)
% PROCESS_IMAGES_FOR_DIMENSION_REDUCTION (input_dir,output_dir)
% this function takes segmented images ie point collections
% input files typically in Segmented_images directory end in *tubed.mat
% output to Dimension_reduced_images directory
%
% See also image_dimension_reduction

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

segmented_data=dir(fullfile(input_dir,'*_tubed.mat'));

for i=1:length(segmented_data)

	current_image=jlab_filestem(segmented_data(i).name);
	
	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*dimension_reduced.mat'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock([output_dir,current_image,'-in_progress.mat'])
		% skip since someone else is working on this image
		continue
	end
	
	% Perform dimension reduction
	[dots,dim,Prob,lam,coords]=image_dimension_reduction(...
	 fullfile(input_dir,segmented_data(i).name)); %#ok<*NASGU,ASGLU>
	save(fullfile(output_dir,[name,'_dimension_reduced.mat'])...
	 ,'dots','Prob','lam','dim','coords','-v7')
	removelock([output_dir,current_image,'-in_progress.mat']);

end

end
