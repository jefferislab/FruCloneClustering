% Script to download sample data from web

% setup directories
Set_Masse_Dirs

%% For querying fruitless neuroblast clones dataset
% Classifier
classdld=questdlg('Download classifier data for fruitless clones (115Mb, Recommended)','Classifier Download','Yes');
if strcmp(classdld,'Cancel')
	return
end
if strcmp(classdld,'Yes')
	urlwrite('https://data.mrc-lmb.cam.ac.uk/weblinks/?id=ccb1d45fb76f7c5a0bf619f979c6cf36&filename=classifier_final.mat',...
		fullfile(root_dir,'data','classifier.mat'));
end

%% Sample data set for full image processing pipeline (see RUN_ALL_PROCESSES) FIXME
% Images
% Registrations
% Masks (part of git repo)
% Traces (part of git repo?)
ppimgdld=questdlg('Download 7 raw sample images and registrations (310Mb, Optional)','Raw Image Download','No');
if strcmp(ppimgdld,'Cancel')
	return
end
if strcmp(ppimgdld,'Yes')
	% Raw Images (main input for the whole image processing pipeline)
    unzip('http://flybrain.mrc-lmb.cam.ac.uk/Masse2011/FruCloneClustering/images.sel7.zip',...
    original_images_dir);
	% Registrations: calculated for the nc82 (neuropil) channel of the raw
	% images and the IS2 template brain used in Cachero, Ostrovsky et al 2010
	% This information is required to transform dot coordinates from the
	% original image to the template (IS2) coordinate space
	unzip('http://flybrain.mrc-lmb.cam.ac.uk/Masse2011/FruCloneClustering/Registration.zip',...
		registration_dir);
end


%% To start after image pre-processing (see RUN_ALL_PROCESSES)
ppimgdld=questdlg('Download 34 preprocessed sample images (580Mb, Optional)','Preprocessed Image Download','No');
if strcmp(ppimgdld,'Cancel')
	return
end
if strcmp(ppimgdld,'Yes')
	% dimension reduced images (for tubular processes)
	unzip('https://data.mrc-lmb.cam.ac.uk/weblinks/?id=bc6dc48b743dc5d013b1abaebd2faed2&filename=dimension_reduced_images_testset.zip',...
	dimension_reduced_dir);
	% reformatted images for cell body locations (see RUN_ALL_PROCESSES) 
	unzip('https://data.mrc-lmb.cam.ac.uk/weblinks/?id=f2fc990265c712c49d51a18a32b39f0c&filename=reformatted_images_testset.zip',...
		reformated_images_dir);
end

