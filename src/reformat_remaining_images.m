function reformat_remaining_images(input_dir,output_dir,registration_dir,filtered_image_dir,gregxform_dir)
% 
% Transform points into template brain space
%
% This function takes the dimension reduced images and transforms them 
% onto the IS2 template
% the input files are XXX_dimensionReduced.mat and output files are XXX_reformated.mat.
% Must specify the directory for the registration data and the gregxform
% command 
%
% INPUTS:
%   input_dir:          Directory in which the tubed image files (saved as *tubed.PIC) are located.
%   output_dir:         Directory in which the segmented image files (saved as *tubed.mat) will be saved to.
%   registration_dir:   all voxel above this intensity level will form part of the
%               image. Voxels with intensity levels below this threshold will be
%               discarded.
%
% See also reformat_coords

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);
registration_dir = fullfile(registration_dir,filesep);
filtered_image_dir = fullfile(filtered_image_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

h=dir([input_dir,'*_dimension_reduced.mat']);

for i=1:length(h)

	% set up the file names we need
	current_image=jlab_filestem(h(i).name);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	registration=[registration_dir,'IS2_',current_image,...
		'_01_warp_m0g80c8e1e-1x26r4.list'];

	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*reformat*ed.mat']) % second * for spelling changes
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile)
		% skip since someone else is working on this image
		continue
	end

	disp(['Reformatting image ',h(i).name])
	
	% load input data
	load([input_dir,h(i).name])
	
	dotsReformatted=cell(size(dots));
	for j=1:length(dots)
		y=dots{j};
		if ~isempty(y)
			dotsReformatted{j}=reformat_coords(y,registration,gregxform_dir);
		end
	end

	save([output_dir,current_image,'_reformatted.mat'],'dots','dotsReformatted','-v7');
	removelock(lockfile);
end

end