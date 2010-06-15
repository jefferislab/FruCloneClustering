function rescale_images( input_dir, output_dir, suffix, scale)
%RESCALE_IMAGES rescale all PIC images in input_dir
%   
% Usage rescale_images( input_dir, scale)
%
% input_dir  - directory containing PIC images
% output_dir - output directory
% suffix     - string which will be appended to output file stem
%              e.g. for suffix='-4xd' file_01.pic -> file_01-4xd.PIC
% scale      - 3-vector which will be multiplied by old size to get new size

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

if nargin < 4
	scale = [0.5 0.5 1];
end

[mfilepath, mfile]= fileparts(mfilename());
scriptfile=fullfile(mfilepath, 'scaleandfilter.py');

for i=1:length(h)

	% set up the file names we need
	infile=h(i).name;
	current_image=jlab_filestem(infile);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	[pathstr, outfile] = fileparts(infile);
	outfile = [outfile suffix '.PIC'];
	
	% Check if we should process current image
	if ~CheckForNewerInput([input_dir infile],[output_dir outfile],true)
		% skip this image since output newer than input
		continue
	elseif ~makelock(lockfile,[],true)
		% skip since someone else is working on this image
		continue
	end

	disp(['Rescaling image ',infile])
	
	% run script
	cmd = sprintf('fiji --headless -Dpython.cachedir.skip=false %s -i %s -o %s -x %f -y %f -batch',...
		scriptfile, [input_dir infile], [output_dir outfile], scale(1), scale (2));
	system(cmd);
	% disp(cmd);
	removelock(lockfile);
end

end
