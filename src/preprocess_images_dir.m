function preprocess_images_dir(input_dir,output_dir)
% PREPROCESS_IMAGES_DIR Preprocess a directory of PIC images using ImageJ/Fiji
%   PREPROCESS_IMAGES_DIR(input_dir,output_dir)
%
%   input_dir:  Directory containing input .PIC, .pic, .PIC.gz, or .pic.gz files
%   output_dir: Directory in which tubed.PIC output files will be saved
%   (defaults to input_dir)
% 
% Note this is a translation of the original PreprocessImages.R script

if nargin < 2
	output_dir=input_dir;
end

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
	if regexpi(allfiles(i).name,'.*02\.(pic|PIC)+(\.gz)*$')
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
	preprocess_image(fullfile(input_dir,images(i).name));
	removelock(lockfile);

end

end

function [ command ] = preprocess_image( infile, outfile )
%PREPROCESS_IMAGE Take an individual image and preprocess with fiji/cfd
%   Detailed explanation goes here

% PreprocessImage<-function(infile,outfile,Verbose=TRUE,DryRun=FALSE,RemoveIntermediates=TRUE){
	% TODO add these options back
	Verbose=1;
	RemoveIntermediates=1;
	DryRun=1;
	
	if nargin < 2
		outfile=[infile,'.4xd-tubed.PIC'];
	end
	
	macro=[];
	
	% open file
	macro=['open("',infile,'");'];
	% resample, 8 bit, save as tiff
	[outdir,~,~] = fileparts(outfile);
	[indir,infilename,infileext] = fileparts(infile);
	resampledfilename=[infilename,infileext,'.4xd.tif'];
	resampledfilepath=fullfile(outdir,resampledfilename);
	macro=[macro,'run("Scale...", "x=0.5 y=0.5 z=1.0 interpolation=Bicubic process title=Scaled");']
	% Make sure that we select the right window
	macro=[macro 'selectWindow("Scaled");'];
	macro=[macro 'run("8-bit");'];
	% store current voxel size
	macro=[macro 'getVoxelSize(xp,yp,zp,unit);'];
	macro=[macro 'saveAs("Tiff", "',resampledfilepath,'");'];
	% run anisofilter
	filteredResampledfile=[infilename infileext,'.4xd-filtered.tif'];
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
		return
	end
	
	system(command)
	delete(tmp);
	if(RemoveIntermediates)
		delete(resampledfile,filteredResampledfile);
	end
	if ~Verbose
		disp('+');
	end

end