function calculate_properties_remaining_images(input_dir,output_dir,mask_file,alpha_thresh,cell_bodies_image_dir,image_list)
% CALCULATE_PROPERTIES_REMAINING_IMAGES - find tangent vector, alpha
%
% Function takes reformatted images and calculates:
% principal eigenvector (tangent vector)
% alpha (alpha=1 -> one-dimenionsal, alpha=0 -> isotropic)
% from the moment of inertia.
%
% Optionally: save only points with alpha > alpha_thresh
% Optionally: supply a mask_file (currently only tif)
%
% The input files are XXX_reformated.mat and output files are XXX_properties.mat.
%
% See also extract_properties


%if an image list is not speicifed, the default will be to take all the
%*properties.mat files in the directory, remove the suffix after the '-',
%and then only use unique images.
if nargin < 6
    properties_data=dir(fullfile(input_dir,'*_reformated.mat'));
    image_list_temp={};
    for i=1:length(properties_data)
        image_list_temp{i}=jlab_filestem(properties.data(i).name,'-');
    end
    image_list_temp = sort(image_list_temp);
    image_list={};
    count=0;
    for i=1:length(image_list_temp)
        if i>1 & ~strcmp(image_list_temp{i-1},image_list_temp{i})
            count=count+1;
            image_list{count}=image_list_temp{i};
        end
    end
    
end

if nargin < 5
    
   find_cell_bodies_flag = 0;
   
   else
    
   find_cell_bodies_flag = 1;
   
end
    

if nargin < 4
	alpha_thresh = 0.25;
end

if nargin >= 3
	%FIXME make sure this mask is loaded up with correct axis orientation
	mask = readpic(mask_file);
	maskiminfo = impicinfo(mask_file);
else
	% Set default to empty array
	mask = [];
end



% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% infiles=dir([input_dir,'*_reformated.mat']);

% OUTPUT
%output_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';

if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

%%TODO: instead of looping through infiles, loop through the image_list

for i=1:length(image_list)
	% This contains just the image stem (everyhing up to first underscore)
	% e.g. SAKW12-1_reformated.mat => SAKW12-1
	current_image=jlab_filestem(image_list{i});

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
    
   % h=dir([input_dir,current_image,'*reformated.mat']);
    h=dir([input_dir,current_image,'*properties.mat']); %%%%%%%% TEMPORARY CHANGE, REVERT TO PREVIOUS LINE
    if isempty(h)
        error([current_image,' is not in the input directory']);
    else

      %  indata=load([input_dir,h(1).name]);
        load([input_dir,h(1).name]);%%%%%%%% TEMPORARY CHANGE, REVERT TO PREVIOUS LINE
        
    end
    
    

% 	for j=1:length(indata.dotsReformated) % iterate over each group of connected dots
% 
% 		y=indata.dotsReformated{j}; % dots in original coord space
% 
% 		if ~isempty(y)
% 
% 			y=indata.dotsReformated{j}; % dots in reference coord space
%             [dummy n]=size(y);
%             if n>20
% 			p.gamma1=[p.gamma1 y];
%              ptrtree=BuildGLTree3D(y);
% 			[alpha,vect]=extract_properties(y',ptrtree);
%             DeleteGLTree3D(ptrtree);
% 			p.alpha=[p.alpha alpha];
% 			p.vect=[p.vect vect];
%             end
% 		end
% 
%     end
    
    
    y=p.gamma1;
      ptrtree=BuildGLTree3D(y);
			[alpha,vect]=extract_properties(y',ptrtree);
            DeleteGLTree3D(ptrtree);
            p.alpha=alpha
            p.vect=vect;
    

	% This part removes any points outside of a mask that covers the
	% central brain and all of its tracts. It also removes points with
	% p.alpha (eigenvalue 1 -eigenvalue 2)/sum(eigenvalues)) below 0.25
	% (by default) that are not part of a linear structure.

	if ~isempty(mask)
		indices=coord2ind(mask,maskiminfo.Delta,p.gamma1);

		if isempty(alpha_thresh)
			maskInd = mask(indices)>0;
		else
			maskInd = mask(indices)>0 & p.alpha>alpha_thresh;
		end
		
		p.gamma2=p.gamma1(:,maskInd);
		p.vect2=p.vect(:,maskInd);
	elseif ~isempty(alpha_thresh)
		p.gamma2=p.gamma1(:,p.alpha>alpha_thresh);
		p.vect2=p.vect(:,p.alpha>alpha_thresh);
    end
    
    
    %%%% This part downsamples the resolution to 1 um
    
    disp(current_image)
    coords=max(1,round(p.gamma2));
    m1=max(coords(1,:));
    m2=max(coords(2,:));
    m3=max(coords(3,:));
    ind = sub2ind([m1 m2 m3],coords(1,:),coords(2,:),coords(3,:));
    [ind included_ind] = unique(ind);
    [i1 i2 i3] = ind2sub([m1 m2 m3],ind);
    
    p.gamma3 = uint16([i1' i2' i3']');
    p.vect3 = p.vect2(:, included_ind);
    
    
    % Will find the location of putative cell bodies if a directory with
    % the reformated images was specified
    if find_cell_bodies_flag
        
        h = dir([cell_bodies_image_dir,current_image,'*.pic']);
        if isempty(h);
            p.cell_body_coords = [];
        else
            p.cell_body_coords = find_cell_body_locations([cell_bodies_image_dir,h(1).name]);;
            
        end
    else
        
        p.cell_body_coords = [];
        
    end
    
    p
	%%%%
	save([output_dir,current_image,'_properties.mat'],'p','-v7');
	removelock([output_dir,current_image,'-in_progress.mat']);
end
end
