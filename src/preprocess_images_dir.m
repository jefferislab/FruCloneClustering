function preprocess_images_dir(input_dir,output_dir)
% PREPROCESS_IMAGES_DIR Preprocess a directory of PIC images using ImageJ/Fiji
%   PREPROCESS_IMAGES_DIR(input_dir,output_dir)
%
%   input_dir:  Directory containing input .PIC, .pic, .PIC.gz, or .pic.gz files
%   output_dir: Directory in which tubed.PIC output files will be saved
% 
% Note this is a translation of the original PreprocessImages.R script

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% find images to preprocess - need to be channel 2 pics (optionally compressed)
% TODO - make file specification more flexible
allfiles=dir(fullfile(input_dir));
images=[];
for i=1:length(allfiles)
	if regexpi(allfiles(i).name,'.*02\.(pic|PIC)+(\.gz)*$')
		images=[images allfiles(i)];
	end
end

for i=1:length(images)
    current_image=jlab_filestem(images(i).name);

	% name of final output file
	tubenessFile=fullfile(output_dir,[current_image '.4xd-tubed.PIC']);
	
	lockfile=fullfile(output_dir,[current_image,'.lock']);
    
	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*tubed.PIC'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile)
		% skip since someone else is working on this image
		continue
	end
	
	% TODO Perform image processing
    disp(['processing image: ' current_image])
	removelock(lockfile);

end

end
