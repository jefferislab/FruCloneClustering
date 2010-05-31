function segment_remaining_images(input_dir,output_dir,threshold)
% SEGMENT_REMAINING_IMAGES Find connected regions with pixels > threshold
%
% This function takes tubed images, thresholds them, and then segments them
% the input files are XXXtubed.PIC the and output files are XXXtubed.mat.
% The segmentation threshold defaults to 10

if nargin < 3
	threshold = 10;
end

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% Process all input files sequentually
input_files=dir(fullfile(input_dir,'*-tubed.PIC'));
for i=1:length(input_files)

	% Trim input file name up to first underscore
	% Apparently there are some cases of multiple images with the same
	% stem and Nick only wanted to process one of these
	current_image=jlab_filestem(input_files(i).name);
	lockfile=[output_dir,current_image,'-tubed-in_progress.lock'];
	
	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*tubed.mat']) % second * for spelling changes
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile) % try to make lock file
		% skip since someone else is working on this image
		continue
	end
	
	% read in image
	x=readpic(fullfile(input_dir,input_files(i).name));

	% threshold at arbitrary low level
	u=zeros(size(x),'uint8');
	u(x>=threshold)=1;

	% Find connected components and give each island a unique index
	[L,NUM]=bwlabeln(u,26);

	disp(['Segmented image ',input_files(i).name,'. Image has ',num2str(NUM),' components.'])

	save(fullfile(output_dir,[current_image,'_filtered2_tubed.mat']),'x','L','NUM');
	% delete lockfile
	removelock(lockfile);
end

end




