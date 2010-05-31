function reformat_remaining_images(input_dir,output_dir,registration_dir,filtered_image_dir,gregxform_dir)
% REFORMAT_REMAINING_IMAGES Transform points into template brain space
%
% Usage: reformat_remaining_images(input_dir,output_dir,registration_dir,...
%	filtered_image_dir,gregxform_dir)
% this script takes the dimension reduced images and transforms them 
% onto the IS2 template
% the input files are XXX_dimensionReduced.mat and output files are XXX_reformated.mat.
% Must specify the directory for the registration data, the gregxform
% command and the image directory which the resized (or filtered) PIC files

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

	disp(['Reformating image ',h(i).name])
	
	% Can we find a matching file to read image dimensions that
	% will be used to transform coords based on matlab's convention 
	% to match regular image processing convention
	% TODO make sure that all coords match image processing axes so that 
	% we don't have to bother with this
	[match_exists first_pic] = matching_images(current_image,...
		[filtered_image_dir current_image '*tubed.PIC']);
	if match_exists
		image_data = impicinfo([filtered_image_dir,first_pic]);
		if (image_data.Delta(1) ~= image_data.Delta(2))
			disp(['WARNING: X and Y dimension mismatch for image',h1(1).name]);
		end
	else
		warning('Skipping %s since no image file (and physical dimensions)',...
			current_image); 
		continue
	end
		
	% load input data
	load([input_dir,h(i).name])
	
	dotsReformatted=cell(size(dots));
	for j=1:length(dots)
		y=dots{j};
		if ~isempty(y)
			% FIXME: Is this axis flipping really correct?
			% And should it be happening here anyway?
			% In general flipping input image data may be preferable
			% Also when should coords of points be in pixels vs microns?

			%in Nick's original implementation, images were all given a depth of 152
			%images. Here we scale back to original size.
			%zScale=image_data.x.NumImages/152;
			y(:,3)=y(:,3)*image_data.Delta(3);
			y(:,1)=y(:,1)*image_data.Delta(1);
			% NB mirror image in Y to conform to matlab's coordinate system which is 
			% left handed (starting bottom, left, front vs top, left front in ImageJ)
			y(:,2)=(image_data.Height-y(:,2))*image_data.Delta(2);

			dotsReformatted{j}=reformat_coords(y,registration,gregxform_dir);
		end
	end

	save([output_dir,name,'_reformatted.mat'],'dots','dotsReformatted','-v7');
	removelock(lockfile);
end

end