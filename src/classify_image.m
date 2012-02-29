function [score,MI_threshold]=classify_image(s, test_images)
% Determine whether an image contains a clone of interest
%
% This function is used to determine whether an image contains a clone of
% interest. It is assumed that the user has already created the neccessary
% XXXmatchedPoints.mat files that compare existing images to the test image.
% It is also assumed that the user defined which image files contain the
% clone of interest. These images are fed in the build_MI_structure.m to 
% produce the cell s. This cell contains the mutual information between 
% the matching dots in other images and whether those images contain the 
% clone.
%
% Input: s, output from build_MI_structure.m
%        template_image_ind, index images containing the clone. Must match
%                         the list of images used to produce the cell s.
%                         The index is based on the imageList cell
%        test_image_ind, is the index where test_image appears in the imageList
%        image_dir, the location of the template image XXXmatchedPoints.mat
%                   files
%
% Output: score, is a 1 by 40 vector given the score that the test_image
%                contains the clone of interest. Scores near zero mean the 
%                clone is not present while higher scores indicate a better
%                chance. The first 20 entries give the mean number of matching
%                dots above 20 different mutual information thresholds.
%                These threshold are [.005:.005:.1]
%                and are contained in the MI_threshold vector. The next 20
%                entries give number of matched points weighted by the
%                modified mutual information for each dot. The mutual
%                information is modified by subtacting one of the
%                thresholds defined above and rectifying.
%


MI_threshold = 0.0025:0.0025:0.1;

count = zeros(length(test_images),40)+10^(-20);
score = zeros(length(test_images),40);

for i=1:length(s)
    if ~isempty(s{i})
        for k=1:length(test_images)
            test_image_logical = strcmp(test_images{k},s{i}.matched_images);
            for j = 1:size(score,2)
                if ~isempty(s{i}.MI)
                    modified_MI=max(0,s{i}.MI'-MI_threshold(j));
                    count(k,j)=count(k,j)+sum(modified_MI);
                    score(k,j)=score(k,j)+sum(single(s{i}.match(:,test_image_logical)).*modified_MI);
                end
            end
        end
    end
end

score=score./count;

