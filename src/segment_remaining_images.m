function segment_remaining_images(input_dir,output_dir,threshold)

% this script takes tubed images, thresholds them, and then segments them
% the input files are XXXtubed.PIC the and output files are XXXtubed.mat.
% The segmentation threshold defaults to 10

if nargin < 3
	threshold = 10;
end

% For testing:
% input_dir = '/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';
% output_dir='~/Projects/imageProcessing/tubed_files/';

% Process all input files sequentually
input_files=dir(fullfile(input_dir,'*-tubed.PIC'));
for i=1:length(input_files)

	% Trim input file name up to first underscore
	% Apparently there are some cases of multiple images with the same
	% stem and Nick only wanted to process one of these
	n=find(input_files(i).name=='_',1,'first');
	inputstem=input_files(i).name(1:n-1);

	processFile=1;

	% Check if we have already generated an output file for this brain
	output_files=dir(fullfile(output_dir,'*_tubed.mat'));
	for j=1:length(output_files)

		n=find(output_files(j).name=='_',1,'first');
		outputstem=output_files(j).name(1:n-1);

		if strcmp(inputstem,outputstem)
			processFile=0;
			break
		end

	end

	% Check if we have already generated a lockfile for this brain
	lock_files=dir(fullfile(output_dir,'*-in_progress.mat'));
	for j=1:length(lock_files)

		n=find(lock_files(j).name=='_',1,'first');
		lockstem=lock_files(j).name(1:n-1);

		if strcmp(inputstem,lockstem)
			processFile=0;
			break
		end

	end

	if processFile==1
		% Make a lockfile so that we are the only one working on this image
		save(fullfile(output_dir,[input_files(i).name,'-in_progress.mat']),'processFile');

		% read in image
		x=readpic(fullfile(input_dir,input_files(i).name));

		% threshold at arbitrary low level
		u=zeros(size(x),'uint8');
		u(x>=threshold)=1;

		% Find connected components and give each island a unique index
		[L,NUM]=bwlabeln(u,26);

		disp(['Segmented image ',input_files(i).name,'. Image has ',num2str(NUM),' components.'])

		save(fullfile(output_dir,[name,'_filtered2_tubed.mat']),'x','L','NUM');
		% delete lockfile
		delete(fullfile(output_dir,[input_files(i).name,'-in_progress.mat']));
	end

end




