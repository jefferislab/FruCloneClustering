function [match_exists, first_matching_image] = matching_images( filename, fileglob )
% no_matching_images: see if any file has same image stem as filename
%
%   filename = filename whose stem will be checked for matches
%   fileglob = will be passed to dir to produce a list of files
%
%   match_exists = 1 when there is a match, 0 otherwise
%   first_matching_image = name of first matching image returned by dir
%
%   The stem is the filestem found by jlab_filestem
%   fileglob might look like [output_dir,'*_properties.mat']
%
match_exists=0;

filestem = jlab_filestem(filename);

queryfiles=dir(fileglob);

for j=1:length(queryfiles)
    
    poss_stem = jlab_filestem(queryfiles(j).name());
    
    if strcmp(filestem,poss_stem)
        % stems match so stop and return 1 (true)
        match_exists=1;
        first_matching_image = queryfiles(j).name();
        break;
    end
    
end

end