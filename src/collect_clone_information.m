function clone=collect_clone_information(clone_file)

% This function produces the cell clone which contains the name of each
% clone and the brains that contain the clone. 
%
% Input: cluster_file, a .tab files, containing the image names in the
%                      first column and the clone names in the second
%                      column. The file should be strcutrued as such to
%                      denote which clones contain which image
%
%                      ImageA  CloneA
%                      ImageB
%                      ImageC
%                      ImageD  CloneB
%                      ImageE
%
%                      Here, Images A-C contain clone A and images D and E
%                      contain clone B.


%clone_file='/Users/nmasse/Projects/imageProcessing/cloneProperties/all-clones.tab';


clone={};


[f1 f2]=textread(clone_file,'%s %s %*s');

numClones=0;


for i=1:length(f2)

	brain = jlab_filestem(f1{i},'-');

	if ~strcmp(f2{i},'');

		numClones=numClones+1;
		clone{numClones}.cloneName=f2{i}; %#ok<*AGROW>
		imageNumber=1;
		clone{numClones}.image{imageNumber}=brain;

	else

		imageNumber=imageNumber+1;
		clone{numClones}.image{imageNumber}=brain;

	end

end

for i=1:length(clone)

	clone{i}.image=unique(clone{i}.image);

end
