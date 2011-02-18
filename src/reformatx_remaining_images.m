function reformatx_remaining_images(input_dir,output_dir,registration_dir,templateimage)
% REFORMAT_REMAINING_IMAGES Transform images into template brain space
%
% Usage: reformatx_remaining_images(input_dir,output_dir,registration_dir,templateimage)
% this script takes regular images and transforms them 
% onto the IS2 template
% the input files are XXX.PIC and output files are eg IS2_XXX.PIC
% Must specify the directory for the registration data and the reformatx
% command 
% templateimage will determine the size of the output images

% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);
registration_dir = fullfile(registration_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

[pathstr, mask_name, ext, versn] = fileparts(jlab_filestem(templateimage));
h=dir([input_dir,'*.pic']);

for i=1:length(h)

	% set up the file names we need
	current_image=jlab_filestem(h(i).name);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	registration=[registration_dir,'IS2_',current_image,...
		'_01_warp_m0g80c8e1e-1x26r4.list'];

	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,mask_name,'*'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile)
		% skip since someone else is working on this image
		continue
	end

	disp(['Reformatting image ',h(i).name])
    
   	
    % figure out output image name: IS2_<current_image>.PIC
  
    [pathstr, image_name, ext, versn] = fileparts(h(i).name);
    output_image = [output_dir, mask_name, '_masked_', image_name,'.nrrd'];
    
    %  reformatx [options] --floating floatingImg target x0 [x1 ...]
    cmd=['reformatx -v --pad-out 0 --mask --outfile ', output_image,' ', ... 
        ' --floating ', input_dir h(i).name,' ',templateimage,' ',registration];
    
    disp(cmd)
    
    system(cmd)
   
	removelock(lockfile);
end

end