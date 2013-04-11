function preprocess_images_dir(input_dir,varargin)
% Preprocess PIC images with ImageJ/Fiji & anisofilter (emphasise neurites)
%
%   PREPROCESS_IMAGES_DIR(input_dir,output_dir,DryRun,Verbose,RemoveIntermediates)
%
%   input_dir:  Directory containing input .PIC, .pic, .PIC.gz, or .pic.gz files
% Optional arguments
%   output_dir: Directory in which tubed.PIC output files will be saved
%   (defaults to input_dir)
%	DryRun (default false)
%	Verbose (default true)
%	RemoveIntermediates (default true)
% Note this is a translation of the original PreprocessImages.R script
	
numvarargs = find(~cellfun('isempty',varargin));
if length(numvarargs) > 4
	error('preprocess_image requires at most 3 optional inputs');
end
% set defaults for optional inputs
optargs = {input_dir 0 1 1};
% now put these defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
optargs(numvarargs) = varargin(numvarargs);
% Place optional args in memorable variable names
[output_dir, DryRun, Verbose, RemoveIntermediates] = optargs{:};

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

% find images to preprocess - need to be channel 2 pics (optionally compressed)
% TODO - make file specification more flexible
allfiles=dir(fullfile(input_dir));
images=[];
for i=1:length(allfiles)
	if regexpi(allfiles(i).name,'.*02\.(pic|PIC|nrrd)+(\.gz)*$')
		images=[images allfiles(i)];
	end
end

% iterate over selected images
for i=1:length(images)
    current_image=jlab_filestem(images(i).name);

	% name of final output file
	tubenessFile=fullfile(output_dir,[current_image '.4xd-tubed.PIC']);
	
	lockfile=fullfile(output_dir,[current_image,'.lock']);
    
	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*tubed.PIC'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile)
		% skip since someone else is working on this image
		continue
	end
	
	% Perform image processing
    disp(['processing image: ' current_image])
	preprocess_image(fullfile(input_dir,images(i).name),...
		fullfile(output_dir,[images(i).name,'.4xd-tubed.PIC']),...
		DryRun, Verbose, RemoveIntermediates);
	removelock(lockfile);

end

end

function [ command, status ] = preprocess_image( infile, varargin)
%PREPROCESS_IMAGE Take an individual image and preprocess with fiji/cfd
% PREPROCESS_IMAGE(infile, outfile, DryRun, Verbose, RemoveIntermediates)
% infile - name of Biorad PIC format input file
% Optional arguments
%   outfile: file name of tubed.PIC output defaults to <infile>.4xd-tubed.PIC
%	DryRun (default false)
%	Verbose (default true)
%	RemoveIntermediates (default true)
	
	numvarargs = find(~cellfun('isempty',varargin));
	if length(numvarargs) > 4
		error('preprocess_image requires at most 3 optional inputs');
	end
	% set defaults for optional inputs
	optargs = {[infile,'.4xd-tubed.PIC'] 0 1 1};
	% now put these defaults into the valuesToUse cell array,
	% and overwrite the ones specified in varargin.
	optargs(numvarargs) = varargin(numvarargs);
	% Place optional args in memorable variable names
	[outfile, DryRun, Verbose, RemoveIntermediates] = optargs{:};
	
	% open file
	macro=['open("',infile,'");'];
	% resample, 8 bit, save as tiff
	[outdir,~,~] = fileparts(outfile);
	[indir,infilename,infileext] = fileparts(infile);
	resampledfilename=[infilename,infileext,'.4xd.tif'];
	resampledfilepath=fullfile(indir,resampledfilename);
	macro=[macro,'run("Scale...", "x=0.5 y=0.5 z=1.0 interpolation=Bicubic process title=Scaled");']
	% Make sure that we select the right window
	macro=[macro 'selectWindow("Scaled");'];
	macro=[macro 'run("8-bit");'];
	% store current voxel size
	macro=[macro 'getVoxelSize(xp,yp,zp,unit);'];
	macro=[macro 'saveAs("Tiff", "',resampledfilepath,'");'];
	% run anisofilter
	filteredResampledfile=[infilename infileext,'.4xd-filtered.tif'];
	filteredResampledfilepath=fullfile(indir,filteredResampledfile);
	anisoOptions='-scanrange:10 -tau:2 -nsteps:2 -lambda:0.1 -ipflag:0 -anicoeff1:1 -anicoeff2:0 -anicoeff3:0';
	macro=[macro 'exec("sh","-c",' '"cd ',indir,'; anisofilter ',anisoOptions,' ',resampledfilename,' ',filteredResampledfile,'");'];
	% open the result
	macro=[macro 'open("',fullfile(indir,filteredResampledfile),'");'];
	% fix voxel size
	macro=[macro 'setVoxelSize(xp,yp,zp,unit);'];
	% calculate tubeness assuming isotropic voxels and smoothing with sigma = pixel separation
	macro=[macro,'run("Tubeness", "sigma=1");'];
	% this makes float output, so change to 8 bit
	macro=[macro,'run("8-bit");'];
	% save as Biorad PIC file for matlab to open
	macro=[macro 'run("Biorad ...", "biorad=[',outfile,']");'];
	
	tmp=[tempname '.ijm'];
	% think about whether we need to add line feeds
	fid = fopen(tmp,'w');
	fprintf(fid, '%s', macro);
	fclose(fid);
	
	command=['fiji -eval ''runMacro("',tmp,'");'' -batch'];
	if DryRun
		result=macro;
		status=-1;
		return
	end
	
	[status, result] = system(command);
	delete(tmp);
	if(RemoveIntermediates)
		delete(resampledfilepath,filteredResampledfilepath);
	end
	if ~Verbose
		disp('+');
	end

end