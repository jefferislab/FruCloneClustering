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
end

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

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

			y=indata.dotsReformated{j}; % dots in reference coord space

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

function indices = coords2ind(img,voxdims,coords)
% COORDS2IND - find 1D indices into 3D image of XYZ coordinates
% 
% Input:
% img     - 3d img array
% voxdims - vector of 3 voxel dimensions (width, height, depth, dx,dy,dz)
% coords  - 3xN XYZ triples 
% 
% indices  - 1D indices into the image array
% 
% NB for the time being no reordering of image axes is done
%
% See also SUB2IND

imsize=size(img);
if(length(imsize)) ~= 3
	error('coords2ind only handles 3d data');
end
	
pixcoords=zeros(size(coords));

% first convert from physical coords to pixel coords
pixcoords(1,:)=round(coords(1,:)/voxdims(1));
pixcoords(2,:)=round(coords(2,:)/voxdims(2));
pixcoords(3,:)=round(coords(3,:)/voxdims(3));

% make sure no points are out of range
pixcoords(1,:)=min(imsize(1),max(1,pixcoords(1,:)));
pixcoords(2,:)=min(imsize(2),max(1,pixcoords(2,:)));
pixcoords(3,:)=min(imsize(3),max(1,pixcoords(3,:)));
% TODO: convert pixel coords to array subscripts by swapping X and Y axes
% and flipping Y?  Either the image or these coords must be flipped

% convert to 1d indices
indices=sub2ind(imsize,pixcoords(1,:),pixcoords(2,:),pixcoords(3,:));
end
