function calculate_properties_remaining_images(input_dir,output_dir,ann_dir);

% this script takes the reformatted image and calculates the the principal eigenvector (tangent vector)
% and the term alpha (alpha=1 -> one-dimenionsal, alpha=0 -> isotropic) from the moment of inertia.
% The input files are XXX_reformated.mat and output files are XXX_properties.mat.


% INPUT
%input_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';
h=dir([input_dir,'*_reformated.mat']);

% OUTPUT
%output_dir='/Volumes/JData/JPeople/Nick/FruCloneClustering/images/';

if ~exist(output_dir,'dir')
	% FIXME this seems to fail if output_dir has a trailing /
	mkdir output_dir;
end

for i=1:length(h)

	n=find(h(i).name=='_',1,'first');
	name=h(i).name(1:n-1);

	flag=1;

	h1=dir([output_dir,'*_properties.mat']);

	for j=1:length(h1)

		n=find(h1(j).name=='_',1,'first');
		name1=h1(j).name(1:n-1);


		if strcmp(name,name1)
			
			flag=0;
			break
			
		end

	end

	h2=dir([output_dir,'*-in_progress.mat']);

	for j=1:length(h2)

		n=find(h2(j).name=='_',1,'first');
		name2=h2(j).name(1:n-1);

		if strcmp(name,name2)

			flag=0;
			break

		end

	end

	if flag==1

		save([output_dir,h(i).name,'-in_progress.mat'],'flag','-v7');

		%%%% Main code

		p=[];
		p.gamma1=[];
		% 		p.dimension1=[];
		% 		p.lambda1=[];
		p.alpha=[];
		p.vect=[];

		load([input_dir,h(i).name])

		for j=1:length(dots) % iterate over each group of connected dots

			y=dots{j}; % dots in original coord space

			if ~isempty(y)

				y=dotsReformated{j}; % dots in reference coord space

				p.gamma1=[p.gamma1 y];

				[temp1,temp2]=extract_properties(y);

				p.alpha=[p.alpha temp1];
				p.vect=[p.vect temp2];
			end

		end

		% This part removes any points outside of a mask that covers the
		% central brain an all of its tracts. It also removes points with
		% p.alpha (eigenvalue 1 -eigenvalue 2)/sum(eigenvalues)) below 0.25. These are points that are not part of a
		% linerar structure.

		x=zeros(384,384,173);
		for j=1:173
			x(:,:,j)=imread('IS2_nym_mask.tif',i);
		end
		
		g(1,:)=round(384/315.13*round(p.gamma1(1,:)));
		g(2,:)=round(384/315.13*round(p.gamma1(2,:)));
		g(3,:)=round(1*round(p.gamma1(3,:)));
		g(1,:)=min(384,max(1,g(1,:)));
		g(2,:)=min(384,max(1,g(2,:)));
		g(3,:)=min(173,max(1,g(3,:)));
		maskInd=zeros(1,length(p.gamma1));
		for j=1:length(p.gamma1)
			x(g(2,j),g(1,j),g(3,j))>0 & p.alpha(j)>.25;
			maskInd(j)=1;
		end;

		clear g
		
		p.gamma2=p.gamma1(:,find(maskInd));
		p.vect2=p.vect(:,find(maskInd));

		%%%%
		save([output_dir,name,'_properties.mat'],'p','-v7');
		delete([output_dir,h(i).name,'-in_progress.mat'])

	end

end
