function [score,MI_threshold,score2]=classify_image_not_in_database(s,template_images_ind,imageList,test_image,image_properties_dir,MI_multiplier,s2);

% This function is used to determine whether an image contains a clone of
% interest. This version uses the masked verison of the image. 
% It is assumed that the user has already created the neccessary
% XXXmatchedPoints.mat files that compare existing images to the test image.
% It is also assumed that the user defined which image files contain the
% clone of interest. These images are fed in the build_MI_strcuture.m to 
% produce the cell s. This cell contains the mutual information between 
% the matching dots in other images and whether those images contain the 
% clone.
%
% Input: s, output from build_MI_structure.m
%        clone_mask, the clone name specifying the mask to be used
%        template_image_ind, index images containing the clone. Must match
%                         the list of images used to produce the cell s.
%                         The index is based on the imageList cell
%        test_image_ind, is the index where test_image appears in the imageList
%        image_dir, the location of the template image XXXmatchedPoints.mat
%                   files
%
% Output: score, is a 1 by 12 vector given the score that the test_image
%                contains the clone of interest. Scores near zero mean the 
%                clone is not present while higher scores indicate a better
%                chance. The first six entries give the mean number of matching
%                dots above 20 different mutual information thresholds.
%                These threshold are [.005:.005:.1]
%                and are contained in the MI_threshold vector. The next 20
%                entries give number of matched points weighted by the
%                modified mutual information for each dot. The mutual
%                information is modified by subtacting one of the
%                thresholds defined above and rectifying.
%

ann_dir='~/src/ann_1.1.2/bin/'; 
text_dir='/Users/nmasse/Projects/imageProcessing/image_classification/';

MI_threshold=[0.005:0.005:0.1]*MI_multiplier;

count=zeros(1,40)+10^(-20);
score=zeros(1,40);



h=dir([image_properties_dir test_image,'*properties.mat']);
load([image_properties_dir h(1).name]);
p1.gamma2=p.gamma2;
p1.vect2=p.vect2;



if nargin==7

    count2=zeros(1,40)+10^(-20);
    score2=zeros(1,40);
    MI_threshold2=[0.005:0.005:0.1]*5;
end

for i=1:length(s)


% load the XXXmatchedPoints.mat file of the ith image containing the
% clone. The matrix y indicates which dots matched dots in other
% images.

    h=dir([image_properties_dir imageList{template_images_ind(i)},'*properties.mat']);
    load([image_properties_dir h(1).name]);

    [m1 n1]=size(p.gamma2);

    y=zeros(n1,1,'uint8');

    ind=find(s{i}.MI>.005);
    p2=[];
    p2.gamma2=p.gamma2(:,ind);
    p2.vect2=p.vect2(:,ind);

    [dist1,dotProd1,dist2,dotProd2]=compareImages(p2,p1,text_dir,ann_dir);

    clear p2

    matchedPoints=ind(find((dist1<5 & dotProd1>cosd(20)) | (dist2<5 & dotProd2>cosd(20))));

    y(matchedPoints)=1;



    for j=1:40

        if j<=20

            ind=find(s{i}.MI>=MI_threshold(j));
            count(j)=count(j)+length(ind);
            score(j)=score(j)+sum(y(ind));

            if nargin==7
                ind=find(s2{i}.MI>=MI_threshold2(j));
                count2(j)=count2(j)+length(ind);
                score2(j)=score2(j)+sum(y(ind));
            end

        else

            modified_MI=max(0,s{i}.MI'-MI_threshold(j-20));
            count(j)=count(j)+sum(modified_MI);
            score(j)=score(j)+sum(single(y(:)).*modified_MI);

            if nargin==8
                modified_MI=max(0,s2{i}.MI'-MI_threshold2(j-20));
                count2(j)=count2(j)+sum(modified_MI);
                score2(j)=score2(j)+sum(single(y(:)).*modified_MI);
            end


        end

    end


end


clear y

score=score./count;
if nargin==7
    score2=score2./count2;
else
    score2=ones(size(score));
end
