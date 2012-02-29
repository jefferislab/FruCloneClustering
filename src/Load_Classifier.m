% Script to load the default fruitless clone classifier

if exist('classifier','var')
	disp('Classifier already loaded. clear it if you want to reload it.');
	return
end

disp('Loading default classifier structure ...');
Set_Masse_Dirs;
classifierpath=fullfile(root_dir,'data','classifier.mat'),'classifier';
if ~exist(classifierpath,'file')
	error('You need to download the sample classifier data. You can do this with Download_Sample_Data');
end

% global classifier; % so that we can access it from inside functions
% 
classifier = load(classifierpath);
% not quite sure how to avoid loading it into a struct called
% classifier(specified by the mat file name) containing a struct called
% classifier ...
if length(classifier)==1
	classifier=classifier.classifier;
end
