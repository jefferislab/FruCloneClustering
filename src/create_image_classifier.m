function create_image_classifier(clone_file,matchedPoints_dir,classifier_name);
% CREATE_IMAGE_CLASSIFIER Make a classifier structure for all clones
%
% INPUTS: clone_file: file name of the .tab file from FileMaker containing
%         the clone information
%         matchedPoints_dir: directory of the XXXmatchedPOints.mat files
%         classifier_name: name of output file containing classifier 
%         secondary = 0 or 1
%         calibrate = 0 or 1
% When secondary = 0, the mutual information per dot is calculated based on
% whether the image contains the clone or does not. When secondary = 1, the
% function computes a confusion matrix, and calculates a secondary mutual
% information per dot based on whether the image contained the clone or
% contained a possible confused clone.
% When calibrate = 1, the scripts determines the optimal mutual information
% level for each clone; might be a bit slow.





%%%%%% OUT OF DATE
% Currently using score_all_clones_cross_validated to create clone
% classifier. However, this function builds a secondary classification
% strucure, so useful to keep around for now.
% Nicolas Masse, Feb 22, 2011


x={};

% clone_file='/Users/nmasse/Projects/imageProcessing/cloneProperties/all-clones.tab';
% matchedPoints_dir='~/Projects/imageProcessing/imageProperties/';

h=dir([matchedPoints_dir,'*matchedPoints.mat']);
load([matchedPoints_dir h(1).name],'imageList');

clone=collect_clone_information(clone_file);

cloneIndex={};
cloneIndexSize=zeros(1,length(clone));


for i=1:length(clone)
	
	classification_score=zeros(length(imageList),40,'single');
	clone_index=zeros(1,length(imageList),'single');
	
	%for each clone, determine the index of which images containing the
	%clone have a matching XXXmatchedPoints.mat file. This index list
	%is given by cloneIndex
	
	count=0;
	
	cloneIndex{i}=[];
	
	for j=1:length(clone{i}.image)
		
		i1=find(strcmp(clone{i}.image{j},imageList));
		
		if ~isempty(i1)
			
			count=count+1;
			
			cloneIndex{i}(count)= i1;
			
		end
		
	end
	
	if ~isempty(cloneIndex{i})
		
		cloneIndex{i}=unique(cloneIndex{i});
		cloneIndexSize(i)=length(cloneIndex{i});
		
	end
	
end

ind=find(cloneIndexSize>=3);

clone=clone(ind);
cloneIndex=cloneIndex(ind);
cloneIndexSize=cloneIndexSize(ind);


for i=1:length(clone)
	
	disp(['Calculating mutual information for clone number ',num2str(i),' ',clone{i}.cloneName]);
	
	indIN=cloneIndex{i};
	indOUT=setdiff(1:length(imageList),cloneIndex{i});
	
	[x{i}.s]=build_MI_structure(matchedPoints_dir,imageList(indIN),imageList(indOUT));
	
	x{i}.clone=clone{i}.cloneName;
	x{i}.images=imageList(indIN);
	
	
end

confusion_matrix=zeros(length(clone),length(clone));

for i=1:length(clone)
	
	score={};
	
	for j=1:length(clone)+1
		score{j}=[];
	end
	
	for j=1:length(clone)+1;
		
		disp(['Calculating confusion matrix between clone numbers ',num2str(i),' and ',num2str(j)])
		
		if j<=length(clone)
			u=cloneIndex{j};
		else
			u=setdiff(1:length(imageList),cloneIndex{i});
		end
		
		
		
		template_image_ind=cloneIndex{i};
		
		t=classify_image(x{i}.s,template_image_ind,imageList,u,matchedPoints_dir,1);
		
		score{j}=[score{j} t'];
		
		
		
		
	end
	
	dp=zeros(1,20);
	
	for j=1:20
		
		dp(j)=detectProb(score{end}(j+20,:),score{i}(j+20,:));
		
	end
	
	[t1 t2]=max(dp);
	
	x{i}.AROC1=t1;
	x{i}.threshold1=t2;
	
	for j=1:length(clone)
		
		confusion_matrix(i,j)=detectProb(score{j}(20+t2,:),score{i}(20+t2,:));
		
	end
	
	
end

for i=1:length(clone)
	
	disp(['Calculating secondary mutual information structure for clone number ',num2str(i),' ',clone{i}.cloneName]);
	
	% ROC scores between specific clones that are 0.1 less than the average
	% ROC score for that clone will determine the clones used to determine
	% the seconday information
	ind=find(confusion_matrix(i,:)<x{i}.AROC-.1);
	ind=setdiff(ind,i);
	
	if ~isempty(ind)
		
		
		indIN=cloneIndex{i};
		indOUT=[];
		for j=1:length(ind)
			indOUT=[indOUT cloneIndex{ind(j)}];
		end
		indOUT=unique(indOUT);
		
		[x{i}.s2]=build_MI_structure(matchedPoints_dir,imageList(indIN),imageList(indOUT));
		
		
		x{i}.secondary_list={};
		for j=1:length(ind)
			x{i}.secondary_list{j}=clone{ind(j)}.cloneName;
		end
		
		% Very slow to perform the leave one out test for the secondary mutual
		% information neccessary to obtain the optimal MI threshold. Thus,
		% we're simply setting the threshold a reasonable value
		x{i}.threshold2=5;
		
	end
	
	
end

save(classifier_name,'x','imageList','confusion_matrix')

end