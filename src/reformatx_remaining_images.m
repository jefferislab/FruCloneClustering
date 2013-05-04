function reformatx_remaining_images(input_dir,output_dir,registration_dir,mask_image)
%  
% Transform (cell body) images into template brain space
%
% Usage: reformatx_remaining_images(input_dir,output_dir,registration_dir,mask_image)
% Input:
% input_dir        - containing XXX.pic images
% output_dir       - where XXX_masked.nrrd images will be generated
% registration_dir - where .list registration folders for each brain live
% mask_image       - defines regions to reformat (& determines output size)
% 
% Takes regular images and transforms them onto the template (IS2 for us).
% This is currently used for the cell bodies only as neurites are processed
% into dots before being reformatted.
% 
% See also reformat_remaining_images (for points)


% Make sure that dirs have a trailing slash
input_dir=fullfile(input_dir,filesep);
output_dir=fullfile(output_dir,filesep);
registration_dir = fullfile(registration_dir,filesep);

% Make output dir if required
if ~exist(output_dir,'dir')
	mkdir(output_dir);
end

[pathstr, mask_name, ext] = fileparts(jlab_filestem(mask_image));
h=dir([input_dir,'*.pic']);

for i=1:length(h)

	% set up the file names we need
	current_image=jlab_filestem(h(i).name);
	lockfile=[output_dir,current_image,'-in_progress.lock'];
	registration=[registration_dir,'IS2_',current_image,...
		'_01_warp_m0g80c8e1e-1x26r4.list'];

	% Check if we should process current image
	if matching_images(current_image,...
			[output_dir,'*',mask_name,'*.nrrd'])
		% skip this image since corresponding output exists
		continue
	elseif ~makelock(lockfile)
		% skip since someone else is working on this image
		continue
	end

	disp(['Reformatting image ',h(i).name])
    
   	
    % figure out output image name: IS2_<current_image>.PIC
  
    [pathstr, image_name, ext, versn] = fileparts(h(i).name);
    output_image = [output_dir, image_name,'_',mask_name,'_masked.nrrd'];
    
    %  reformatx [options] --floating floatingImg target x0 [x1 ...]
    cmd=['reformatx -v --pad-out 0 --mask --outfile ', output_image,' ', ... 
        ' --floating ', input_dir h(i).name,' ',mask_image,' ',registration];
    
    system(cmd)
   
	removelock(lockfile);
end

end