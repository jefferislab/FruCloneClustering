function calculate_properties_remaining_images(input_dir,output_dir,alpha_thresh,mask_file,vox_dims)
% CALCULATE_PROPERTIES_REMAINING_IMAGES - find tangent vector, alpha
%
% Function takes reformatted images and calculates:
% principal eigenvector (tangent vector)
% alpha (alpha=1 -> one-dimenionsal, alpha=0 -> isotropic)
% from the moment of inertia.
%
% Optionally: save only points with alpha > alpha_thresh
% Optionally: supply a mask_file (currently only tif)
% and voxel dimensions (a vector containing physical size in each axis)
%
% The input files are XXX_reformated.mat and output files are XXX_properties.mat.
%
% See also extract_properties


if nargin < 3
	alpha_thresh = [];
end

if nargin >= 4
	mask = load3dtif(mask_file);
else
	% Set default to empty array
	mask = [];
end

if nargin < 5
	% default to size that Nick was assuming
	% in fact Z step was 1.066
	vox_dims=[384/315.13 384/315.13 1];
	% TODO: supply mask in a form that retains calibration information
end

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% NB Second asterisk permits spelling variants
infiles=dir([input_dir,'*_reformat*ed.mat']);

% OUTPUT
%output_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';

if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

for i=1:length(infiles)
	% This contains just the image stem (everyhing up to first underscore)
	% e.g. SAKW12-1_reformated.mat => SAKW12-1
	current_image=jlab_filestem(infiles(i).name);

	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*_properties.mat'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock([output_dir,current_image,'-in_progress.mat'])
		% Looks like someone else is working on this image
		continue
	end

	%%%% Main code

	p=[];
	p.gamma1=[];
	p.alpha=[];
	p.vect=[];

	indata=load([input_dir,infiles(i).name]);

	for j=1:length(indata.dots) % iterate over each group of connected dots

		y=indata.dots{j}; % dots in original coord space

		if ~isempty(y)

			y=indata.dotsReformatted{j}; % dots in reference coord space

			p.gamma1=[p.gamma1 y];

			[alpha,vect]=extract_properties(y);

			p.alpha=[p.alpha alpha];
			p.vect=[p.vect vect];
		end

	end

	% This part removes any points outside of a mask that covers the
	% central brain and all of its tracts. It also removes points with
	% p.alpha (eigenvalue 1 -eigenvalue 2)/sum(eigenvalues)) below 0.25
	% (by default) that are not part of a linear structure.

	if ~isempty(mask)
		indices=coords2ind(mask,vox_dims,p.gamma1);

		if isempty(alpha_thresh)
			maskInd = x(indices)>0;
		else
			maskInd = x(indices)>0 & p.alpha>alpha_thresh;
		end
		
		p.gamma2=p.gamma1(:,maskInd);
		p.vect2=p.vect(:,maskInd);
	elseif ~isempty(alpha_thresh)
		p.gamma2=p.gamma1(:,p.alpha>alpha_thresh);
		p.vect2=p.vect(:,p.alpha>alpha_thresh);
	end

	%%%%
	save([output_dir,name,'_properties.mat'],'p','-v7');
	removelock([output_dir,current_image,'-in_progress.mat']);
end
end
