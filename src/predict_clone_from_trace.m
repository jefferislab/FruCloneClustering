function [sortedscores, sortedclones] = predict_clone_from_trace(trace_file,clone_classifier,registration)
% PREDICT_CLONE_FROM_TRACE - Match tracing against clone image database
% 
% Usage: 
% [sortedscores, sortedclones] = ...
%	predict_clone_from_trace(trace_file,clone_classifier,registration)
% 
% trace_file     - CSV or space/tab delimited set of 3D points
% clone_classier - .mat file created by create_image_classifier
% registration   - optional CMTK registration 
%
% See also create_image_classifier

% Choose register_option=1 to reformat coordinates

disp('Location of gregxform unix command...');
gregxform_dir='/Applications/IGSRegistrationTools/bin/'

disp('Location of image properties (ie SAKU1-1_properties.mat...)');
image_properties_dir='~/NickTempFolder/imageProperties/'

% Load classifier structure with mutual information data
load(clone_classifier);

clones=cell(1,length(x));
for i=1:length(x)
	clones{i}=x{i}.clone;
end

% Read in trace file
y=dlmread(trace_file);

% Transform points if necessary
if nargin>2
	y=reformat_coords(x1,registration);
end

% Calculate tangent vectors for query points
[alpha,vect]=extract_properties(y);

MI_threshold=0.005:0.005:0.1;
MI_threshold2=(0.005:0.005:0.1)*5;
count=zeros(1,length(x))+10^(-20);
score=zeros(1,length(x));
% count2=zeros(1,40)+10^(-20);
% score2=zeros(1,40);

% aggregated position & vector information for query points
p1.gamma2=y';
p1.vect2=vect;

% Make a nearest search structure for query points
ptrtree=BuildGLTree3DFEX(y);

% Iterate through each template clone
for i=1:length(x)

	disp(['Comparing trace to clone ',clones{i}])

% iterate through each template image for current template clone
	for j=1:length(x{i}.s)

% load dot positions and tangent vectors for this image
% note that there may be multiple variants of this image
% depending on flips etc - this will just use the first one
% TODO - tidy this up
		h=dir([image_properties_dir x{i}.images{j},'*properties.mat']);
		load([image_properties_dir h(1).name]);

% p.gamma is aggregated position & vector information for this
% template image
		[m1 n1]=size(p.gamma2);

% Binary vector containing match points (size of template)
		y=zeros(n1,1,'uint8');

% restrict to template dots above minimum MI score
		ind=find(x{i}.s{j}.MI>.005);
		p2=[];
		p2.gamma2=p.gamma2(:,ind);
		p2.vect2=p.vect2(:,ind);

% find index of template dots that have a match in query
		[matchedPoints]=compareImages_GLTree(p2,p1,ptrtree);

		clear p2

% selected template dots
		y(ind(matchedPoints))=1;

% subtract optimal MI threshold for this template clone (+ rectify)
		modified_MI=max(0,x{i}.s{j}.MI'-MI_threshold(x{i}.threshold));

% count is sum of MI for all template dots
% score for matched template dots
		count(i)=count(i)+sum(modified_MI);
		score(i)=score(i)+sum(single(y(:)).*modified_MI);

	end

end

clear y

DeleteGLTree3DFEX(ptrtree);

score=score./count;

[dummy ind]=sort(score,'descend');

sortedscores = score(ind);
sortedclones = clones{ind};

disp('The top five clone scores...');
disp(' ')

for i=1:5

	disp([clones{ind(i)},'  score = ',num2str(score(ind(i)))]);

end
