function rescale_images( input_dir, output_dir, suffix, scale, anisofilter, tube, fiji, fijiopts)
%RESCALE_IMAGES Rescale and preprocess input images to emphasise neurites
%   
% Usage rescale_images( input_dir, output_dir, suffix, scale, anisofilter, tube, fiji, fijiopts)
%
% Rescale, 8 bit, anisotropic diffusion filtering & calculate Hessian
%
% input_dir   - directory containing PIC images
% output_dir  - output directory
% suffix      - string which will be appended to output file stem
%               e.g. for suffix='-4xd.nrrd' file_01.pic -> file_01-4xd.nrrd
%               NB if suffix ends in nrrd, will be saved in NRRD format
%               otherwise Biorad PIC.
% scale       - 3-vector which will be multiplied by old size to get new size
% anisofilter - path to anisofilter - if set to true or omitted, defaults to 
%               'anisofilter' when it must be in system path.
%               If set to ''/false then anisofilter will not be called by fiji
% tube        - run tubeness algorithm in fiji (default true)
% fiji        - path to fiji - defaults to 'fiji' ie must be in system path
% fijiopts    - additional options passed to fiji or the Java Runtime
%               (e.g. --mem 2048M to restrict how much memory fiji tries to take)
%
% See scaleandfilter.py for the ImageJ jython script that does the processing.
% 

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% d1=dir([input_dir '*.pic']);
% d2=dir([input_dir '*.PIC']);
% h=[d1;d2];
h=dir([input_dir '*.nhdr']);

if nargin < 4 || isempty(scale)
	scale = [0.5 0.5 1];
end
if nargin < 5 || isempty(anisofilter) || (islogical(anisofilter) && anisofilter)
	anisofilter = 'anisofilter';
elseif islogical(anisofilter) && ~anisofilter
	anisofilter='FALSE'; % so fiji won't run this step
end

if nargin < 6 || isempty(tube) || tube
	tube = true;
else
	tube = false;
end

if nargin < 7 || isempty(fiji)
	fiji = 'fiji';
end

if nargin < 8
	fijiopts ='';
end

%[mfilepath, mfile]= fileparts(mfilename());
scriptfile=which('scaleandfilter.py');

for i=randperm(length(h))

	% set up the file names we need
	infile=h(i).name;
	current_image=jlab_filestem(infile);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	[pathstr, outfile] = fileparts(infile);
	outfile = [outfile suffix];
	
	% Check if we should process current image
	if ~check_newer_input([input_dir infile],[output_dir outfile],true)
		% skip this image since output newer than input
		continue
	elseif ~makelock(lockfile,[],true)
		% skip since someone else is working on this image
		continue
	end

	disp(['Rescaling image ',infile])
	
	% run fiji script
	scriptargs = sprintf('-i %s -o %s -x %f -y %f -z %f -a %s', ...
		[input_dir infile], [output_dir outfile], scale(1), scale(2), scale(3),  ...
		anisofilter);
	if ~tube
		scriptargs = [scriptargs ' --notube'];
	end
	
	cmd = sprintf('%s --headless %s -- %s %s -batch',...
		fiji, fijiopts, scriptfile, scriptargs);
	if strcmp(computer(),'MACI64') && ~strcmp(anisofilter,'FALSE')
		% Fix problem with anisofilter getting upset by old libtiff distributed with matlab
		cmd = ['export DYLD_LIBRARY_PATH=""; ' cmd];
	end
	disp(cmd);
	system(cmd);
	removelock(lockfile);
end

end
