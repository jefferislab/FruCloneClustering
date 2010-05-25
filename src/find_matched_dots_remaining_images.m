function find_matched_dots_remaining_images(input_dir,output_dir)
% Find matching dots for all pairwise combinations of property files in directory
%
% input_dir =  location of the SA*properties.mat files
% output_dir = location of the SA*matchedPoints.mat files
%
% property files store tangent vector and local dimensionality for each dot

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

properties_files=dir([input_dir,'*_properties.mat']);

for i=1:length(properties_files)

	current_image=jlab_filestem(properties_files(i).name);

	% flag = 1 means that the current image property file will be
	%          processed from scratch
	% flag = 2 means that some kind of update will be required

	% However, there are first several checks to ensure the file is
	% not currently completed or in process

	% First, check that there is no matching image in progress
	flag = ~matching_images(current_image,...
		[output_dir,'*-matched_points-in_progress.mat']);

	% Then check that there is no completed matching image
	[match_exists matching_file_name] = matching_images(current_image,...
		[output_dir,'*matchedPoints.mat']);
	if match_exists
		% if there is then load in some vars for that image
		load([output_dir matching_file_name],'num_images','imageList');
		% to check if all image pairs have been processed
		if num_images==length(properties_files)
			flag=0; % Yes, nothing to do
		else
			flag=2; % Some update required
		end
	end

	if flag==1 || flag==2

		if flag==1
			% First time this image is being processed so need to construct
			% a list of image names that it will be matched against
			imageList={};
			y=[];
		else
			% load in what we have already done
			load([output_dir matching_file_name]);
		end

		save([output_dir properties_files(i).name,'-matched_points-in_progress.mat'],'flag');
		load([input_dir properties_files(i).name],'p');

		p1=p; % rename p array from 1st image to avoid name clash with 2nd
		clear p

		[m1 n1]=size(p1.gamma2);

		for j=1:length(properties_files)

			disp([i j]); % We're processing image i vs image j

			short_name=jlab_filestem(properties_files(j).name,'-');

			% Process if there is no match for this image in existing list
			if ~any(strcmp(imageList,short_name))

				y1=zeros(n1,1,'uint8');

				load([input_dir properties_files(j).name],'p');

				imageList{end+1}=short_name;

				%ind_union is the index of the query points (p1.gamma2)
				%that are matched to the template (p.gamma2)
				ptrtree=BuildGLTree3DFEX(p.gamma2');
				[ind_union]=compareImages_GLTree(p1,p,ptrtree);
				DeleteGLTree3DFEX(ptrtree);

				y1(ind_union)=1;

				y=[y y1];

			end

		end

		% Verify that there are no duplicate images
		num_images=length(imageList);
		f=sort(imageList);

		f1={};

		ind=[1];
		f1{1}=f{1};

		for j=2:length(f)

			name1=f{j-1};
			name2=f{j};

			if ~strcmp(name1,name2)
				ind=[ind j];
				f1{j}=name2;
			end

		end

		imageList=f1(ind);
		y=y(:,ind);

		save([output_dir current_image,'_matchedPoints.mat'],'num_images','imageList','y','-v7');
		delete([output_dir properties_files(i).name,'-matched_points-in_progress.mat'])

	end

end
