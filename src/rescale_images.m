function rescale_images( input_dir, output_dir, suffix, scale, anisofilter, fiji)
%RESCALE_IMAGES rescale all PIC/nrrd images in input_dir
%   
% Usage rescale_images( input_dir, output_dir, suffix, scale, anisofilter, fiji)
%
% Rescale, calculate Hessian and 
%
% input_dir   - directory containing PIC images
% output_dir  - output directory
% suffix      - string which will be appended to output file stem
%               e.g. for suffix='-4xd.nrrd' file_01.pic -> file_01-4xd.nrrd
%               NB if suffix ends in nrrd, will be saved in NRRD format
%               otherwise Biorad PIC.
% scale       - 3-vector which will be multiplied by old size to get new size
% anisofilter - path to anisofilter - defaults to 'anisofilter' when it
%               must be in system path.
%               If set to '' then anisofilter will not be called by fiji
% fiji        - path to fiji - defaults to 'fiji' ie must be in system path

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
if nargin < 5
	anisofilter = 'anisofilter';
end
if nargin < 6
	fiji = 'fiji';
end
[mfilepath, mfile]= fileparts(mfilename());
scriptfile=fullfile(mfilepath, 'scaleandfilter.py');
if isempty(anisofilter)
	anisofilter='FALSE'; % so fiji won't run this step
end

for i=1:length(h)

	% set up the file names we need
	infile=h(i).name;
	current_image=jlab_filestem(infile);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	[pathstr, outfile] = fileparts(infile);
	outfile = [outfile suffix];
	
	% Check if we should process current image
	if ~CheckForNewerInput([input_dir infile],[output_dir outfile],true)
		% skip this image since output newer than input
		continue
	elseif ~makelock(lockfile,[],true)
		% skip since someone else is working on this image
		continue
	end

	disp(['Rescaling image ',infile])
	
	% run fiji script
	cmd = sprintf('%s --headless -- %s -i %s -o %s -x %f -y %f -a %s -batch',...
		fiji, scriptfile, [input_dir infile], [output_dir outfile], ...
		 scale(1), scale (2), anisofilter);
	disp(cmd);
	system(cmd);
	removelock(lockfile);
end

end
