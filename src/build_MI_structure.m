function [s]=build_MI_structure(matched_dots_dir,fileNamesIN,fileNamesOUT)
% BUILD_MI_STRUCTURE Calculate mutual information for one clone type
% 
%given a list of file names given by the cell fileNamesIN and fileNamesOUT, this function
%computes the mutual information between matched dots and to which list the image
%belong to. The general purpose is to feed in the file
%names that all contain the same clone, and those that don't, and this function will identify how
%informative each dots in each these files is of the clone.
%
% See also create_image_classifier

s=cell(1,length(fileNamesIN));

for i=1:length(fileNamesIN)

	h=dir([matched_dots_dir, fileNamesIN{i},'*matchedPoints.mat']);
	load([matched_dots_dir h(1).name],'y','imageList');

	if nargin==2 && i==1
		fileNamesOUT=setdiff(imageList,fileNamesIN);
	end
% during the first iteration, set up the index list
% imageList is the list of file names that make up each XXXmatchedPoints.mat
% file

	if i==1

		indIN=zeros(1,length(fileNamesIN));
		indOUT=zeros(1,length(fileNamesOUT));

		for j=1:length(fileNamesIN)
			indIN(j)=find(strcmp(fileNamesIN{j},imageList));
		end

		for j=1:length(fileNamesOUT)
			indOUT(j)=find(strcmp(fileNamesOUT{j},imageList));
		end

	end

% y is a matrix in each XXXmatchedPoints.mat file where each dot is
% described by a row. A one in a column mean that dot in the image matched
% another dot in the image specified by the column.

% remove the comparaison between the image and itself 
	indIN_current=indIN([1:i-1 i+1:end]);

	yIN=y(:,indIN_current); %#ok<NODEF>
	yOUT=y(:,indOUT);
	n1=length(indIN_current);
	n2=length(indOUT);

	[m dummy]=size(yIN); %#ok<NASGU>

	s{i}.MI=zeros(1,m,'single');

	
	t11=single(sum(yIN,2)/(n1+n2))+10^(-20);

	t01=single(n1/(n1+n2))-single(sum(yIN,2)/(n1+n2))+10^(-20);

	t10=single(sum(yOUT,2)/(n1+n2))+10^(-20);

	t00=single(n2/(n1+n2))-single(sum(yOUT,2)/(n1+n2))+10^(-20);

	s{i}.MI(:)=s{i}.MI(:)+(t11.*log2(t11./((t11+t10).*(t11+t01))));
	s{i}.MI(:)=s{i}.MI(:)+(t10.*log2(t10./((t11+t10).*(t10+t00))));
	s{i}.MI(:)=s{i}.MI(:)+(t01.*log2(t01./((t00+t01).*(t11+t01))));
	s{i}.MI(:)=s{i}.MI(:)+(t00.*log2(t00./((t00+t01).*(t10+t00))));

	s{i}.image=fileNamesIN{i};

	clear y

end
