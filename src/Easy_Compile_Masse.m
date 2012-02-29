% Script to compile the support functions required for the source code.

% The GLTreePro library is currently essential, while the ANN library
% is used for some of the early data processing steps

disp('Now compiling support code')

% GLTreePro nearest neighbour library
% Nick has been using this, though no major
% advantage over ANN, is no longer to be available on web
% and does not run under Octave
disp('Now compiling GLTreePro nearest neighbour library')
glpath=fileparts(which('BuildGLTree3D'));
run(fullfile(glpath,'compilethis3D.m'));

% Now ANN nearest neighbour library
% I prefer this, but have not translated all Nick's code to use it
disp('Now compiling ANN nearest neighbour library')
annpath=fileparts(which('ann_class_compile'));
run(fullfile(annpath,'ann_class_compile.m'));

% Finally see if we can compile teem
% this will usually work if teem has previously been installed on
% mac/linux machines
% see http://teem.sourceforge.net/ for details
% We also offer the pure matlab nrrdio for basic nrrd reading, so not a
% disaster if we can't compile.
teempath=fullfile(fileparts(annpath),'teem');
try
	run(fullfile(teempath,'compilethis.m'));
catch err
	disp(['Failed to compile teem library -'... 
		'reading nrrd files will be slower and restricted to 3D images.' ...
		' See Easy_Compile_Masse for details']);
end
