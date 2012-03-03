function process_images_for_dimension_reduction(input_dir,output_dir)
%
% Dimension reduction on all dots
%
% This function takes segmented images, which contain sets of 3D
% coordinates and are saved as *tubed.mat files, and tries to fit them onto
% tubular structures using a diemnsion reduction algorithm.
%
% INPUTS:
%   input_dir:  Directory in which the segemented image files (saved as *tubed.mat) are located.
%   output_dir: Directory in which the dimension-reduced files (*dimensionReduced.mat) will be saved to.
%
% Uses: image_dimension_reduction.m



% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

segmented_data=dir(fullfile(input_dir,'*_tubed.mat'));

for i=randperm(segmented_data))

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
	 [input_dir,segmented_data(i).name]); 
	save([output_dir,current_image,'_dimension_reduced.mat'],...
	 'dots','Prob','lam','dim','coords','-v7');
	removelock([output_dir,current_image,'-in_progress.mat']);

end

end
